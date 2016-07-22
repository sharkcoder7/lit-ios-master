//
//  LITKeyboardInstallerHelper.h
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const kLITKeyboardWasInstalledNotificationName;
extern NSString *const kLITKeyboardWasRemovedNotificationName;

typedef NS_ENUM(NSInteger, LITKeyboardStatus) {
    LITKeyboardStatusInstalled,
    LITKeyboardStatusUninstalled,
    LITKeyboardStatusNonInstalled
};
typedef void(^LITKeyboardInstallationProgressBlock)(CGFloat progress);

@class BFTask, LITKeyboard, BFCancellationToken;
@interface LITKeyboardInstallerHelper : NSObject

+ (BFTask *)installKeyboard:(LITKeyboard *)targetKeyboard fromViewController:(UIViewController *)viewController;
+ (BFTask *)installKeyboard:(LITKeyboard *)targetKeyboard
         fromViewController:(UIViewController *)viewController
          withProgressBlock:(LITKeyboardInstallationProgressBlock)block
       andCancellationToken:(BFCancellationToken *)cancelToken;

+ (BFTask *)downloadKeyboardContentsToSharedCache:(LITKeyboard *)targetKeyboard;
+ (BFTask *)downloadKeyboardContentsToSharedCache:(LITKeyboard *)targetKeyboard
                                withProgressBlock:(LITKeyboardInstallationProgressBlock)block;

+ (BFTask *)removeKeyboard:(LITKeyboard *)targetKeyboard;
+ (BFTask *)checkKeyboardStatus:(LITKeyboard *)keyboard;

@end
