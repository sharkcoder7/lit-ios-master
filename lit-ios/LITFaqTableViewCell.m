//
//  LITFaqTableViewCell.m
//  lit-ios
//
//  Created by Antonio Losada on 8/10/15.
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import "LITFaqTableViewCell.h"

@implementation LITFaqTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)didMoveToSuperview
{
    [self layoutIfNeeded];
}
@end
