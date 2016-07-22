//
//  UIViewController+UserNameUpdater.h
//  lit-ios
//

//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kProfileDataUsernameKey;
extern NSString *const kProfileDataEmailKey;
extern NSString *const kProfileDataPictureURLKey;

@class BFTask;
@interface UIViewController (ProfileUpdater)

- (BFTask *)updateProfileDataWithAuthData:(NSDictionary *)authData;

@end
