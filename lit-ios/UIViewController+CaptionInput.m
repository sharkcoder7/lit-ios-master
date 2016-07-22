//
//  UIViewController+CaptionInput.m
//  lit-ios
//
//  Created by ioshero on 07/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "UIViewController+CaptionInput.h"
#import "LITBlurEffect.h"
#import "LITGradientNavigationBar.h"
#import "UIView+BlurEffect.h"

static void *LITFinishBlockPropertyKey;

@implementation UIViewController (CaptionInput)
@dynamic view;

- (void)setupCustomViewDelegate
{
    ((LITKeyboardCustomView *)self.view).keyboardBarDelegate = self;
}

- (void)showKeyboardWithPlaceholder:(NSString*)placeholder andCompletionBlock:(void(^)(NSString *text, NSError *error))finishBlock
{
    NSAssert([self.view isKindOfClass:[LITKeyboardCustomView class]]
             , @"View's class must be LITKeyboardCustomView");
    NSParameterAssert(finishBlock);
    self.finishBlock = finishBlock;
    LITKeyboardBar *keyboardBar =  (LITKeyboardBar *)((LITKeyboardCustomView *)self.view).inputAccessoryView;
    NSAssert([keyboardBar isKindOfClass:[LITKeyboardBar class]], @"Accessory view must be of class LITKeyboardClass");
    [keyboardBar setDelegate:self];
    [self.view becomeFirstResponder];
    [keyboardBar.textfield becomeFirstResponder];
    [keyboardBar.textfield setPlaceholder:placeholder];
    if([self.navigationController.navigationBar isKindOfClass:[LITGradientNavigationBar class]] &&
       [self.navigationController.navigationBar respondsToSelector:@selector(addBlurEffectBehindOthers:)]) {
        [((LITGradientNavigationBar *)self.navigationController.navigationBar) addBlurEffectBehindOthers:NO];
    }
    
}

#pragma mark - Bar Delegate

- (void)keyboardBar:(LITKeyboardBar *)keyboardBar sendText:(NSString *)text
{
    if (self.finishBlock) {
        
        self.finishBlock(text, nil);
    }
}

#pragma mark - Public
-(void)removeEffectViewFromNavigationBar
{
    if([self.navigationController.navigationBar isKindOfClass:[LITGradientNavigationBar class]] &&
       [self.navigationController.navigationBar respondsToSelector:@selector(removeBlurEffect)]) {
        [((LITGradientNavigationBar *)self.navigationController.navigationBar) removeBlurEffect];
    }
}
#pragma mark - Accessors
- (void)setFinishBlock:(void (^)(NSString *, NSError *))finishBlock
{
    objc_setAssociatedObject(self,
                             LITFinishBlockPropertyKey,
                             finishBlock,
                             OBJC_ASSOCIATION_COPY);
}

- (void (^)(NSString *, NSError *))finishBlock
{
    return objc_getAssociatedObject(self, LITFinishBlockPropertyKey);
}


@end
