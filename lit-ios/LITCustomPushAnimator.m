//
//  LITRightToLeftPushAnimator.m
//  lit-ios
//
//  Created by ioshero on 09/09/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITCustomPushAnimator.h"

@implementation LITCustomPushAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey]
    ;
    CGFloat originX, originY;
    CGRect outFinalFrame, navBarFinalFrame, inFinalFrame;
    UINavigationBar *navBar = [fromViewController navigationController].navigationBar;
    
    CGFloat animationFrameWidth = CGRectGetWidth([transitionContext containerView].frame);
    
    if (self.isReverse) {
        originX = self.direction == LITCustomPushAnimatorDirectionLeft ? animationFrameWidth - 30.0f : -30.0;
        originY = 64.0f;
        if (self.direction == LITCustomPushAnimatorDirectionLeft) {
            outFinalFrame = CGRectMake(-animationFrameWidth, CGRectGetMinY(fromViewController.view.frame), CGRectGetWidth(fromViewController.view.frame), CGRectGetHeight(fromViewController.view.frame));
        } else {
            outFinalFrame = CGRectMake(animationFrameWidth, CGRectGetMinY(fromViewController.view.frame), CGRectGetWidth(fromViewController.view.frame), CGRectGetHeight(fromViewController.view.frame));
        }
    } else {
         originX = self.direction == LITCustomPushAnimatorDirectionLeft ? -animationFrameWidth : CGRectGetWidth([transitionContext containerView].frame);
        originY = 0.0f;
        if (self.direction == LITCustomPushAnimatorDirectionLeft) {
            outFinalFrame = CGRectMake(30.0f, CGRectGetMinY(fromViewController.view.frame), CGRectGetWidth(fromViewController.view.frame), CGRectGetHeight(fromViewController.view.frame));
            navBarFinalFrame = CGRectOffset(navBar.frame,
                                            animationFrameWidth,
                                            0.0f);
        } else {
            outFinalFrame = CGRectMake(-30.0f, CGRectGetMinY(fromViewController.view.frame), CGRectGetWidth(fromViewController.view.frame), CGRectGetHeight(fromViewController.view.frame));
            navBarFinalFrame = CGRectOffset(navBar.frame,
                                            -animationFrameWidth,
                                            0.0f);
        }
    }
    
    [toViewController.view setFrame:CGRectMake(originX, originY, CGRectGetWidth(toViewController.view.frame), CGRectGetHeight(toViewController.view.frame))];
    if (self.isReverse) {
        inFinalFrame = CGRectMake(CGRectGetMinX([transitionContext containerView].frame),
                                  64.0f, CGRectGetWidth([transitionContext containerView].frame), CGRectGetHeight([transitionContext containerView].frame) - 64.0f);
        [[transitionContext containerView] insertSubview:toViewController.view atIndex:0];
    } else {
        [[transitionContext containerView] addSubview:toViewController.view];
        inFinalFrame = [transitionContext containerView].frame;
    }


    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        [fromViewController.view setFrame:outFinalFrame];
        [toViewController.view setFrame:inFinalFrame];
        if (!self.isReverse) {
            [navBar setFrame:navBarFinalFrame];
        }
    } completion:^(BOOL finished) {
        if ([transitionContext transitionWasCancelled]) {
            if (self.isReverse) {
                [[toViewController navigationController] setNavigationBarHidden:YES];
            }
        } else {
            if (!self.isReverse) {
                [[fromViewController navigationController] setNavigationBarHidden:YES];
            }
        }
    
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}



@end
