//
//  LITLyricsTableViewCell.h
//  lit-ios
//
//  Created by ioshero on 09/07/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kLITLyricsTableViewCellIdentifier;
extern CGFloat const kLITLyricsCellHeight;

@class PFImageView,LITAdjustableLabel;
@interface LITLyricsTableViewCell : UITableViewCell

@property (weak, nonatomic, readonly) LITAdjustableLabel *contentLabel;
@property (weak, nonatomic, readonly) PFImageView *userImageView;
@property (weak, nonatomic, readonly) UILabel *userLabel;
@property (weak, nonatomic, readonly) UILabel *likesLabel;
@property (weak, nonatomic, readonly) UIButton *likeButton;
@property (weak, nonatomic, readonly) UIButton *addButton;
@property (weak, nonatomic, readonly) UIButton *optionsButton;
@property (readonly, weak, nonatomic) UIButton *fullHeaderButton;

@end
