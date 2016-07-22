//
//  LITAddDubmashViewController.h
//  slit-ios
//
//  Created by ioshero on 08/07/2015.
//  Copyright (c) 2015 Slit Inc. All rights reserved.
//

#import "LITSoundbitePlayerHelper.h"
#import "LITContentQueryTableViewController.h"
@import UIKit;

extern NSString *const kDubPickSoundbiteSegueIdentifier;

@interface LITDubsPickSoundbiteViewController : LITContentQueryTableViewController <LITSoundbitePlayHosting>

- (id)initWithCoder:(NSCoder *)aCoder;

@end
