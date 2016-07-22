//
//  DataKeeper.h
//  LITKeyboard
//
//  Copyright © 2016 LIT, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataKeeper : NSObject

+ (DataKeeper*)sharedInstance;

@property (nonatomic, strong) NSMutableArray *arrayLyrics;
@property (nonatomic, strong) NSMutableArray *arraySoundBites;
@property (nonatomic, strong) NSMutableArray *arrayDubs;
@property (nonatomic, strong) NSMutableArray *arrayTags;

@end
