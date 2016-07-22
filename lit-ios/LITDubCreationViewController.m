//
//  LITDubmashCreationViewController.m
//  lit-ios
//
//  Created by ioshero on 15/07/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITDubCreationViewController.h"
#import "LITDubPreviewViewController.h"
#import "AVUtils.h"
#import "LITTheme.h"
#import "UIView+GradientBackground.h"
#import "LITProgressHud.h"
#import <VOXHistogramView/VOXHistogramControlView.h>
#import <EZAudio/EZAudioFile.h>
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"

NSString *const kDubCreationSegueIdentifier = @"DubCreationSegue";

@interface LITDubCreationViewController () <VOXHistogramControlViewDelegate>

@property (weak, nonatomic) IBOutlet VOXHistogramControlView *histogramControlView;
@property (strong, nonatomic) SCRecorder *recorder;

@property (strong, nonatomic) SCRecordSession *recordSession;
@property (strong, nonatomic) AVPlayerItem *mixedVideo;
@property (strong, nonatomic) NSURL *mixedVideoURL;

@property (strong, nonatomic) AVPlayer *player;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *flipButton;

@property (strong, nonatomic) EZAudioFile *ezAudioFile;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *histogramViewHeightConstraint;

@end


@implementation LITDubCreationViewController


- (void)dealloc {
    _recorder.previewView = nil;
    
    @try {
        [_player removeObserver:self forKeyPath:@"status"];
        [_player removeObserver:self forKeyPath:@"rate"];
    }
    @catch (NSException *exception) {
        //no-op
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.recorder = [SCRecorder recorder];
    self.recorder.device = AVCaptureDevicePositionFront;
    self.recorder.captureSessionPreset = [SCRecorderTools bestCaptureSessionPresetCompatibleWithAllDevices];
    
    SCVideoConfiguration *video = self.recorder.videoConfiguration;
    
    [AVUtils fillSCVideoConfigurationWithPresets:&video];
    

//    self.recorder.maxRecordDuration = CMTimeMake(6, 1);
    [self.recorder setDelegate:self];
    
    
    [self.recorder setPreviewView:self.previewView];

    self.recorder.initializeSessionLazily = YES;
    

    self.flipButton.hidden = NO;
    
    
    NSError *error;
    if (![self.recorder prepare:&error]) {
        NSLog(@"Prepare error: %@", error.localizedDescription);
    }
    
    [self.view setupGradientBackground];
    [self initHistogramViewWithFileURL:self.soundURL];
    
    if ([ [ UIScreen mainScreen ] bounds ].size.height == 480) {
        self.histogramViewHeightConstraint.constant = 24;
        [self updateViewConstraints];
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.recordButton setEnabled:YES];
    [self.recordButton setSelected:NO];
    
    [self prepareRecording];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.recorder previewViewFrameChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.recorder startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_recorder stopRunning];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)initHistogramViewWithFileURL:(NSURL *)cachedFileURL
{
    self.ezAudioFile = [[EZAudioFile alloc] initWithURL:cachedFileURL];
    [self.ezAudioFile getWaveformDataWithCompletionBlock:^(float **waveformData, int length) {
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
        [self.histogramControlView setDelegate:self];
        
        [self.histogramControlView setNotCompleteColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
        [self.histogramControlView setCompleteColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
        
        [self.histogramControlView setLevels:[NSArray arrayWithArray:normalizedValues]];
        [self.histogramControlView setBackgroundColor:[UIColor clearColor]];
        [self.histogramControlView setUserInteractionEnabled:NO];
    }];
}

- (void)prepareRecording
{
    self.recorder.session = nil;
    [self prepareSession];
    self.mixedVideo = nil;
    self.mixedVideoURL = nil;
    self.flipButton.hidden = NO;
    if (self.player) {
        [self.player removeObserver:self forKeyPath:@"rate"];
        [self.player removeObserver:self forKeyPath:@"status"];
    }
    self.player = [[AVPlayer alloc] initWithURL:self.soundURL];
    [self.player addObserver:self forKeyPath:@"status" options:0 context:0];
    [self.histogramControlView setPlaybackProgress:0.0f];
}

- (void)prepareSession {
    if (_recorder.session == nil) {
        
        SCRecordSession *session = [SCRecordSession recordSession];
        session.fileType = AVFileTypeQuickTimeMovie;
        
        _recorder.session = session;
    }
    
//    [self updateTimeRecordedLabel];
//    [self updateGhostImage];
}

- (void)saveAndShowSession:(SCRecordSession *)recordSession {
//    [[SCRecordSessionManager sharedInstance] saveRecordSession:recordSession];
    
    _recordSession = recordSession;
    
    JGProgressHUD *savingHud = [LITProgressHud createHudWithMessage:@"Generating dub..."];
    [savingHud showInView:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVMutableComposition *composition = [AVMutableComposition composition];
        
        AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        AVAsset *soundbiteAsset = [AVAsset assetWithURL:self.soundURL];
        AVAssetTrack *sounditeAudioTrack = [[soundbiteAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, soundbiteAsset.duration) ofTrack:sounditeAudioTrack atTime:kCMTimeZero error:nil];
        
        AVAsset *videoAsset = [recordSession assetRepresentingSegments];
        
        
        AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];
        
        
        SCAssetExportSession *assetExportSession = [[SCAssetExportSession alloc] initWithAsset:composition];
        SCVideoConfiguration *videoConfiguration = assetExportSession.videoConfiguration;
        [AVUtils fillSCVideoConfigurationWithPresets:&videoConfiguration];
        assetExportSession.audioConfiguration.preset = SCPresetMediumQuality;
        assetExportSession.outputUrl = [AVUtils dubRecordingTempFilePathURL];
        assetExportSession.outputFileType = AVFileTypeMPEG4;

        
        NSURL *videoURL = assetExportSession.outputUrl;
        [assetExportSession exportAsynchronouslyWithCompletionHandler: ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (assetExportSession.error == nil) {
                    // We have our video and/or audio file
                    
                    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:videoURL];
                    self.mixedVideo = playerItem;
                    self.mixedVideoURL = videoURL;
                    JGProgressHUD *hud = [[JGProgressHUD allProgressHUDsInView:self.view] objectAtIndex:0];
                    [hud dismissAnimated:YES];
                    
                    [[Mixpanel sharedInstance] track:kMixpanelAction_uploadPressed_Dubs properties:nil];
                    
                    [self performSegueWithIdentifier:kLITDubPreviewSegueIdentifier sender:nil];
                    
                } else {
                    // Something bad happened
                    NSLog(@"Error creating video from segments: %@", assetExportSession.error.localizedDescription);
                }
            });
        }];
    });
}

#pragma mark - SCRecorderDelegate
- (void)recorder:(SCRecorder *)recorder didSkipVideoSampleBufferInSession:(SCRecordSession *)recordSession {
    NSLog(@"Skipped video buffer");
}

- (void)recorder:(SCRecorder *)recorder didReconfigureAudioInput:(NSError *)audioInputError {
    NSLog(@"Reconfigured audio input: %@", audioInputError);
}

- (void)recorder:(SCRecorder *)recorder didReconfigureVideoInput:(NSError *)videoInputError {
    NSLog(@"Reconfigured video input: %@", videoInputError);
}

- (void)recorder:(SCRecorder *)recorder didCompleteSession:(SCRecordSession *)recordSession {
    NSLog(@"didCompleteSession:");
}

- (void)recorder:(SCRecorder *)recorder didInitializeAudioInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized audio in record session");
    } else {
        NSLog(@"Failed to initialize audio in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didInitializeVideoInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized video in record session");
    } else {
        NSLog(@"Failed to initialize video in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didBeginSegmentInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Began record segment: %@", error);
}

- (void)recorder:(SCRecorder *)recorder didCompleteSegment:(SCRecordSessionSegment *)segment inSession:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Completed record segment at %@: %@ (frameRate: %f)", segment.url, error, segment.frameRate);
//    [self updateGhostImage];
}


#pragma mark - AVPlayer KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.player && [keyPath isEqualToString:@"status"]) {
        if (self.player.status == AVPlayerStatusReadyToPlay) {
            [self.recordButton setEnabled:YES];
        } else if (self.player.status == AVPlayerStatusFailed) {
            NSLog(@"Error playing soundbite: %@", self.player.error.localizedDescription);
        }
    }
    
    if (object == self.player && [keyPath isEqualToString:@"rate"]) {
        if (self.player.rate == 0) {
            //Player just stopped. Pause video
            [self.recorder pause:^{
                [self saveAndShowSession:self.recorder.session];
            }];
        }
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LITDubPreviewViewController *previewViewController = (LITDubPreviewViewController *)segue.destinationViewController;
    NSAssert([previewViewController isKindOfClass:[LITDubPreviewViewController class]], @"Destination controller must be of class LITDubPreviewViewController");
    previewViewController.soundbite = self.soundbite;
    previewViewController.mixedVideo = self.mixedVideo;
    previewViewController.mixedVideoURL = self.mixedVideoURL;
}

#pragma mark - Actions
- (IBAction)recordButtonTapped:(UIButton *)sender
{
    [[Mixpanel sharedInstance] track:kMixpanelAction_dubRecording_Dubs properties:nil];
    
    self.flipButton.hidden = YES;
    [self.recordButton setSelected:YES];
    [self.recordButton setEnabled:NO];
    
//    self.recorder.audioConfiguration.shouldIgnore = !self.recordAmbientSound;
    
    [self.player play];
    [self.player addObserver:self forKeyPath:@"rate" options:0 context:0];
    
    __weak typeof(self) weakSelf = self;
    
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(100, 1000) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        typeof(self) strongSelf = weakSelf;
        [strongSelf.histogramControlView setPlaybackProgress:(CMTimeGetSeconds(time)/self.ezAudioFile.duration)];
    }];
    [self.recorder record];
}

- (IBAction)flipButtonTapped:(id)sender {
    
    if(self.recorder.device == AVCaptureDevicePositionFront){
        self.recorder.device = AVCaptureDevicePositionBack;
    }
    else{
        self.recorder.device = AVCaptureDevicePositionFront;
    }
}

@end
