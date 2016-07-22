//
//  LITAddSoundbiteViewController.h
//  slit-ios
//
//  Created by ioshero on 07/07/2015.
//  Copyright (c) 2015 Slit Inc. All rights reserved.
//

#import "LITSoundbitePlayerHelper.h"
#import "LITContentQueryTableViewController.h"
#import <UIKit/UIKit.h>
#import <ParseUI/PFQueryTableViewController.h>
#import <MediaPlayer/MediaPlayer.h>

@interface LITSoundbitesViewController : LITContentQueryTableViewController <MPMediaPickerControllerDelegate, LITSoundbitePlayHosting>

- (id)initWithCoder:(NSCoder *)aCoder;

@end
