//
//  LITProfileFavoritesViewController.h
//  lit-ios
//
//  Created by ioshero on 24/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITSoundbitePlayerHelper.h"
#import "LITFeedDelegate.h"
#import <Parse/PFUser.h>
#import <ParseUI/PFQueryTableViewController.h>

@interface LITProfileFavoritesViewController : PFQueryTableViewController <LITSoundbitePlayHosting>

@property (strong, nonatomic) PFUser *user;
@property (weak, nonatomic) id<LITFeedDelegate> delegate;

- (void)reloadFavoritesCollection;

@end
