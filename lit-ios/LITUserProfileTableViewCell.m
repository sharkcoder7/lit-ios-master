//
//  LITUserProfileTableViewCell.m
//  slit-ios
//
//  Created by ioshero on 09/07/2015.
//  Copyright (c) 2015 Slit Inc. All rights reserved.
//

#import "LITUserProfileTableViewCell.h"

NSString *const kLITUserProfileTableViewCellIdentifier = @"LITUserProfileTableViewCell";

@interface LITUserProfileTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UILabel *keyboardsLabel;

@end


@implementation LITUserProfileTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.nameLabel.text = @"User Full Name";
        [self.facebookButton setEnabled:NO];
        [self.twitterButton setEnabled:NO];
        [self.keyboardsLabel setText:@"0 Keyboards"];
    }
    return self;
}

@end
