//
//  LITKeyboardFooterView.m
//  lit-ios
//
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import "LITKeyboardFooterView.h"
#import "UIView+GradientBackground.h"

@implementation LITKeyboardFooterView

- (void)awakeFromNib {
    
    [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.removeButton setHidden:YES];
    [self.removeButton.layer setBorderWidth:1.0f];
    [self.removeButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.removeButton.layer setCornerRadius:2.0f];
    [self.editButton setHidden:YES];
    [self.editButton.layer setBorderWidth:1.0f];
    [self.editButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.editButton.layer setCornerRadius:2.0f];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setupFeedKeyboardTitleBarGradientBackground];
}

@end
