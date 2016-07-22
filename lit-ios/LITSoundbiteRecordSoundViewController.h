//
//  LITSoundbiteRecordSoundViewController.h
//  lit-ios
//
//  Created by ioshero on 16/07/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EZAudio/EZRecorder.h>
#import <EZAudio/EZMicrophone.h>

@class ZLSinusWaveView;
@interface LITSoundbiteRecordSoundViewController : UIViewController <EZMicrophoneDelegate, EZRecorderDelegate>

@property (weak, nonatomic) IBOutlet ZLSinusWaveView *recordingAudioPlot;
@property (assign ,nonatomic, getter=isRecording) BOOL recording;


@end
