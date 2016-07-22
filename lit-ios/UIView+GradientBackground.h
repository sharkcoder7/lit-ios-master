//
//  UIView+GradientBackground.h
//  lit-ios
//
//  10/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (GradientBackground)

@property (strong, readonly, nonatomic) CAGradientLayer *gradientLayer;

- (void)setupGradientBackground;
- (void)setupFeedKeyboardGradientBackground;
- (void)setupFeedKeyboardTitleBarGradientBackground;
- (void)setupGradientBackgroundWithColors:(NSArray *)colors;
- (void)setupGradientBackgroundFromPoint:(CGPoint)point andStartingColor:(UIColor*)color toPoint:(CGPoint)point andFinalColor:(UIColor*)color;

@end
