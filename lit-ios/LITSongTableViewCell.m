//
//  LITSongTableViewCell.m
//  lit-ios
//
//  Created by ioshero on 25/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITSongTableViewCell.h"

NSString *const kLITSongTableViewCellIdentifier = @"LITSongTableViewCell";

@interface LITSongTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *songTitleLabel;

@end


@implementation LITSongTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
