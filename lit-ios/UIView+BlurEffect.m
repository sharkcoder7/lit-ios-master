//
//  UIView+BlurEffect.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "UIView+BlurEffect.h"
#import "LITBlurEffect.h"

#define kEffectViewTag      100

@implementation UIView (BlurEffect)

- (void)addBlurEffectBehindOthers:(BOOL)behind withStyle:(UIBlurEffectStyle)style
{
    if (self.visualEffectView) {
        return;
    }
    UIVisualEffect *blurEffect;
    blurEffect = [LITBlurEffect effectWithStyle:style];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    visualEffectView.frame = self.bounds;
    visualEffectView.userInteractionEnabled = NO;
    visualEffectView.tag = kEffectViewTag;
    if (behind) {
        [self insertSubview:visualEffectView atIndex:0];
    } else {
        [self addSubview:visualEffectView];
    }
    
    [visualEffectView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    if (![self isKindOfClass:[UINavigationBar class]]) {
        NSDictionary *bindings = NSDictionaryOfVariableBindings(visualEffectView);
        NSArray *vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[visualEffectView]|" options:0 metrics:nil views:bindings];
        NSArray *hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[visualEffectView]|" options:0 metrics:nil views:bindings];
        [self addConstraints:vConstraints];
        [self addConstraints:hConstraints];
    }
}


- (void)addBlurEffectBehindOthers:(BOOL)behind;
{
    [self addBlurEffectBehindOthers:behind withStyle:UIBlurEffectStyleLight];
}

- (void)removeBlurEffect
{
    UIVisualEffectView *effectView = (UIVisualEffectView *)[self viewWithTag:kEffectViewTag];
    if (effectView) {
        NSAssert([effectView isKindOfClass:[UIVisualEffectView class]], @"effectView must be of class UIVisualEffectView");
        [effectView removeFromSuperview];
    }
}

- (UIVisualEffectView *)visualEffectView
{
    return (UIVisualEffectView *)[self viewWithTag:kEffectViewTag];

}

@end
