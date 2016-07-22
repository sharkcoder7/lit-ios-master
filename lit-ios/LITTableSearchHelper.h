
//
//  LITTableSearchHelper.h
//  lit-ios
//
//  Created by ioshero on 01/09/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol LITTableSearchHosting, LITSearchPresentationDelegate;
@class PFQuery;

@interface LITTableSearchHelper : NSObject

@property (nonatomic, weak)   id<LITTableSearchHosting> host;
@property (nonatomic, strong) UISearchController *searchController;
@property (strong, nonatomic) NSString *searchString;
@property (weak, nonatomic) id<LITSearchPresentationDelegate> presentationDelegate;
@property (nonatomic, assign, getter = isActive) BOOL active;
@property (nonatomic, assign) BOOL searchBarStartsHidden;

@property (strong, nonatomic) NSString *searchPlaceholderText;

- (instancetype)initWithTableSearchHosting:(id<LITTableSearchHosting>)host;
- (void)setupSearch;
- (void)setupEmojiSearch;
- (void)replaceSearchBarIconWithEmoji:(NSString *)emoji;
- (PFQuery *)modifyQuery:(PFQuery *)query
            forSearchKey:(NSString *)searchKey;

@end

@class BFTask;
@protocol LITTableSearchHosting <NSObject>

//@property (nonatomic, strong) UITableView *tableView;

@property (strong, nonatomic) UIView *headerView;
@property (weak, nonatomic, readonly) UIScrollView *scrollView;


@property(nonatomic,assign) BOOL definesPresentationContext NS_AVAILABLE_IOS(5_0);
@required
- (BFTask *)loadObjects;
@optional
- (PFQuery *)queryForTable;
- (PFQuery *)queryForCollection;


- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar;
- (void)performSearchWithString:(NSString *)emojiString;

@end


@protocol LITSearchPresentationDelegate <NSObject>
- (void)searchHelper:(LITTableSearchHelper *)searchQueryViewController willDismissSearchController:(UISearchController *)searchController;


@optional
- (void)searchHelper:(LITTableSearchHelper *)searchQueryViewController
didRequestPresentingSearchController:(UISearchController *)searchController;

@end

