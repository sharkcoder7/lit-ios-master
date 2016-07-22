//
//  LITKeyboardHeaderView.m
//  lit-ios
//
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import "LITKeyboardHeaderView.h"
#import "LITTheme.h"

@implementation LITKeyboardHeaderView

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor whiteColor];
    [self.likesLabel setTextColor:[UIColor lit_coolGreyColor]];
    
    ((UIImageView *)self.userImageView).layer.cornerRadius =
        CGRectGetWidth(((UIImageView *)self.userImageView).frame)  / 2.0f;
    
    ((UIImageView *)self.userImageView).layer.masksToBounds = YES;
    ((UIImageView *)self.userImageView).contentMode = UIViewContentModeScaleAspectFill;
}

@end
