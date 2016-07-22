//
//  LITKBLetter.m
//  lit-ios
//
//  Created by Admin on 4/12/16.
//  Copyright © 2016 Lit Inc. All rights reserved.
//

#import "LITKBLetter.h"

@implementation LITKBLetter

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib
{
    UIColor *backgroundColor = [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:0.15];
    
    if (self.tag == 10000) // search button
        backgroundColor = [UIColor colorWithRed:0 green:121.0/255.0 blue:221/255.0 alpha:1];
    
    [self setBackgroundColor:backgroundColor];
    
    self.clipsToBounds = YES;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = [UIScreen mainScreen].bounds.size.width * 0.012;
    
    if (self.tag == 0 || self.tag == 10000) {
        UIFont *font = [UIFont fontWithName:@"SFUIText-Regular" size:16];
        [self.titleLabel setFont:font];
    }
    else {
        UIFont *font = [UIFont fontWithName:@"SFUIText-Regular" size:22.5];
        [self.titleLabel setFont:font];
    }    
}

@end
