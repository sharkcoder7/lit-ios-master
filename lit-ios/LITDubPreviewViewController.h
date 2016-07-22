//
//  LITDubPreviewViewController.h
//  lit-ios
//
//  Created by ioshero on 15/07/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

@import UIKit;
#import <SCRecorder/SCRecorder.h>

extern NSString *const kLITDubPreviewSegueIdentifier;

@class LITSoundbite;
@interface LITDubPreviewViewController : UIViewController <SCPlayerDelegate, SCAssetExportSessionDelegate>

//@property (strong, nonatomic) SCRecordSession *recordSession;
//@property (strong, nonatomic) AVMutableComposition *composition;
@property (strong, nonatomic) LITSoundbite *soundbite;
@property (strong, nonatomic) AVPlayerItem *mixedVideo;
@property (strong, nonatomic) NSURL *mixedVideoURL;

@end
