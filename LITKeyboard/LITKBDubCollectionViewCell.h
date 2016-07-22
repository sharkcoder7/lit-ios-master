//
//  LITKBDubCollectionViewCell.h
//  lit-ios
//
//  Created by ioshero on 12/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LITKBBaseCollectionViewCell.h"
#import "AVUtils.h"

extern NSString *const kLITKBDubCollectionViewCellIdentifier;

@class LITAdjustableLabel, PFImageView, SharkfoodMuteSwitchDetector;
@interface LITKBDubCollectionViewCell : LITKBBaseCollectionViewCell

@property (weak, nonatomic, readonly) LITAdjustableLabel *titleLabel;
@property (weak, nonatomic, readonly) PFImageView *imageView;
@property (weak, nonatomic, readonly) UIView *overlayView;
@property (weak, nonatomic, readonly) UIImageView *cellIcon;

@property (copy)void (^silentBlock)(BOOL);

@property (strong, nonatomic) PFFile *dubVideo;

@property (strong, nonatomic) SharkfoodMuteSwitchDetector *switchDetector;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)playVideo;

@end
