//
//  LITEmoji.h
//  lit-ios
//
//  Copyright © 2016 Lit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LITTaggableContent.h"
#import "LITKBEmojiCollectionViewCell.h"
#import <Parse/PFSubclassing.h>
#import <Parse/PFObject.h>
#import <Parse/PFFile.h>

@class LITKBEmojiCollectionViewCell;

@interface LITEmoji : PFObject <PFSubclassing, LITTaggableContent>

@property (strong, nonatomic) PFFile *emoji;
@property (strong, nonatomic) PFFile *emojiPreview;

+ (void)updateCollectionCell:(LITKBEmojiCollectionViewCell *)collectionCell
                  withObject:(LITEmoji *)emoji;
+ (void)updateCollectionCell:(LITKBEmojiCollectionViewCell *)collectionCell
                  withObject:(LITEmoji *)emoji tryLocalCache:(BOOL)tryLocalCache;

@end
