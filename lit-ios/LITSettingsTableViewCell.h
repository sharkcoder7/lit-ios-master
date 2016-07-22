//
//  LITSettingsTableViewCell.h
//  lit-ios
//
//  Created by Antonio Losada on 14/8/15.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kLITSettingsCellIdentifier;

@interface LITSettingsTableViewCell : UITableViewCell

@property (weak, nonatomic, readonly) UIImageView *iconImageView;
@property (weak, nonatomic, readonly) UILabel *titleLabel;
@property (weak, nonatomic, readonly) UIImageView *iconArrow;

@end
