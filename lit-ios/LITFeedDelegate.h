//
//  LITFeedDelegate.h
//  lit-ios
//
//  Created by ioshero on 20/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PFObject, UIButton, PFQueryTableViewController, PFQueryCollectionViewController, BFTask;

@protocol LITObjectOptionDelegate <NSObject>

- (void)queryViewController:(UIViewController *)queryViewController didTapOptionsButton:(UIButton *)button forObject:(PFObject *)object withImage:(UIImage *)image;
- (BFTask *)objectIsFavorited:(PFObject *)object;

@end

@class LITKeyboardTableViewCell, LITKeyboardFooterView, LITKeyboardHeaderView, PFUser, LITProfileViewController, AMPopTip;
@protocol LITFeedDelegate <LITObjectOptionDelegate>

- (void)queryViewController:(UIViewController *)queryViewController
           didTapLikeButton:(UIButton *)button
                  forObject:(PFObject *)object
             withLikesLabel:(UILabel *)likesLabel;

- (void)queryViewController:(PFQueryCollectionViewController *)queryViewController
   didTapKeyboardLikeButton:(UIButton *)button
                forKeyboard:(PFObject *)object
             withFooterView:(LITKeyboardFooterView *)footerView
                 headerView:(LITKeyboardHeaderView *)headerView
                andFavorite:(BOOL)isFavorite;

- (void)queryViewController:(UIViewController *)queryViewController
     didRequestAddingObject:(PFObject *)object;

- (void)updateLikeButtonForCell:(UITableViewCell *)tableViewCell
                      andObject:(PFObject *)object;

- (void)updateLikeButtonForKeyboardFooterView:(LITKeyboardFooterView *)footerView
                                  andKeyboard:(PFObject *)object;

- (void)showProfileOfUser:(PFUser *)user;

- (void)reloadUserInstalledKeyboards:(LITProfileViewController *)profileViewController;

@end
