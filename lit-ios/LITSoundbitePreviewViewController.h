//
//  LITSoundibitePreviewViewController.h
//  lit-ios
//
//  Created by Antonio Losada on 4/9/15.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/PFObject.h>


@class LITSong;
@interface LITSoundbitePreviewViewController : UIViewController

@property (strong, nonatomic) NSURL *contentURL;
@property (strong, nonatomic) LITSong *song;
@property (assign, nonatomic) BOOL comesFromRecording;

@end
