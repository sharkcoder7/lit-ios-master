//
//  LITEmoji.m
//  lit-ios
//
//  Copyright © 2016 Lit Inc. All rights reserved.
//

#import "LITEmoji.h"
#import "ParseGlobals.h"
#import <Parse/PFObject+Subclass.h>
#import <DateTools/NSDate+DateTools.h>
#import <ParseUI/PFImageView.h>
#import <Bolts/Bolts.h>

@implementation LITEmoji

@dynamic emoji,
         emojiPreview,
         tags;

+ (void)load {
    [self registerSubclass];
}

+ (NSString*)parseClassName
{
    return kEmojiClassName;
}

+ (void)updateCollectionCell:(LITKBEmojiCollectionViewCell *)collectionCell
                  withObject:(LITEmoji *)emoji
{
    [self updateCollectionCell:collectionCell withObject:emoji tryLocalCache:NO];
}

+ (void)updateCollectionCell:(LITKBEmojiCollectionViewCell *)collectionCell
                  withObject:(LITEmoji *)emoji tryLocalCache:(BOOL)tryLocalCache
{
    id(^successBlock)(BFTask *) = ^id(BFTask *task) {
        if (task.error) {
            NSLog(@"There was an error: %@", task.error);
            return [BFTask taskWithError:task.error];
        }
        collectionCell.objectId = ((LITEmoji *)task.result).objectId;
        
        [emoji.emojiPreview getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            if (data && error == nil) {
                [collectionCell.emojiImageView setImage:[UIImage imageWithData:data]];
                [collectionCell.activityIndicator stopAnimating];
            }
        }];
        
        return nil;
    };
    
    [collectionCell.activityIndicator startAnimating];
    [collectionCell.emojiImageView setImage:nil];
    [collectionCell setNeedsDisplay];
    
    if (tryLocalCache) {
        [[emoji fetchFromLocalDatastoreInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor]
                                                         withSuccessBlock:successBlock];
    } else {
        [[emoji fetchIfNeededInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor]
                                               withSuccessBlock:successBlock];
    }
}

@end
