//
//  LITKBEmptyCollectionViewCell.m
//  lit-ios
//
//  Created by ioshero on 25/09/2015.
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import "LITKBEmptyCollectionViewCell.h"

@interface LITKBEmptyCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *plusImageView;
@property (weak, nonatomic) IBOutlet UILabel *noInternetConnection;

@end

NSString *const kLITKBEmptyCollectionViewCellIdentifier = @"LITKBEmptyCollectionViewCell";

@implementation LITKBEmptyCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}



@end
