//
//  LITSearchController.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITSearchController.h"
#import "LITSearchBar.h"


@interface LITSearchController () <UISearchBarDelegate>

@end

@implementation LITSearchController {
    LITSearchBar *_searchBar;
}
@dynamic delegate;

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        _searchBar = [[LITSearchBar alloc] initWithFrame:CGRectMake(14.0f, 0.0, CGRectGetWidth([UIScreen mainScreen].bounds) - 14.0f, 40.0f)];
    }
    //[_searchBar setDelegate:self];
    return _searchBar;
}

//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
//{
//    [searchBar resignFirstResponder];
//}
//
//- (void)presentSearchController:(UISearchController *)searchController
//{
//    [self.delegate presentSearchController:self];
//}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.active = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.active = NO;
    [self.searchBar setImage:[UIImage imageNamed:@"emoji"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.searchResultsUpdater updateSearchResultsForSearchController:self];
}

- (void)performSearchWithString:(NSString *)string{
    [self.searchResultsUpdater updateSearchResultsForSearchController:self];
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    [self.litDelegate searchBarBookmarkButtonClicked:searchBar];
}

@end
