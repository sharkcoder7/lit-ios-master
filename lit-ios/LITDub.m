//
//  LITDub.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITDub.h"
#import "LITDubTableViewCell.h"
#import "LITKBDubCollectionViewCell.h"
#import "LITAdjustableLabel.h"
#import "ParseGlobals.h"
#import "LITSharedFileCache.h"

#import <Parse/PFObject+Subclass.h>
#import <ParseUI/PFImageView.h>
#import <Parse/PFUser.h>
#import <DateTools/DateTools.h>
#import <Bolts/Bolts.h>

NSString *const kLITDubDataKey         = @"data";
NSString *const kLITDubTagsKey         = @"tags";
NSString *const kLITDubThumbnailsKey   = @"thumbnails";

@interface LITDub ()

//@property (strong, nonatomic) NSDictionary *jsonRepresentation;


@end


@implementation LITDub
@dynamic    caption,
            user,
            tags,
            snapshot,
            soundbite,
            video;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"dub";
}

+ (void)updateCell:(LITDubTableViewCell *)tableCell withObject:(LITDub *)dub
{
//    tableCell.titleLabel.text = dub.caption;
    [dub.user fetchIfNeededInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        if ([user isKindOfClass:[PFUser class]]) {
            tableCell.titleLabel.text =  ((PFUser *)user).username;
            [tableCell.userImageView setFile:[user objectForKey:@"picture"]];
            [tableCell.userImageView loadInBackground];
        }
    }];
    
    tableCell.dubVideo = dub.video;
    [tableCell.previewImageView setFile:dub.snapshot];
    [tableCell.previewImageView loadInBackground];
    
    int originalCounter = (int)[[dub valueForKey:kLITObjectLikesKey] integerValue];
    [tableCell.likesLabel setText:[NSString stringWithFormat:@"%d",originalCounter]];

    
    [[[[PFUser currentUser] objectForKey:kUserFavKeyboardKey] fetchIfNeededInBackground] continueWithBlock:^id(BFTask *task) {
        PFObject *favKeyboard = task.result;
        if ([[favKeyboard objectForKey:kFavKeyboardContentsKey] containsObject:dub]) {
            [tableCell.likeButton setImage:[UIImage imageNamed:@"likeButtonFilled"] forState:UIControlStateNormal];
        } else {
            [tableCell.likeButton setImage:[UIImage imageNamed:@"likeButton"] forState:UIControlStateNormal];
        }
        return nil;
    }];
}
+ (void)updateCollectionCell:(LITKBDubCollectionViewCell *)collectionCell
                  withObject:(LITDub *)dub
{
    [self updateCollectionCell:collectionCell withObject:dub tryLocalCache:NO];
}

+ (void)updateCollectionCell:(LITKBDubCollectionViewCell *)collectionCell
                  withObject:(LITDub *)dub tryLocalCache:(BOOL)tryLocalCache
{
    [collectionCell.titleLabel setText:nil];
    [collectionCell.activityIndicator startAnimating];
    if (tryLocalCache) {
        [[dub fetchFromLocalDatastoreInBackground]
         continueWithExecutor:[BFExecutor mainThreadExecutor]
         withSuccessBlock:^id(BFTask *task) {
             LITDub *theDub = task.result;
             NSString *caption = theDub.caption;
             NSLog(@"Dub - %@", caption);
             [collectionCell.titleLabel setText:caption];
             [collectionCell.activityIndicator stopAnimating];
             collectionCell.cellIcon.hidden = NO;
             [[theDub.snapshot retrieveFromSharedCache]
              continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
                  [collectionCell.imageView setImage:[UIImage
                                                      imageWithContentsOfFile:((NSURL *)task.result).path]];
                return nil;
              }];
             collectionCell.objectId = dub.objectId;
             collectionCell.dubVideo = dub.video;
             collectionCell.useLocalCache = YES;
             return nil;
        }];
    } else {
        [[dub fetchIfNeededInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask<__kindof PFObject *> * _Nonnull task) {
            LITDub *dub = task.result;
            NSString *caption = dub.caption;
            NSLog(@"Dub - %@", caption);
            [collectionCell.titleLabel setText:dub.caption];
            collectionCell.objectId = dub.objectId;
            collectionCell.dubVideo = dub.video;
            collectionCell.cellIcon.hidden = NO;
            [collectionCell.imageView setImage:nil];
            [collectionCell setNeedsDisplay];
            
            [dub.snapshot getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                if (data && error == nil)
                    [collectionCell.imageView setImage:[UIImage imageWithData:data]];
                [collectionCell.activityIndicator stopAnimating];                
            }];
            
            return nil;
        }];
    }
}

- (BFTask *)addToSharedCache
{
    NSMutableArray *tasks = [NSMutableArray array];
    [tasks addObject:[self saveColumnNameAtSharedCache:@"video"]];
    [tasks addObject:[self saveColumnNameAtSharedCache:@"snapshot"]];
    return [BFTask taskForCompletionOfAllTasks:tasks];
}

- (BOOL)addToSharedCacheSync
{
    return [self saveColumnNameAtSharedCacheSync:@"video"] &&
    [self saveColumnNameAtSharedCacheSync:@"snapshot"];
}

- (BOOL)removeFromSharedCacheWithError:(NSError **)error
{
    if (![self deleteColumnNameFromSharedCache:@"video" withError:error]) {
        NSLog(@"Error deleting item in keyboard: %@", [*error localizedDescription]);
        return NO;
    }
    if (![self deleteColumnNameFromSharedCache:@"snapshot" withError:error]) {
        NSLog(@"Error deleting item in keyboard: %@", [*error localizedDescription]);
        return NO;
    }
    return YES;
}



@end
