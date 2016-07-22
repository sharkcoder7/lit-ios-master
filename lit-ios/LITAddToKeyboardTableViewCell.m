//
//  LITAddToKeyboardTableViewCell.m
//  lit-ios
//
//  Created by ioshero on 18/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITAddToKeyboardTableViewCell.h"

NSString *const kLITAddToKeyboardTableViewCellIdentifier = @"LITAddToKeyboardTableViewCell";
CGFloat const kLITAddToKeyboardCellHeight = 68.0f;

@interface LITAddToKeyboardTableViewCell ()
@property (weak, nonatomic) IBOutlet UIView *labelContainerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation LITAddToKeyboardTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.labelContainerView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.labelContainerView.layer.borderWidth = 2.0f;
    self.labelContainerView.layer.cornerRadius = 2.0f;
}

@end
