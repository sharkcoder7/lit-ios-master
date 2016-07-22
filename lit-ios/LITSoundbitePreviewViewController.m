//
//  LITSoundibitePreviewViewController.m
//  lit-ios
//
//  Created by Antonio Losada on 4/9/15.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITSoundbitePreviewViewController.h"
#import "UIViewController+CaptionInput.h"
#import "LITTaggingViewController.h"
#import "AVUtils.h"
#import "LITSoundbite.h"
#import "LITSong.h"
#import "LITProgressHud.h"
#import "LITTheme.h"
#import "UIView+GradientBackground.h"
#import <Parse/PFFile.h>
#import <EZAudio/EZAudioFile.h>
#import <EZaudio/EZAudioPlayer.h>
#import <VOXHistogramView/VOXHistogramControlView.h>
#import <VOXHistogramView/VOXHistogramView.h>
#import <VOXHistogramView/VOXHistogramRenderer.h>
#import <VOXHistogramView/VOXHistogramRenderingConfiguration.h>
#import <VOXHistogramView/VOXHistogramLevelsConverter.h>
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"



@interface LITSoundbitePreviewViewController () <VOXHistogramControlViewDelegate>

@property CGFloat currentKeyboardHeight;
@property (strong, nonatomic) LITSoundbite *soundbite;
@property (weak, nonatomic) IBOutlet VOXHistogramControlView *histogramView;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) id playerObserver;
@property (strong, nonatomic) EZAudioFile *audioFile;

@property (assign, nonatomic) BOOL didSetupHistogram;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation LITSoundbitePreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    self.currentKeyboardHeight = 0.0f;
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"NEXT"
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(nextButtonPressed:)];
    
    [nextButton setTitleTextAttributes: @{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f], NSForegroundColorAttributeName: [UIColor whiteColor], NSBackgroundColorAttributeName : [UIColor clearColor]} forState:UIControlStateNormal];
    
    [self.navigationItem setRightBarButtonItem:nextButton animated:YES];
    
    [self.playButton setEnabled:NO];
    
    // Do any additional setup after loading the view.
    NSParameterAssert(self.contentURL);
    self.audioFile = [[EZAudioFile alloc] initWithURL:self.contentURL];
    NSParameterAssert(self.audioFile);

    __weak typeof(self) weakSelf = self;
    [self.audioFile getWaveformDataWithCompletionBlock:^(float **waveformData, int length) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        //        NSCAssert(waveformData, @"Waveform data cannot be NULL");
        if (!waveformData) {
            NSLog(@"Waveform data is NULL. Returning");
            return;
        }
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
        [strongSelf.histogramView setDelegate:strongSelf];
        
        [strongSelf.histogramView setNotCompleteColor:[UIColor colorWithWhite:1.0 alpha:0.45]];
        [strongSelf.histogramView setCompleteColor:[UIColor lit_histogramGreyColor]];
        
        [strongSelf.histogramView setLevels:[NSArray arrayWithArray:normalizedValues]];
        [strongSelf.histogramView setBackgroundColor:[UIColor clearColor]];
        [strongSelf.histogramView setUserInteractionEnabled:NO];
        
        strongSelf.didSetupHistogram = YES;
    }];
    
    [self.view setupGradientBackground];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.player.rate != 0) {
        [self.player pause];
    }
    [self removeEffectViewFromNavigationBar];
}

- (void)dealloc
{
    if (self.player) {
        [self.player removeObserver:self forKeyPath:@"rate"];
        [self.player removeTimeObserver:self.playerObserver];
    }
}

#pragma mark - Keyboard management

- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.currentKeyboardHeight = kbSize.height;
}

#pragma mark - Actions
- (IBAction)playButtonPressed:(UIButton *)sender {
    [sender setEnabled:NO];
    [self.player play];
    
    if(self.comesFromRecording){
        [[Mixpanel sharedInstance] track:kMixpanelAction_previewRecording_Soundbites properties:nil];
    }
    else {
        [[Mixpanel sharedInstance] track:kMixpanelAction_previewPlay_Soundbites properties:nil];
    }
    
}

- (void)nextButtonPressed:(UIBarButtonItem *)button {
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if(self.comesFromRecording){
        [[Mixpanel sharedInstance] track:kMixpanelAction_next_PreviewRecording_Soundbites properties:nil];
    }
    else {
        [[Mixpanel sharedInstance] track:kMixpanelAction_next_PreviewApprove_Soundbites properties:nil];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showKeyboardWithPlaceholder:@"Add soundbite name..." andCompletionBlock:^(NSString *text, NSError *error) {
            
            int textFieldHeight = 60;
            
            JGProgressHUD *savingHud = [LITProgressHud createHudWithMessage:@"Saving soundbite..."];
            int hudRectW = self.view.frame.size.width;
            int hudRectH;
            int hudRectX = 0;
            int hudRectY;
            if(self.view.window.rootViewController.navigationController.navigationBarHidden){
                hudRectY = 0;
                hudRectH = hudRectY + self.view.frame.size.height - self.currentKeyboardHeight - self.view.inputAccessoryView.frame.size.height - textFieldHeight;
            }
            else{
                hudRectY = self.navigationController.navigationBar.frame.size.height;
                hudRectH = hudRectY + self.view.frame.size.height - self.currentKeyboardHeight - self.view.inputAccessoryView.frame.size.height - textFieldHeight;
            }
            [savingHud showInRect:CGRectMake(hudRectX,hudRectY,hudRectW,hudRectH) inView:self.view];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                VOXHistogramRenderingConfiguration *renderingConfiguration = [VOXHistogramRenderingConfiguration new];
                renderingConfiguration.outputImageSize = CGSizeMake(196.0f, 196.0f);
                renderingConfiguration.renderingMode = UIImageRenderingModeAlwaysTemplate;
                renderingConfiguration.peaksColor = [UIColor colorWithWhite:1.0 alpha:0.25];
                renderingConfiguration.peakWidth = 5;
                renderingConfiguration.marginWidth = 2;
                renderingConfiguration.produceFlipped = NO;
                renderingConfiguration.usePixelMeasure = YES;
                
                VOXHistogramLevelsConverter *converter = [VOXHistogramLevelsConverter new];
                [converter updateLevels:self.histogramView.levels];
                
                /* Calculate number of levels that histogram can display in current bounds */
                
                /* Creating histogram renderer */
                VOXHistogramRenderer *histogramRenderer = [VOXHistogramRenderer rendererWithRenderingConfiguration:renderingConfiguration];
                /* Rendering histogram image */
                [converter calculateLevelsForSamplingRate:28 completion:^(NSArray *levelsResampled) {
                    [histogramRenderer renderHistogramWithLevels:levelsResampled completion:^(UIImage *image) {
                        UIImage *logoImage = [UIImage imageNamed:@"lit-video-image"];
                        [AVUtils createVideoFromImage:logoImage
                                      andAudioFileURL:self.contentURL
                                  withCompletionBlock:^(NSURL *assetURL, NSError *error) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          if (error) {
                                              NSLog(@"Error merging audio and image: %@", error.localizedDescription);
                                          } else {
                                              self.soundbite = [LITSoundbite object];
                                              
                                              NSLog(@"Composition successfully created. Saved to %@", assetURL.absoluteString);
                                              PFFile *videoFile = [PFFile fileWithName:@"video.mp4" contentsAtPath:assetURL.path];
                                              [self.soundbite setVideo:videoFile];
                                              PFFile *audioFile = [PFFile fileWithName:@"audio.m4a" contentsAtPath:[self.contentURL path]];
                                              [self.soundbite setAudio:audioFile];
                                              PFFile *imageFile = [PFFile fileWithName:@"image.png" data:UIImagePNGRepresentation(image) contentType:@"image/png"];
                                              [self.soundbite setImage:imageFile];
                                              
                                              if(self.song){
                                                  [self.soundbite setSong:self.song];
                                              }
                                              [self.soundbite setCaption:text];
                                              [self.soundbite setUser:[PFUser currentUser]];
                                              
                                              [self.navigationController setNavigationBarHidden:NO animated:YES];
                                              
                                              [savingHud dismiss];
                                              
                                              [self performSegueWithIdentifier:kLITPresentTagsForSoundbiteSegueIdentifier sender:nil];
                                          }
                                      });
                                  }];
                    }];
                }];
            });
        }];
    });
}

#pragma mark - Getter
- (AVPlayer *)player
{
    if (!_player) {
        _player = [AVPlayer playerWithURL:self.contentURL];
        [_player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:NULL];
        __weak typeof(self) weakSelf = self;
        self.playerObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(100, 1000) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            typeof(weakSelf) strongSelf = weakSelf;
            Float64 seconds = CMTimeGetSeconds(time);
            CGFloat playbackProgress = seconds / CMTimeGetSeconds(_player.currentItem.asset.duration);
            [strongSelf.histogramView setPlaybackProgress:playbackProgress];
        }];
    }
    return _player;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:kLITPresentTagsForSoundbiteSegueIdentifier]) {
        LITTaggingViewController *taggingController = segue.destinationViewController;
        NSAssert([taggingController isKindOfClass:[LITTaggingViewController class]], @"Destination view controller must be of class LITTaggingViewController");
        taggingController.content = self.soundbite;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - VOXHistogramControlViewDelegate
- (void)histogramControlViewWillStartRendering:(VOXHistogramControlView *)controlView
{
    [[LITProgressHud createHudWithMessage:@"Wait"] showInView:self.view];
}
- (void)histogramControlViewDidFinishRendering:(VOXHistogramControlView *)controlView
{
    [[[JGProgressHUD allProgressHUDsInView:self.view] objectAtIndex:0] dismiss];
    [self.playButton setEnabled:YES];
}

#pragma mark - AVPlayer KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.player && [keyPath isEqualToString:@"rate"]) {
        if (self.player.rate == 0) {
            [self.playButton setEnabled:YES];
            [self.histogramView setPlaybackProgress:0.0];
            [self.player seekToTime:kCMTimeZero];
        }
    }
}

@end
