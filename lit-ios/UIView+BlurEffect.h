//
//  UIView+BlurEffect.h
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (BlurEffect)

- (UIVisualEffectView *)visualEffectView;
- (void)addBlurEffectBehindOthers:(BOOL)behind withStyle:(UIBlurEffectStyle)style;
- (void)addBlurEffectBehindOthers:(BOOL)behind;
- (void)removeBlurEffect;

@end
