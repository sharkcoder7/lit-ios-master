//
//  LITBlurEffect.h
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>


@interface UIBlurEffect (Protected)
@property (nonatomic, readonly) id effectSettings;
@end

@interface LITBlurEffect : UIBlurEffect

@end
