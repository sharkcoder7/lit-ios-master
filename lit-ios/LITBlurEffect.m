//
//  LITBlurEffect.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITBlurEffect.h"

@implementation LITBlurEffect

+ (instancetype)effectWithStyle:(UIBlurEffectStyle)style
{
    id result = [super effectWithStyle:style];
    object_setClass(result, self);
    
    return result;
}

- (id)effectSettings
{
    id settings = [super effectSettings];
    [settings setValue:@10 forKey:@"blurRadius"];
    return settings;
}

- (id)copyWithZone:(NSZone*)zone
{
    id result = [super copyWithZone:zone];
    object_setClass(result, [self class]);
    return result;
}


@end
