//
//  LITCollectionViewDecorationLayout.h
//  lit-ios
//
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LITCollectionViewDecorationLayout : UICollectionViewFlowLayout

@end


@interface LITCollectionViewDecorationLayoutAttributes : UICollectionViewLayoutAttributes

@property (nonatomic, strong) UIColor *gradientStartColor;
@property (nonatomic, strong) UIColor *gradientMidColor;
@property (nonatomic, strong) UIColor *gradientEndColor;

@end


@interface LITCollectionReusableView : UICollectionReusableView

@end
