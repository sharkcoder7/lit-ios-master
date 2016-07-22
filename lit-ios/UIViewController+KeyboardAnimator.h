//
//  UIViewController+KeyboardAnimation.h
//  lit-ios
//
//  Created by Antonio Losada on 1/9/15.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController(KeyboardAnimator) <UITextViewDelegate>

- (void)setupKeyboardAnimations;
- (void)keyboardWillShow:(NSNotification *)aNotification;
- (void)keyboardWillHide:(NSNotification *)aNotification;
- (void)discardKeyboardAnimations;

@end
