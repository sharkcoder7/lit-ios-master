//
//  LITKBDubCollectionViewCell.m
//  lit-ios
//
//  Created by ioshero on 12/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITKBDubCollectionViewCell.h"
#import "LITAdjustableLabel.h"
#import "AVUtils.h"
#import "UIView+BlurEffect.h"
#import "LITSharedFileCache.h"
#import "SharkfoodMuteSwitchDetector.h"
#import <Parse/PFFile.h>
#import <ParseUI/PFImageView.h>
#import <Bolts/Bolts.h>


NSString *const kLITKBDubCollectionViewCellIdentifier = @"LITKBDubCollectionViewCell";

@interface LITKBDubCollectionViewCell () {
    BOOL _blurSet;
    AVPlayer *_player;
    AVPlayerItem *_playerItem;
    AVPlayerLayer *_playerLayer;
}

@property (weak, nonatomic) IBOutlet LITAdjustableLabel *titleLabel;
@property (weak, nonatomic) IBOutlet PFImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property (weak, nonatomic) IBOutlet UIImageView *cellIcon;

@end

@implementation LITKBDubCollectionViewCell
@synthesize removeButton;

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.titleLabel setAdjustsFontSizeToFitFrame:YES];
//    [self.activityIndicator setHidden:YES];
}

- (void)prepareForReuse
{
//    [self.activityIndicator setHidden:YES];
    [self.imageView setImage:nil];
    [self.overlayView setHidden:NO];
    if (_player.rate != 0) {
        self.switchDetector = nil;
        self.silentBlock = nil;
        [_playerLayer removeFromSuperlayer];
        _playerLayer = nil;
        [_player removeObserver:self forKeyPath:@"rate"];
        _player = nil;
    }
    [super prepareForReuse];
    
}

- (void)playVideo
{
    if (self.useLocalCache) {
        [[self.dubVideo retrieveFromSharedCache]
        continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
            _playerItem = [AVPlayerItem playerItemWithURL:task.result];
            _player = [AVPlayer playerWithPlayerItem:_playerItem];
            [_player addObserver:self forKeyPath:@"rate" options:0 context:NULL];
            _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
            _playerLayer.frame = self.imageView.bounds;
            [self.imageView.layer addSublayer:_playerLayer];
            [self.overlayView setHidden:YES];
            [self.activityIndicator setHidden:NO];
            [self.activityIndicator startAnimating];
            
            [_player play];
            return nil;
        }];
    } else {
        if (self.dubVideo.url) {
            _playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.dubVideo.url]];
            _player = [AVPlayer playerWithPlayerItem:_playerItem];
            [_player addObserver:self forKeyPath:@"rate" options:0 context:NULL];
            _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
            _playerLayer.frame = self.imageView.bounds;
            [self.imageView.layer addSublayer:_playerLayer];
            [self.overlayView setHidden:YES];
            NSLog(@"Play video: will set hidden NO");
            [self.activityIndicator setHidden:NO];
            [self.activityIndicator startAnimating];
            
            [_player play];
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == _player && [keyPath isEqualToString:@"rate"]) {
        if (_player.rate == 0) {
            if (CMTimeGetSeconds(_playerItem.duration) != CMTimeGetSeconds(_playerItem.currentTime) &&
                !_playerItem.isPlaybackLikelyToKeepUp) {
                //stalled
                NSLog(@"Observe rate is %f: will set hidden NO", _player.rate);
                [self.activityIndicator setHidden:NO];
                [self.activityIndicator startAnimating];
                [self performSelector:@selector(_playVideo) withObject:nil afterDelay:0.4];
            } else {
                [self.overlayView setHidden:NO];
                self.switchDetector = nil;
                self.silentBlock = nil;
                [_playerLayer removeFromSuperlayer];
                _playerLayer = nil;
                [_player removeObserver:self forKeyPath:@"rate"];
                _player = nil;
            }
        } else if (_player.rate != 0) {
            NSLog(@"Time: %f", CMTimeGetSeconds(_player.currentTime));
            if (_player.status == AVPlayerStatusReadyToPlay) {
                [self.activityIndicator stopAnimating];
                NSLog(@"Observe rate is %f: will set hidden YES", _player.rate);
                [self.activityIndicator setHidden:YES];
                if (!self.switchDetector) {
                    self.switchDetector = [[SharkfoodMuteSwitchDetector alloc] init];
                    self.switchDetector.silentNotify = self.silentBlock;
                }
            }
        }
    }
}

- (void)_playVideo
{
    [_player play];
}

@end
