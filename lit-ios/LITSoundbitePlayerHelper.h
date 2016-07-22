//
//  LITSoundbitePlayerHelper.h
//  lit-ios
//
//  Created by ioshero on 01/09/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITSoundbitePlayerController.h"
#import <Foundation/Foundation.h>

@protocol LITSoundbitePlayHosting;

@interface LITSoundbitePlayerHelper : NSObject <LITSoundbitePlayerController>

@property (assign, nonatomic) BOOL useLocalCache;
- (instancetype)initWithSoundbitePlayerHosting:(id<LITSoundbitePlayHosting>)host;

@end


@protocol LITSoundbitePlayHosting <NSObject>

@property (strong, nonatomic) UITableView *tableView;

@end