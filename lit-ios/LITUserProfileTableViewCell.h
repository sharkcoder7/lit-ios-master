//
//  LITUserProfileTableViewCell.h
//  slit-ios
//
//  Created by ioshero on 09/07/2015.
//  Copyright (c) 2015 Slit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kLITUserProfileTableViewCellIdentifier;

@interface LITUserProfileTableViewCell : UITableViewCell

@property (weak, nonatomic, readonly) UIImageView *profileImageView;
@property (weak, nonatomic, readonly) UILabel *nameLabel;
@property (weak, nonatomic, readonly) UIButton *facebookButton;
@property (weak, nonatomic, readonly) UIButton *twitterButton;
@property (weak, nonatomic, readonly) UILabel *keyboardsLabel;

@end
