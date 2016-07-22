//
//  LITDub.h
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITTaggableContent.h"
#import "LITVideoObject.h"
#import <Parse/PFSubclassing.h>
#import <Parse/PFObject.h>
#import <Foundation/Foundation.h>

extern NSString *const kLITDubDataKey;
extern NSString *const kLITDubTagsKey;
extern NSString *const kLITDubThumbnailsKey;

@class LITDubTableViewCell;
@class LITSoundbite;
@class LITKBDubCollectionViewCell;
@interface LITDub : PFObject <PFSubclassing, LITTaggableContent, LITVideoObject>

@property (strong, nonatomic) NSString *caption;
@property (strong, nonatomic) LITSoundbite *soundbite;
@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) PFFile *snapshot;

+ (void)updateCell:(LITDubTableViewCell *)tableCell withObject:(LITDub *)dub;
+ (void)updateCollectionCell:(LITKBDubCollectionViewCell *)collectionCell
                  withObject:(LITDub *)dub;
+ (void)updateCollectionCell:(LITKBDubCollectionViewCell *)collectionCell
                  withObject:(LITDub *)dub tryLocalCache:(BOOL)tryLocalCache;

- (BFTask *)addToSharedCache;
- (BOOL)addToSharedCacheSync;
- (BOOL)removeFromSharedCacheWithError:(NSError **)error;

@end
