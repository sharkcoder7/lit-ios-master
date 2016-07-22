//
//  LITKBLyricCollectionViewCell.m
//  lit-ios
//
//  Created by ioshero on 12/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITKBLyricCollectionViewCell.h"
#import "LITAdjustableLabel.h"
#import "UIView+BlurEffect.h"

NSString *const kLITKBLyricCollectionViewCellIdentifier = @"LITKBLyricCollectionViewCell";

@interface LITKBLyricCollectionViewCell ()

@property (weak, nonatomic) IBOutlet LITAdjustableLabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;

@end

@implementation LITKBLyricCollectionViewCell
@synthesize removeButton;

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    [self.titleLabel setAdjustsFontSizeToFitFrame:YES];
}

@end
