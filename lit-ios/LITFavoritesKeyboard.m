//
//  LITFavoritesKeyboard.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITFavoritesKeyboard.h"

@implementation LITFavoritesKeyboard

@dynamic contents;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"favKeyboard";
}

- (NSString *)displayName
{
    return @"Favorites";
}

- (void)setDisplayName:(NSString *)displayName
{
    NSAssert(NO, @"Can't set display name for favs keyboard");
}

@end
