//
//  LITContentQueryTableViewController.m
//  lit-ios
//
//  Created by ioshero on 02/09/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITContentQueryTableViewController.h"
#import "LITSoundbitesViewController.h"
#import "LITDubsViewController.h"
#import "LITDubsPickSoundbiteViewController.h"
#import "LITLyricsViewController.h"
#import "LITSimpleSoundbiteTableViewCell.h"
#import "LITDubTableViewCell.h"
#import "LITSimpleLyricsTableViewCell.h"
#import "LITEmojiSearchCollectionViewController.h"
#import "LITTheme.h"
#import "LITKeyboard.h"
#import "LITKeyboardInstallerHelper.h"
#import "ParseGlobals.h"
#import "LITProgressHud.h"
#import "LITGlobals.h"

#import <Parse/PFQuery.h>
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"
#import <Bolts/Bolts.h>
#import <HMSegmentedControl/HMSegmentedControl.h>


#define FirstSegmentIndex 0
#define SecondSegmentIndex 1

#define kButtonSize 100
#define kButtonBottomMargin 10

@interface LITContentQueryTableViewController () <LITSearchPresentationDelegate, LITEmojiSearchDelegate, LITTableSearchHosting> {
    NSInteger _lastSegmentIndex;
}

@property (strong, nonatomic) LITEmojiSearchCollectionViewController *emojiVC;
@property (strong, nonatomic) HMSegmentedControl *segmentedControl;

@property (strong, nonatomic) JGProgressHUD *hud;

@property (assign, nonatomic) BOOL addButtonConfigured;

@end

@implementation LITContentQueryTableViewController {
    NSString *_savedTitle;
}

@dynamic headerView;
@synthesize isAddingToKeyboard = _isAddingToKeyboard;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        searchHelper = [[LITTableSearchHelper alloc] initWithTableSearchHosting:self];
        _showsAddButton = YES;
        _showsSegmentedHeader = YES;
        self.loadingViewEnabled = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.showsAddButton &&
        !self.addButtonConfigured &&
        (!self.isAddingToKeyboard || (self.isAddingToKeyboard && [self isKindOfClass:[LITLyricsViewController class]]))) {
        [self setupAddButton];
    }
    
    if (self.showsSegmentedHeader) {
        [self setupSegmentedHeader];
    }
    
    [self.tableView setScrollsToTop:YES];
    [self.tableView setAllowsSelection:YES];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UIImage imageNamed:@"navBarClose"] forState:UIControlStateNormal];
    [closeButton sizeToFit];
    [closeButton addTarget:self
                    action:@selector(closeButtonPressed:)
          forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    self.navigationItem.leftBarButtonItem = closeBarButtonItem;
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton setImage:[UIImage imageNamed:@"navBarSearch"] forState:UIControlStateNormal];
    [searchButton sizeToFit];
    [searchButton addTarget:self
                     action:@selector(searchButtonPressed:)
           forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    self.navigationItem.rightBarButtonItem = searchBarButtonItem;
    
    [searchHelper setSearchPlaceholderText:@"Search"];
    [searchHelper setSearchBarStartsHidden:YES];
    [searchHelper setupSearch];
    [searchHelper setupEmojiSearch];
    
    [searchHelper setPresentationDelegate:self];
    
    self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.tableView setBackgroundColor:[UIColor lit_lightGreyColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setIsAddingToKeyboard:(BOOL)isAddingToKeyboard {
    _isAddingToKeyboard = isAddingToKeyboard;
    [self.addButtonView setHidden:YES];
}

#pragma mark - Actions

- (void)closeButtonPressed:(UIBarButtonItem *)button
{
    if (self.isAddingToKeyboard) {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Are you sure you want to cancel?"
                                              message:@"You are in the middle of adding content to your keyboard"
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController
         addAction:[UIAlertAction actionWithTitle:@"OK"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"No"
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil]];
        
        [self presentViewController:alertController animated:NO completion:nil];
    } else
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchButtonPressed:(UIBarButtonItem *)button
{
    if([self class] == [LITSoundbitesViewController class]){
        [[Mixpanel sharedInstance] track:kMixpanelAction_search_Soundbites properties:nil];
    }
    else if([self class] == [LITDubsViewController class]){
        [[Mixpanel sharedInstance] track:kMixpanelAction_search_Dubs properties:nil];
    }
    else if([self class] == [LITDubsPickSoundbiteViewController class]){
        [[Mixpanel sharedInstance] track:kMixpanelAction_searchBaseSound_New_Dubs properties:nil];
    }
    else if([self class] == [LITLyricsViewController class]){
        [[Mixpanel sharedInstance] track:kMixpanelAction_search_Lyrics properties:nil];
    }
    
    CGRect searchBarFrame = self.navigationController.navigationBar.frame;
    searchBarFrame.origin.y = 0.0f;
//    searchBarFrame.origin.x = 14.0f;
//    searchBarFrame.size.width -= 28.0f;

    [self.navigationController.navigationBar addSubview:searchHelper.searchController.searchBar];
//    UISearchBar *searchBar = searchHelper.searchController.searchBar;
//    [searchBar setTranslatesAutoresizingMaskIntoConstraints:NO];
//    NSDictionary *bindings = NSDictionaryOfVariableBindings(searchBar);
//    NSArray *hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-14-[searchBar]-14-|" options:0 metrics:nil views:bindings];
//    NSArray *vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[searchBar]|" options:0 metrics:nil views:bindings];
//    [self.navigationController.navigationBar addConstraints:vConstraints];
//    [self.navigationController.navigationBar addConstraints:hConstraints];
    _savedTitle = self.navigationItem.title;
    [self.navigationItem setTitleView:searchHelper.searchController.searchBar];

    [searchHelper.searchController.searchBar setShowsCancelButton:YES animated:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        [searchHelper.searchController.searchBar setFrame:searchBarFrame];
        [self.navigationController.navigationBar layoutIfNeeded];
        [self.tableView setContentOffset:CGPointMake(0.0f, 0.0f)];
        [self.navigationItem.leftBarButtonItem.customView setAlpha:0.0f];
        [self.navigationItem.rightBarButtonItem.customView setAlpha:0.0f];
        [self.addButton setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [self.tableView layoutIfNeeded];
        [searchHelper.searchController.searchBar becomeFirstResponder];
        self.tableView.tableHeaderView = nil;
        [self.navigationItem.leftBarButtonItem.customView setHidden:YES];
        [self.navigationItem.rightBarButtonItem.customView setHidden:YES];
        [searchHelper setActive:YES];
    }];
    
}

#pragma mark - Add Button
- (void)setupAddButton {
    
    self.addButtonConfigured = YES;
    
    self.addButtonView = [[UIView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width-140, [[UIScreen mainScreen] bounds].size.height, kButtonSize, kButtonSize)];
    [self.addButtonView setBackgroundColor:[UIColor clearColor]];
    [self.addButtonView setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, kButtonSize, kButtonSize);
    [button setTranslatesAutoresizingMaskIntoConstraints:YES];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setImage:[UIImage imageNamed:@"addContentButton"] forState:UIControlStateNormal];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
    [button setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
    
    CGRect frame = self.addButtonView.frame;
    frame.origin.y = self.tableView.contentOffset.y + self.tableView.frame.size.height - self.addButtonView.frame.size.height-kButtonSize;
    self.addButtonView.frame = frame;
    
    self.addButton = button;
    [self.addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.addButtonView addSubview:self.addButton];
    
    [self.view addSubview:self.addButtonView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect frame = self.addButtonView.frame;
    frame.origin.y = scrollView.contentOffset.y + self.tableView.frame.size.height - self.addButtonView.frame.size.height-kButtonSize/2+kButtonBottomMargin;
    self.addButtonView.frame = frame;
    
    [self.view bringSubviewToFront:self.addButtonView];
}

- (void)addButtonPressed:(UIBarButtonItem *)button
{
    //Default implementation does nothing
}

- (void)optionsButtonPressed:(UIButton *)optionsButton
{
    if([self class] == [LITDubsViewController class]){
        [[Mixpanel sharedInstance] track:kMixpanelAction_3dots_Dubs properties:nil];
    }
    else if([self class] == [LITSoundbitesViewController class]){
        [[Mixpanel sharedInstance] track:kMixpanelAction_3dots_Soundbites properties:nil];
    }
    else if([self class] == [LITLyricsViewController class]){
        [[Mixpanel sharedInstance] track:kMixpanelAction_3dots_Lyrics properties:nil];
    }
    else if([self class] == [LITDubsPickSoundbiteViewController class]){
        [[Mixpanel sharedInstance] track:kMixpanelAction_3dotsSound_New_Dubs properties:nil];
    }
    
    
    PFObject *object = self.objects[optionsButton.tag];
    [optionsButton setEnabled:NO];
    
    if(!self.optionsVisible){
        self.optionsVisible = YES;
        if (self.optionsDelegate && [self.optionsDelegate respondsToSelector:@selector(queryViewController:didTapOptionsButton:forObject:withImage:)]) {
            [self.optionsDelegate queryViewController:self didTapOptionsButton:optionsButton forObject:object withImage:nil];
        }
    }
}


#pragma mark - Segmented Header
- (void)setupSegmentedHeader {
    
    self.segmentedHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), 37.0f)];
    [self.segmentedHeaderView setBackgroundColor:[UIColor colorWithWhite:.9 alpha:1]];
    [self.segmentedHeaderView setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"POPULAR 🔥", @"NEW 🕓"]];
    [self.segmentedControl setSelectionIndicatorColor:[UIColor lit_darkOrangishColor]];
    //    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(4, -40, 3, -80);
    self.segmentedControl.borderColor = [UIColor lit_coolGreyColor];
    [self.segmentedControl setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        
        UIColor *color = selected ? [UIColor lit_darkOrangishColor] : [UIColor lit_coolGreyColor];
        return [[NSAttributedString alloc] initWithString:title
                                               attributes:@{NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-DemiBold" size:9],
                                                            NSForegroundColorAttributeName : color}];
    }];
    
    [self.segmentedControl setSelectedSegmentIndex:FirstSegmentIndex];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.segmentedControl setFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 36.0f)];
    [self.segmentedHeaderView addSubview:self.segmentedControl];
    
    self.tableView.tableHeaderView = self.segmentedHeaderView;
}

- (void)segmentedControlValueChanged:(UISegmentedControl *)control
{
    if (self.segmentedControl.selectedSegmentIndex == _lastSegmentIndex) {
        return;
    }
    
    // Show a spinner until the objects are fully loaded
    NSString *hudMsg = @"";
    if([self class] == [LITSoundbitesViewController class]){
        hudMsg = @"Loading\nSoundbites...";
        
        if(self.segmentedControl.selectedSegmentIndex == FirstSegmentIndex){
            [[Mixpanel sharedInstance] track:kMixpanelAction_soundbitesContent_Trending properties:nil];
        }
        else if(self.segmentedControl.selectedSegmentIndex == SecondSegmentIndex){
            [[Mixpanel sharedInstance] track:kMixpanelAction_soundbitesContent_Recent properties:nil];
        }
    }
    else if([self class] == [LITDubsViewController class]){
        hudMsg = @"Loading\nDubs...";
        
        if(self.segmentedControl.selectedSegmentIndex == FirstSegmentIndex){
            [[Mixpanel sharedInstance] track:kMixpanelAction_dubsContent_Trending properties:nil];
        }
        else if(self.segmentedControl.selectedSegmentIndex == SecondSegmentIndex){
            [[Mixpanel sharedInstance] track:kMixpanelAction_dubsContent_Recent properties:nil];
        }
    }
    else if([self class] == [LITLyricsViewController class]){
        hudMsg = @"Loading\nLyrics...";
        
        if(self.segmentedControl.selectedSegmentIndex == FirstSegmentIndex){
            [[Mixpanel sharedInstance] track:kMixpanelAction_lyricsContent_Trending properties:nil];
        }
        else if(self.segmentedControl.selectedSegmentIndex == SecondSegmentIndex){
            [[Mixpanel sharedInstance] track:kMixpanelAction_lyricsContent_Recent properties:nil];
        }
    }
    
    self.hud = [LITProgressHud createHudWithMessage:hudMsg];
    self.hud.square = YES;
    [self.hud showInView:self.view];
    
    _lastSegmentIndex = self.segmentedControl.selectedSegmentIndex;
    [self loadObjects];
}


#pragma mark - PFQueryTableViewController
- (PFQuery *)queryForTable
{
    PFQuery *query = [super queryForTable];
    [query whereKey:kLITObjectHiddenKey equalTo:[NSNumber numberWithBool:false]];
    
    if(_lastSegmentIndex == FirstSegmentIndex){
        //        Real order -> Uses > Priority > Date
        //        [query orderByDescending:kLITObjectUsesKey];
        //        [query addDescendingOrder:kLITObjectPriorityKey];
        [query orderByDescending:kLITObjectPriorityKey];
        [query addDescendingOrder:kLITObjectUsesKey];
        [query addDescendingOrder:kLITObjectCreatedAtKey];
    }
    else if(_lastSegmentIndex == SecondSegmentIndex){
        [query orderByDescending:kLITObjectCreatedAtKey];
        [query addDescendingOrder:kLITObjectPriorityKey];
        [query addDescendingOrder:kLITObjectUsesKey];
    }
    else {
        [query orderByDescending:kLITObjectCreatedAtKey];
        [query addDescendingOrder:kLITObjectPriorityKey];
        [query addDescendingOrder:kLITObjectUsesKey];
    }
    
    if (searchHelper.isActive) {
        return [searchHelper modifyQuery:query forSearchKey:kMainFeedSearchDataKey];
    }
    return query;
}

- (void)objectsDidLoad:(nullable NSError *)error
{
    [super objectsDidLoad:error];
    
    if(self.hud){
        [self.hud dismissAnimated:YES];
        self.hud = nil;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.isAddingToKeyboard){
        
        self.isAddingToKeyboard = NO;
   
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        if(![self.keyboard.contents containsObject:object]){
        	[self saveKeyboardInBackground:self.keyboard withObject:object andSaveBlock:^(BOOL succeeded, NSError * __nullable error) {
            
            	[[LITKeyboardInstallerHelper installKeyboard:self.keyboard fromViewController:self] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                	if (!task.error) {
                    	NSLog(@"Content added successfully");
                    	[[NSNotificationCenter defaultCenter] postNotificationName:kLITAddedContentToKeyboardNotificationName object:self userInfo:nil];
                	}
                	return nil;
            	}];
			}];
        }
        if (searchHelper.isActive) {
            [self dismissViewControllerAnimated:NO completion:^{
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        } else [self dismissViewControllerAnimated:YES completion:nil];

    } else [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - Object Saving
- (void)saveKeyboardInBackground:(LITKeyboard *)keyboard withObject:(PFObject *)object andSaveBlock:(PFBooleanResultBlock)saveBlock
{
    [keyboard addObject:object forKey:kLITKeyboardContentsKey];
    [keyboard saveInBackgroundWithBlock:saveBlock];
}

#pragma mark - LITSearchPresentationDelegate
- (void)searchHelper:(LITTableSearchHelper *)searchQueryViewController
willDismissSearchController:(UISearchController *)searchController;
{
    self.tableView.tableHeaderView = self.headerView;
    if(![self isKindOfClass:[LITDubsPickSoundbiteViewController class]]){
        [self.tableView setContentOffset:CGPointMake(0.0f, 60.0f)];
    }
    [self.navigationItem.leftBarButtonItem.customView setHidden:NO];
    [self.navigationItem.rightBarButtonItem.customView setHidden:NO];
    [UIView animateWithDuration:0.3 animations:^{
        [self.navigationController.navigationBar layoutIfNeeded];
        if(![self isKindOfClass:[LITDubsPickSoundbiteViewController class]]){
            [self.tableView setContentOffset:CGPointMake(0.0f, 0.0f)];
        }
        [self.navigationItem.leftBarButtonItem.customView setAlpha:1.0f];
        [self.navigationItem.rightBarButtonItem.customView setAlpha:1.0f];
        [searchHelper.searchController.searchBar setAlpha:0.0f];
        [self.addButton setAlpha:1.0f];
    } completion:^(BOOL finished) {
        [self.navigationItem setTitleView:nil];
        [self.navigationItem setTitle:_savedTitle];
        [searchHelper.searchController.searchBar setAlpha:1.0f];
        [searchHelper.searchController.searchBar setFrame:CGRectZero];
        [searchHelper setActive:NO];
    }];
}


#pragma mark Invocation Forwarding
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([searchHelper respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:searchHelper];
    }else {
        [super forwardInvocation:anInvocation];
    }
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature* signature = [super methodSignatureForSelector:selector];
    if (!signature) {
        signature = [searchHelper methodSignatureForSelector:selector];
    }
    return signature;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector] ||
        [searchHelper respondsToSelector:aSelector])
    {
        return YES;
    }
    return NO;
}

#pragma mark LITTableSearchHosting Delegate

- (UIView *)headerView
{
    return self.tableView.tableHeaderView;
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    self.emojiVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([LITEmojiSearchCollectionViewController class])];
    
    if([searchHelper.searchController isActive]){
        [searchHelper.searchController resignFirstResponder];
        [searchHelper.searchController.searchBar resignFirstResponder];
    }
    else{
        [searchHelper.searchController setActive:YES];
    }
    
    [self.emojiVC setDelegate:self];
    [self presentViewController:self.emojiVC animated:YES completion:nil];
}

- (void)performSearchWithString:(NSString *)emojiString
{
    [searchHelper replaceSearchBarIconWithEmoji:emojiString];
    searchHelper.searchString = [emojiString lowercaseString];
    [searchHelper.host loadObjects];
}


- (UIScrollView *)scrollView
{
    return self.tableView;
}


#pragma mark LITEmojiSearchDelegate
- (void) didTapCloseButton:(LITEmojiSearchCollectionViewController *) emojiCV
{
    [self.emojiVC dismissViewControllerAnimated:YES completion:^{
        [self performSearchWithString:emojiCV.emojiString];
    }];
}




@end
