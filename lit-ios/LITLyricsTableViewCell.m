//
//  LITLyricsTableViewCell.m
//  lit-ios
//
//  Created by ioshero on 09/07/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITLyricsTableViewCell.h"
#import "LITAdjustableLabel.h"
#import "UIView+GradientBackground.h"
#import "LITTheme.h"
#import <ParseUI/PFImageView.h>

NSString *const kLITLyricsTableViewCellIdentifier = @"LITLyricsTableViewCell";
CGFloat const kLITLyricsCellHeight = 159.0f;

@interface LITLyricsTableViewCell ()

@property (weak, nonatomic) IBOutlet LITAdjustableLabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *gradientView;
@property (weak, nonatomic) IBOutlet PFImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelRightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *optionsButton;
@property (weak, nonatomic) IBOutlet UIButton *fullHeaderButton;

@end


@implementation LITLyricsTableViewCell

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
    [self.contentLabel setAdjustsFontSizeToFitFrame:YES];
    
    [self.gradientView setFrame:CGRectMake(self.gradientView.frame.origin.x, self.gradientView.frame.origin.y, [[UIScreen mainScreen] bounds].size.width, self.gradientView.frame.size.height)];
    
    [self.gradientView setupGradientBackgroundFromPoint:CGPointMake(0.0, 0.5)
                                       andStartingColor:[UIColor lit_lyricCellOrangeLightColor]
                                                toPoint:CGPointMake(1.0, 0.5)
                                          andFinalColor:[UIColor lit_lyricCellOrangeDarkColor]];
    
    [self.likesLabel setTextColor:[UIColor lit_coolGreyColor]];
    [self.likeButton setHidden:YES];
    
    self.userImageView.layer.cornerRadius = CGRectGetWidth(self.userImageView.frame)  / 2.0f;
    self.userImageView.layer.masksToBounds = YES;
    self.userImageView.contentMode = UIViewContentModeScaleAspectFill;
}


@end
