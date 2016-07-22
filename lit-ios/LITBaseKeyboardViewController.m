//
//  LITBaseKeyboardViewController.m
//  
//
//  Created by ioshero on 21/08/2015.
//
//

#import "LITBaseKeyboardViewController.h"
#import "LITProfileKeyboardsViewController.h"
#import "LITKeyboardFeedViewController.h"
#import "LITKeyboard.h"
#import "LITKeyboardTableViewCell.h"
#import "LITKBBaseCollectionViewCell.h"
#import "LITReportViewController.h"
#import "LITProfileKeyboardsViewController.h"
#import "LITProgressHud.h"
#import "LITKeyboardInstallerHelper.h"
#import "ParseGlobals.h"
#import "LITTheme.h"
#import "UICollectionView+OptionsPresenting.h"
#import "LITKBSoundbiteCollectionViewCell.h"
#import "LITKBDubCollectionViewCell.h"
#import "LITKeyboardCellPlayerHelper.h"
#import "LITAddContentViewController.h"
#import "LITSoundbitesViewController.h"
#import "LITDubsViewController.h"
#import "LITLyricsViewController.h"
#import "LITGradientNavigationBar.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import <DMActivityInstagram/DMActivityInstagram.h>
#import <DateTools/DateTools.h>
#import <ParseUI/PFImageView.h>
#import <Parse/PFQuery.h>
#import <Parse/PFUser.h>
#import <Parse/PFFile.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <Bolts/Bolts.h>
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"
#import <AFViewShaker/AFViewShaker.h>
#import "WSCoachMarksView.h"
#import "LITGlobals.h"

NSUInteger const kLITIndexSectionOptions = 0;
NSUInteger const kLITIndexSectionShare = 1;
NSUInteger const kLITNumSections = 2;
NSUInteger const kLITNumOptions = 3;

NSString *const kLITSoundbiteClass = @"soundbite";
NSString *const kLITDubClass = @"dub";
NSString *const kLITLyricClass = @"lyric";

static NSString *const kTurnOnSoundMessage = @"Turn on your sound 🙉";

@interface LITBaseKeyboardViewController () <WSCoachMarksViewDelegate, LITAddContentViewControllerDelegate>

@property (strong, nonatomic) JGProgressHUD *hud;
@property (strong, nonatomic) UIPasteboard *pasteboard;

@property (strong, nonatomic) UICollectionView *targetCollectionView;

@property (strong, nonatomic) PFObject *object;
@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *objectClass;
@property (strong, nonatomic) UICollectionView *objectCollectionView;
@property (strong, nonatomic) NSIndexPath *objectIndexPath;

@property (strong, nonatomic) UIView *optionsPresentationView;
@property (strong, nonatomic) UITableView *optionsTableView;

@property (strong, nonatomic) UICollectionReusableView *headerContainerView;

@property (strong, nonatomic) NSMutableDictionary *footerMapping;

@property (strong, nonatomic) NSIndexPath *addingToKeyboardIndexPath;

@end

@implementation LITBaseKeyboardViewController {
    LITTableSearchHelper *_searchHelper;
    LITKeyboardCellPlayerHelper *_playerHelper;
}

@synthesize headerView=_headerView;

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        
        _footerMapping = [NSMutableDictionary new];
        _keyboardInstallationsMapping = [NSMutableDictionary new];
        
        // Customize the table
        
        // The className to query on
        self.parseClassName = [LITKeyboard parseClassName];
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = kLITObjectsPerPage;
        
        _searchHelper = [[LITTableSearchHelper alloc] initWithTableSearchHosting:self];
        _playerHelper = [[LITKeyboardCellPlayerHelper alloc] initWithKeyboardControllerHosting:self];
        self.loadingViewEnabled = NO;
        
        self.optionsVisible = NO;
        
        _shouldShowSearch = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *optionsPresentationView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    UITableView *optionsTableView = [[UITableView alloc] initWithFrame:CGRectZero];
    [optionsTableView setSeparatorColor:[UIColor colorWithWhite:1 alpha:.3]];
    [optionsTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [optionsTableView setTag:kOptionsTableViewTag];
    [optionsTableView setBackgroundColor:[UIColor clearColor]];
    [optionsTableView setDelegate:self];
    [optionsTableView setDataSource:self];
    optionsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [optionsPresentationView addSubview:optionsTableView];
    optionsPresentationView.clipsToBounds = YES;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    [button setImage:[UIImage imageNamed:@"iconClose"] forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(optionsCloseButtonTapped:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [optionsPresentationView addSubview:button];
    
    NSDictionary *bindings = NSDictionaryOfVariableBindings(optionsTableView, button);
    NSArray *vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[optionsTableView]|" options:0 metrics:nil views:bindings];
    NSArray *hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[optionsTableView]|" options:0 metrics:nil views:bindings];
    [optionsPresentationView addConstraints:vConstraints];
    [optionsPresentationView addConstraints:hConstraints];
    
    NSArray *bvConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[button(30)]-10-|" options:0 metrics:nil views:bindings];
    NSArray *bhConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(30)]-10-|" options:0 metrics:nil views:bindings];
    [optionsPresentationView addConstraints:bvConstraints];
    [optionsPresentationView addConstraints:bhConstraints];
    
    self.optionsPresentationView = optionsPresentationView;
    self.optionsTableView = optionsTableView;
    
    [self.optionsTableView registerClass:[UITableViewCell class]
                  forCellReuseIdentifier:kLITOptionsTableViewCellIdentifier];

    
    [self configureCollectionView:self.collectionView];
    
    
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:@"HeaderView"];
    
    [self.collectionView setBackgroundColor:[UIColor colorWithWhite:0.6 alpha:1.0]];

}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
//    [self.tableView setBackgroundColor:[UIColor lit_lightGreyColor]];
}

-(void)didDismissKeyboardCoach {
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kLITnotificationCellCoachDismissed]){
     
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        
        UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
        
        // Coach Marks
        
        // Setup coach marks
        NSArray *coachMarks = @[
                                @{
                                    @"rect": [NSValue valueWithCGRect:
                                              CGRectMake(attributes.frame.origin.x,
                                                         attributes.frame.origin.y+kLITheightCellDifference,
                                                         attributes.frame.size.width,
                                                         attributes.frame.size.height)],
                                    @"caption": @"This is just one of the 6 pieces of content any keyboard can have at any given time.",
                                    @"shape": @"square"
                                    }
                                ];
        WSCoachMarksView *coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.navigationController.view.bounds coachMarks:coachMarks];
        [coachMarksView setTag:kLITCellCoachTag];
        [self.navigationController.view addSubview:coachMarksView];
        [coachMarksView setMaskColor:[UIColor colorWithWhite:0 alpha:.75]];
        [coachMarksView setEnableSkipButton:NO];
        [coachMarksView setEnableContinueLabel:NO];
        [coachMarksView.lblCaption setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:14.0f]];
        [coachMarksView setDelegate:self];
        [coachMarksView start];

        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kLITnotificationCellCoachDismissed];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)didDismissCellCoach {
    
    // Simulate a tap
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    NSDictionary *params = @{kTouchDetectorIndexPathKey : indexPath,
                             kTouchDetectorCollectionViewKey: self.collectionView
                             };
    [self singleTapDetectedOnCellAtIndexPathForCollectionView:params];
    
    // Setup coach marks
    NSArray *coachMarks = @[
                            @{
                                @"rect": [NSValue valueWithCGRect:
                                          CGRectMake(attributes.frame.origin.x,
                                                     attributes.frame.origin.y+kLITheightCellDifference,
                                                     attributes.frame.size.width,
                                                     attributes.frame.size.height)],
                                @"caption": @"If you tap any keyboard piece it will preview its content.\n\n This means that Soundbites will play a sound and Dubs will play the video they have assigned.",
                                @"shape": @"square"
                                }
                            ];
    WSCoachMarksView *coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.navigationController.view.bounds coachMarks:coachMarks];
    [coachMarksView setTag:kLITSingleTapCoachTag];
    [self.navigationController.view addSubview:coachMarksView];
    [coachMarksView setMaskColor:[UIColor colorWithWhite:0 alpha:.75]];
    [coachMarksView setEnableSkipButton:NO];
    [coachMarksView setEnableContinueLabel:NO];
    [coachMarksView.lblCaption setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:14.0f]];
    [coachMarksView setDelegate:self];
    [coachMarksView start];
}

- (void)didDismissSingleTapCoach {
    
    // Simulate a long press
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    NSDictionary *params = @{kTouchDetectorIndexPathKey : indexPath,
                             kTouchDetectorCollectionViewKey: self.collectionView
                             };
    [self longPressDetectedOnCellAtIndexPathForCollectionView:params];
    
    // Setup coach marks
    NSArray *coachMarks = @[
                            @{
                                @"rect": [NSValue valueWithCGRect:
                                          CGRectMake(attributes.frame.origin.x,
                                                     attributes.frame.origin.y+kLITheightCellDifference,
                                                     attributes.frame.size.width*3+4,
                                                     attributes.frame.size.height*2+2)],
                                @"caption": @"Tap and hold any keyboard cell to finesse individual pieces of content.",
                                @"shape": @"square"
                                }
                            ];
    WSCoachMarksView *coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.navigationController.view.bounds coachMarks:coachMarks];
    [coachMarksView setTag:kLITLongPressCoachTag];
    [self.navigationController.view addSubview:coachMarksView];
    [coachMarksView setMaskColor:[UIColor colorWithWhite:0 alpha:.75]];
    [coachMarksView setEnableSkipButton:NO];
    [coachMarksView setEnableContinueLabel:NO];
    [coachMarksView.lblCaption setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:14.0f]];
    [coachMarksView setDelegate:self];
    [coachMarksView start];
}

- (void)didDismissLongPressCoach {
    [self optionsCloseButtonTapped:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLITnotificationLongPressCoachDismissed
                                                        object:nil
                                                      userInfo:nil];
}

#pragma mark - WSCoachMarks Delegate

- (void)coachMarksView:(WSCoachMarksView*)coachMarksView willNavigateToIndex:(NSUInteger)index {}
- (void)coachMarksView:(WSCoachMarksView*)coachMarksView didNavigateToIndex:(NSUInteger)index {}
- (void)coachMarksViewDidCleanup:(WSCoachMarksView*)coachMarksView {}
- (void)coachMarksViewWillCleanup:(WSCoachMarksView*)coachMarksView {
    
//    if(coachMarksView.tag == kLITKeyboardCoachTag){
//        [self didDismissKeyboardCoach];
//    }
//    else if(coachMarksView.tag == kLITCellCoachTag){
//        [self didDismissCellCoach];
//    }
//    else if(coachMarksView.tag == kLITSingleTapCoachTag){
//        [self didDismissSingleTapCoach];
//    }
//    else if(coachMarksView.tag == kLITLongPressCoachTag){
//        [self didDismissLongPressCoach];
//    }
    
    if(coachMarksView.tag == kLITKeyboardCoachTag){
        [self didDismissSingleTapCoach];
    }
    else if(coachMarksView.tag == kLITLongPressCoachTag){
        [self didDismissLongPressCoach];
    }
}


#pragma mark - PFQueryTableViewController
- (PFQuery *)queryForCollection
{
    PFQuery *query = [super queryForCollection];
    [query whereKey:@"objectId" notEqualTo:kLITKeyboardObjectId];
    
    if([self class] != [LITProfileKeyboardsViewController class]){
        [query whereKey:kLITObjectHiddenKey equalTo:[NSNumber numberWithBool:false]];
        [query orderByDescending:kLITKeyboardPriorityKey];
        //[query orderByDescending:kLITKeyboardFeaturedKey];
    }
    [query addDescendingOrder:kLITKeyboardCreatedAtKey];
    if (_searchHelper.isActive) {
        return [_searchHelper modifyQuery:query forSearchKey:kLITKeyboardSearchDataKey];
    }
    return query;
}

- (void)objectsDidLoad:(nullable NSError *)error
{
    [super objectsDidLoad:error];
    
    // Once the keyboards have loaded, we store the state of each
    // keyboard so we know if they are installed, cloud, or never installed
    
    for(int i = 0; i<[self.objects count]; i++){
        LITKeyboard *keyboard = [self.objects objectAtIndex:i];
        [[LITKeyboardInstallerHelper checkKeyboardStatus:keyboard] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
            NSValue *keyboardKey = [NSValue valueWithNonretainedObject:keyboard];
            [self.keyboardInstallationsMapping setObject:@([task.result integerValue]) forKey:keyboardKey];
            return nil;
        }];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.optionsTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLITOptionsTableViewCellIdentifier];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:32]];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        if (indexPath.section == kLITIndexSectionOptions) {
            switch (indexPath.row) {
                case kLITIndexAddToKeyboard: {
                    [cell.imageView setImage:[UIImage imageNamed:@"addToFavs"]];
                    [cell.textLabel setText:@"Add to Keyboard"];
                    break;
                }
                case kLITIndexFav: {
                    // Check if the object is already favorited
                    PFObject *favKB = [[PFUser currentUser] objectForKey:kUserFavKeyboardKey];
                    NSString *favKBid = favKB.objectId;
                    
                    [cell.textLabel setText:@""];
                    [cell.imageView setImage:[UIImage imageNamed:@"addToFavs"]];
                    
                    PFQuery *query = [PFQuery queryWithClassName:kUserFavKeyboardKey];
                    [query getObjectInBackgroundWithId:favKBid block:^(PFObject *favKeyboard, NSError *error) {
                        if ([[favKeyboard objectForKey:kFavKeyboardContentsKey] containsObject:self.object]) {
                            [cell.textLabel setText:@"Remove from your favorites"];
                            [cell.imageView setImage:[UIImage imageNamed:@"removeFromFavs"]];
                        } else {
                            [cell.textLabel setText:@"Add to your favorites"];
                            [cell.imageView setImage:[UIImage imageNamed:@"addToFavs"]];
                        }
                    }];
                    break;
                }
                case kLITIndexReport:
                    [cell.imageView setImage:[UIImage imageNamed:@"reportItem"]];
                    [cell.textLabel setText:@"Report content"];
                    break;
                default:
                    [NSException raise:NSInternalInconsistencyException
                                format:@"Unexpected row in indexPath"];
                    break;
            }
        } else if (indexPath.section == kLITIndexSectionShare) {
            switch (indexPath.row) {
                    
                case 0:
                    [cell.imageView setImage:[UIImage imageNamed:@"shareItem"]];
                    [cell.textLabel setText:[NSString stringWithFormat:@"Share %@...",self.objectClass]];
                    break;
                    
            /*
                case kLITIndexShareMessages:
                    [cell.imageView setImage:[UIImage imageNamed:@"messagesShare"]];
                    [cell.textLabel setText:@"Messages"];
                    break;
                case kLITIndexShareFacebook:
                    [cell.imageView setImage:[UIImage imageNamed:@"facebookShare"]];
                    [cell.textLabel setText:@"Facebook"];
                    break;
                case kLITIndexShareFacebookMessenger:
                    [cell.imageView setImage:[UIImage imageNamed:@"facebookMessengerShare"]];
                    [cell.textLabel setText:@"Facebook Messenger"];
                    break;
                case kLITIndexShareTwitter:
                    [cell.imageView setImage:[UIImage imageNamed:@"twitterShare"]];
                    [cell.textLabel setText:@"Twitter"];
                    break;
                case kLITIndexShareWhatsapp:
                    [cell.imageView setImage:[UIImage imageNamed:@"whatsappShare"]];
                    [cell.textLabel setText:@"Whatsapp"];
                    break;
                case kLITIndexShareSlack:
                    [cell.imageView setImage:[UIImage imageNamed:@"slackShare"]];
                    [cell.textLabel setText:@"Slack"];
                    break;
                case kLITIndexShareInstagram:
                    [cell.imageView setImage:[UIImage imageNamed:@"instagramShare"]];
                    [cell.textLabel setText:@"Instagram"];
                    break;
                case kLITIndexShareTumblr:
                    [cell.imageView setImage:[UIImage imageNamed:@"tumblrShare"]];
                    [cell.textLabel setText:@"Tumblr"];
                    break;
             */
                    
                default:
                    [NSException raise:NSInternalInconsistencyException
                                format:@"Unexpected row in indexPath"];
                    break;
            }
        } else [NSException raise:NSInternalInconsistencyException
                           format:@"Unexpected section in indexPath"];
        return cell;
        
    } else return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.optionsTableView) {
        if (section == kLITIndexSectionOptions) {
            return nil;
        } else return @"SHARE CONTENT";
        
    } else return nil;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.optionsTableView) {
        if (section == kLITIndexSectionOptions) {
            return kLITNumOptions;
        } else /*return kLITNumShareApps;*/ return 1;
    } else return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.optionsTableView) {
        return kLITNumSections;
    } else return 0;
}

#pragma mark - UICollectionView

- (nullable PFObject *)objectAtIndexPath:(nullable NSIndexPath *)indexPath
{
    if ([self.objects count] == 0) {
        return nil;
    }
    NSInteger section;
    
    if (self.shouldShowSearch && [self.objects count] > 0) {
        if (indexPath.section == 0) {
            return nil;
        } else if (indexPath.section == [self.objects count] + 1) {
            return nil;
        } else {
            section = indexPath.section - 1;
        }
        return self.objects[section];
    } else return self.objects[indexPath.section];
}

- (PFCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    
    PFCollectionViewCell *cell = (PFCollectionViewCell *)[self collectionView:collectionView cellForItemAtIndexPath:indexPath usingKeyboard:(LITKeyboard *)object];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger maxSectionNumber = self.shouldShowSearch ? [self.objects count] + 1 : [self.objects count];
    if (indexPath.section == maxSectionNumber &&
        indexPath.section != 0 &&
        kind == UICollectionElementKindSectionFooter) {
        
        UICollectionReusableView *loadMoreFooter = [super collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
        for(UIView *view in [loadMoreFooter subviews]){
            if([view isKindOfClass:[UILabel class]]){
                ((UILabel *)view).frame = CGRectMake(20, ((UILabel *)view).frame.origin.y + 2, ((UILabel *)view).frame.size.width, ((UILabel *)view).frame.size.height);
            }
        }
        return loadMoreFooter;
    }
    if (indexPath.section == 0 && self.shouldShowSearch) {
        self.headerContainerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        [self.headerContainerView setFrame:CGRectMake(0, 0, CGRectGetWidth(collectionView.frame), 44.0)];
        [self.headerContainerView setBackgroundColor:[UIColor lit_lightGreyColor]];
        if (self.shouldShowSearch && [[self.headerContainerView subviews] count] == 0) {
            _searchHelper = [[LITTableSearchHelper alloc] initWithTableSearchHosting:self];
            [_searchHelper setupSearch];
            NSAssert([self.parentViewController
                      conformsToProtocol:@protocol(LITSearchPresentationDelegate)],
                     @"Parent View Controller must conform to LITSearchPresentationDelegate");
            [_searchHelper setPresentationDelegate:(id<LITSearchPresentationDelegate>)self.parentViewController];
        }
        return self.headerContainerView;
    }
    UICollectionReusableView *view;
    LITKeyboard *keyboard = (LITKeyboard *)[self objectAtIndexPath:indexPath];
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        LITKeyboardHeaderView *headerView = (LITKeyboardHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"LITKeyboardHeaderView" forIndexPath:indexPath];

        [[keyboard.user fetchIfNeededInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask<__kindof PFObject *> *task) {
            [headerView.userLabel setText:keyboard.user.username];
            [headerView.userImageView setFile:[keyboard.user objectForKey:@"picture"]];
            [headerView.userImageView loadInBackground];
            return nil;
        }];
        
        [headerView.fullHeaderButton setTag:indexPath.section];
        [headerView.fullHeaderButton addTarget:self action:@selector(headerPressed:) forControlEvents:UIControlEventTouchUpInside];

        NSInteger originalCounter = [[keyboard valueForKey:kLITKeyboardLikesKey] integerValue];
        [headerView.likesLabel setText:[NSString stringWithFormat:@"%ld",(long)originalCounter]];
        
        [((UIButton *)headerView.downloadButton) setHidden:YES];
        view = headerView;
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        LITKeyboardFooterView *footerView = (LITKeyboardFooterView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"LITKeyboardFooterView" forIndexPath:indexPath];
        
        [self.footerMapping setObject:footerView forKey:@(indexPath.section)];
        NSAssert([footerView isKindOfClass:[LITKeyboardFooterView class]],
                 @"Header view must be of class LITKeyboardFooterView");
        
        [footerView.titleLabel setText:keyboard.displayName];
        
        [footerView.optionsButton setTag:indexPath.section];
        [footerView.optionsButton addTarget:self action:@selector(optionsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [footerView.editButton setTitle:@"EDIT" forState:UIControlStateNormal];

        view = footerView;
    }
    
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0 && self.shouldShowSearch) {
        return CGSizeMake(CGRectGetWidth(collectionView.frame), 44.0f);
    } if (section == [self.objects count] + 1 && self.shouldShowSearch){
        return CGSizeZero;
    }else return kLITKeyboardHeaderReferenceSize;

}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section
{
    if (section == 0 && self.shouldShowSearch) {
        return CGSizeZero;
    } else return kLITKeyboardFooterReferenceSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0 && self.shouldShowSearch) ||
        (indexPath.section == [self.objects count] + 1 && self.shouldShowSearch)) {
        return CGSizeZero;
    } else return CGSizeMake(kLITKeyboardCellItemPortraitDimension, kLITKeyboardCellItemPortraitDimension);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ((section == 0 && self.shouldShowSearch) ||
        (section == [self.objects count] + 1 && self.shouldShowSearch)) {
        return 0;
    } else return 6;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.shouldShowSearch ? [self.objects count] + 2 : [self.objects count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.optionsTableView) {
        return 44.0f;
    } else {
        if (indexPath.row >= [self.objects count]) {
            return 50.0f;
        }
        else
            return kLITKeyboardCellHeight;
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.optionsTableView) {
        
    } else {
        if ([cell isKindOfClass:[LITKeyboardTableViewCell class]]) {
            [((LITKeyboardTableViewCell *) cell) setCollectionViewDataSourceDelegate:self indexPath:indexPath];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        [headerView.textLabel setTextColor:[UIColor whiteColor]];
        [headerView.textLabel setAlpha:.7];
        [headerView.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:12.0f]];
        headerView.contentView.backgroundColor = [UIColor clearColor];
        headerView.backgroundView.backgroundColor = [UIColor clearColor];
        
        CGRect bottomFrame = CGRectMake(20, view.frame.size.height-1, view.frame.size.width, 1);
        CGRect topFrame = CGRectMake(20, 1, view.frame.size.width, 1);
        UIView *seperatorView =[[UIView alloc] initWithFrame:bottomFrame];
        seperatorView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:.2];
        [headerView addSubview:seperatorView];
        seperatorView =[[UIView alloc] initWithFrame:topFrame];
        seperatorView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:.2];
        [headerView addSubview:seperatorView];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.optionsTableView) {
        if(indexPath.section == kLITIndexSectionOptions){
            
            switch (indexPath.item) {
                
                case kLITIndexAddToKeyboard:
                    [self addObjectInTableView:tableView withIndexPath:indexPath];
                    break;
                
                case kLITIndexFav:
                    [self favoriteObjectInTableView:tableView withIndexPath:indexPath];
                    break;
                    
                case kLITIndexReport:
                    
                    [[Mixpanel sharedInstance] track:kMixpanelAction_reportCont_HoldDown_KFeed properties:nil];
                    
                    LITReportViewController *reportVC = [self.storyboard   instantiateViewControllerWithIdentifier:@"reportVC"];
                    [reportVC assignObject:self.object];
                    [self.navigationController presentViewController:reportVC animated:YES completion:nil];
                    break;
            }
        } else if(indexPath.section == kLITIndexSectionShare){
            
            [[Mixpanel sharedInstance] track:kMixpanelAction_shareCont_HoldDown_KFeed properties:nil];
            
            [self generateDatafromObjectToShareInAppWithIndex:indexPath.item];
        }
    }
}

#pragma mark Feed Delegate

- (void)optionsButtonPressed:(UIButton *)optionsButton
{
    [[Mixpanel sharedInstance] track:kMixpanelAction_dots_KeyboardFeed properties:nil];
    
    NSIndexPath* cellIndexPath = [NSIndexPath indexPathForItem:0 inSection:optionsButton.tag];
    UICollectionViewLayoutAttributes* attr = [self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:cellIndexPath];
    UIEdgeInsets insets = self.collectionView.scrollIndicatorInsets;
    
    CGRect rectScroll = attr.frame;
    rectScroll.size = self.collectionView.frame.size;
    rectScroll.size.height -= insets.top + insets.bottom;
    CGFloat offset = (rectScroll.origin.y + rectScroll.size.height) - self.collectionView.contentSize.height;
    if ( offset > 0.0 ) rectScroll = CGRectOffset(rectScroll, 0, -offset);
    
    [UIView animateWithDuration:.2 animations:^{
        [self.collectionView scrollRectToVisible:rectScroll animated:NO];// YES + completion
    } completion:^(BOOL finished) {
        
        // Get the snapshot from the keyboard cell
        
        UIGraphicsBeginImageContext(self.collectionView.contentSize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.collectionView.layer renderInContext:context];
        UIImage *fullCollectionImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // Crop the header and the grey footer
        CGSize size = [fullCollectionImage size];
        
        int sectionHeaderHeight = 54;
        int searchBarHeight = 44;
        int sectionContentHeight = (int)((((size.width)/3)*2)+38);
        int sectionGreyBarHeight = 15;
        int fullSectionHeight = sectionHeaderHeight + sectionContentHeight + sectionGreyBarHeight;
        
        CGRect rect = CGRectMake(0,
                                 searchBarHeight + fullSectionHeight*(optionsButton.tag
                                                                      -1) + sectionHeaderHeight,
                                 size.width,
                                 sectionContentHeight);
        CGImageRef imageRef = CGImageCreateWithImageInRect([fullCollectionImage CGImage], rect);
        UIImage *img = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
        
        NSString *className = @"keyboard";
        //    NSString *referenceID = [self.objects[optionsButton.tag] objectId];
        NSString *referenceID = [[self objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:optionsButton.tag]] objectId];
        
        [[[PFQuery queryWithClassName:className] includeKey:@"user"] getObjectInBackgroundWithId:referenceID block:^(PFObject *object, NSError *error) {
            NSAssert([NSThread isMainThread], @"This call must be run on the main thread");
            if (!error && !self.optionsVisible) {
                self.optionsVisible = YES;
                [optionsButton setEnabled:NO];
                if (self.delegate && [self.delegate respondsToSelector:@selector(queryViewController:didTapOptionsButton:forObject:withImage:)]) {
                    [self.delegate queryViewController:self didTapOptionsButton:optionsButton forObject:object withImage:img];
                }
            }
        }];

    }];
    
    
}


#pragma mark - LITKeyboardCellTouchDetector
- (void)singleTapDetectedOnCellAtIndexPathForCollectionView:(NSDictionary *)dictionary
{
    NSIndexPath *indexPath = [dictionary objectForKey:kTouchDetectorIndexPathKey];
    UICollectionView *collectionView = [dictionary objectForKey:kTouchDetectorCollectionViewKey];
    self.addingToKeyboardIndexPath = indexPath;
    
    if ([[collectionView cellForItemAtIndexPath:indexPath] isKindOfClass:[LITKBEmptyCollectionViewCell class]]) {
        LITAddContentViewController *contentViewController = [[UIStoryboard storyboardWithName:@"Main"
                                                                                        bundle:nil]
                                                              instantiateViewControllerWithIdentifier:NSStringFromClass([LITAddContentViewController class])];
        [contentViewController setDelegate:self];
        if([self class] == [LITKeyboardFeedViewController class]){
            LITKeyboard *keyboard = [self.objects objectAtIndex:indexPath.section-1];
            [contentViewController setKeyboard:keyboard];
            [self presentViewController:contentViewController animated:YES completion:nil];
        }
        else if([self class] == [LITProfileKeyboardsViewController class]){
            LITKeyboard *keyboard = [self.objects objectAtIndex:indexPath.section];
            [contentViewController setKeyboard:keyboard];
            [self presentViewController:contentViewController animated:YES completion:nil];
        }
    } else {
        // Cell's object data
        [self saveObjectDataFromCell:(LITKBBaseCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath]];
        
        // Preview the object data
        [self previewObjectAtIndexPath:indexPath withCollectionView:collectionView];
    }
}

// Only for the extension
- (void)animationLongPressDetectedOnCellAtIndexPathForCollectionView:(NSDictionary *)dictionary
{
}

- (void)doubleTapDetectedOnCellAtIndexPathForCollectionView:(NSDictionary *)dictionary
{
    /*
    NSIndexPath *indexPath = [dictionary objectForKey:kTouchDetectorIndexPathKey];
    UICollectionView *collectionView = [dictionary objectForKey:kTouchDetectorCollectionViewKey];
    
    // Cell's object data
    [self saveObjectDataFromCell:(LITKBBaseCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath]];
    
    // Preview the object data
    [self previewObjectAtIndexPath:indexPath withCollectionView:collectionView];
    */
    
    NSLog(@"double tap");
}


- (void)longPressDetectedOnCellAtIndexPathForCollectionView:(NSDictionary *)dictionary
{
    [[Mixpanel sharedInstance] track:kMixpanelAction_holdDownContentContainer_KeyboardFeed properties:nil];
    
    NSIndexPath *indexPath = [dictionary objectForKey:kTouchDetectorIndexPathKey];
    UICollectionView *collectionView = [dictionary objectForKey:kTouchDetectorCollectionViewKey];
    
    self.objectCollectionView = collectionView;
    self.objectIndexPath = indexPath;
    
    // Cell's object data
    [self saveObjectDataFromCell:(LITKBBaseCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath]];
    
    [collectionView presentOptionsView:self.optionsPresentationView inKeyboardAtSection:indexPath.section];
    self.targetCollectionView = collectionView;
}

- (void)deleteActionDetectedOnCellAtIndexPathForCollectionView:(NSDictionary *)dictionary {
    NSLog(@"Default implementation does nothing");
}

- (void)saveObjectDataFromCell:(LITKBBaseCollectionViewCell *)cell{
    
    self.objectId = cell.objectId;
    
    if([NSStringFromClass([cell class]) isEqualToString:kLITKBSoundbiteCollectionViewCell]){
        self.objectClass = kLITSoundbiteClass;
    }
    else if([NSStringFromClass([cell class]) isEqualToString:kLITKBDubCollectionViewCell]){
        self.objectClass = kLITDubClass;
    }
    else if([NSStringFromClass([cell class]) isEqualToString:kLITKBLyricCollectionViewCell]){
        self.objectClass = kLITLyricClass;
    }
    
    self.object = [PFObject objectWithoutDataWithClassName:self.objectClass objectId:self.objectId];
}

- (void)optionsCloseButtonTapped:(UIButton *)button
{
    [[Mixpanel sharedInstance] track:kMixpanelAction_close_HoldDown_KExtension properties:nil];
    
    [self.targetCollectionView dismissOptionsView];
}


#pragma mark Functionalities

- (void)headerPressed:(UIButton *)headerButton
{
    LITKeyboard *object;
    if([self isKindOfClass:[LITProfileKeyboardsViewController class]]) {
        object = self.objects[headerButton.tag];
    }
    else {
        object = self.objects[headerButton.tag-1];
    }
    PFUser *objectOwner = object.user;
    
    // Prevent pushing the same profile already presented again
    if(objectOwner == self.user) {
        return;
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(showProfileOfUser:)]) {
        [self.delegate showProfileOfUser:objectOwner];
    }
}


- (void)addObjectInTableView:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath
{
    [[Mixpanel sharedInstance] track:kMixpanelAction_addToKeyboard_Plus_ContentFeed properties:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(queryViewController:didRequestAddingObject:)]) {
        [self.delegate queryViewController:self didRequestAddingObject:self.object];
    }
}


- (void)favoriteObjectInTableView:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath
{
    
    JGProgressHUD * hud = [LITProgressHud createHudWithMessage:@""];
    
    PFObject *favKB = [[PFUser currentUser] objectForKey:kUserFavKeyboardKey];
    NSString *favKBid = favKB.objectId;
    
    PFQuery *query = [PFQuery queryWithClassName:kUserFavKeyboardKey];
    [query getObjectInBackgroundWithId:favKBid block:^(PFObject *favKeyboard, NSError *error) {
        if ([[favKeyboard objectForKey:kFavKeyboardContentsKey] containsObject:self.object]) {
            
            [[Mixpanel sharedInstance] track:kMixpanelAction_addToFavs_HoldDown_KFeed properties:nil];
            
            NSMutableArray *array = [NSMutableArray arrayWithArray:[favKeyboard objectForKey:kFavKeyboardContentsKey]];
            [array removeObject:self.object];
            [favKeyboard setObject:array forKey:kFavKeyboardContentsKey];
            
            [[favKeyboard saveEventually] continueWithBlock:^id(BFTask *task) {
                if (task.error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError withMessage:@"Error removing"];
                        [hud showInView:self.view];
                        [hud dismissAfterDelay:1.5f];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[[tableView cellForRowAtIndexPath:indexPath] textLabel] setText:@"Add to your favorites"];
                        [[[tableView cellForRowAtIndexPath:indexPath] imageView] setImage:[UIImage imageNamed:@"addToFavs"]];
                        [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:@"Removed"];
                        [hud showInView:self.view];
                        [hud dismissAfterDelay:1.5f];
                    });
                }
                return nil;
            }];
        } else {
            
            [[Mixpanel sharedInstance] track:kMixpanelAction_removeFav_HoldDown_KFeed properties:nil];
            
            NSMutableArray *array = [NSMutableArray arrayWithArray:[favKeyboard objectForKey:kFavKeyboardContentsKey]];
            [array addObject:self.object];
            [favKeyboard setObject:array forKey:kFavKeyboardContentsKey];
            
            [[favKeyboard saveEventually] continueWithBlock:^id(BFTask *task) {
                if (task.error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError withMessage:@"Error adding"];
                        [hud showInView:self.view];
                        [hud dismissAfterDelay:1.5f];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[[tableView cellForRowAtIndexPath:indexPath] textLabel] setText:@"Remove from your favorites"];
                        [[[tableView cellForRowAtIndexPath:indexPath] imageView] setImage:[UIImage imageNamed:@"removeFromFavs"]];
                        [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:@"Favorites"];
                        [hud showInView:self.view];
                        [hud dismissAfterDelay:1.5f];
                    });
                }
                return nil;
            }];
        }
    }];
}

- (void)previewObjectAtIndexPath:(NSIndexPath *)indexPath withCollectionView:(UICollectionView *)collectionView {
    
    NSLog(@"%@",NSStringFromClass([self.object class]));
    
    if([NSStringFromClass([self.object class]) isEqualToString:@"LITSoundbite"]){
        
        [[Mixpanel sharedInstance] track:kMixpanelAction_soundContentPreview_KeyboardFeed properties:nil];
        
        [((LITKBSoundbiteCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath]).activityIndicator setHidden:NO];
        [((LITKBSoundbiteCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath]).activityIndicator startAnimating];
        [_playerHelper getDataForSoundbite:(LITSoundbite *)self.object atIndexPath:indexPath withCompletionBlock:^(NSError *error) {
            [((LITKBSoundbiteCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath]).activityIndicator setHidden:YES];
            if (!error) {
                __weak typeof(self) weakSelf = self;
                _playerHelper.silentBlock = ^(BOOL silent) {
                    if (silent) {
                        [weakSelf detectMuteSwitchState:silent forKeyboardAtIndexPath:indexPath withCollectionView:collectionView];
                    }
                };
                [_playerHelper playSoundbite:(LITSoundbite *)self.object atIndexPath:indexPath withCollectionView:collectionView];
            } else {
                NSLog(@"Error previewing soundbite: %@", error.localizedDescription);
            }
        }];
    }
    else if([NSStringFromClass([self.object class]) isEqualToString:@"LITDub"]){
        
        [[Mixpanel sharedInstance] track:kMixpanelAction_videoContentPreview_KeyboardFeed properties:nil];
        
        LITKBDubCollectionViewCell *dubCell = (LITKBDubCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        __weak typeof(self) weakSelf = self;
        dubCell.silentBlock = ^(BOOL silent) {
            if (silent) {
                [weakSelf detectMuteSwitchState:silent forKeyboardAtIndexPath:indexPath withCollectionView:collectionView];
            }
        };
        [dubCell playVideo];
    }
    
    else if([NSStringFromClass([self.object class]) isEqualToString:@"LITLyric"]){
        
        [[Mixpanel sharedInstance] track:kMixpanelAction_lyricContentPreview_KeyboardFeed properties:nil];
    }
}

- (void)detectMuteSwitchState:(BOOL)on
       forKeyboardAtIndexPath:(NSIndexPath *)indexPath
           withCollectionView:(UICollectionView *)collectionView
{
    if (on) {
        LITKeyboardFooterView *footerView = self.footerMapping[@(indexPath.section)];
        NSParameterAssert(footerView);
        
        LITKeyboard *keyboard = (LITKeyboard *)[self objectAtIndexPath:indexPath];
        
        [footerView.titleLabel setText:kTurnOnSoundMessage];
        AFViewShaker *shaker = [[AFViewShaker alloc] initWithView:footerView.titleLabel];
        [shaker shakeWithDuration:2 completion:^{
            [footerView.titleLabel setText:keyboard.displayName];
        }];
    }
}

- (void)generateDatafromObjectToShareInAppWithIndex:(NSUInteger)appIndex
{
    self.hud = [LITProgressHud createHudWithMessage:[NSString stringWithFormat:@"Preparing\n%@",self.objectClass]];
    [self.hud showInView:self.view];
    
    // First of all we get the object
    [[PFQuery queryWithClassName:self.objectClass] getObjectInBackgroundWithId:self.objectId block:^(PFObject *object, NSError *error) {
        
        if(object && !error){

            if(self.objectClass == kLITLyricClass){
                
                // Save the object "use" reference
                PFObject *objectUse = [PFObject objectWithClassName:kLyricUseClassName];
                objectUse[kLyricUseLyricKey] = object;
                objectUse[kLyricUseUserKey] = [PFUser currentUser];
                [objectUse saveInBackground];
                
                NSString *lyricText = object[@"text"];
                [[UIPasteboard generalPasteboard] setString:lyricText];
                [self forwardShareToAppWithIndex:appIndex andText:lyricText];
            }
            
            else if(self.objectClass == kLITDubClass || self.objectClass == kLITSoundbiteClass){
                
                // Save the object "use" reference
                if(self.objectClass == kLITSoundbiteClass){
                    PFObject *objectUse = [PFObject objectWithClassName:kSoundbiteUseClassName];
                    objectUse[kSoundbiteUseSoundbiteKey] = object;
                    objectUse[kSoundbiteUseUserKey] = [PFUser currentUser];
                    [objectUse saveInBackground];
                }
                else if(self.objectClass == kLITDubClass){
                    PFObject *objectUse = [PFObject objectWithClassName:kDubUseClassName];
                    objectUse[kDubUseDubKey] = object;
                    objectUse[kDubUseUserKey] = [PFUser currentUser];
                    [objectUse saveInBackground];
                }
                
                
                PFFile *video = object[@"video"];
                NSURL *videoURL = [NSURL URLWithString:video.url];
                
                
                if(self.objectClass == kLITDubClass){
                    [self shareVideoFromVideoFileURL:videoURL usingWaterMarkImage:[UIImage imageNamed:@"watermark"] withAppIndex:appIndex andViewController:self];
                }
                else {
                    NSURLRequest *request = [NSURLRequest requestWithURL:videoURL];
                    
                    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                        
                        if(connectionError){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                JGProgressHUD * hud = [LITProgressHud createHudWithMessage:@""];
                                [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError withMessage:@"Error sharing"];
                                [hud showInView:self.view];
                                [hud dismissAfterDelay:1.5f];
                                return;
                            });
                        }
                        else{
                            NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
                            NSURL *tempURL = [documentsURL URLByAppendingPathComponent:[videoURL lastPathComponent]];
                            
                            [data writeToURL:tempURL atomically:YES];
                            //UISaveVideoAtPathToSavedPhotosAlbum(tempURL.path, nil, NULL, NULL);
                            
                            [self forwardShareToAppWithIndex:appIndex andURL:tempURL];
                        }
                    }];
                }
            }
        }
        
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                JGProgressHUD * hud = [LITProgressHud createHudWithMessage:@""];
                [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError withMessage:@"Error sharing"];
                [hud showInView:self.view];
                [hud dismissAfterDelay:1.5f];
                return;
            });
        }
    }];
}

- (void)forwardShareToAppWithIndex:(NSUInteger)appIndex andURL:(NSURL *)url
{
    DMActivityInstagram *instagramActivity = [[DMActivityInstagram alloc] init];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[url]
                                                                                     applicationActivities:@[instagramActivity]];

    activityViewController.excludedActivityTypes = @[UIActivityTypePrint,
                                                     UIActivityTypeCopyToPasteboard,
                                                     UIActivityTypeAssignToContact,
                                                     UIActivityTypeAirDrop,
                                                     //UIActivityTypeSaveToCameraRoll,
                                                     UIActivityTypeAddToReadingList];
    
    // Response handler
    if ([activityViewController respondsToSelector:@selector(completionWithItemsHandler)]) {
        activityViewController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            
            if(!activityError){
                NSLog(@"completed");
            }
            else {
                [self dismissViewControllerAnimated:YES completion:^{
                    JGProgressHUD *hud = [LITProgressHud createHudWithMessage:[NSString stringWithFormat:@"Error sharing"]];
                    [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError withMessage:@"Error sharing"];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.hud showInView:self.view animated:YES];
                        [hud dismissAfterDelay:1.5f];
                    });
                }];
            }
        };
    }
    
    [self.hud dismiss];
    
    // Show the social picker
    [self presentViewController:activityViewController animated:YES completion:nil];
    
    return;
}

- (void)forwardShareToAppWithIndex:(NSUInteger)appIndex andText:(NSString *)text
{
    DMActivityInstagram *instagramActivity = [[DMActivityInstagram alloc] init];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[text]
                                                                                         applicationActivities:@[instagramActivity]];
    
    activityViewController.excludedActivityTypes = @[UIActivityTypePrint,
                                                     UIActivityTypeAssignToContact,
                                                     UIActivityTypeAirDrop,
                                                     UIActivityTypeAddToReadingList];
    
    // Response handler
    if ([activityViewController respondsToSelector:@selector(completionWithItemsHandler)]) {
        activityViewController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            
            if(!activityError){
                NSLog(@"completed");
            }
            else {
                [self dismissViewControllerAnimated:YES completion:^{
                    JGProgressHUD *hud = [LITProgressHud createHudWithMessage:[NSString stringWithFormat:@"Error sharing"]];
                    [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError withMessage:@"Error sharing"];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.hud showInView:self.view animated:YES];
                        [hud dismissAfterDelay:1.5f];
                    });
                }];
            }
        };
    }
    
    [self.hud dismiss];
    
    // Show the social picker
    [self presentViewController:activityViewController animated:YES completion:nil];
    
    return;
}

#pragma mark LITTableSearchHosting Delegate
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    NSAssert(NO, @"This method implementation should never be called");
}

- (void)performSearchWithString:(NSString *)emojiString
{
    NSAssert(NO, @"This method implementation should never be called");
}

- (UIScrollView *)scrollView
{
    return self.collectionView;
}

- (UIView *)headerView
{
    return [self.headerContainerView viewWithTag:100];
}

- (void)setHeaderView:(UIView *)headerView
{
    if (headerView == nil) {
        [_headerView removeFromSuperview];
        _headerView = nil;
        CGRect headerContainerViewFrame = _headerContainerView.frame;
        CGSize originalSize = headerContainerViewFrame.size;
        headerContainerViewFrame.size = CGSizeZero;
        [_headerContainerView setFrame:headerContainerViewFrame];
        [self.collectionView setContentOffset:CGPointMake(0, originalSize.height)];
        return;
    }
    if (_headerView == headerView) {
        return;
    }
    if([self.headerContainerView viewWithTag:100]) {
        [[self.headerView viewWithTag:100] removeFromSuperview];
    }
    [headerView setTag:100];
    if (CGRectGetHeight(_headerContainerView.frame) == 0) {
        CGRect headerContainerViewFrame = _headerContainerView.frame;
        headerContainerViewFrame.size = CGSizeMake(CGRectGetWidth(self.collectionView.frame), 44.0f);
        [_headerContainerView setFrame:headerContainerViewFrame];
        [self.collectionView setContentOffset:CGPointMake(0, 0)];
    }
    [headerView setFrame:self.headerContainerView.bounds];
    [self.headerContainerView addSubview:headerView];
    _headerView = headerView;
}

#pragma mark Video Stamp Share

- (void)shareVideoFromVideoFileURL:(NSURL *)url
               usingWaterMarkImage:(UIImage *)watermarkImage
                      withAppIndex:(NSUInteger)appIndex
                 andViewController:(UIViewController *)viewController
{
    AVAsset *video1Asset = [AVURLAsset assetWithURL:url];
    if (!video1Asset) {
        NSLog(@"Couldn't open video asset");
    }
    
    AVAssetTrack *assetTrack = [[video1Asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize videoSize = CGSizeMake(assetTrack.naturalSize.width, assetTrack.naturalSize.height);
    
    //    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    //    videoComposition.renderSize = squareVideoSize;
    
    
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, video1Asset.duration)
                        ofTrack:assetTrack
                         atTime:kCMTimeZero error:nil];
    
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, video1Asset.duration) ofTrack:[[video1Asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    AVMutableVideoCompositionLayerInstruction *firstLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
    
    CGFloat assetXPosition = (assetTrack.naturalSize.width - assetTrack.naturalSize.width) / 2.0f;
    CGAffineTransform Move = CGAffineTransformMakeTranslation(assetXPosition, 0.0f);
    [firstLayerInstruction setTransform:Move atTime:kCMTimeZero];
    
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, video1Asset.duration);
    mainInstruction.layerInstructions = @[firstLayerInstruction];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat white[] = {1, 1, 1, 1};
    CGColorRef whiteColor = CGColorCreate(colorSpace, white);
    mainInstruction.backgroundColor = whiteColor;
    
    AVMutableVideoComposition *composition = [AVMutableVideoComposition videoComposition];
    composition.instructions = @[mainInstruction];
    composition.frameDuration = CMTimeMake(1, 30);
    composition.renderSize = videoSize;
    
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    CALayer *imageLayer = [CALayer layer];
    imageLayer.contents = (id)watermarkImage.CGImage;
    CGSize stampSize = CGSizeMake(52, 71);
    CGFloat stampXPos = videoSize.width - stampSize.width - 20;
    CGRect stampFrame = CGRectMake(stampXPos, 25, stampSize.width, stampSize.height);
    
    imageLayer.frame = stampFrame;
    
    parentLayer.frame = CGRectMake(0.0f, 0.0f, videoSize.width, videoSize.height);
    videoLayer.frame = parentLayer.frame;
    
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:imageLayer];
    
    composition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    // Create the export session with the composition and set the preset to the highest quality.
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    // Set the desired output URL for the file created by the export process.
    NSString *timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    
    NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *exportVideoPath = [NSString stringWithFormat:@"%@/%@.mp4",documentsDirectoryPath,timestamp];
    
    exporter.outputURL = [NSURL fileURLWithPath:exportVideoPath];
    exporter.videoComposition = composition;
    //Set the output file type to be a MP4 movie.
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    
    //Asynchronously export the composition to a video file and save this file to the camera roll once export completes.
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (exporter.status == AVAssetExportSessionStatusCompleted) {
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                NSURL *exportVideoPathURL = [NSURL URLWithString:exportVideoPath];
                if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:exportVideoPathURL]) {
                    [library writeVideoAtPathToSavedPhotosAlbum:exportVideoPathURL completionBlock:^(NSURL *assetURL, NSError *error) {
                        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                        
                        [self forwardShareToAppWithIndex:appIndex andURL:assetURL];

                    }];
                }
            }
        });
    }];
}

#pragma mark - LITAddContentViewControllerDelegate
- (void)addContentViewControllerDidRequestClose:(LITAddContentViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addContentViewControllerDidSelectSoundbiteOption:(LITAddContentViewController *)controller
{
    LITContentQueryTableViewController *contentViewController = [[UIStoryboard storyboardWithName:@"Main"
                                                                         bundle:nil]
                                               instantiateViewControllerWithIdentifier:NSStringFromClass([LITSoundbitesViewController class])];
    [self presentAddContentNavController:contentViewController fromController:controller];
}

- (void)addContentViewControllerDidSelectDubOption:(LITAddContentViewController *)controller
{
    LITContentQueryTableViewController *contentViewController = [[UIStoryboard storyboardWithName:@"Main"
                                                                         bundle:nil]
                                               instantiateViewControllerWithIdentifier:NSStringFromClass([LITDubsViewController class])];
    [self presentAddContentNavController:contentViewController fromController:controller];
}

- (void)addContentViewControllerDidSelectLyricOption:(LITAddContentViewController *)controller
{
    LITContentQueryTableViewController *contentViewController = [[UIStoryboard storyboardWithName:@"Main"
                                                                         bundle:nil]
                                               instantiateViewControllerWithIdentifier:NSStringFromClass([LITLyricsViewController class])];
    [self presentAddContentNavController:contentViewController fromController:controller];
}

- (void)presentAddContentNavController:(LITContentQueryTableViewController *)contentViewController
                        fromController:(LITAddContentViewController *)controller
{
    [contentViewController setKeyboard:controller.keyboard];
    [contentViewController setIsAddingToKeyboard:YES];
    
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithNavigationBarClass:[LITGradientNavigationBar class]
                                             toolbarClass:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(addedContentToKeyboardNotificationReceived:)
     name:kLITAddedContentToKeyboardNotificationName
     object:nil];
    
    [navController setViewControllers:@[contentViewController]];
    [self dismissViewControllerAnimated:YES completion:^{
        [self presentViewController:navController animated:YES completion:nil];
    }];
}

#pragma mark - Notifications

- (void)addedContentToKeyboardNotificationReceived:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    JGProgressHUD *hud = [LITProgressHud createHudWithMessage:@""];
    [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:@"Added"];
    [hud showInView:self.view];
    [hud dismissAfterDelay:1.5f];
    
    [self.collectionView reloadData];
//    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:self.addingToKeyboardIndexPath.section]];
    self.addingToKeyboardIndexPath = nil;
}


#pragma mark Invocation Forwarding
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([_searchHelper respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:_searchHelper];
    }else {
        [super forwardInvocation:anInvocation];
    }
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature* signature = [super methodSignatureForSelector:selector];
    if (!signature) {
        signature = [_searchHelper methodSignatureForSelector:selector];
    }
    return signature;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector] ||
        [_searchHelper respondsToSelector:aSelector])
    {
        return YES;
    }
    return NO;
}


@end
