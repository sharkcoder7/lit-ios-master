//
//  LITKeyboard.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITKeyboard.h"



@implementation LITKeyboard

@dynamic    displayName,
            user,
            contents,
            featured;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"keyboard";
}


@end
