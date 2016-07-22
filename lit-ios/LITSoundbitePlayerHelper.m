
//
//  LITSoundbitePlayerHelper.m
//  lit-ios
//
//  Created by ioshero on 01/09/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITSoundbitePlayerHelper.h"
#import "LITBaseSoundbiteTableViewCell.h"
#import "LITSoundbite.h"
#import "LITSharedFileCache.h"
#import <VOXHistogramView/VOXHistogramControlView.h>
#import <Bolts/Bolts.h>

@interface LITSoundbitePlayerHelper ()

@property (weak, nonatomic) id<LITSoundbitePlayHosting> host;

@property (strong, nonatomic) NSMutableDictionary *audioFiles;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) id playerObserver;
@property (assign, nonatomic) NSInteger currentlyPlayingIndex;

@end

@implementation LITSoundbitePlayerHelper


#pragma mark - LITSoundbitePlayerController

- (instancetype)initWithSoundbitePlayerHosting:(id<LITSoundbitePlayHosting>)host
{
    self = [super init];
    if (self) {
        _currentlyPlayingIndex = -1;
        _host = host;
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

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.currentlyPlayingIndex) {
        [self.player pause];
        [self.player removeObserver:self forKeyPath:@"rate"];
        if(self.playerObserver) {
            [self.player removeTimeObserver:self.playerObserver];
        }
        self.player = nil;
        [((LITBaseSoundbiteTableViewCell *)cell).histogramControlView setPlaybackProgress:0.0];
        [((LITBaseSoundbiteTableViewCell *)cell).playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        self.currentlyPlayingIndex = -1;
    }
}

- (void)playButtonPressed:(UIButton *)playButton {
    if (playButton.tag == self.currentlyPlayingIndex) {
        //Pressed button on the same cell that was playing
        if (self.player.rate != 0) {
            [self.player pause];
            [playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        } else {
            [self.player play];
            [playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        }
    }
    else {
        if (self.player.rate != 0 && playButton.tag != self.currentlyPlayingIndex) {
            //Pressed play on another cell
            [self.player pause];
            LITBaseSoundbiteTableViewCell *soundbiteCell = (LITBaseSoundbiteTableViewCell *)[self.host.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentlyPlayingIndex inSection:0]];
            [soundbiteCell.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            [soundbiteCell.histogramControlView setPlaybackProgress:0.0];
        }
        //Play the sound
        [playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        if (self.player) {
            [self.player removeObserver:self forKeyPath:@"rate"];
            if(self.playerObserver) {
                [self.player removeTimeObserver:self.playerObserver];
            }
            LITBaseSoundbiteTableViewCell *soundbiteCell = (LITBaseSoundbiteTableViewCell *)[self.host.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentlyPlayingIndex inSection:0]];
            [soundbiteCell.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            [soundbiteCell.histogramControlView setPlaybackProgress:0.0];
        }
        self.playerObserver = nil;
        LITBaseSoundbiteTableViewCell *soundbiteCell = (LITBaseSoundbiteTableViewCell *)[self.host.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:playButton.tag inSection:0]];
        NSURL *audioFileURL = [self.audioFiles objectForKey:soundbiteCell.soundbiteId];
        self.player = [AVPlayer playerWithURL:audioFileURL];
        [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:NULL];
        self.playerObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(100, 1000) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            typeof(weakSelf) strongSelf = weakSelf;
            Float64 seconds = CMTimeGetSeconds(time);
            CGFloat playbackProgress = seconds / CMTimeGetSeconds(strongSelf.player.currentItem.asset.duration);
            LITBaseSoundbiteTableViewCell *soundbiteCell = (LITBaseSoundbiteTableViewCell *)[strongSelf.host.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:playButton.tag inSection:0]];
            NSCAssert([soundbiteCell isKindOfClass:[LITBaseSoundbiteTableViewCell class]], @"cell should be of class LITBaseSoundbiteTableViewCell");
            [soundbiteCell.histogramControlView setPlaybackProgress:playbackProgress];
        }];
        [self.player play];
        self.currentlyPlayingIndex = playButton.tag;
    }
}


- (void)getDataForSoundbite:(LITSoundbite *)soundbite atIndexPath:(NSIndexPath *)indexPath
        withCompletionBlock:(LITSoundbiteDataCompletionBlock)completionBlock
{
    NSURL *audioFileURL = [self.audioFiles objectForKey:soundbite.objectId];
    if (audioFileURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(audioFileURL, nil);
        });
    } else {
        if (self.useLocalCache) {
            [[soundbite retrieveColumnNameFromSharedCache:@"audio"] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                if (!task.error) {
                    [self.audioFiles setObject:task.result forKey:soundbite.objectId];
                    completionBlock(task.result, nil);
                } else {
                    completionBlock(nil, task.error);
                }
                return nil;
            }];
        } else {
            [soundbite.audio getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!error) {
                        NSURL *newAudioFileURL = [AVUtils PFFileCacheURLForContentName:soundbite.audio.name];
                        [self.audioFiles setObject:newAudioFileURL forKey:soundbite.objectId];
                        completionBlock(newAudioFileURL, nil);
                    } else {
                        completionBlock(nil, error);
                    }
                });
            }];
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

#pragma mark - KVO player
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (CMTIME_COMPARE_INLINE(self.player.currentTime, >=, self.player.currentItem.asset.duration)) {
        LITBaseSoundbiteTableViewCell *soundbiteCell = (LITBaseSoundbiteTableViewCell *)[self.host.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentlyPlayingIndex inSection:0]];
        [soundbiteCell.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self.player seekToTime:kCMTimeZero];
        [soundbiteCell.histogramControlView setPlaybackProgress:0];
        self.currentlyPlayingIndex = -1;
    }
}

@end
