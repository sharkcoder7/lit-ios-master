//
//  LITSoundbite.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITSoundbite.h"
#import "LITSong.h"
#import "LITKBSoundbiteCollectionViewCell.h"
#import "LITAdjustableLabel.h"
#import "ParseGlobals.h"
#import "LITSharedFileCache.h"

#ifndef LIT_EXTENSION
#import "LITBaseSoundbiteTableViewCell.h"
#import "LITSoundbiteTableViewCell.h"
#import <ParseUI/PFImageView.h>
#endif

#import <DateTools/NSDate+DateTools.h>
#import <Parse/PFObject+Subclass.h>
#import <Bolts/Bolts.h>

NSString *const kFirebaseSoundbiteDataKey    = @"data";

@interface LITSoundbite ()

@end


@implementation LITSoundbite
@dynamic    caption,
            user,
            song,
            video,
            tags,
            audio,
            image;


+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"soundbite";
}

#pragma mark - Helper for Cell update
#ifndef LIT_EXTENSION
+ (void)updateCell:(LITBaseSoundbiteTableViewCell *)tableCell withObject:(LITSoundbite *)soundbite
{
    tableCell.titleLabel.text = soundbite.caption;
    tableCell.soundbiteId = soundbite.objectId;
    if ([tableCell isKindOfClass:[LITSoundbiteTableViewCell class]]) {
        LITSoundbiteTableViewCell *songCell = (LITSoundbiteTableViewCell *)tableCell;
        
        int originalCounter = (int)[[soundbite valueForKey:kLITObjectLikesKey] integerValue];
        [songCell.likesLabel setText:[NSString stringWithFormat:@"%d",originalCounter]];
        
        [soundbite.user fetchIfNeededInBackgroundWithBlock:^(PFObject *user, NSError *error) {
            if ([user isKindOfClass:[PFUser class]]) {
                songCell.userLabel.text =  ((PFUser *)user).username;
                [songCell.userImageView setFile:user[@"picture"]];
                [songCell.userImageView loadInBackground];
            }
        }];
    }
}
#endif

+ (void)updateCollectionCell:(LITKBSoundbiteCollectionViewCell *)collectionCell
                  withObject:(LITSoundbite *)soundbite;
{
    [self updateCollectionCell:collectionCell withObject:soundbite tryLocalCache:NO];
}

+ (void)updateCollectionCell:(LITKBSoundbiteCollectionViewCell *)collectionCell
                  withObject:(LITSoundbite *)soundbite tryLocalCache:(BOOL)tryLocalCache
{
    [collectionCell.titleLabel setText:nil];
    [collectionCell.activityIndicator startAnimating];
    
    if (tryLocalCache) {
        [[soundbite fetchFromLocalDatastoreInBackground]
         continueWithExecutor:[BFExecutor mainThreadExecutor]
         withSuccessBlock:^id(BFTask *task) {
             LITSoundbite *theSoundbite = task.result;
             NSString *caption = theSoundbite.caption;
             NSLog(@"SoundBite - %@", caption);
             [collectionCell.titleLabel setText:caption];
             [[theSoundbite.image retrieveFromSharedCache]
              continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
                  [collectionCell.imageView setImage:[UIImage
                                                      imageWithContentsOfFile:((NSURL *)task.result).path]];
                  [collectionCell.activityIndicator stopAnimating];
                  collectionCell.cellIcon.hidden = NO;
                  return nil;
              }];
             collectionCell.objectId = theSoundbite.objectId;
             return nil;
         }];
    } else {
        [[soundbite fetchIfNeededInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask<__kindof PFObject *> * _Nonnull task) {
            LITSoundbite *theSoundbite = task.result;
            NSString *caption = theSoundbite.caption;
            NSLog(@"SoundBite - %@", caption);
            [collectionCell.titleLabel setText:caption];
            collectionCell.objectId = theSoundbite.objectId;
            [collectionCell.activityIndicator stopAnimating];
            collectionCell.cellIcon.hidden = NO;
            [collectionCell setNeedsDisplay];
            
            //#ifndef LIT_EXTENSION
            [theSoundbite.image getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                if (data && error == nil) {
                    UIImage *image = [UIImage imageWithData:data];
                    [collectionCell.imageView setImage:image];
                }
            }];
            //#endif
            
            return nil;
        }];
//        [soundbite fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//            NSString *caption = ((LITSoundbite *)object).caption;
//             NSLog(@"SoundBite - %@", caption);            
//            [collectionCell.titleLabel setText:caption];
////#ifndef LIT_EXTENSION
//            [soundbite.image getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
//                if (data && error == nil) {
//                    UIImage *image = [UIImage imageWithData:data];
//                    [collectionCell.imageView setImage:image];
//                }
//            }];
////#endif
//            collectionCell.objectId = ((LITSoundbite *)object).objectId;
//            [collectionCell.activityIndicator stopAnimating];
//        }];
    }
}

- (BFTask *)addToSharedCache
{
    NSMutableArray *tasks = [NSMutableArray array];
    [tasks addObject:[self saveColumnNameAtSharedCache:@"audio"]];
    [tasks addObject:[self saveColumnNameAtSharedCache:@"video"]];
    [tasks addObject:[self saveColumnNameAtSharedCache:@"image"]];
    return [BFTask taskForCompletionOfAllTasks:tasks];
}

- (BOOL)addToSharedCacheSync
{
    return [self saveColumnNameAtSharedCacheSync:@"audio"] &&
    [self saveColumnNameAtSharedCacheSync:@"video"] &&
    [self saveColumnNameAtSharedCacheSync:@"image"];
}

- (BOOL)removeFromSharedCacheWithError:(NSError **)error
{
    if (![self deleteColumnNameFromSharedCache:@"video" withError:error]) {
        NSLog(@"Error deleting item in keyboard: %@", [*error localizedDescription]);
        return NO;
    }
    if (![self deleteColumnNameFromSharedCache:@"audio" withError:error]) {
        NSLog(@"Error deleting item in keyboard: %@", [*error localizedDescription]);
        return NO;
    }
    if (![self deleteColumnNameFromSharedCache:@"image" withError:error]) {
        NSLog(@"Error deleting item in keyboard: %@", [*error localizedDescription]);
        return NO;
    }
    return YES;
}


@end
