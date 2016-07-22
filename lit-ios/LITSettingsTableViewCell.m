//
//  LITSettingsTableViewCell.m
//  lit-ios
//
//  Created by Antonio Losada on 14/8/15.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITSettingsTableViewCell.h"

NSString *const kLITSettingsCellIdentifier = @"LITSettingsCell";

@interface LITSettingsTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconArrow;


@end

@implementation LITSettingsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
