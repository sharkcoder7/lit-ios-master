//
//  LITSongTableViewCell.m
//  slit-ios
//
//  Created by ioshero on 07/07/2015.
//  Copyright (c) 2015 Slit Inc. All rights reserved.
//

#import "LITTheme.h"
#import "LITSoundbiteTableViewCell.h"
#import "LITSoundbite.h"
#import <ParseUI/PFImageView.h>
#import <VOXHistogramView/VOXHistogramControlView.h>
#import <VOXHistogramView/VOXHistogramRenderingConfiguration.h>

NSString *const kLITSoundbiteTableViewCellIdentifier = @"LITSongTableViewCell";
CGFloat const kLITSoundbiteCellHeight = 172.0f;

@interface LITSoundbiteTableViewCell () <VOXHistogramControlViewDelegate>

@property (weak, nonatomic) IBOutlet PFImageView *userImageView;
@property (weak ,nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *fullHeaderButton;

@end


@implementation LITSoundbiteTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel.text = @"";
        self.userLabel.text = @"";
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.userLabel.text = @"";
    [self.userLabel setTextColor:[UIColor lit_darkGreyColor]];
    [self.likesLabel setTextColor:[UIColor lit_coolGreyColor]];
    [self.likeButton setHidden:YES];
    
    self.userImageView.layer.cornerRadius = CGRectGetWidth(self.userImageView.frame)  / 2.0f;
    self.userImageView.layer.masksToBounds = YES;
    self.userImageView.contentMode = UIViewContentModeScaleAspectFill;
}

@end
