//
//  LITBlockFAQ.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITBlockFAQ.h"
#import "UIView+GradientBackground.h"
#import "LITTheme.h"

@interface LITBlockFAQ () {
    BOOL _borderSet;
}

@end

@implementation LITBlockFAQ

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!_borderSet) {
        
        CALayer *border = [CALayer layer];
        border.backgroundColor = [UIColor lit_whiteColor].CGColor;
        border.frame = CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1);
        [self.layer addSublayer:border];
        
        self.clipsToBounds = NO;
        
        _borderSet = YES;
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
