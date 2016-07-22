//
//  LITSimpleLyricsTableViewCell.m
//  lit-ios
//
//  Created by ioshero on 25/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITSimpleLyricsTableViewCell.h"

NSString *const kLITSimpleLyricsTableViewCellIdentifier = @"LITSimpleLyricsTableViewCell";

@interface LITSimpleLyricsTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *lyricsLabel;
@property (weak, nonatomic) IBOutlet UIButton *optionsButton;

@end

@implementation LITSimpleLyricsTableViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [self.lyricsLabel setNumberOfLines:0];
    [self.lyricsLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
