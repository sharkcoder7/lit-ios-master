//
//  LITActionSheet.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITActionSheet.h"
#import "LITTheme.h"
#import <QuartzCore/QuartzCore.h>
#import <JGActionSheet/JGActionSheet.h>

@interface JGButton : UIButton

@property (nonatomic, assign) NSUInteger row;

@end

@implementation LITActionSheet

+ (void)setButtonStyle:(JGActionSheetButtonStyle)buttonStyle forButton:(UIButton *)button {
    UIColor *backgroundColor, *borderColor, *titleColor = nil;
    UIFont *font = nil;
    
    font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    titleColor = [UIColor lit_coolGreyColor];
    backgroundColor = [UIColor whiteColor];
    borderColor = [UIColor clearColor];
    
//    if (buttonStyle == JGActionSheetButtonStyleDefault) {
//        
//    }
//    else if (buttonStyle == JGActionSheetButtonStyleCancel) {
//    
//    }
    
    button.layer.cornerRadius = 0.0f;
    
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    
    [button setBackgroundImage:[self pixelImageWithColor:backgroundColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[self pixelImageWithColor:backgroundColor] forState:UIControlStateHighlighted];
    
    //[button setBackgroundColor:backgroundColor];
    
    button.titleLabel.font = font;
    button.layer.borderColor = borderColor.CGColor;
}

+ (UIImage *)pixelImageWithColor:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions((CGSize){1.0f, 1.0f}, YES, 0.0f);
    
    [color setFill];
    
    [[UIBezierPath bezierPathWithRect:(CGRect){CGPointZero, {1.0f, 1.0f}}] fill];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return [img resizableImageWithCapInsets:UIEdgeInsetsZero];
}

@end
