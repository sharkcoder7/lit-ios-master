//
//  LITSearchBar.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITSearchBar.h"

@implementation LITSearchBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setFrame:(CGRect)frame
{
    [super setFrame:CGRectMake(14.0f, 0.0, CGRectGetWidth([UIScreen mainScreen].bounds) - 28.0f, frame.size.height)];
}

@end
