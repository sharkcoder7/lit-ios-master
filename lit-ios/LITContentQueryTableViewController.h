//
//  LITContentQueryTableViewController.h
//  lit-ios
//
//  Created by ioshero on 02/09/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITTableSearchHelper.h"
#import "LITFeedDelegate.h"
#import "LITKeyboard.h"
#import <UIKit/UIKit.h>
#import <ParseUI/PFQueryTableViewController.h>

@interface LITContentQueryTableViewController : PFQueryTableViewController <LITTableSearchHosting> {
    LITTableSearchHelper *searchHelper;
}

@property (strong, nonatomic)   LITKeyboard *keyboard;

@property (strong, nonatomic)   UIView *addButtonView;
@property (strong, nonatomic)   UIButton *addButton;
@property (strong, nonatomic)   NSString *searchKey;

@property (strong, nonatomic)   UIView *segmentedHeaderView;

@property (assign, nonatomic)   BOOL showsSegmentedHeader; //Default is YES
@property (assign, nonatomic)   BOOL showsAddButton; //Default is YES

@property (weak, nonatomic)     id<LITObjectOptionDelegate> optionsDelegate;
@property (weak, nonatomic)     id<LITFeedDelegate> feedDelegate;

@property (assign, nonatomic) BOOL optionsVisible;

@property (assign, nonatomic) BOOL isAddingToKeyboard;

//Adds default functionality
- (void)optionsButtonPressed:(UIButton *)optionsButton;

//Must be implemented in subclass
- (void)addButtonPressed:(UIBarButtonItem *)button;


@end
