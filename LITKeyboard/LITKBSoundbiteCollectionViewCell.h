//
//  LITKBSoundbiteCollectionViewCell.h
//  lit-ios
//
//  Created by ioshero on 12/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LITKBBaseCollectionViewCell.h"
#import "PFImageView.h"

extern NSString *const kLITKBSoundbiteCollectionViewCellIdentifier;

@class LITAdjustableLabel, PFImageView;
@interface LITKBSoundbiteCollectionViewCell : LITKBBaseCollectionViewCell

@property (weak, nonatomic, readonly) LITAdjustableLabel *titleLabel;
#ifndef LIT_EXTENSION
@property (weak, nonatomic, readonly) PFImageView *imageView;
#else
@property (weak, nonatomic, readonly) UIImageView *imageView;
#endif
@property (weak, nonatomic, readonly) UIImageView *cellIcon;

@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;

@end
