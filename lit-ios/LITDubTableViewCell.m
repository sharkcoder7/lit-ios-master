//
//  LITDubTableViewCell.m
//  lit-ios
//
//  Created by ioshero on 28/07/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITDubTableViewCell.h"
#import "LITDub.h"
#import "LITTheme.h"
#import "AVUtils.h"
#import "SharkfoodMuteSwitchDetector.h"
#import <Parse/PFFile.h>
#import <ParseUI/PFImageView.h>

NSString *const kLITDubTableViewCellIdentifier = @"LITDubTableViewCell";
CGFloat kLITDubCellHeight;

@interface LITDubTableViewCell () {
    BOOL _shouldAnimate;
    NSUInteger _animationIndex;
    __block NSMutableArray *_imagesArray;
    AVPlayer *_player;
    AVPlayerItem *_playerItem;
    AVPlayerLayer *_playerLayer;
}

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet PFImageView *userImageView;
@property (weak, nonatomic) IBOutlet PFImageView *previewImageView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *optionsButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *fullHeaderButton;
@property (weak, nonatomic) IBOutlet UIImageView *speakerImageView;

@property (assign, nonatomic, getter=isReady) BOOL ready;
@property (assign, nonatomic) BOOL shouldAnimate;
@property (assign, nonatomic, getter=isAnimating) BOOL animating;
@property (strong, nonatomic) NSTimer *animationTimer;

@property (strong, nonatomic) SharkfoodMuteSwitchDetector *switchDetector;

@end


@implementation LITDubTableViewCell

+ (void)load
{
    kLITDubCellHeight = CGRectGetWidth([UIScreen mainScreen].bounds) + 54.0f + 15.0f;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)dealloc {
    @try {
        [_player removeObserver:self forKeyPath:@"rate"];
    }
    @catch (NSException *exception) {
        //no-op
    }
}

- (void)prepareForReuse
{
    [self.activityIndicator setHidden:YES];
    [self.overlayView setHidden:NO];
    [self.previewImageView setImage:nil];
    if (_player.rate) {
        self.switchDetector = nil;
        [_playerLayer removeFromSuperlayer];
        _playerLayer = nil;
        [self.playButton setHidden:NO];
        [_player removeObserver:self forKeyPath:@"rate"];
        _player = nil;
    }
    [super prepareForReuse];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.activityIndicator setHidesWhenStopped:NO];
    [self.activityIndicator setHidden:YES];
    
    [self.likesLabel setTextColor:[UIColor lit_coolGreyColor]];
    [self.likeButton setHidden:YES];
    
    self.userImageView.layer.cornerRadius = CGRectGetWidth(self.userImageView.frame)  / 2.0f;
    self.userImageView.layer.masksToBounds = YES;
    self.userImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.speakerImageView setHidden:YES];
}

- (IBAction)playButtonTapped:(UIButton *)sender
{
    if (self.dubVideo.url) {
        _playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.dubVideo.url]];
        _player = [AVPlayer playerWithPlayerItem:_playerItem];
        [_player addObserver:self forKeyPath:@"rate" options:0 context:NULL];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        [_playerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        _playerLayer.frame = self.previewImageView.bounds;
        [self.previewImageView.layer addSublayer:_playerLayer];
        [self.playButton setHidden:YES];
        [self.overlayView setHidden:YES];
        [self.activityIndicator setHidden:NO];
        [self.activityIndicator startAnimating];

        [_player play];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == _player && [keyPath isEqualToString:@"rate"]) {
        if (_player.rate == 0) {
            if (CMTimeGetSeconds(_playerItem.duration) != CMTimeGetSeconds(_playerItem.currentTime) &&
                !_playerItem.isPlaybackLikelyToKeepUp) {
                //stalled
                [self.activityIndicator startAnimating];
                [self.activityIndicator setHidden:NO];
                [self performSelector:@selector(_playVideo) withObject:nil afterDelay:0.4];
            } else {
                [self.overlayView setHidden:NO];
                [self.playButton setHidden:NO];
                self.switchDetector = nil;
                [self.speakerImageView setHidden:YES];
                [self.speakerImageView setHighlighted:NO];
                [_playerLayer removeFromSuperlayer];
                _playerLayer = nil;
                [_player removeObserver:self forKeyPath:@"rate"];
                _player = nil;
            }
        } else if (_player.rate != 0) {
            if (_player.status == AVPlayerStatusReadyToPlay) {
                [self.activityIndicator stopAnimating];
                [self.activityIndicator setHidden:YES];
                [self.speakerImageView setHidden:NO];
                __weak typeof(self) weakSelf = self;
                self.switchDetector = [[SharkfoodMuteSwitchDetector alloc] init];
                self.switchDetector.silentNotify = ^(BOOL silent){
                    [weakSelf.speakerImageView setHighlighted:silent];
                };
            }
        }
    }
}

- (void)_playVideo
{
    [_player play];
}



@end
