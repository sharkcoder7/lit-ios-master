//
//  UICollectionView+OptionsPresenting.h
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSInteger const kOptionsTableViewTag;

@interface UICollectionView (OptionsPresenting)

- (void)presentOptionsView:(UIView *)optionsView inKeyboardAtSection:(NSUInteger)section;
- (void)dismissOptionsView;


- (void)presentOptionsView:(UIView *)optionsView withTopOffset:(NSInteger)topOffset;
- (void)dismissOptionsViewWithNumberOfItems:(NSUInteger)numberOfItems itemCellHeight:(NSUInteger)itemCellHeight andTopOffset:(NSUInteger)topOffset;
//- (void)presentOptionsTableView:(UITableView *)optionsTableView withCompletionBlock:(void (^)())completion;

@end
