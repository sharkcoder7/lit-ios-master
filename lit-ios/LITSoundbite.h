//
//  LITSoundbite.h
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITTaggableContent.h"
#import "LITVideoObject.h"
#import "LITSong.h"
#import <Parse/PFObject.h>
#import <Parse/PFFile.h>
#import <Parse/PFSubclassing.h>
#import <Foundation/Foundation.h>

extern NSString *const kFirebaseSoundbiteDataKey;

@class LITBaseSoundbiteTableViewCell;
@class LITKBSoundbiteCollectionViewCell;
@interface LITSoundbite : PFObject <PFSubclassing, LITTaggableContent, LITVideoObject>

@property (strong, nonatomic) NSString *caption;
@property (strong, nonatomic) LITSong *song;
@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) PFFile *audio;
@property (strong, nonatomic) PFFile *image;

#ifndef LIT_EXTENSION
+ (void)updateCell:(LITBaseSoundbiteTableViewCell *)tableCell withObject:(LITSoundbite *)soundbite;
#endif

+ (void)updateCollectionCell:(LITKBSoundbiteCollectionViewCell *)collectionCell
                  withObject:(LITSoundbite *)soundbite;
+ (void)updateCollectionCell:(LITKBSoundbiteCollectionViewCell *)collectionCell
                  withObject:(LITSoundbite *)soundbite tryLocalCache:(BOOL)tryLocalCache;

- (BFTask *)addToSharedCache;
- (BOOL)addToSharedCacheSync;
- (BOOL)removeFromSharedCacheWithError:(NSError **)error;

@end
