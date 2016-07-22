//
//  LITTableSearchHelper.m
//  lit-ios
//
//  Created by ioshero on 01/09/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITTableSearchHelper.h"
#import "LITSearchController.h"
#import "LITTheme.h"
#import "UIImage+emoji.h"
#import <Parse/PFQuery.h>
#import <CoreGraphics/CoreGraphics.h>

@interface LITTableSearchHelper () <UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate>

@end

@implementation LITTableSearchHelper

- (instancetype)initWithTableSearchHosting:(id<LITTableSearchHosting>)aHost
{
    self = [super init];
    if (self) {
        _host = aHost;
    }
    return self;
}

- (void)setupSearch
{
    if (!self.searchBarStartsHidden) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    } else {
        _searchController = [[LITSearchController alloc] initWithSearchResultsController:nil];
        ((LITSearchController*)_searchController).litDelegate = (id<LITTableSearchHosting, UISearchControllerDelegate>)self;
    }
    
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    [self.searchController.searchBar setPlaceholder:self.searchPlaceholderText ? : @"Search..."];
    [self.searchController.searchBar setTintColor:[UIColor lit_lightOrangishColor]];
    
    // FIX - Removes black lines surrounding the box after pressing Cancel
    [self.searchController.searchBar setBackgroundImage:[UIImage new]];
    
    if (!self.searchBarStartsHidden) {
        [self.searchController.searchBar sizeToFit];
        self.searchController.searchBar.layer.borderWidth = 2;
        self.searchController.searchBar.layer.borderColor = [[UIColor lit_lightGreyColor] CGColor];
        self.searchController.view.frame = CGRectMake(self.searchController.view.frame.origin.x+10, self.searchController.view.frame.origin.y, self.searchController.view.frame.size.width-5, self.searchController.view.frame.size.height);
        _host.headerView = self.searchController.searchBar;
    }
    
    _host.definesPresentationContext = YES;
}

- (void)setupEmojiSearch
{
    //[self.searchController.searchBar setImage:[UIImage imageNamed:@"emoji"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    //[self.searchController.searchBar setShowsBookmarkButton:YES];
}

- (void)replaceSearchBarIconWithEmoji:(NSString *)emoji
{
    if([emoji isEqualToString:@""]){
        [self.searchController.searchBar setImage:[UIImage imageNamed:@"emoji"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    }
    else{
        UIImage *emojiImage = [UIImage imageWithEmoji:emoji];
        [self.searchController.searchBar setImage:emojiImage forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    }
}

- (PFQuery *)modifyQuery:(PFQuery *)query
            forSearchKey:(NSString *)searchKey
{
    return [query whereKey:searchKey containsString:self.searchString];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    self.searchString = [searchString lowercaseString];
    [_host loadObjects];
}

#pragma mark - UISearchControllerDelegate

// Called after the search controller's search bar has agreed to begin editing or when
// 'active' is set to YES.
// If you choose not to present the controller yourself or do not implement this method,
// a default presentation is performed on your behalf.
//
// Implement this method if the default presentation is not adequate for your purposes.
//
- (void)presentSearchController:(UISearchController *)searchController {
    if (self.presentationDelegate &&
        [self.presentationDelegate
         respondsToSelector:@selector(searchHelper:didRequestPresentingSearchController:)]) {
        [self.presentationDelegate searchHelper:self didRequestPresentingSearchController:self.searchController];
    }
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    // do something before the search controller is presented
    NSLog(@"Will present");
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    // do something after the search controller is presented
    NSLog(@"Did present");
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    // do something before the search controller is dismissed
    NSLog(@"Will dismiss");
    [self replaceSearchBarIconWithEmoji:@""];
    if (self.presentationDelegate && [self.presentationDelegate respondsToSelector:@selector(searchHelper:willDismissSearchController:)]) {
        [self.presentationDelegate searchHelper:self willDismissSearchController:self.searchController];
    }
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    // do something after the search controller is dismissed
    NSLog(@"Did dismiss");
    self.searchString = nil;
    [self.searchController.searchBar setImage:[UIImage imageNamed:@"emoji"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchController.active = YES;
    [self.searchController.searchBar becomeFirstResponder];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    
}
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    if ([self.host respondsToSelector:@selector(searchBarBookmarkButtonClicked:)]) {
        [self.host searchBarBookmarkButtonClicked:searchBar];
    }
}

#pragma mark - Getters
- (BOOL)isActive
{
    return self.searchController.isActive;
}

@end
