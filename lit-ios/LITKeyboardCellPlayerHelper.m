//
//  LITKeyboardCellPlayerHelper.m
//  lit-ios
//
//  Created by Antonio Losada on 7/9/15.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITKeyboardCellPlayerHelper.h"
#import "LITSoundbite.h"
#import "LITDub.h"
#import "LITSharedFileCache.h"
#import "SharkfoodMuteSwitchDetector.h"
#import <Bolts/Bolts.h>

@interface LITKeyboardCellPlayerHelper ()

@property (strong, nonatomic) NSMutableDictionary *audioFiles;
@property (strong, nonatomic) NSMutableDictionary *videoFiles;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) id playerObserver;
@property (assign, nonatomic) NSIndexPath *currentlyPlayingIndexPath;

@end

@implementation LITKeyboardCellPlayerHelper

- (instancetype)initWithKeyboardControllerHosting:(UIViewController *)host {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    if (self.player) {
        @try {
            [self.player removeObserver:self forKeyPath:@"rate"];
            if (self.playerObserver) {
                [self.player removeTimeObserver:self.playerObserver];
                self.playerObserver = nil;
            }
        }
        @catch (NSException *exception) {
            if (exception) {
                NSLog(@"Tried to remove observer for player when no one was registered");
            }
        }
    }
}

- (void)playSoundbite:(LITSoundbite *)soundbite
          atIndexPath:(NSIndexPath *)indexPath
   withCollectionView:(UICollectionView *)collectionView
{
    if ([indexPath compare:self.currentlyPlayingIndexPath] == NSOrderedSame) {
        //Pressed button on the same cell that was playing
        if (self.player.rate != 0) {
            [self.player pause];
        } else {
            [self.player play];
        }
    }
    else {
        if (self.player.rate != 0 && [indexPath compare:self.currentlyPlayingIndexPath] !=  NSOrderedSame) {
            //Pressed play on another cell
            [self.player pause];
        }
        //Play the sound
        if (self.player) {
            [self.player removeObserver:self forKeyPath:@"rate"];
            if(self.playerObserver) {
                [self.player removeTimeObserver:self.playerObserver];
            }
        }
        self.playerObserver = nil;
        NSURL *audioFileURL = [self.audioFiles objectForKey:soundbite.objectId];
        self.player = [AVPlayer playerWithURL:audioFileURL];
        [self.player addObserver:self forKeyPath:@"rate" options:0 context:NULL];
        [self.player play];
        self.currentlyPlayingIndexPath = indexPath;
    }

}

- (void)getDataForSoundbite:(LITSoundbite *)soundbite
                atIndexPath:(NSIndexPath *)indexPath
        withCompletionBlock:(LITKeyboardCellDataCompletionBlock)completionBlock
{
    [self getDataForSoundbite:soundbite
                  atIndexPath:indexPath
          withCompletionBlock:completionBlock
               trySharedCache:NO];
}

- (void)getDataForSoundbite:(LITSoundbite *)soundbite
                atIndexPath:(NSIndexPath *)indexPath
        withCompletionBlock:(LITKeyboardCellDataCompletionBlock)completionBlock
             trySharedCache:(BOOL)trySharedCache
{
    NSURL *audioFileURL = [self.audioFiles objectForKey:soundbite.objectId];
    if (!audioFileURL) {
        if (trySharedCache) {
            [[soundbite retrieveColumnNameFromSharedCache:@"audio"]
             continueWithExecutor:[BFExecutor mainThreadExecutor]
             withBlock:^id(BFTask *task) {
                 [self.audioFiles setObject:task.result forKey:soundbite.objectId];
                 completionBlock(nil);
                 return nil;
            }];
        } else {
            [soundbite.audio getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!error) {
                        NSURL *newAudioFileURL = [AVUtils PFFileCacheURLForContentName:soundbite.audio.name];
                        [self.audioFiles setObject:newAudioFileURL forKey:soundbite.objectId];
                        completionBlock(nil);
                    } else {
                        completionBlock(error);
                    }
                });
            }];
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(nil);
        });
    }
}

- (void)getDataForDub:(LITDub *)dub
                atIndexPath:(NSIndexPath *)indexPath
        withCompletionBlock:(LITKeyboardCellDataCompletionBlock)completionBlock
{
    NSURL *videoFileURL = [self.videoFiles objectForKey:dub.objectId];
    if (!videoFileURL) {
        [dub.video getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    NSURL *newVideoFileURL = [AVUtils PFFileCacheURLForContentName:dub.video.name];
                    [self.videoFiles setObject:newVideoFileURL forKey:dub.objectId];
                    completionBlock(nil);
                } else {
                    completionBlock(error);
                }
            });
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(nil);
        });
    }
}

#pragma mark - KVO player
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (CMTIME_COMPARE_INLINE(self.player.currentTime, ==, self.player.currentItem.asset.duration)) {
        [self.player seekToTime:kCMTimeZero];
        self.currentlyPlayingIndexPath = nil;
    }
    
    if (self.silentBlock) {
        if (self.player.rate == 0) {
            self.switchDetector = nil;
            self.silentBlock = nil;
        } else {
            if (!self.switchDetector) {
                self.switchDetector = [[SharkfoodMuteSwitchDetector alloc] init];
                self.switchDetector.silentNotify = self.silentBlock;
            }
        }
    }
}


- (NSMutableDictionary *)audioFiles
{
    if (!_audioFiles) {
        _audioFiles = [NSMutableDictionary dictionary];
    }
    return _audioFiles;
}

- (NSMutableDictionary *)videoFiles
{
    if (!_videoFiles) {
        _videoFiles= [NSMutableDictionary dictionary];
    }
    return _videoFiles;
}

@end
