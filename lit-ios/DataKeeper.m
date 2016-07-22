//
//  DataKeeper.m
//  LITKeyboard
//
//  Copyright © 2016 LIT, Inc. All rights reserved.
//

#import "DataKeeper.h"

@implementation DataKeeper

+ (DataKeeper*)sharedInstance
{
    static DataKeeper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DataKeeper alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.arrayDubs = [NSMutableArray array];
        self.arrayLyrics = [NSMutableArray array];
        self.arraySoundBites = [NSMutableArray array];
        self.arrayTags = [NSMutableArray array];
    }
    
    return self;
}

@end
