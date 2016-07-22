//
//  LITSoundbiteRecordSoundViewController.m
//  lit-ios
//
//  Created by ioshero on 16/07/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITSoundbiteRecordSoundViewController.h"
#import "LITTouchDetector.h"
#import "LITSoundbitePreviewViewController.h"
#import "AVUtils.h"
#import "LITTheme.h"
#import "LITProgressHud.h"
#import <ZLSinusWaveView/ZLSinusWaveView.h>
#import <MDRadialProgress/MDRadialProgressView.h>
#import <MDRadialProgress/MDRadialProgressTheme.h>
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"

static NSString *const kLITHoldToRecordText = @"HOLD TO RECORD";
static NSString *const kLITRecordingText    = @"RECORDING...";

static NSString *const kLITPresentTagsForRecordingSegueIdentifier = @"LITPresentTagsForRecordingSegue";
static NSString *const kLITPresentSoundbitePreviewSegueIdentifier = @"LITPresentSoundbitePreviewSegue";

static NSTimeInterval kTimerResolution = 0.01; // 1/100 secs

@interface LITSoundbiteRecordSoundViewController ()

@property (strong, nonatomic) EZRecorder *recorder;
@property (nonatomic, strong) EZMicrophone *microphone;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet MDRadialProgressView *progressView;
@property (strong, nonatomic) NSURL *recordingURL;

@property (assign, nonatomic) CGFloat lastTimeProgressUpdate;

@property (strong, nonatomic) NSTimer *durationTimer;
@property (assign, nonatomic) NSTimeInterval duration;

@property (strong, nonatomic) UIBarButtonItem *nextButton;
@end

@implementation LITSoundbiteRecordSoundViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.recording = NO;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error) {
        NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
    [session setActive:YES error:&error];
    if (error){
        NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
    }

    self.recordingAudioPlot.backgroundColor = [UIColor lit_fadedOrangeLightColor];
    self.recordingAudioPlot.color           = [UIColor colorWithWhite:1.0 alpha:0.5];
    self.recordingAudioPlot.plotType        = EZPlotTypeBuffer;
    self.recordingAudioPlot.shouldFill      = YES;
    self.recordingAudioPlot.shouldMirror    = NO;
    self.recordingAudioPlot.waves           = 15;
    self.recordingAudioPlot.density         = 10;
    self.recordingAudioPlot.maxAmplitude    = 1.0;
    self.recordingAudioPlot.idleAmplitude   = 0;
    
    self.recordingAudioPlot.shouldOptimizeForRealtimePlot = YES;
    
    // Create an instance of the microphone and tell it to use this view controller instance as the delegate
    self.microphone = [EZMicrophone microphoneWithDelegate:self];
    
    
    //Create recorder
    

    MDRadialProgressTheme *theme = [MDRadialProgressTheme standardTheme];
    theme.completedColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    theme.thickness = 40.0f;
    theme.incompletedColor = [UIColor clearColor];
    theme.sliceDividerHidden = YES;
    [self.progressView setTheme:theme];
    [self.progressView setProgressTotal:100];
    
    [self.infoLabel setText:@"HOLD TO RECORD"];
    
    self.view.backgroundColor = [UIColor lit_fadedOrangeLightColor];
    
    [self.recordingAudioPlot setHidden:YES];
    
    self.nextButton = [[UIBarButtonItem alloc] initWithTitle:@"NEXT"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(nextButtonPressed:)];
    [self.nextButton setTitleTextAttributes: @{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f], NSForegroundColorAttributeName: [UIColor whiteColor], NSBackgroundColorAttributeName : [UIColor clearColor]} forState:UIControlStateNormal];
    
    
    self.navigationItem.title = @"Record Soundbite";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.microphone stopFetchingAudio];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.recorder) {
        [self initRecorder];
    }
    self.duration = 0;
    self.lastTimeProgressUpdate = 0;
    self.recording = NO;
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.progressView setProgressCounter:0];
    [self.microphone startFetchingAudio];
    
}


#pragma mark - EZMicrophoneDelegate
// Note that any callback that provides streamed audio data (like streaming microphone input) happens on a separate audio thread that should not be blocked. When we feed audio data into any of the UI components we need to explicity create a GCD block on the main thread to properly get the UI to work.
- (void)   microphone:(EZMicrophone *)microphone
     hasAudioReceived:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    // Getting audio data as an array of float buffer arrays. What does that mean? Because the audio is coming in as a stereo signal the data is split into a left and right channel. So buffer[0] corresponds to the float* data for the left channel while buffer[1] corresponds to the float* data for the right channel.
    
    // See the Thread Safety warning above, but in a nutshell these callbacks happen on a separate audio thread. We wrap any UI updating in a GCD block on the main thread to avoid blocking that audio flow.
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        // All the audio plot needs is the buffer data (float*) and the size. Internally the audio plot will handle all the drawing related code, history management, and freeing its own resources. Hence, one badass line of code gets you a pretty plot :)
        if (self.recordingAudioPlot.isHidden) {
            [self.recordingAudioPlot setHidden:NO];
        }
        [weakSelf.recordingAudioPlot updateBuffer:buffer[0]
                                   withBufferSize:bufferSize];
    });
}

- (void)microphone:(EZMicrophone *)microphone
        hasBufferList:(AudioBufferList *)bufferList
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    // Getting audio data as a buffer list that can be directly fed into the EZRecorder. This is happening on the audio thread - any UI updating needs a GCD main queue block. This will keep appending data to the tail of the audio file.
    if (self.isRecording) {
        [self.recorder appendDataFromBufferList:bufferList
                                 withBufferSize:bufferSize];
    }
}


#pragma mark - EZRecorderDelegate
- (void)recorderDidClose:(EZRecorder *)recorder
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.recorder = nil;
        [self performSegueWithIdentifier:kLITPresentSoundbitePreviewSegueIdentifier
                                  sender:self];
    });
}


- (void)recorderUpdatedCurrentTime:(EZRecorder *)recorder
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.duration >= kSoundbiteMaxLength) {
            [self stopFetchingAudioAndClose];
        } else {
            if (self.duration >= kSoundbiteTriggerLength && !self.navigationItem.rightBarButtonItem) {
                [self.navigationItem setRightBarButtonItem:self.nextButton animated:YES];
            }
            CGFloat update = floorf(self.duration / kSoundbiteMaxLength * 100) / 100;
            if (update > self.lastTimeProgressUpdate) {
                self.lastTimeProgressUpdate = update;
                NSLog(@"%f", self.lastTimeProgressUpdate);
                [self.progressView setProgressCounter:update * 100];
            }
        }
    }); 
}

- (void)stopFetchingAudioAndClose
{
    if (self.durationTimer) {
        [self pauseTimer];
    }
    [self.microphone stopFetchingAudio];
    self.recording = NO;
    [self.progressView setProgressCounter:100];
    [self.recorder closeAudioFile];
}

#pragma mark - Actions

- (IBAction)recordButtonTouchedDown:(UIButton *)sender
{
    [[Mixpanel sharedInstance] track:kMixpanelAction_recordSound_Soundbites properties:nil];
    
    [self.infoLabel setText:kLITRecordingText];
    self.recording = YES;
    [self startTimer];
}

- (IBAction)recordButtonTouchedUp:(UIButton *)sender
{
    [self.infoLabel setText:kLITHoldToRecordText];
    self.recording = NO;
    [self pauseTimer];
}

- (void)nextButtonPressed:(UIBarButtonItem *)nextButton
{
    [self stopFetchingAudioAndClose];
    [self.infoLabel setText:kLITHoldToRecordText];
}


#pragma mark - Timer

- (void)startTimer {
    self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:kTimerResolution
                                                          target:self
                                                        selector:@selector(fireTimer:)
                                                        userInfo:nil
                                                         repeats:YES];
}

- (void)fireTimer:(NSTimer *)inTimer
{
    self.duration += kTimerResolution;
}

- (void)resumeTimer {
    if(self.durationTimer)
    {
        [self.durationTimer invalidate];
        self.durationTimer = nil;
    }
    [self startTimer];
}

- (void)pauseTimer {
    [self.durationTimer invalidate];
    self.durationTimer = nil;
}

- (void)initRecorder
{
    self.recordingURL = [AVUtils soundbiteRecordingTempFilePathURL];
    self.recorder = [EZRecorder recorderWithURL:self.recordingURL
                                   clientFormat:[self.microphone audioStreamBasicDescription]
                                       fileType:EZRecorderFileTypeM4A
                                       delegate:self];
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kLITPresentSoundbitePreviewSegueIdentifier]) {
        LITSoundbitePreviewViewController *previewController = segue.destinationViewController;
        NSAssert([previewController isKindOfClass:[LITSoundbitePreviewViewController class]], @"Destination view controller must be of class LITSoundbitePreviewViewController");
        previewController.contentURL = self.recordingURL;
        previewController.comesFromRecording = YES;
    }
}

@end
