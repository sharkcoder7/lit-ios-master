//
//  LITProfileViewController.h
//  slit-ios
//
//  Created by ioshero on 09/07/2015.
//  Copyright (c) 2015 Slit Inc. All rights reserved.
//

#import "LITFeedDelegate.h"
#import <UIKit/UIKit.h>
#import <Parse/PFUser.h>

/* MODEL created objects same way as content feed */
/* Favs keyboard check already created class in Parse backend 
    Will be modeled as a separate class
 */

@class LITMainViewController;
@interface LITProfileViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (assign, nonatomic) NSInteger numberOfProfileView;
@property (strong, nonatomic) PFUser * user;
@property (strong, nonatomic) NSArray *installedKeyboards;
@property (weak, nonatomic) id<LITFeedDelegate> delegate;


- (void)reloadKeyboards:(NSArray *)keyboards;
- (void)presentPointsView;

@end
