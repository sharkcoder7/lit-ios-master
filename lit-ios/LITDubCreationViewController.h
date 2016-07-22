//
//  LITDubmashCreationViewController.h
//  lit-ios
//
//  Created by ioshero on 15/07/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SCRecorder/SCRecorder.h>

extern NSString *const kDubCreationSegueIdentifier;

@class LITSoundbite;
@interface LITDubCreationViewController : UIViewController <SCRecorderDelegate>

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (strong ,nonatomic) NSURL *soundURL;
@property (strong, nonatomic) LITSoundbite *soundbite;

@end
