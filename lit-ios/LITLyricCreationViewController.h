//
//  LITLyricCreationViewController.h
//  lit-ios
//
//  Created by ioshero on 23/07/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kLITLyricCreationSegue;

@class LITSong;
@class LITKeyboard;
@interface LITLyricCreationViewController : UIViewController

@property (strong, nonatomic) LITSong *song;
@property (strong, nonatomic) LITKeyboard *destinationKeyboard;

@end
