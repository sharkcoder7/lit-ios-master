//
//  LITKeyboardCellPlayerHelper.h
//  lit-ios
//
//  Created by Antonio Losada on 7/9/15.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITKeyboardCellPreviewController.h"
@import Foundation;

@protocol LITKeyboardCellPlayerHelper;

@class SharkfoodMuteSwitchDetector;
@interface LITKeyboardCellPlayerHelper : NSObject <LITKeyboardCellPreviewController>

@property (strong, nonatomic) SharkfoodMuteSwitchDetector *switchDetector;
@property (copy)void (^silentBlock)(BOOL);

- (instancetype)initWithKeyboardControllerHosting:(UIViewController *)host;

@end