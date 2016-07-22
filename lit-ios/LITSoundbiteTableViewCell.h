//
//  LITSongTableViewCell.h
//  slit-ios
//
//  Created by ioshero on 07/07/2015.
//  Copyright (c) 2015 Slit Inc. All rights reserved.
//

#import "LITBaseSoundbiteTableViewCell.h"
#import <UIKit/UIKit.h>

extern NSString *const kLITSoundbiteTableViewCellIdentifier;
extern CGFloat const kLITSoundbiteCellHeight;

@class LITSoundbite, PFImageView;
@interface LITSoundbiteTableViewCell : LITBaseSoundbiteTableViewCell

@property (readonly, weak, nonatomic) PFImageView *userImageView;
@property (readonly, weak, nonatomic) UILabel *userLabel;
@property (readonly, weak, nonatomic) UILabel *likesLabel;
@property (readonly, weak, nonatomic) UIButton *likeButton;
@property (readonly, weak, nonatomic) UIButton *addButton;
@property (readonly, weak, nonatomic) UIButton *fullHeaderButton;

@property (strong, nonatomic) NSDate *updatedDate;


@end
