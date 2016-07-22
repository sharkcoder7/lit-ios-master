//
//  UIViewController+CaptionInput.h
//  lit-ios
//
//  Created by ioshero on 07/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LITKeyboardCustomView.h"

@interface UIViewController (CaptionInput) <LITKeyboardBarDelegate>

@property (strong, nonatomic)   LITKeyboardCustomView *view;
@property (copy)                void (^finishBlock)(NSString *, NSError *);

- (void)setupCustomViewDelegate;
- (void)showKeyboardWithPlaceholder:(NSString*)placeholder andCompletionBlock:(void(^)(NSString *text, NSError *error))finishBlock;
- (void)removeEffectViewFromNavigationBar;

@end
