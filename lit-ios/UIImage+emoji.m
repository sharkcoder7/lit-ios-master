//
//  UIImage+emoji.m
//  Dog's Spot
//
//  Created by Michael Sena on 4/16/13.
//  Copyright (c) 2013 Michael Sena. All rights reserved.
//

#import "UIImage+emoji.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImage (emoji)

+ (UIImage *)imageWithEmoji:(NSString *)emoji
                   withSize:(CGFloat)size
{
    // Create a label
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"Apple Color Emoji" size:size];
    label.text = emoji;
    label.opaque = NO;
    label.backgroundColor = [UIColor clearColor];
    CGSize labelSize = CGSizeMake(size, size);
    label.frame = CGRectMake(0, 0, labelSize.width, labelSize.height);
    
    return [UIImage imageFromView:label];
}

+ (UIImage *)imageWithEmoji:(NSString *)emoji
{
    //return [UIImage imageWithEmoji:emoji withSize:DEFAULTTEXTSIZE];
    
    CGFloat size = 26;
    
    // Create a label
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"Apple Color Emoji" size:size];
    label.text = emoji;
    label.opaque = NO;
    label.backgroundColor = [UIColor clearColor];
    CGSize labelSize = CGSizeMake(size, size*1.6);
    label.frame = CGRectMake(10, 0, labelSize.width, labelSize.height);
    
    return [UIImage imageFromView:label];
}


+ (UIImage *)imageFromView:(UIView *)view
{
    UIGraphicsPushContext(UIGraphicsGetCurrentContext());
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    UIGraphicsPopContext();
    
    return img;
}
@end
