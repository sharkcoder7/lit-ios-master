//
//  UIImage+emoji.h
//  Dog's Spot
//
//  Created by Michael Sena on 4/16/13.
//  Copyright (c) 2013 Michael Sena. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DEFAULTTEXTSIZE 12.0f

@interface UIImage (emoji)

+ (UIImage *)imageWithEmoji:(NSString *)emoji;

+ (UIImage *)imageWithEmoji:(NSString *)emoji
                   withSize:(CGFloat)size;

@end
