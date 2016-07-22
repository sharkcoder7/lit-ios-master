//
//  LITSoundbiteCropSongViewController.m
//  lit-ios
//
//  Created by ioshero on 10/07/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITSoundbiteCropSongViewController.h"
#import "LITTheme.h"
#import "LITProgressHud.h"
#import "Constants.h"
#import "AVUtils.h"
#import "LITSoundbite.h"
#import "LITSong.h"
#import "LITSoundbitePreviewViewController.h"
#import "LITKeyboardCustomView.h"
#import "LITBlurEffect.h"
#import <Parse/PFFile.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MDRadialProgress/MDRadialProgressView.h>
#import <MDRadialProgress/MDRadialProgressTheme.h>
#import <MDRadialProgress/MDRadialProgressLabel.h>
#import <EZAudio/EZAudioUtilities.h>
#import <EZaudio/EZAudioFile.h>
#import <EZaudio/EZAudioPlayer.h>
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"

static NSString *const kMetadataTitleKey        = @"title";
static NSString *const kMetadataAlbumNameKey    = @"albumName";
static NSString *const kMetadataArtistKey       = @"artist";

static NSString *const kLITPresentSoundbitePreviewSegueIdentifier = @"LITPresentSoundbitePreviewSegue";

@interface LITSoundbiteCropSongViewController () <EZAudioPlayerDelegate> {
    SInt64 _startFrame;
    SInt64 _endFrame;
}

@property (weak, nonatomic)     IBOutlet LITHistogramControlView *histogramView;
@property (weak, nonatomic)     IBOutlet MDRadialProgressView *progressView;
@property (assign, nonatomic)   CMTimeScale assetTimeScale;

@property (strong, nonatomic)   NSURL *finalSoundbiteURL;
@property (strong, nonatomic)   NSDictionary *songMetadata;
@property (strong, nonatomic)   EZAudioPlayer *audioPlayer;

@property (strong, nonatomic)   JGProgressHUD *processingHud;
@property BOOL firstTime;

@property (strong, nonatomic) LITSong *song;

@property (strong, nonatomic) UIBarButtonItem *nextButton;

@end

@implementation LITSoundbiteCropSongViewController

static inline SInt64 GetFrameForSecond(SInt64 totalFrames, NSTimeInterval duration, NSTimeInterval seconds)
{
    return totalFrames * (seconds / duration);
}

static inline float GetProgressForFrame(SInt64 frame, SInt64 totalFrames)
{
    return frame / (float)totalFrames;
}

static inline NSTimeInterval GetSecondForFrame(SInt64 frame, SInt64 totalFrames, NSTimeInterval duration)
{
    return duration * GetProgressForFrame(frame, totalFrames);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSParameterAssert(self.audioFile);
    [self.audioFile getWaveformDataWithNumberOfPoints:16348 completion:^(float **waveformData, int length) {
        
        NSAssert(waveformData, @"Waveform data cannot be NULL");
        float *buffer1 = waveformData[0];
        float *buffer2 = waveformData[1];
        NSMutableArray *numbersArray = [NSMutableArray arrayWithCapacity:length];
        float max = 0;
        for (NSInteger i = 0; i < length; i++) {
            //Mean of the two channels (for stereo)
            float avg = (buffer1[i] + buffer2[i]) / 2;
            max = avg > max ? avg : max;
            [numbersArray addObject:[NSNumber numberWithFloat:avg]];
        }
        NSMutableArray *normalizedValues = [NSMutableArray arrayWithCapacity:numbersArray.count];
        for (NSNumber *floatNumber in numbersArray) {
            [normalizedValues addObject:[NSNumber numberWithFloat:(floatNumber.floatValue / max)]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.histogramView setDelegate:self];
            [self.histogramView setAssetDuration:self.audioFile.duration];
            [self.histogramView setLevels:[NSArray arrayWithArray:normalizedValues]];
            [self.histogramView setBackgroundColor:[UIColor clearColor]];
            
            [self.histogramView setNotCompleteColor:[UIColor lit_lightGreyColor]];
        });
    }];
    
    
    self.view.backgroundColor = [UIColor lit_fadedOrangeLightColor];
    
    //Disable this gesture as it interfers with views contained
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    MDRadialProgressTheme *theme = [MDRadialProgressTheme standardTheme];
    theme.completedColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    theme.thickness = 40.0f;
    theme.incompletedColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    theme.sliceDividerHidden = YES;
    [self.progressView setTheme:theme];
    [self.progressView setProgressTotal:20];
    [self.progressView.label setHidden:YES];
    
    self.firstTime = YES;

    self.nextButton = [[UIBarButtonItem alloc] initWithTitle:@"NEXT"
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(nextButtonPressed:)];
    
    [self.nextButton setTitleTextAttributes: @{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f], NSForegroundColorAttributeName: [UIColor whiteColor], NSBackgroundColorAttributeName : [UIColor clearColor]} forState:UIControlStateNormal];

    [self.navigationItem setRightBarButtonItem:self.nextButton animated:YES];
    
    [self.navigationItem setTitle:@"New Sound"];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(self.firstTime){
        self.processingHud = [LITProgressHud createHudWithMessage:@"Generating preview..."];
        [self.processingHud showInView:self.view];
    } else {
        if (![self.audioPlayer isPlaying]) {
            [self.audioPlayer play];
        }
        [self.nextButton setEnabled:YES];
    }
}

#pragma mark - Actions
- (void)nextButtonPressed:(UIBarButtonItem *)button
{
    [self.audioPlayer pause];
    [self.nextButton setEnabled:NO];
    
    JGProgressHUD *savingHud = [LITProgressHud createHudWithMessage:@"Generating soundbite..."];
    [savingHud showInView:self.view];
    
    //Actually crop song according to selection
    
    NSURL *tmpCroppedSoundURL = [AVUtils soundbiteRecordingTempFilePathURL];
    
    NSURL *url = [self.mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
    
    NSArray *metadata =  [playerItem.asset commonMetadata];
    
    NSMutableDictionary *songMetadataDict = [NSMutableDictionary dictionary];
    for (AVMetadataItem *item in metadata ) {
        if ([[item commonKey] isEqualToString:kMetadataAlbumNameKey]) {
            [songMetadataDict setObject:[item stringValue] forKey:kMetadataAlbumNameKey];
        }
        if ([[item commonKey] isEqualToString:kMetadataArtistKey]) {
            [songMetadataDict setObject:[item stringValue] forKey:kMetadataArtistKey];
        }
        if ([[item commonKey] isEqualToString:kMetadataTitleKey]) {
            [songMetadataDict setObject:[item stringValue] forKey:kMetadataTitleKey];
        }
    }
    
    PFQuery *query = [[PFQuery queryWithClassName:[LITSong parseClassName]] whereKey:kSongTitleKey containsString:songMetadataDict[kSongTitleKey]];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object) {
            NSAssert([object isKindOfClass:[LITSong class]], @"object must be of class LITSong");
            [object incrementKey:kSongTimesUsedKey];
            self.song = (LITSong *)object;
        } else {
            self.song = [LITSong object];
            [self.song setSongMetadata:songMetadataDict];
        }
        
        NSTimeInterval start = GetSecondForFrame(_startFrame, self.audioFile.totalFrames, self.audioFile.duration);
        NSTimeInterval duration = GetSecondForFrame(_endFrame, self.audioFile.totalFrames, self.audioFile.duration) - start;
        
        ;
        
        [AVUtils cropAudioAsset:playerItem.asset audioStartTime:start
                       duration:duration outputURL:tmpCroppedSoundURL
                     completion:^(NSURL *assetURL, NSError *error) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [self.audioPlayer pause];
                             if (error) {
                                 NSAssert([NSThread isMainThread],
                                          @"Block must be executed on the main thread");
                                 [LITProgressHud changeStateOfHUD:savingHud to:kLITHUDStateError withMessage:@"Error while saving. Please try again."];
                                 [savingHud dismissAfterDelay:5.0];
                                 
                                 NSLog(@"Error cropping audio file: %@", error.localizedDescription);
                             } else {
                                 
                                 self.finalSoundbiteURL = tmpCroppedSoundURL;
                                 
                                 [savingHud dismiss];
                                 
                                 [self performSegueWithIdentifier:kLITPresentSoundbitePreviewSegueIdentifier sender:self];
                             }
                         });
                     }];
    }];
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kLITPresentSoundbitePreviewSegueIdentifier]) {
        
        [[Mixpanel sharedInstance] track:kMixpanelAction_next_Cropping_Soundbites properties:nil];
        
        LITSoundbitePreviewViewController *previewController = segue.destinationViewController;
        NSAssert([previewController isKindOfClass:[LITSoundbitePreviewViewController class]], @"Destination view controller must be of class LITSoundbitePreviewViewController");
        previewController.contentURL = self.finalSoundbiteURL;
        previewController.song = self.song;
        previewController.comesFromRecording = NO;
    }
}

#pragma EZAudioPlayerDelegate

- (void)audioPlayer:(EZAudioPlayer *)audioPlayer
    updatedPosition:(SInt64)framePosition
        inAudioFile:(EZAudioFile *)audioFile
{
    if (framePosition >= _endFrame) {
        //Looping
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.audioPlayer seekToFrame:_startFrame];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.histogramView setPlaybackProgress:GetProgressForFrame(framePosition, audioFile.totalFrames)];
        });
        
    }
}

#pragma LITHistogramControlViewDelegate

- (void)histogramControlViewWillStartRendering:(LITHistogramControlView *)controlView
{
    NSLog(@"Did start rendering");
}

- (void)histogramControlViewDidFinishRendering:(LITHistogramControlView *)controlView
{
    NSLog(@"Did finish rendering");
    
    [self.processingHud dismiss];
    self.firstTime = NO;
    
    [self.histogramView setPlaybackStart:0];
    [self.histogramView setPlaybackEnd:6/self.audioFile.duration];
    [self.progressView setProgressCounter:100];
    
    self.audioPlayer = [EZAudioPlayer audioPlayerWithAudioFile:self.audioFile delegate:self];
    
    _startFrame = GetFrameForSecond(self.audioFile.totalFrames, self.audioFile.duration, 0);
    _endFrame = GetFrameForSecond(self.audioFile.totalFrames, self.audioFile.duration, 6);
    [self.audioPlayer seekToFrame:_startFrame];
    
    if (![self.audioPlayer isPlaying]) {
        [self.audioPlayer play];
    }
}

- (void)histogramControlViewWillMoveLeftHandle:(LITHistogramControlView *)controlView
{
    [self.audioPlayer pause];
}

- (void)histogramControlViewWillMoveRightHandle:(LITHistogramControlView *)controlView
{
    [self.audioPlayer pause];
}

- (void)histogramControlView:(LITHistogramControlView *)controlView didMoveLeftHandleToProgress:(CGFloat)progress
{
    _startFrame = GetFrameForSecond(self.audioFile.totalFrames, self.audioFile.duration, progress * self.audioFile.duration);
    if (_startFrame < 0) {
        _startFrame = 0;
    }
    NSTimeInterval gap = GetSecondForFrame(_endFrame, self.audioFile.totalFrames, self.audioFile.duration) - GetSecondForFrame(_startFrame, self.audioFile.totalFrames, self.audioFile.duration);
    [self.progressView setProgressCounter:round((gap / kLITSelectionSeconds) * 20)];
    [controlView setPlaybackStart:progress];
    [self.audioPlayer seekToFrame:_startFrame];
    if (![self.audioPlayer isPlaying]) {
        [self.audioPlayer play];
    }
}

- (void)histogramControlView:(LITHistogramControlView *)controlView didMoveRightHandleToProgress:(CGFloat)progress
{
    _endFrame = GetFrameForSecond(self.audioFile.totalFrames, self.audioFile.duration, progress * self.audioFile.duration);
    if (_endFrame > self.audioFile.totalFrames) {
        _endFrame = self.audioFile.totalFrames;
    }
    NSTimeInterval gap = GetSecondForFrame(_endFrame, self.audioFile.totalFrames, self.audioFile.duration) - GetSecondForFrame(_startFrame, self.audioFile.totalFrames, self.audioFile.duration);
    [self.progressView setProgressCounter:round((gap / kLITSelectionSeconds) * 20)];
    [controlView setPlaybackEnd:progress];
    [self.audioPlayer seekToFrame:_startFrame];
    if (![self.audioPlayer isPlaying]) {
        [self.audioPlayer play];
    }
}

- (void)histogramControlViewWillScrollDetailView:(LITHistogramControlView *)controlView
{
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer pause];
    }

}

- (void)histogramControlView:(LITHistogramControlView *)controlView didScrollToProgress:(CGFloat)progress
{
    if (![self.audioPlayer isPlaying]) {
        [self.audioPlayer play];
    }

}


@end
