//
//  LITProfileKeyboardsViewController.h
//  lit-ios
//
//  Created by ioshero on 21/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITBaseKeyboardViewController.h"
#import <Parse/PFUser.h>
#import <DownloadButton/PKDownloadButton.h>

@class LITProfileViewController;
@interface LITProfileKeyboardsViewController : LITBaseKeyboardViewController <PKDownloadButtonDelegate>

@property (strong, nonatomic) NSArray *installedKeyboards;
@property (strong, nonatomic) LITProfileViewController *parent;

- (id)initWithCoder:(NSCoder *)aCoder;

@end
