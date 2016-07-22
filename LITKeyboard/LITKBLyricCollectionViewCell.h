//
//  LITKBLyricCollectionViewCell.h
//  lit-ios
//
//  Created by ioshero on 12/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LITKBBaseCollectionViewCell.h"

extern NSString *const kLITKBLyricCollectionViewCellIdentifier;

@class LITAdjustableLabel;
@interface LITKBLyricCollectionViewCell : LITKBBaseCollectionViewCell

@property (weak, nonatomic, readonly) LITAdjustableLabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
