//
//  UIViewController+KeyboardAnimation.m
//  lit-ios
//
//  Created by Antonio Losada on 1/9/15.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "UIViewController+KeyboardAnimator.h"

@implementation UIViewController(KeyboardAnimator)

- (void)setupKeyboardAnimations {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)discardKeyboardAnimations
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSValue *endFrameValue = aNotification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardEndFrame = [self.view convertRect:endFrameValue.CGRectValue fromView:nil];
    
    if(![self isViewShortened]){
        [self moveViewUp:YES withAnimationDuration:[aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
       andAnimationCurve:[aNotification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] forKeyboardFrame:keyboardEndFrame];
    }
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    /*
    if (self.view.frame.origin.y == 0.0f) {
        return;
    }
    */
    NSValue *endFrameValue = aNotification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardEndFrame = [self.view convertRect:endFrameValue.CGRectValue fromView:nil];
    
    
    if([self isViewShortened]){
        [self moveViewUp:NO withAnimationDuration:[aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
       andAnimationCurve:[aNotification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] forKeyboardFrame:keyboardEndFrame];
    }
}

#pragma mark - Animation

- (void)moveViewUp:(BOOL)up withAnimationDuration:(NSTimeInterval)duration andAnimationCurve:(UIViewAnimationCurve)animationCurve forKeyboardFrame:(CGRect)keyboardFrame
{
    CGFloat uppedOrigin = 0.0f;
    CGFloat shortenedHeight = 0.0f;
    CGFloat keyboardHeight = 0.0f;
    CGRect viewFrame = self.view.frame;
    if (up) {
        keyboardHeight = CGRectGetHeight(keyboardFrame);
        uppedOrigin = viewFrame.origin.y - keyboardHeight/1.6;
        shortenedHeight = viewFrame.size.height - keyboardHeight;
    }
    else{
        uppedOrigin = viewFrame.origin.y;
        shortenedHeight = [[UIScreen mainScreen] bounds].size.height;
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    /*
    // If we're using this category in the Lyric creation controller, we move the view up
    if([controllerClass caseInsensitiveCompare:@"LITLyricCreationViewController"] == NSOrderedSame){
        viewFrame.origin.y = uppedOrigin;
    }
    
    // If we're using it for reporting content or giving feedback, we resize the view
    // without moving it
    else if([controllerClass caseInsensitiveCompare:@"LITReportViewController"] == NSOrderedSame
            || [controllerClass caseInsensitiveCompare:@"LITFeedbackViewController"] == NSOrderedSame){
        */viewFrame.size.height = shortenedHeight;
    //}
    self.view.frame = viewFrame;
    [UIView commitAnimations];
}

#pragma mark Helpers

- (BOOL) isViewShortened{
    if(self.view.frame.size.height < [[UIScreen mainScreen] bounds].size.height-100){
        return YES;
    }
    else{
        return NO;
    }
}

@end
