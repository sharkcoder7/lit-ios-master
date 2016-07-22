//
//  LITAddLyricViewController.h
//  slit-ios
//
//  Created by ioshero on 08/07/2015.
//  Copyright (c) 2015 Slit Inc. All rights reserved.
//

#import "LITContentQueryTableViewController.h"
#import <UIKit/UIKit.h>
#import <ParseUI/PFQueryTableViewController.h>

extern NSString *const kLITPresentTopSongsForLyricsSegueIdentifier;

@interface LITLyricsViewController : LITContentQueryTableViewController

- (instancetype)initWithCoder:(NSCoder *)aCoder;

@end
