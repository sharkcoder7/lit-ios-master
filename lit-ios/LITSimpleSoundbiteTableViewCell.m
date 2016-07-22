//
//  LITSimpleSongTableViewCell.m
//  lit-ios
//
//  Created by ioshero on 19/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITSimpleSoundbiteTableViewCell.h"
#import "LITTheme.h"
#import "AVUtils.h"
#import <EZAudio/EZAudioFile.h>
#import <Parse/PFFile.h>
#import <VOXHistogramView/VOXHistogramControlView.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerItem.h>
#import <AVFoundation/AVAsset.h>

NSString *const kLITSimpleSoundbiteTableViewCellIdentifier = @"LITSimpleSongTableViewCell";
CGFloat const kLITSimpleSoundbiteCellHeight = 70.0f;

@implementation LITSimpleSoundbiteTableViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end
