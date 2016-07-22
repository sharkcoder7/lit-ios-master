//
//  LITProgressHud.h
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JGProgressHUD/JGProgressHUD.h>

extern NSString *const kLITHUDStateError;
extern NSString *const kLITHUDStateSuccess;
extern NSString *const kLITHUDStateDone;
extern NSString *const kLITHUDStatePaste;

@interface LITProgressHud : NSObject

+ (JGProgressHUD *)createHudWithMessage:(NSString*)msg;
+ (JGProgressHUD *)createKeyboardHudWithMessage:(NSString*)msg;
+ (JGProgressHUD *)createCopyPasteHudWithMessage:(NSString*)msg;
+ (void)changeStateOfHUD:(JGProgressHUD*)hud to:(NSString*)newState withMessage:(NSString*)msg;

@end
