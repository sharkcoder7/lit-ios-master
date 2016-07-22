//
//  LITKeyboardFeedViewController.h
//  lit-ios
//
//  Created by ioshero on 20/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITFeedDelegate.h"
#import "LITBaseKeyboardViewController.h"
#import <DownloadButton/PKDownloadButton.h>

@interface LITKeyboardFeedViewController : LITBaseKeyboardViewController <PKDownloadButtonDelegate>

- (id)initWithCoder:(NSCoder *)aCoder;

@end

