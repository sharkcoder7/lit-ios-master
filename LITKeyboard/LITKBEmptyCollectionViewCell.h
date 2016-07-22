//
//  LITKBEmptyCollectionViewCell.h
//  lit-ios
//
//  Created by ioshero on 25/09/2015.
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LITKBBaseCollectionViewCell.h"

extern NSString *const kLITKBEmptyCollectionViewCellIdentifier;

@interface LITKBEmptyCollectionViewCell : LITKBBaseCollectionViewCell

@property (weak, readonly, nonatomic) UIImageView *plusImageView;
@property (weak, readonly, nonatomic) UILabel *noInternetConnection;

@end
