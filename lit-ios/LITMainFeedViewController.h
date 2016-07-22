//
//  LITMainFeedViewController.h
//  lit-ios
//
//  Created by ioshero on 20/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITFeedDelegate.h"
#import "LITSoundbitePlayerHelper.h"
#import "LITTableSearchHelper.h"
#import <Foundation/Foundation.h>
#import <ParseUI/PFQueryTableViewController.h>

@interface LITMainFeedViewController : PFQueryTableViewController <LITSoundbitePlayHosting, LITTableSearchHosting>

@property (weak, nonatomic) id<LITFeedDelegate> delegate;
@property (assign, nonatomic) BOOL optionsVisible;

@end
