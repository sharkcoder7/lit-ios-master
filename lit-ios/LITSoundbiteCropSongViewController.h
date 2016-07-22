//
//  LITDubCropSongViewController.h
//  lit-ios
//
//  Created by ioshero on 10/07/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LITHistogramControlView.h"

@class LITSoundbite, MPMediaItem, EZAudioFile;
@interface LITSoundbiteCropSongViewController : UIViewController <LITHistogramControlViewDelegate>

@property (strong, nonatomic) MPMediaItem *mediaItem;
@property (strong, nonatomic) LITSoundbite *soundbite;
@property (strong, nonatomic) EZAudioFile *audioFile;

@end
