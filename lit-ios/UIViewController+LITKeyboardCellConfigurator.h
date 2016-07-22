//
//  UIViewController+LITKeyboardCellConfigurator.h
//  lit-ios
//
//  Created by ioshero on 17/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LITKBEmptyCollectionViewCell.h"

@class LITKeyboard;

extern CGFloat kLITKeyboardCellHeight;
extern CGFloat kLITKeyboardCellItemPortraitDimension;
extern CGFloat kLITKeyboardCellItemLandscapeDimension;
extern CGFloat kLITKeyboardCellItemSpacing;
extern CGSize  kLITKeyboardHeaderReferenceSize;
extern CGSize  kLITKeyboardFooterReferenceSize;

extern NSString *const kTouchDetectorIndexPathKey;
extern NSString *const kTouchDetectorCollectionViewKey;
extern NSString *const kTouchDetectorGesturecognizerKey;


extern NSString *const kLITOptionsTableViewCellIdentifier;

@protocol LITKeyboardCellTouchDetector <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
@optional
- (void)deleteActionDetectedOnCellAtIndexPathForCollectionView:(NSDictionary *)dictionary;
@required
- (void)singleTapDetectedOnCellAtIndexPathForCollectionView:(NSDictionary *)dictionary;
- (void)doubleTapDetectedOnCellAtIndexPathForCollectionView:(NSDictionary *)dictionary;
- (void)animationLongPressDetectedOnCellAtIndexPathForCollectionView:(NSDictionary *)dictionary;
- (void)longPressDetectedOnCellAtIndexPathForCollectionView:(NSDictionary *)dictionary;
@end

@protocol LITKeyboardCellConfigurator <UICollectionViewDataSource,UIGestureRecognizerDelegate, LITKeyboardCellTouchDetector>
- (void)configureCollectionView:(UICollectionView *)collectionView;
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath usingKeyboard:(LITKeyboard *)keyboard;
@end


@interface UIViewController(LITKeyboardCellConfigurator) <UIGestureRecognizerDelegate>
- (void)configureCollectionView:(UICollectionView *)collectionView;
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath usingKeyboard:(LITKeyboard *)keyboard;

@end
