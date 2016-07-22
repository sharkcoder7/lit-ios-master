//
//  KeyboardBar.h
//  KeyboardInputView
//
//  Created by Brian Mancini on 10/4/14.
//  Copyright (c) 2014 iOSExamples. All rights reserved.
//

@import UIKit;

@class LITKeyboardBar;

@protocol LITKeyboardBarDelegate <NSObject>

- (void)keyboardBar:(LITKeyboardBar *)keyboardBar sendText:(NSString *)text;

@end

@interface LITKeyboardBar : UIView

- (id)initWithDelegate:(id<LITKeyboardBarDelegate>)delegate;

@property (strong, nonatomic/*, readonly*/) UITextField *textfield;
@property (strong, nonatomic, readonly) UIButton *actionButton;
@property (weak, nonatomic) id<LITKeyboardBarDelegate> delegate;

@end
