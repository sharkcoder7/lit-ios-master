//
//  LITDubsViewController.h
//  lit-ios
//
//  Created by ioshero on 20/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITContentQueryTableViewController.h"
#import <ParseUI/PFQueryTableViewController.h>

@interface LITDubsViewController : LITContentQueryTableViewController

- (instancetype)initWithCoder:(NSCoder *)aCoder;
@property (weak, nonatomic) id<LITFeedDelegate> delegate;

@end
