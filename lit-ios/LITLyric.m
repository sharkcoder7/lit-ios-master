//
//  LITLyric.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITLyric.h"
#import "LITAdjustableLabel.h"
#import "LITKBLyricCollectionViewCell.h"
#import "LITSimpleLyricsTableViewCell.h"
#import "ParseGlobals.h"
#import <Parse/PFObject+Subclass.h>
#import <DateTools/NSDate+DateTools.h>
#import <ParseUI/PFImageView.h>
#import <Bolts/Bolts.h>


@interface LITLyric ()


@end

@implementation LITLyric
@dynamic    user,
            song,
            text,
            tags;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"lyric";
}

#pragma mark - Helper for Cell update
+ (void)updateCell:(LITLyricsTableViewCell *)tableCell withObject:(LITLyric *)lyric;
{
    [lyric.user fetchIfNeededInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        if ([user isKindOfClass:[PFUser class]]) {
            tableCell.userLabel.text =  ((PFUser *)user).username;
            [tableCell.userImageView setFile:[user objectForKey:@"picture"]];
            [tableCell.userImageView loadInBackground];
        }
    }];
    
    tableCell.contentLabel.text = lyric.text;
    
    int originalCounter = (int)[[lyric valueForKey:kLITObjectLikesKey] integerValue];
    [tableCell.likesLabel setText:[NSString stringWithFormat:@"%d",originalCounter]];

}

+ (void)updateSimpleCell:(LITSimpleLyricsTableViewCell *)tableCell withObject:(LITLyric *)lyric
{
    tableCell.lyricsLabel.text = lyric.text;
}

+ (void)updateCollectionCell:(LITKBLyricCollectionViewCell *)collectionCell
                  withObject:(LITLyric *)lyric
{
    [self updateCollectionCell:collectionCell withObject:lyric tryLocalCache:NO];
}

+ (void)updateCollectionCell:(LITKBLyricCollectionViewCell *)collectionCell
                  withObject:(LITLyric *)lyric tryLocalCache:(BOOL)tryLocalCache
{
    id(^successBlock)(BFTask *) = ^id(BFTask *task) {
        NSLog(@"%@", lyric.text);        
        if (task.error) {
            NSLog(@"There was an error: %@", task.error);
            return [BFTask taskWithError:task.error];
        }
        [collectionCell.titleLabel setText:((LITLyric *)task.result).text];
        collectionCell.objectId = ((LITLyric *)task.result).objectId;
        [collectionCell.activityIndicator stopAnimating];
        return nil;
    };
    
    [collectionCell.titleLabel setText:nil];
    [collectionCell.activityIndicator startAnimating];
    [collectionCell setNeedsDisplay];
    
    if (tryLocalCache) {
        [[lyric fetchFromLocalDatastoreInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor]
                                                         withSuccessBlock:successBlock];
    } else {
        [[lyric fetchIfNeededInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor]
                                               withSuccessBlock:successBlock];
    }
}



@end
