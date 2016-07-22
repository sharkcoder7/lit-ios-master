//
//  LITDubTableViewCell.h
//  lit-ios
//
//  Created by ioshero on 28/07/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

@import UIKit;

#import "PFImageView.h"

extern NSString *const kLITDubTableViewCellIdentifier;
extern CGFloat kLITDubCellHeight;

@class LITDub, PFImageView, PFFile;
@interface LITDubTableViewCell : UITableViewCell

@property (readonly, weak, nonatomic) UIView *headerView;

@property (readonly, weak, nonatomic) UILabel *titleLabel;
@property (readonly, weak, nonatomic) UIButton *playButton;
@property (readonly, weak, nonatomic) UILabel *likesLabel;
@property (readonly, weak, nonatomic) UIButton *optionsButton;

@property (readonly, weak, nonatomic) UIButton *likeButton;
@property (readonly, weak, nonatomic) UIButton *addButton;
@property (readonly, weak, nonatomic) UIButton *fullHeaderButton;

@property (readonly, weak, nonatomic) PFImageView *userImageView;
@property (readonly, weak, nonatomic) PFImageView *previewImageView;

@property (strong, nonatomic) PFFile *dubVideo;

@end
