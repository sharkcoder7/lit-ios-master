//
//  LITShareHelper.h
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LITSharingGlobals) {
    LITSharingLinkErrorTwitter,
    LITSharingLinkErrorFacebook,
    LITSharingLinkAlreadyTwitter,
    LITSharingLinkAlreadyFacebook,
    LITSharingLinkOkTwitter,
    LITSharingLinkOkFacebook
};

@class BFTask;
@interface LITShareHelper : NSObject

+ (BOOL)checkTwitterLinked;
+ (BOOL)checkFacebookLinked;
+ (BFTask *)linkTwitterAccount;
+ (BFTask *)linkFacebookAccount;
+ (void)shareMessage:(NSString *)message;
+ (void)shareMessage:(NSString *)message inView:(UIView *)view;

@end
