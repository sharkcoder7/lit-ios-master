//
//  LITKBBaseCollectionViewCell.h
//  lit-ios
//
//  Created by Antonio Losada on 2/9/15.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LITKBCollectionViewCellDelegate;
@interface LITKBBaseCollectionViewCell : UICollectionViewCell <UIGestureRecognizerDelegate>

@property (strong,nonatomic) NSString *objectId;
@property (assign, nonatomic) BOOL useLocalCache;

@property (weak, nonatomic, readonly) UIButton *removeButton;

@end
