//
//  LITMainFeedViewController.m
//  lit-ios
//
//  Created by ioshero on 20/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITMainFeedViewController.h"
#import "ParseGlobals.h"
#import "LITLyricsTableViewCell.h"
#import "LITSoundbiteTableViewCell.h"
#import "LITDubTableViewCell.h"
#import "LITDub.h"
#import "LITSoundbite.h"
#import "LITLyric.h"
#import "LITTheme.h"
#import "LITEmojiSearchCollectionViewController.h"
#import "MixpanelGlobals.h"
#import "LITGlobals.h"
#import "WSCoachMarksView.h"

#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerItem.h>
#import <AVFoundation/AVAsset.h>
#import <Mixpanel/Mixpanel.h>
#import <Parse/PFQuery+Synchronous.h>


#import <Bolts/Bolts.h>

@interface LITMainFeedViewController () <LITEmojiSearchDelegate, WSCoachMarksViewDelegate>

@property (strong, nonatomic) LITEmojiSearchCollectionViewController *emojiVC;
@property (assign, atomic, getter=isAdding) BOOL adding;

@end

@implementation LITMainFeedViewController {
    LITSoundbitePlayerHelper *_playerHelper;
    LITTableSearchHelper *_searchHelper;
}

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(doesNeedContentCoach)
                                                     name:kLITnotificationNeedContentCoach
                                                   object:nil];
        
        // Customize the table
        
        // The className to query on
        self.parseClassName = kMainFeedClassName;
        
        // The key of the PFObject to display in the label of the default cell style
        //        self.textKey = @"text";
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
        // self.imageKey = @"image";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = kLITObjectsPerPage;
        
        self.loadingViewEnabled = NO;
        
        self.optionsVisible = NO;
        
        _playerHelper = [[LITSoundbitePlayerHelper alloc] initWithSoundbitePlayerHosting:self];
        _searchHelper = [[LITTableSearchHelper alloc] initWithTableSearchHosting:self];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([LITSoundbiteTableViewCell class])bundle:nil] forCellReuseIdentifier:kLITSoundbiteTableViewCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([LITLyricsTableViewCell class])bundle:nil] forCellReuseIdentifier:kLITLyricsTableViewCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([LITDubTableViewCell class])bundle:nil] forCellReuseIdentifier:kLITDubTableViewCellIdentifier];
    
    [_searchHelper setSearchPlaceholderText:@"Search for Content..."];
    [_searchHelper setupSearch];
    [_searchHelper setupEmojiSearch];
    
//    [_searchHelper.searchController.searchBar setDelegate:self];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    NSAssert([parent
              conformsToProtocol:@protocol(LITSearchPresentationDelegate)],
             @"Parent View Controller must conform to LITSearchPresentationDelegate");
    [_searchHelper setPresentationDelegate:(id<LITSearchPresentationDelegate>)parent];
    
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


-(void)doesNeedContentCoach {
    
    [self didDismissContentFullCoach];
    
//    if (![[NSUserDefaults standardUserDefaults] objectForKey:kLITnotificationNeedContentCoach]){
//        
//        NSArray *coachMarks;
//        
//        if([[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] class] == [LITSoundbiteTableViewCell class]){
//            LITSoundbiteTableViewCell *cell = (LITSoundbiteTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//            
//            // Setup coach marks
//            coachMarks = @[
//                           @{
//                               @"rect": [NSValue valueWithCGRect:
//                                         CGRectMake(cell.frame.origin.x,
//                                                    cell.frame.origin.y+kLITheightKeyboardDifference,
//                                                    cell.frame.size.width,
//                                                    cell.frame.size.height-15)],
//                               @"caption": @"This is a Soundbite cell in the Content feed. You can listen to the recorded sound by tapping the play button.",
//                               @"shape": @"square"
//                               }
//                           ];
//
//        }
//        else if([[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] class] == [LITDubTableViewCell class]){
//            LITDubTableViewCell *cell = (LITDubTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//            
//            // Setup coach marks
//            coachMarks = @[
//                           @{
//                               @"rect": [NSValue valueWithCGRect:
//                                         CGRectMake(cell.frame.origin.x,
//                                                    cell.frame.origin.y+kLITheightKeyboardDifference,
//                                                    cell.frame.size.width,
//                                                    cell.frame.size.height-15)],
//                               @"caption": @"This is a Dub cell in the Content feed. You can watch the recorded video by tapping the play button.",
//                               @"shape": @"square"
//                               }
//                           ];
//
//        }
//        else if([[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] class] == [LITLyricsTableViewCell class]){
//            LITLyricsTableViewCell *cell = (LITLyricsTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//            
//            // Setup coach marks
//            coachMarks = @[
//                           @{
//                               @"rect": [NSValue valueWithCGRect:
//                                         CGRectMake(cell.frame.origin.x,
//                                                    cell.frame.origin.y+kLITheightKeyboardDifference,
//                                                    cell.frame.size.width,
//                                                    cell.frame.size.height-15)],
//                               @"caption": @"This is a Lyric cell in the Content feed.",
//                               @"shape": @"square"
//                               }
//                           ];
//
//        }
//        
//        // Coach Marks
//        
//        WSCoachMarksView *coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.navigationController.view.bounds coachMarks:coachMarks];
//        [coachMarksView setTag:kLITContentFullCoachTag];
//        [self.navigationController.view addSubview:coachMarksView];
//        [coachMarksView setMaskColor:[UIColor colorWithWhite:0 alpha:.75]];
//        [coachMarksView setEnableSkipButton:NO];
//        [coachMarksView setEnableContinueLabel:NO];
//        [coachMarksView.lblCaption setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:14.0f]];
//        [coachMarksView setDelegate:self];
//        [coachMarksView start];
//        
//        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kLITnotificationNeedContentCoach];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
}

-(void)didDismissContentFullCoach { // To the header options

    NSString *tutorialMsg = @"It's simple. Press the ❤ to add to favorites (and press again to remove), and + to add to your keyboard.";
    
    NSArray *coachMarks;
    
    if([[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] class] == [LITSoundbiteTableViewCell class]){
        LITSoundbiteTableViewCell *cell = (LITSoundbiteTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        // Setup coach marks
        coachMarks = @[
                       @{
                           @"rect": [NSValue valueWithCGRect:
                                     CGRectMake(cell.frame.origin.x,
                                                cell.frame.origin.y+kLITheightKeyboardDifference,
                                                cell.frame.size.width,
                                                cell.fullHeaderButton.frame.size.height)],
                           @"caption": tutorialMsg,
                           @"shape": @"square"
                           }
                       ];
        
    }
    else if([[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] class] == [LITDubTableViewCell class]){
        LITDubTableViewCell *cell = (LITDubTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        // Setup coach marks
        coachMarks = @[
                       @{
                           @"rect": [NSValue valueWithCGRect:
                                     CGRectMake(cell.frame.origin.x,
                                                cell.frame.origin.y+kLITheightKeyboardDifference,
                                                cell.frame.size.width,
                                                cell.fullHeaderButton.frame.size.height)],
                           @"caption": tutorialMsg,
                           @"shape": @"square"
                           }
                       ];
        
    }
    else if([[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] class] == [LITLyricsTableViewCell class]){
        LITLyricsTableViewCell *cell = (LITLyricsTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        // Setup coach marks
        coachMarks = @[
                       @{
                           @"rect": [NSValue valueWithCGRect:
                                     CGRectMake(cell.frame.origin.x,
                                                cell.frame.origin.y+kLITheightKeyboardDifference,
                                                cell.frame.size.width,
                                                cell.fullHeaderButton.frame.size.height)],
                           @"caption": tutorialMsg,
                           @"shape": @"square"
                           }
                       ];
        
    }
    
    // Coach Marks
    
    WSCoachMarksView *coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.navigationController.view.bounds coachMarks:coachMarks];
    [coachMarksView setTag:kLITContentHeaderCoachTag];
    [self.navigationController.view addSubview:coachMarksView];
    [coachMarksView setMaskColor:[UIColor colorWithWhite:0 alpha:.75]];
    [coachMarksView setEnableSkipButton:NO];
    [coachMarksView setEnableContinueLabel:NO];
    [coachMarksView.lblCaption setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:14.0f]];
    [coachMarksView setDelegate:self];
    [coachMarksView start];
}

-(void)didDismissContentHeaderCoach { // To the footer options

    NSString *tutorialMsg = @"As with the keyboards, any content can be managed from this little handler. It allows you to share, favorite, report and add pieces to your keyboards.";
    
    NSArray *coachMarks;
    
    if([[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] class] == [LITSoundbiteTableViewCell class]){
        LITSoundbiteTableViewCell *cell = (LITSoundbiteTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        // Setup coach marks
        coachMarks = @[
                       @{
                           @"rect": [NSValue valueWithCGRect:
                                     CGRectMake(cell.optionsButton.frame.origin.x,
                                                cell.optionsButton.frame.origin.y+kLITheightKeyboardDifference+kLITheightContentFeedFooter,
                                                cell.optionsButton.frame.size.width,
                                                cell.optionsButton.frame.size.height)],
                           @"caption": tutorialMsg,
                           @"shape": @"circle"
                           }
                       ];
        
    }
    else if([[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] class] == [LITDubTableViewCell class]){
        LITDubTableViewCell *cell = (LITDubTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        // Setup coach marks
        coachMarks = @[
                       @{
                           @"rect": [NSValue valueWithCGRect:
                                     CGRectMake(cell.optionsButton.frame.origin.x,
                                                cell.optionsButton.frame.origin.y+kLITheightKeyboardDifference+kLITheightContentFeedFooter,
                                                cell.optionsButton.frame.size.width,
                                                cell.optionsButton.frame.size.height)],
                           @"caption": tutorialMsg,
                           @"shape": @"circle"
                           }
                       ];
        
    }
    else if([[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] class] == [LITLyricsTableViewCell class]){
        LITLyricsTableViewCell *cell = (LITLyricsTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        // Setup coach marks
        coachMarks = @[
                       @{
                           @"rect": [NSValue valueWithCGRect:
                                     CGRectMake(cell.optionsButton.frame.origin.x,
                                                cell.optionsButton.frame.origin.y+kLITheightKeyboardDifference+kLITheightContentFeedFooter,
                                                cell.optionsButton.frame.size.width,
                                                cell.optionsButton.frame.size.height)],
                           @"caption": tutorialMsg,
                           @"shape": @"circle"
                           }
                       ];
    }
    
    // Coach Marks
    
    WSCoachMarksView *coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.navigationController.view.bounds coachMarks:coachMarks];
    [coachMarksView setTag:kLITContentFooterCoachTag];
    [self.navigationController.view addSubview:coachMarksView];
    [coachMarksView setMaskColor:[UIColor colorWithWhite:0 alpha:.75]];
    [coachMarksView setEnableSkipButton:NO];
    [coachMarksView setEnableContinueLabel:NO];
    [coachMarksView.lblCaption setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:14.0f]];
    [coachMarksView setDelegate:self];
    [coachMarksView start];
}


#pragma mark - WSCoachMarks Delegate

- (void)coachMarksView:(WSCoachMarksView*)coachMarksView willNavigateToIndex:(NSUInteger)index {}
- (void)coachMarksView:(WSCoachMarksView*)coachMarksView didNavigateToIndex:(NSUInteger)index {}
- (void)coachMarksViewDidCleanup:(WSCoachMarksView*)coachMarksView {}
- (void)coachMarksViewWillCleanup:(WSCoachMarksView*)coachMarksView {
    
//    if(coachMarksView.tag == kLITContentFullCoachTag){
//        [self didDismissContentFullCoach];
//    }
//    else if(coachMarksView.tag == kLITContentHeaderCoachTag){
//        [self didDismissContentHeaderCoach];
//    }
//    else if(coachMarksView.tag == kLITContentFooterCoachTag){
//        [[NSNotificationCenter defaultCenter] postNotificationName:kLITnotificationContentCoachDismissed
//                                                            object:nil
//                                                          userInfo:nil];
//    }
    
    if(coachMarksView.tag == kLITContentHeaderCoachTag){
        [[NSNotificationCenter defaultCenter] postNotificationName:kLITnotificationContentCoachDismissed object:nil userInfo:nil];
    }
}


#pragma mark - PFQueryTableViewController
- (PFQuery *)queryForTable
{
    PFQuery *query = [super queryForTable];
    [query whereKey:kLITObjectHiddenKey equalTo:[NSNumber numberWithBool:false]];

    [query orderByDescending:kLITObjectPriorityKey];
    [query addDescendingOrder:kLITObjectCreatedAtKey];
    
    if (_searchHelper.isActive) {
        return [_searchHelper modifyQuery:query forSearchKey:kMainFeedSearchDataKey];
    }
    return query;
}

- (PFTableViewCell *)tableView:(UITableView *)tableView
                       cellForRowAtIndexPath:(NSIndexPath *)indexPath
                                      object:(nullable PFObject *)object
{
    NSString *referenceClass = [object objectForKey:kMainFeedClassKey];
    NSString *referenceId = [object objectForKey:kMainFeedReferenceKey];
    
    PFQuery *query = [PFQuery queryWithClassName:referenceClass];
    
    //    PFObject *object = [self.objects[indexPath.row] objectForKey:kMainFeedReferenceKey];
    
    UITableViewCell *tableViewCell;
    
    if ([referenceClass isEqualToString:[LITLyric parseClassName]]) {
        tableViewCell = [self.tableView dequeueReusableCellWithIdentifier:kLITLyricsTableViewCellIdentifier];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PFObject *lyricObject = [query getObjectWithId:referenceId];
            NSAssert([lyricObject isKindOfClass:[LITLyric class]], @"Unexpected class for object");
            dispatch_async(dispatch_get_main_queue(), ^{
                [LITLyric updateCell:(LITLyricsTableViewCell *)tableViewCell withObject:(LITLyric *)lyricObject];
                [((LITLyricsTableViewCell *)tableViewCell).likeButton setImage:[UIImage imageNamed:@"likeButton"] forState:UIControlStateNormal];
                [self.delegate updateLikeButtonForCell:tableViewCell andObject:lyricObject];
            });
        });
        
        [((LITLyricsTableViewCell *)tableViewCell).addButton setTag:indexPath.row];
        [((LITLyricsTableViewCell *)tableViewCell).likeButton setTag:indexPath.row];
        [((LITLyricsTableViewCell *)tableViewCell).optionsButton setTag:indexPath.row];
        [((LITLyricsTableViewCell *)tableViewCell).addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [((LITLyricsTableViewCell *)tableViewCell).likeButton addTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [((LITLyricsTableViewCell *)tableViewCell).optionsButton addTarget:self action:@selector(optionsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [((LITLyricsTableViewCell *)tableViewCell).fullHeaderButton setTag:indexPath.row];
        [((LITLyricsTableViewCell *)tableViewCell).fullHeaderButton addTarget:self action:@selector(headerPressed:) forControlEvents:UIControlEventTouchUpInside];
        
    } else if ([referenceClass isEqualToString:[LITSoundbite parseClassName]]) {
        tableViewCell = [self.tableView dequeueReusableCellWithIdentifier:kLITSoundbiteTableViewCellIdentifier];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PFObject *soundbiteObject = [query getObjectWithId:referenceId];
            NSAssert([soundbiteObject isKindOfClass:[LITSoundbite class]], @"Unexpected class for object");
            [_playerHelper getDataForSoundbite:(LITSoundbite *)soundbiteObject atIndexPath:indexPath withCompletionBlock:^(NSURL *fileURL, NSError *error) {
                if (!error) {
                    [((LITSoundbiteTableViewCell *)tableViewCell) initHistogramViewWithFileURL:fileURL];
                } else {
                    NSLog(@"Error setting histogram view: %@", error.localizedDescription);
                }
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                [LITSoundbite updateCell:(LITSoundbiteTableViewCell *)tableViewCell withObject:(LITSoundbite *)soundbiteObject];
                [((LITSoundbiteTableViewCell *)tableViewCell).likeButton setImage:[UIImage imageNamed:@"likeButton"] forState:UIControlStateNormal];
                [self.delegate updateLikeButtonForCell:tableViewCell andObject:soundbiteObject];
            });
        });
        
        
        [((LITSoundbiteTableViewCell *)tableViewCell).addButton setTag:indexPath.row];
        [((LITSoundbiteTableViewCell *)tableViewCell).addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [((LITSoundbiteTableViewCell *)tableViewCell).likeButton setTag:indexPath.row];
        [((LITSoundbiteTableViewCell *)tableViewCell).likeButton addTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [((LITSoundbiteTableViewCell *)tableViewCell).playButton setTag:indexPath.row];
        [((LITSoundbiteTableViewCell *)tableViewCell).playButton addTarget:_playerHelper action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [((LITSoundbiteTableViewCell *)tableViewCell).optionsButton setTag:indexPath.row];
        [((LITSoundbiteTableViewCell *)tableViewCell).optionsButton addTarget:self action:@selector(optionsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [((LITSoundbiteTableViewCell *)tableViewCell).fullHeaderButton setTag:indexPath.row];
        [((LITSoundbiteTableViewCell *)tableViewCell).fullHeaderButton addTarget:self action:@selector(headerPressed:) forControlEvents:UIControlEventTouchUpInside];
        
    } else if ([referenceClass isEqualToString:[LITDub parseClassName]]) {
        tableViewCell = [self.tableView dequeueReusableCellWithIdentifier:kLITDubTableViewCellIdentifier];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PFObject *dubObject = [query getObjectWithId:referenceId];
            NSAssert([dubObject isKindOfClass:[LITDub class]], @"Unexpected class for object");
            dispatch_async(dispatch_get_main_queue(), ^{
                [LITDub updateCell:(LITDubTableViewCell *)tableViewCell withObject:(LITDub *)dubObject];
                [((LITDubTableViewCell *)tableViewCell).likeButton setImage:[UIImage imageNamed:@"likeButton"] forState:UIControlStateNormal];
                [self.delegate updateLikeButtonForCell:tableViewCell andObject:dubObject];
            });
        });
        
        
        [((LITDubTableViewCell *)tableViewCell).addButton setTag:indexPath.row];
        [((LITDubTableViewCell *)tableViewCell).likeButton setTag:indexPath.row];
        [((LITDubTableViewCell *)tableViewCell).optionsButton setTag:indexPath.row];
        
        [((LITDubTableViewCell *)tableViewCell).addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [((LITDubTableViewCell *)tableViewCell).likeButton addTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [((LITDubTableViewCell *)tableViewCell).optionsButton addTarget:self action:@selector(optionsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [((LITDubTableViewCell *)tableViewCell).fullHeaderButton setTag:indexPath.row];
        [((LITDubTableViewCell *)tableViewCell).fullHeaderButton addTarget:self action:@selector(headerPressed:) forControlEvents:UIControlEventTouchUpInside];
        
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"Object doesn't match any of expected types"];
    }
    
    return (PFTableViewCell *)tableViewCell;
    
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (indexPath.row >= [self.objects count]) {
        return 50.0f;
    }
    NSString *referenceClassName = [[self.objects objectAtIndex:indexPath.row] objectForKey:kMainFeedClassKey];
    if ([referenceClassName isEqualToString:[LITSoundbite parseClassName]]) {
        //Will get a soundbite
        return kLITSoundbiteCellHeight;
    } else if ([referenceClassName isEqualToString:[LITDub parseClassName]]) {
        return kLITDubCellHeight;
    } else if ([referenceClassName isEqualToString:[LITLyric parseClassName]]) {
        return kLITLyricsCellHeight;
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"Unexpected object class"];
    }
    return 0.0f;
}

#pragma mark - Actions

- (void)headerPressed:(UIButton *)headerButton
{
    NSString *className = [self.objects[headerButton.tag] objectForKey:kMainFeedClassKey];
    NSString *referenceID = [self.objects[headerButton.tag] objectForKey:kMainFeedReferenceKey];
    [[PFQuery queryWithClassName:className] getObjectInBackgroundWithId:referenceID block:^(PFObject *object, NSError *error) {
        NSAssert([NSThread isMainThread], @"This call must be run on the main thread");
        if (!error) {
            
            PFUser *objectOwner;
            if([object isKindOfClass:[LITSoundbite class]]){
                objectOwner = ((LITSoundbite *)object).user;
            }
            else if([object isKindOfClass:[LITDub class]]){
                objectOwner = ((LITDub *)object).user;
            }
            else if([object isKindOfClass:[LITLyric class]]){
                objectOwner = ((LITLyric *)object).user;
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(showProfileOfUser:)]) {
                [self.delegate showProfileOfUser:objectOwner];
            }
        }
    }];
}

- (void)addButtonPressed:(UIButton *)addButton
{
    if (self.isAdding) {
        return;
    }
    self.adding = YES;
    [[Mixpanel sharedInstance] track:kMixpanelAction_addToKeyboard_Plus_ContentFeed properties:nil];
    
    NSString *className = [self.objects[addButton.tag] objectForKey:kMainFeedClassKey];
    NSString *referenceID = [self.objects[addButton.tag] objectForKey:kMainFeedReferenceKey];
    [[PFQuery queryWithClassName:className] getObjectInBackgroundWithId:referenceID block:^(PFObject *object, NSError *error) {
        NSAssert([NSThread isMainThread], @"This call must be run on the main thread");
        if (!error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(queryViewController:didRequestAddingObject:)]) {
                [self.delegate queryViewController:self didRequestAddingObject:object];
            }
        }
        self.adding = NO;
    }];
}

- (void)likeButtonPressed:(UIButton *)likeButton
{
    NSString *className = [self.objects[likeButton.tag] objectForKey:kMainFeedClassKey];
    NSString *referenceID = [self.objects[likeButton.tag] objectForKey:kMainFeedReferenceKey];
    [[PFQuery queryWithClassName:className] getObjectInBackgroundWithId:referenceID block:^(PFObject *object, NSError *error) {
        NSAssert([NSThread isMainThread], @"This call must be run on the main thread");
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:likeButton.tag inSection:0]];
        if (!error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(queryViewController:didTapLikeButton:forObject: withLikesLabel:)]) {
                [self.delegate queryViewController:self didTapLikeButton:likeButton forObject:object withLikesLabel:[cell valueForKey:@"likesLabel"]];
            }
        }
    }];
}


- (void)optionsButtonPressed:(UIButton *)optionsButton
{
    [[Mixpanel sharedInstance] track:kMixpanelAction_threeDots_ContentFeed properties:nil];
    
    NSString *className = [self.objects[optionsButton.tag] objectForKey:kMainFeedClassKey];
    NSString *referenceID = [self.objects[optionsButton.tag] objectForKey:kMainFeedReferenceKey];
    [[[PFQuery queryWithClassName:className] includeKey:@"user"] getObjectInBackgroundWithId:referenceID block:^(PFObject *object, NSError *error) {
        NSAssert([NSThread isMainThread], @"This call must be run on the main thread");
        if (!error && !self.optionsVisible) {
            self.optionsVisible = YES;
            [optionsButton setEnabled:NO];
            if (self.delegate && [self.delegate respondsToSelector:@selector(queryViewController:didTapOptionsButton:forObject:withImage:)]) {
                [self.delegate queryViewController:self didTapOptionsButton:optionsButton forObject:object withImage:nil];
            }
        }
    }];
}

#pragma mark LITTableSearchHosting Delegate

- (UIView *)headerView
{
    return self.tableView.tableHeaderView;
}

- (void)setHeaderView:(UIView *)headerView
{
    self.tableView.tableHeaderView = headerView;
}

- (UIScrollView *)scrollView
{
    return self.tableView;
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    self.emojiVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([LITEmojiSearchCollectionViewController class])];

    if([_searchHelper.searchController isActive]){
        [_searchHelper.searchController resignFirstResponder];
        [_searchHelper.searchController.searchBar resignFirstResponder];
    }
    else{
        [_searchHelper.searchController setActive:YES];
    }
    
    [self.emojiVC setDelegate:self];
    [self presentViewController:self.emojiVC animated:YES completion:nil];
}

- (void)performSearchWithString:(NSString *)emojiString
{
    [_searchHelper replaceSearchBarIconWithEmoji:emojiString];
    _searchHelper.searchString = [emojiString lowercaseString];
    [_searchHelper.host loadObjects];
}


#pragma mark LITEmojiSearchDelegate
- (void) didTapCloseButton:(LITEmojiSearchCollectionViewController *) emojiCV
{
    [self.emojiVC dismissViewControllerAnimated:YES completion:^{
        [self performSearchWithString:emojiCV.emojiString];
    }];
}


#pragma mark Invocation Forwarding
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([_playerHelper respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:_playerHelper];
    } else if ([_searchHelper respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:_searchHelper];
    }else {
        [super forwardInvocation:anInvocation];
    }
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature* signature = [super methodSignatureForSelector:selector];
    if (!signature) {
        signature = [_playerHelper methodSignatureForSelector:selector];
        if (!signature) {
            signature = [_searchHelper methodSignatureForSelector:selector];
        }
    }
    return signature;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector] ||
        [_playerHelper respondsToSelector:aSelector] ||
        [_searchHelper respondsToSelector:aSelector])
    {
        return YES;
    }
    return NO;
}


@end
