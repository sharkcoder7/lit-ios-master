//
//  UICollectionView+OptionsPresenting.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "UICollectionView+OptionsPresenting.h"

static NSInteger const kOptionsViewTag = 666;
NSInteger const kOptionsTableViewTag = 123;

@implementation UICollectionView (OptionsPresenting)

- (void)presentOptionsView:(UIView *)optionsView inKeyboardAtSection:(NSUInteger)section
{
    NSParameterAssert(optionsView);
    UICollectionViewCell *topCell = [self cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    UICollectionViewCell *bottomCell = [self cellForItemAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:section]];
    
    CGFloat tableBottom = CGRectGetMaxY(bottomCell.frame);
    CGFloat tableTop = CGRectGetMinY(topCell.frame);
    CGFloat tableHeight = tableBottom - tableTop;
    
    [optionsView setFrame:CGRectMake(CGRectGetMinX(self.frame),
                                          tableBottom,
                                          CGRectGetWidth(self.frame),
                                          0)];
    [optionsView setTag:kOptionsViewTag];
    [self addSubview:optionsView];
    UITableView *optionsTableView = (UITableView *)[optionsView viewWithTag:kOptionsTableViewTag];
    NSAssert([optionsTableView isKindOfClass:[UITableView class]],
             @"optionsTableView must be of class UITableView");
    [optionsTableView reloadData];
    [UIView animateWithDuration:0.25 animations:^{
        [optionsView setFrame:CGRectMake(CGRectGetMinX(self.frame),
                                         tableTop,
                                         CGRectGetWidth(optionsView.frame),
                                         tableHeight)];
    }];
}

- (void)dismissOptionsView
{
    UIView *optionsView = [self viewWithTag:kOptionsViewTag];
    NSAssert([optionsView isKindOfClass:[UIVisualEffectView class]], @"optionsView must be of class UIVisualEffectView");
    if (optionsView) {
//        [UIView animateWithDuration:0.25 animations:^{
//            [optionsView setFrame:CGRectMake(CGRectGetMinX(self.frame),
//                                                  CGRectGetMinY(optionsView.frame),
//                                                  CGRectGetWidth(self.frame),
//                                                  optionsView.frame.size.height*2)];
//        }];
        CGFloat originY = CGRectGetMinY(optionsView.frame);
        CGFloat tableHeight = CGRectGetHeight(optionsView.frame);
        CGFloat tableWidth = CGRectGetWidth(optionsView.frame);
        [UIView animateKeyframesWithDuration:0.25 delay:0.0 options:0 animations:^{
            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.25 animations:^{
                [optionsView setFrame:CGRectMake(CGRectGetMinX(self.frame),
                                                 originY + tableHeight / 4,
                                                 tableWidth,
                                                 tableHeight * 3/4)];
            }];
            
            [UIView addKeyframeWithRelativeStartTime:0.25 relativeDuration:0.25 animations:^{
                [optionsView setFrame:CGRectMake(CGRectGetMinX(self.frame),
                                                 originY + tableHeight / 2,
                                                 tableWidth,
                                                 tableHeight * 2/4)];
            }];
            
            [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.25 animations:^{
                [optionsView setFrame:CGRectMake(CGRectGetMinX(self.frame),
                                                 originY + 3*tableHeight / 4,
                                                 tableWidth,
                                                 tableHeight * 1/4)];
            }];
            
            [UIView addKeyframeWithRelativeStartTime:0.75 relativeDuration:0.25 animations:^{
                [optionsView setFrame:CGRectMake(CGRectGetMinX(self.frame),
                                                 originY + tableHeight,
                                                 tableWidth,
                                                 0)];
            }];
        } completion:nil];
    }
}

- (void)presentOptionsView:(UIView *)optionsView withTopOffset:(NSInteger)topOffset {
    NSParameterAssert(optionsView);
    
    [optionsView setHidden:NO];
    
    [optionsView setFrame:CGRectMake(CGRectGetMinX(self.frame),
                                     CGRectGetHeight(self.frame)+topOffset,
                                     CGRectGetWidth(self.frame),
                                     CGRectGetHeight(self.frame))];
    [optionsView setTag:kOptionsViewTag];
    [self addSubview:optionsView];
    [optionsView setExclusiveTouch:YES];
    UITableView *optionsTableView = (UITableView *)[optionsView viewWithTag:kOptionsTableViewTag];
    NSAssert([optionsTableView isKindOfClass:[UITableView class]],
             @"optionsTableView must be of class UITableView");
    [optionsTableView reloadData];
    [UIView animateWithDuration:0.20 animations:^{
        [optionsView setFrame:CGRectMake(0, topOffset, CGRectGetWidth(optionsView.frame), CGRectGetHeight(optionsView.frame))];
    }];
}

- (void)dismissOptionsViewWithNumberOfItems:(NSUInteger)numberOfItems itemCellHeight:(NSUInteger)itemCellHeight andTopOffset:(NSUInteger)topOffset
{
    UIView *optionsView = [self viewWithTag:kOptionsViewTag];
    [optionsView setExclusiveTouch:NO];
    NSAssert([optionsView isKindOfClass:[UIVisualEffectView class]], @"optionsView must be of class UIVisualEffectView");
    if (optionsView) {
        [UIView animateWithDuration:0.35 animations:^{
            int extraPadding = 110;
            
            if(numberOfItems < 7){
                [optionsView setFrame:CGRectMake(0,
                                                 CGRectGetHeight(self.frame)+extraPadding,
                                                 CGRectGetWidth(self.frame),
                                                 CGRectGetHeight(self.frame))];
            }
            else {
                [optionsView setFrame:CGRectMake(0,
                                                 CGRectGetHeight(self.frame)+floor(numberOfItems/3)*itemCellHeight+extraPadding,
                                                 CGRectGetWidth(self.frame),
                                                 CGRectGetHeight(self.frame))];
            }
        } completion:^(BOOL finished) {
            [optionsView setHidden:YES];
        }];
    }
}

@end
