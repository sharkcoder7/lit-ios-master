//
//  LITRightToLeftPushAnimator.h
//  lit-ios
//
//  Created by ioshero on 09/09/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LITCustomPushAnimatorDirection) {
    LITCustomPushAnimatorDirectionLeft,
    LITCustomPushAnimatorDirectionRight
};

@interface LITCustomPushAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (assign, nonatomic, getter=isReverse) BOOL reverse;
@property (assign, nonatomic) LITCustomPushAnimatorDirection direction;

@end
