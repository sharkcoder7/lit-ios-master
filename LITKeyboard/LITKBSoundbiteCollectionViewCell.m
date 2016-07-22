//
//  LITKBSoundbiteCollectionViewCell.m
//  lit-ios
//
//  Created by ioshero on 12/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITKBSoundbiteCollectionViewCell.h"
#import "LITAdjustableLabel.h"
#import "UIView+BlurEffect.h"
#import "AVUtils.h"
#ifndef LIT_EXTENSION
#import <ParseUI/PFImageView.h>
#endif


NSString *const kLITKBSoundbiteCollectionViewCellIdentifier = @"LITKBSoundbiteCollectionViewCell";

@interface LITKBSoundbiteCollectionViewCell () {
    BOOL _blurSet;
    AVPlayer *_player;
    AVPlayerItem *_playerItem;
}

@property (weak, nonatomic) IBOutlet LITAdjustableLabel *titleLabel;

#ifndef LIT_EXTENSION
@property (weak, nonatomic) IBOutlet PFImageView *imageView;
#else
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
#endif

@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property (weak, nonatomic) IBOutlet UIImageView *cellIcon;

@end

@implementation LITKBSoundbiteCollectionViewCell
@synthesize removeButton;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    /*
    // Single tap over the cell
    UITapGestureRecognizer *cellTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    cellTapRecognizer.delegate = self;
    [self addGestureRecognizer:cellTapRecognizer];
     */
    /*
    // Long press over the cell
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressRecognizer.minimumPressDuration = .5;
    longPressRecognizer.delegate = self;
    [self addGestureRecognizer:longPressRecognizer];
    */
    
    [self.titleLabel setAdjustsFontSizeToFitFrame:YES];
    [self.imageView setOpaque:NO];
    [self.imageView setAlpha:0.7];
    
    [self.removeButton addTarget:self action:@selector(removeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [self.activityIndicator setHidden:YES];
//    self.layer.borderWidth = 1.0f;
//    self.layer.borderColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3].CGColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//    if (!_blurSet) {
//        [self.contentView addBlurEffectBehindOthers:YES withStyle:UIBlurEffectStyleDark];
//        _blurSet = YES;
//    }
}


- (void)removeButtonTapped:(UIButton *)button
{
 NSLog(@"Button tapped");
}

- (void)prepareForReuse
{
//    [self.activityIndicator setHidden:YES];
    [self.imageView setImage:nil];
    [super prepareForReuse];
}

//-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    UIView *view = [self.removeButton hitTest:[self.removeButton convertPoint:point fromView:self.contentView] withEvent:event];
//    if (view == nil) {
//        view = [super hitTest:point withEvent:event];
//    }
//    return view;
//}
//
//-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
//    if ([super pointInside:point withEvent:event]) {
//        return YES;
//    }
//    //Check to see if it is within the delete button
//    return !self.removeButton.hidden && [self.removeButton pointInside:[self.removeButton convertPoint:point fromView:self] withEvent:event];
//}

@end
