//
//  LITKeyboardViewController.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITKeyboardViewController.h"
#import "LITKBBaseCollectionViewCell.h"
#import "LITKBEmptyCollectionViewCell.h"
#import "LITKBDubCollectionViewCell.h"
#import "LITKBLyricCollectionViewCell.h"
#import "LITKBSoundbiteCollectionViewCell.h"
#import "LITKeyboardCellPlayerHelper.h"
#import "UICollectionView+OptionsPresenting.h"
#import "ParseGlobals.h"
#import "LITDub.h"
#import "LITLyric.h"
#import "LITSoundbite.h"
#import "LITKeyboard.h"
#import "LITProgressHUD.h"
#import "LITSharedFileCache.h"
#import "SharkfoodMuteSwitchDetector.h"
#import <Bolts/Bolts.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <GBVersionTracking/GBVersionTracking.h>
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"
#import <Reachability/Reachability.h>

NSString *const kLITKeyboardViewControllerStoryboardID = @"LITKeyboardViewController";
NSString *const kLITSoundbiteClass = @"soundbite";
NSString *const kLITDubClass = @"dub";
NSString *const kLITLyricClass = @"lyric";
NSString *const kLITEmojiClass = @"emoji";
NSString *const kLITNoConnectionClass = @"noconnection";


NSUInteger const kLITNumSections = 2;
NSUInteger const kLITNumOptions = 1;
NSUInteger const kLITIndexSectionOptions = 0;
NSUInteger const kLITIndexSectionShare = 1;

NSUInteger const extraSubviews = 3;


@interface LITKeyboardViewController ()

@property (strong, nonatomic) UIView *optionsPresentationView;
@property (strong, nonatomic) UITableView *optionsTableView;

@property (strong, nonatomic) UICollectionView *targetCollectionView;

@property (strong, nonatomic) PFObject *object;
@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *objectClass;

@property (strong, nonatomic) JGProgressHUD *hud;
@property (strong, nonatomic) UIPasteboard *pasteboard;

@property (strong, nonatomic) UICollectionViewFlowLayout *landscapeLayout;
@property (strong, nonatomic) UICollectionViewFlowLayout *portraitLayout;

@property (assign, nonatomic) BOOL alreadySharing;
@property (strong, nonatomic) Reachability *reachability;

@end

@implementation LITKeyboardViewController {
    LITKeyboardCellPlayerHelper *_playerHelper;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.alreadySharing = NO;
    
    UIView *optionsPresentationView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    UITableView *optionsTableView = [[UITableView alloc] initWithFrame:CGRectZero];
    [optionsTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [optionsTableView setTag:kOptionsTableViewTag];
    [optionsTableView setBackgroundColor:[UIColor clearColor]];
    [optionsTableView setSeparatorColor:[UIColor colorWithWhite:1 alpha:.3]];
    [optionsTableView setDelegate:self];
    [optionsTableView setDataSource:self];
    [optionsPresentationView addSubview:optionsTableView];
    
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
    
    NSArray *bvConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[button(30)]-22-|" options:0 metrics:nil views:bindings];
    NSArray *bhConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(30)]-10-|" options:0 metrics:nil views:bindings];
    [optionsPresentationView addConstraints:bvConstraints];
    [optionsPresentationView addConstraints:bhConstraints];
    
    self.optionsPresentationView = optionsPresentationView;
    self.optionsTableView = optionsTableView;
    
    [self.optionsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kLITOptionsTableViewCellIdentifier];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;

    [self configureCollectionView:self.collectionView];
//    [self.collectionView setPagingEnabled:YES];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenH = screenSize.height;
    CGFloat screenW = screenSize.width;
    BOOL isLandscape =  !(self.view.frame.size.width ==
                          (screenW*(screenW<screenH))+(screenH*(screenW>screenH)));
    
    [self.collectionView
     setCollectionViewLayout:[self collectionViewLayoutForOrientation:isLandscape ? UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationPortrait
                                                        basedOnLayout:layout]];

    
    self.pasteboard = [UIPasteboard generalPasteboard];
    
    _playerHelper = [[LITKeyboardCellPlayerHelper alloc] initWithKeyboardControllerHosting:self];
    
    self.reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    self.reachability.reachableOnWWAN = YES;
    [self.reachability startNotifier];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        if (self.currentLITKeyboardType == LITKeyboard_Emoji) {
            if (indexPath.section == kLITIndexSectionShare - 1) {
                switch (indexPath.row) {
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
                    default:
                        [NSException raise:NSInternalInconsistencyException
                                    format:@"Unexpected row in indexPath"];
                        break;
                }
            } else [NSException raise:NSInternalInconsistencyException
                               format:@"Unexpected section in indexPath"];
        }
        else {
            if (indexPath.section == kLITIndexSectionOptions) {
                switch (indexPath.row) {
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
                    default:
                        [NSException raise:NSInternalInconsistencyException
                                    format:@"Unexpected row in indexPath"];
                        break;
                }
            } else if (indexPath.section == kLITIndexSectionShare) {
                switch (indexPath.row) {
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
                    default:
                        [NSException raise:NSInternalInconsistencyException
                                    format:@"Unexpected row in indexPath"];
                        break;
                }
            } else [NSException raise:NSInternalInconsistencyException
                               format:@"Unexpected section in indexPath"];
        }
        return cell;
    }
    else return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.optionsTableView) {
        if (section == kLITIndexSectionShare) {
            return @"SHARE CONTENT";
        } else return nil;
    }
    else return 0;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.optionsTableView) {
        if (self.currentLITKeyboardType == LITKeyboard_Emoji) {
            if (section == kLITIndexSectionShare - 1) {
                return kLITNumShareApps;
            }
            else return kLITNumOptions;
        } else {
            if (section == kLITIndexSectionShare) {
                return kLITNumShareApps;
            }
            else return kLITNumOptions;
        }
    }
    else return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.optionsTableView) {
        NSInteger countSection = kLITNumSections;
        if (self.currentLITKeyboardType == LITKeyboard_Emoji)
            countSection = 1;
        return countSection;
    } else return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.optionsTableView) {
        return 44.0f;
    }
    else return 0.0f;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.optionsTableView) {
        if (self.currentLITKeyboardType == LITKeyboard_Emoji) {
            if(indexPath.section == kLITIndexSectionShare - 1){
                
                NSString *objectId = self.keyboard.objectId;
                if (objectId == nil)
                    objectId = @"";
                
                [[Mixpanel sharedInstance] track:kMixpanelAction_soundContentPreview_KExtension
                                      properties:@{kMixpanelPropertyContentId: self.objectId,
                                                   kMixpanelPropertyKeyboardId:objectId}];
                
                [self generateDatafromObjectToShareInAppWithIndex:indexPath.item];
            }
        } else {
            if(indexPath.section == kLITIndexSectionOptions){
                
                switch (indexPath.item) {
                    case kLITIndexFav:
                        [self favoriteObjectInTableView:tableView withIndexPath:indexPath];
                        break;
                        
                    default:
                        break;
                }
            } else if(indexPath.section == kLITIndexSectionShare){
                
                NSString *objectId = self.keyboard.objectId;
                if (objectId == nil)
                    objectId = @"";
                
                [[Mixpanel sharedInstance] track:kMixpanelAction_soundContentPreview_KExtension
                                      properties:@{kMixpanelPropertyContentId: self.objectId,
                                                   kMixpanelPropertyKeyboardId:objectId}];
                
                [self generateDatafromObjectToShareInAppWithIndex:indexPath.item];
            }
        }
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.reachability isReachable]) {
        NSInteger numberOfItems = [[self.keyboard valueForKey:@"contents"] count];
        if(numberOfItems > 6){
            return 6 + (floor(numberOfItems/6))*6;
        }
        else {
            return 6;
        }
    }
    else {
        return 6;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LITKBBaseCollectionViewCell *cell = (LITKBBaseCollectionViewCell *)[self collectionView:collectionView
                                                                     cellForItemAtIndexPath:indexPath
                                                                              usingKeyboard:self.keyboard];
    NSAssert([cell isKindOfClass:[LITKBBaseCollectionViewCell class]],
             @"Cell must be of class LITKBBaseCollectionViewCell");
    
    return cell;
}


#pragma mark - LITKeyboardCellTouchDetector

- (void)singleTapDetectedOnCellAtIndexPathForCollectionView:(NSDictionary *)dictionary
{
    if(self.alreadySharing){
        return;
    }
    else{
        self.alreadySharing = YES;
    }
    
    NSIndexPath *indexPath = [dictionary objectForKey:kTouchDetectorIndexPathKey];
    UICollectionView *collectionView = [dictionary objectForKey:kTouchDetectorCollectionViewKey];

    
    // "+" Cell => Open LIT App
    if([[collectionView cellForItemAtIndexPath:indexPath] isKindOfClass:[LITKBEmptyCollectionViewCell class]]){
        UIResponder* responder = self;
        while ((responder = [responder nextResponder]) != nil)
        {
            if([responder respondsToSelector:@selector(openURL:)] == YES)
            {
                [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:@"itslit://"]];
            }
        }
    }
    
    // Content Cell
    else {
        
        // Cell's object data
        [self saveObjectDataFromCell:(LITKBBaseCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath]];
        
        NSLog(@"single tap");
        
        BOOL isTutorialCompleted = [[[NSUserDefaults standardUserDefaults] objectForKey:@"extensionTutorialCompleted"] boolValue];
        
        if (isTutorialCompleted == NO){
            if (self.delegate && [self.delegate respondsToSelector:@selector(presentTutorialViewControllerForItem:)]) {
                if(![self.delegate presentTutorialViewControllerForItem:self.object]){
                    // Preview the object data
                    [self previewObjectAtIndexPath:indexPath withCollectionView:collectionView];
                }
            }
        }
        else {
            // Preview the object data
            [self previewObjectAtIndexPath:indexPath withCollectionView:collectionView];
        }
    
        [self performCopyPaste];
    }
}

- (void)doubleTapDetectedOnCellAtIndexPathForCollectionView:(NSDictionary *)dictionary
{
    NSLog(@"double tap");
}

- (void)longPressDetectedOnCellAtIndexPathForCollectionView:(NSDictionary *)dictionary
{
    NSIndexPath *indexPath = [dictionary objectForKey:kTouchDetectorIndexPathKey];
    UICollectionView *collectionView = [dictionary objectForKey:kTouchDetectorCollectionViewKey];
    
    [collectionView presentOptionsView:self.optionsPresentationView withTopOffset:self.collectionView.contentOffset.y];
    self.targetCollectionView = collectionView;
    
    // Cell's object data
    [self saveObjectDataFromCell:(LITKBBaseCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath]];
    
    NSString *objectId = self.keyboard.objectId;
    if (objectId == nil)
        objectId = @"";
    
    [[Mixpanel sharedInstance] track:kMixpanelAction_soundContentPreview_KExtension
                          properties:@{kMixpanelPropertyContentId: self.objectId,
                                       kMixpanelPropertyKeyboardId:objectId}];
}

- (void)animationLongPressDetectedOnCellAtIndexPathForCollectionView:(NSDictionary *)dictionary
{
    NSIndexPath *indexPath = [dictionary objectForKey:kTouchDetectorIndexPathKey];
    UICollectionView *collectionView = [dictionary objectForKey:kTouchDetectorCollectionViewKey];
    
    UITapGestureRecognizer *gestureRecognizer = [dictionary objectForKey:kTouchDetectorGesturecognizerKey];
    [self animateGestureAtIndexPath:indexPath withCollectionView:collectionView andGestureRecognizer:gestureRecognizer];
}

- (void)saveObjectDataFromCell:(LITKBBaseCollectionViewCell *)cell{
    
    self.objectId = cell.objectId;
    
    if([NSStringFromClass([cell class]) isEqualToString:@"LITKBSoundbiteCollectionViewCell"]){
        self.objectClass = kLITSoundbiteClass;
    }
    else if([NSStringFromClass([cell class]) isEqualToString:@"LITKBDubCollectionViewCell"]){
        self.objectClass = kLITDubClass;
    }
    else if([NSStringFromClass([cell class]) isEqualToString:@"LITKBLyricCollectionViewCell"]){
        self.objectClass = kLITLyricClass;
    }
    else if([NSStringFromClass([cell class]) isEqualToString:@"LITKBEmojiCollectionViewCell"]){
        self.objectClass = kLITEmojiClass;
    }

    self.object = [PFObject objectWithoutDataWithClassName:self.objectClass objectId:self.objectId];
}

- (void)optionsCloseButtonTapped:(UIButton *)button
{
    [[Mixpanel sharedInstance] track:kMixpanelAction_close_HoldDown_KExtension properties:nil];
    
    NSUInteger cellHeight = [self.collectionView.subviews objectAtIndex:0].frame.size.height;
    [self.targetCollectionView dismissOptionsViewWithNumberOfItems:self.collectionView.subviews.count-extraSubviews itemCellHeight:cellHeight andTopOffset:self.collectionView.contentOffset.y];
}

- (void)performCopyPaste {
    NSString *objectId = self.keyboard.objectId;
    if (objectId == nil)
        objectId = @"";
    
    if([self.objectClass isEqualToString:kLITSoundbiteClass]){
        [[Mixpanel sharedInstance] track:kMixpanelAction_soundContentPreview_KExtension
                              properties:@{kMixpanelPropertyContentId: self.objectId,
                                           kMixpanelPropertyKeyboardId: objectId}];
        
        NSString *hudMsg = @"";
        
        if(self.landscapeActive){
            hudMsg = @"Soundbite Copied";
        }
        else {
            hudMsg = @"Soundbite\nCopied";
        }
        
        self.hud = [LITProgressHud createCopyPasteHudWithMessage:hudMsg];
        
        if(self.landscapeActive){
            self.hud.indicatorView.frame = CGRectMake(0, 0, 0, 0);
            self.hud.square = NO;
            [self.hud.indicatorView setHidden:YES];
        }
        
        [self.hud showInView:self.view animated:YES];
        
        if ([self.object saveColumnNameAtSharedCacheSync:@"video"])
        {
            PFFile *video = self.object[@"video"];
            [[self.object retrieveColumnNameFromSharedCache:@"video"] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
                NSURL *videoURL = task.result ? : [NSURL URLWithString:video.url];
                NSData *data = [[NSData alloc] initWithContentsOfURL:videoURL];
                [self.pasteboard setData:data forPasteboardType:@"public.mpeg-4"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    NSString *hudMsg = @"";
                    
                    if(self.landscapeActive){
                        hudMsg = @"Paste as Message";
                    }
                    else {
                        hudMsg = @"Paste as\nMessage";
                    }
                    
                    [LITProgressHud changeStateOfHUD:self.hud to:kLITHUDStatePaste withMessage:hudMsg];
                    
                    if(self.landscapeActive){
                        self.hud.indicatorView.frame = CGRectMake(0, 0, 0, 0);
                        self.hud.square = NO;
                        [self.hud.indicatorView setHidden:YES];
                    }
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        
                        [self.hud dismiss];
                        
                        self.alreadySharing = NO;
                        
                        NSUInteger cellHeight = [self.collectionView.subviews objectAtIndex:0].frame.size.height;
                        [self.targetCollectionView dismissOptionsViewWithNumberOfItems:self.collectionView.subviews.count-extraSubviews itemCellHeight:cellHeight andTopOffset:self.collectionView.contentOffset.y];
                    });
                });
                return nil;
            }];
        }
    }
    else if([self.objectClass isEqualToString:kLITDubClass]){
        NSString *objectId = self.keyboard.objectId;
        if (objectId == nil)
            objectId = @"";
        
        [[Mixpanel sharedInstance] track:kMixpanelAction_videoContentPreview_KExtension
                              properties:@{kMixpanelPropertyContentId: self.objectId,
                                           kMixpanelPropertyKeyboardId: objectId}];
        
        NSString *hudMsg = @"";
        
        if(self.landscapeActive){
            hudMsg = @"Copying Dub";
        }
        else {
            hudMsg = @"Copying\nDub";
        }
        
       self.hud = [LITProgressHud createCopyPasteHudWithMessage:hudMsg];
        
        if(self.landscapeActive){
            self.hud.indicatorView.frame = CGRectMake(0, 0, 0, 0);
            self.hud.square = NO;
            [self.hud.indicatorView setHidden:YES];
        }
        
        [self.hud showInView:self.view animated:YES];
        
        //        PFFile *video = self.object[@"video"];
        if ([self.object saveColumnNameAtSharedCacheSync:@"video"])
        {
            [[self.object retrieveColumnNameFromSharedCache:@"video"] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                if (task.error) {
                    
                    NSString *hudMsg = @"";
                    
                    if(self.landscapeActive){
                        hudMsg = @"Error Copying the Dub";
                    }
                    else {
                        hudMsg = @"Error Copying\nthe Dub";
                    }
                    
                    [LITProgressHud changeStateOfHUD:self.hud to:kLITHUDStateError withMessage:hudMsg];
                    
                    if(self.landscapeActive){
                        self.hud.indicatorView.frame = CGRectMake(0, 0, 0, 0);
                        self.hud.square = NO;
                        [self.hud.indicatorView setHidden:YES];
                    }
                    
                    NSLog(@"Error: %@", task.error.localizedDescription);
                    [self.hud dismissAfterDelay:1.0f];
                    return [BFTask taskWithError:task.error];
                } else {
                    //            NSURL *videoURL = task.result ? : [NSURL URLWithString:video.url];
                    NSURL *videoURL = task.result;
                    //NSData *data = [[NSData alloc] initWithContentsOfURL:videoURL];
                    //[self.pasteboard setData:data forPasteboardType:@"public.mpeg-4"];
                    [self shareVideoFromVideoFileURL:videoURL usingWaterMarkImage:[UIImage imageNamed:@"watermark"] withAppIndex:kLITIndexShareMessages andHud:self.hud];
                }
                return nil;
            }];
        }
    }
    else if([self.objectClass isEqualToString:kLITLyricClass]){
        NSString *objectId = self.keyboard.objectId;
        if (objectId == nil)
            objectId = @"";
        
        [[Mixpanel sharedInstance] track:kMixpanelAction_soundContentPreview_KExtension
                              properties:@{kMixpanelPropertyContentId: self.objectId,
                                           kMixpanelPropertyKeyboardId:objectId}];
        
        NSString *hudMsg = @"";
        
        if(self.landscapeActive){
            hudMsg = @"Lyric Copied";
        }
        else {
            hudMsg = @"Lyric\nCopied";
        }
        
        self.hud = [LITProgressHud createCopyPasteHudWithMessage:hudMsg];
        
        if(self.landscapeActive){
            self.hud.indicatorView.frame = CGRectMake(0, 0, 0, 0);
            self.hud.square = NO;
            [self.hud.indicatorView setHidden:YES];
        }
        
        [self.hud showInView:self.view animated:YES];
        
        [self.pasteboard setString:self.object[@"text"]];
        [self.textDocumentProxy insertText:[self.pasteboard string]];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [self.hud dismiss];
            
            self.alreadySharing = NO;
            
            NSUInteger cellHeight = [self.collectionView.subviews objectAtIndex:0].frame.size.height;
            [self.targetCollectionView dismissOptionsViewWithNumberOfItems:self.collectionView.subviews.count-extraSubviews itemCellHeight:cellHeight andTopOffset:self.collectionView.contentOffset.y];
        });
    }
    else if([self.objectClass isEqualToString:kLITEmojiClass]) {
        NSString *objectId = self.keyboard.objectId;
        if (objectId == nil)
            objectId = @"";
        
        [[Mixpanel sharedInstance] track:kMixpanelAction_soundContentPreview_KExtension
                              properties:@{kMixpanelPropertyContentId: self.objectId,
                                           kMixpanelPropertyKeyboardId:objectId}];
        
        NSString *hudMsg = @"";
        
        if(self.landscapeActive){
            hudMsg = @"Emoji Copied";
        }
        else {
            hudMsg = @"Emoji\nCopied";
        }
        
        self.hud = [LITProgressHud createCopyPasteHudWithMessage:hudMsg];
        
        if(self.landscapeActive){
            self.hud.indicatorView.frame = CGRectMake(0, 0, 0, 0);
            self.hud.square = NO;
            [self.hud.indicatorView setHidden:YES];
        }
        
        [self.hud showInView:self.view animated:YES];
        
        if ([self.object saveColumnNameAtSharedCacheSync:@"emoji"])
        {
            PFFile *emoji = self.object[@"emoji"];
            [[self.object retrieveColumnNameFromSharedCache:@"emoji"] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
                NSURL *emojiURL = task.result ? : [NSURL URLWithString:emoji.url];
                NSData *data = [[NSData alloc] initWithContentsOfURL:emojiURL];
                [self.pasteboard setData:data forPasteboardType:@"public.png"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    NSString *hudMsg = @"";
                    
                    if(self.landscapeActive){
                        hudMsg = @"Paste as Message";
                    }
                    else {
                        hudMsg = @"Paste as\nMessage";
                    }
                    
                    [LITProgressHud changeStateOfHUD:self.hud to:kLITHUDStatePaste withMessage:hudMsg];
                    
                    if(self.landscapeActive){
                        self.hud.indicatorView.frame = CGRectMake(0, 0, 0, 0);
                        self.hud.square = NO;
                        [self.hud.indicatorView setHidden:YES];
                    }
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        
                        [self.hud dismiss];
                        
                        self.alreadySharing = NO;
                        
                        NSUInteger cellHeight = [self.collectionView.subviews objectAtIndex:0].frame.size.height;
                        [self.targetCollectionView dismissOptionsViewWithNumberOfItems:self.collectionView.subviews.count-extraSubviews itemCellHeight:cellHeight andTopOffset:self.collectionView.contentOffset.y];
                    });
                });
                return nil;
            }];
        }
    }
}

- (void)generateDatafromObjectToShareInAppWithIndex:(NSUInteger)appIndex
{
    if(appIndex == kLITIndexShareMessages){
        [self performCopyPaste];
        
        // First of all we get the object
        [[PFQuery queryWithClassName:self.objectClass] getObjectInBackgroundWithId:self.objectId block:^(PFObject *object, NSError *error) {
            
            if(object && !error){
                
                if(self.objectClass == kLITLyricClass){
                    PFObject *objectUse = [PFObject objectWithClassName:kLyricUseClassName];
                    objectUse[kLyricUseLyricKey] = object;
                    objectUse[kLyricUseUserKey] = [PFUser currentUser];
                    [objectUse saveInBackground];
                }
                
                else if(self.objectClass == kLITSoundbiteClass){
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
            }
        }];
    }
    
    else{
        
        // First of all we get the object
        [[PFQuery queryWithClassName:self.objectClass] getObjectInBackgroundWithId:self.objectId block:^(PFObject *object, NSError *error) {
            
            if(object && !error){
                
                if(self.objectClass == kLITLyricClass){
                    
                    // Save the object "use" reference
                    PFObject *objectUse = [PFObject objectWithClassName:kLyricUseClassName];
                    objectUse[kLyricUseLyricKey] = object;
                    objectUse[kLyricUseUserKey] = [PFUser currentUser];
                    [objectUse saveInBackground];
                    
                    // Then share it
                    
                    NSString *lyricText = object[@"text"];
                    [[UIPasteboard generalPasteboard] setString:lyricText];
                    [self.textDocumentProxy insertText:[[UIPasteboard generalPasteboard] string]];
                    
                    JGProgressHUD *hud = [LITProgressHud createHudWithMessage:[NSString stringWithFormat:@"%@\n%@", @"Lyric", @"Copied"]];
                    
                    NSString *hudMsg = @"";
                    
                    if(self.landscapeActive){
                        hudMsg = @"Lyric Copied";
                    }
                    else {
                        hudMsg = @"Lyric\nCopied";
                    }
                    
                    [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:hudMsg];
                    
                    if(self.landscapeActive){
                        hud.indicatorView.frame = CGRectMake(0, 0, 0, 0);
                        hud.square = NO;
                        [hud.indicatorView setHidden:YES];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [hud showInView:self.view animated:YES];
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            
                            [hud dismiss];
                            
                            NSUInteger cellHeight = [self.collectionView.subviews objectAtIndex:0].frame.size.height;
                            [self.targetCollectionView dismissOptionsViewWithNumberOfItems:self.collectionView.subviews.count-extraSubviews itemCellHeight:cellHeight andTopOffset:self.collectionView.contentOffset.y];
                        });
                    });
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
                    
                    // Then share it
                    
                    JGProgressHUD * hud;
                    
                    if(self.landscapeActive){
                        hud = [LITProgressHud createHudWithMessage:[NSString stringWithFormat:@"%@%@%@", @"Saving ", self.objectClass, @" as video in Camera Roll"]];
                        hud.indicatorView.frame = CGRectMake(0, 0, 0, 0);
                        hud.square = NO;
                        [hud.indicatorView setHidden:YES];
                    }
                    else {
                        hud = [LITProgressHud createHudWithMessage:[NSString stringWithFormat:@"%@%@%@\n%@", @"Saving ", self.objectClass, @" as video", @"in Camera Roll"]];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [hud showInView:self.view animated:YES];
                    });
                    
                    
                    PFFile *video = object[@"video"];
                    NSURL *videoURL = [NSURL URLWithString:video.url];
                    
                    
                    if(self.objectClass == kLITDubClass){
                        [self shareVideoFromVideoFileURL:videoURL
                                     usingWaterMarkImage:[UIImage imageNamed:@"watermark"]
                                            withAppIndex:appIndex
                                                  andHud:hud];
                    }
                    else {
                        NSURLRequest *request = [NSURLRequest requestWithURL:videoURL];
                        
                        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                            
                            if(connectionError){
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    NSString *hudMsg = @"";
                                    
                                    if(self.landscapeActive){
                                        hudMsg = @"Error sharing";
                                    }
                                    else {
                                        hudMsg = @"Error\nSharing";
                                    }
                                    
                                    [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError withMessage:hudMsg];
                                    
                                    if(self.landscapeActive){
                                        hud.indicatorView.frame = CGRectMake(0, 0, 0, 0);
                                        hud.square = NO;
                                        [hud.indicatorView setHidden:YES];
                                    }
                                    
                                    [hud dismissAfterDelay:1.5f];
                                    return;
                                });
                            }
                            else{
                                NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
                                NSURL *tempURL = [documentsURL URLByAppendingPathComponent:[videoURL lastPathComponent]];
                                
                                [data writeToURL:tempURL atomically:YES];
                                ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
                                [assetLibrary writeVideoAtPathToSavedPhotosAlbum:tempURL completionBlock:^(NSURL *assetURL, NSError *error){
                                    
                                    if(!error){
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            
                                            NSString *hudMsg = @"";
                                            
                                            if(self.landscapeActive){
                                                hudMsg = @"Get Video From Camera Roll";
                                            }
                                            else {
                                                hudMsg = @"Get Video From\nCamera Roll";
                                            }
                                            
                                            [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:hudMsg];
                                            
                                            if(self.landscapeActive){
                                                hud.indicatorView.frame = CGRectMake(0, 0, 0, 0);
                                                hud.square = NO;
                                                [hud.indicatorView setHidden:YES];
                                            }
                                            
                                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                                
                                                [hud dismiss];
                                                
                                                NSUInteger cellHeight = [self.collectionView.subviews objectAtIndex:0].frame.size.height;
                                                [self.targetCollectionView dismissOptionsViewWithNumberOfItems:self.collectionView.subviews.count-extraSubviews itemCellHeight:cellHeight andTopOffset:self.collectionView.contentOffset.y];
                                            });
                                        });
                                    }
                                }];
                            }
                        }];
                    }
                }
            }
            
            else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    JGProgressHUD * hud = [LITProgressHud createHudWithMessage:@"Error sharing"];
                    
                    NSString *hudMsg = @"";
                    
                    if(self.landscapeActive){
                        hudMsg = @"Error Sharing";
                    }
                    else {
                        hudMsg = @"Error\nSharing";
                    }
                    
                    [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError withMessage:hudMsg];
                    
                    if(self.landscapeActive){
                        hud.indicatorView.frame = CGRectMake(0, 0, 0, 0);
                        hud.square = NO;
                        [hud.indicatorView setHidden:YES];
                    }
                    
                    [hud dismissAfterDelay:1.5f];
                    return;
                });
            }
        }];
    }
}


#pragma mark Functionalities

- (void)animateGestureAtIndexPath:(NSIndexPath *)indexPath
               withCollectionView:(UICollectionView *)collectionView
             andGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer
{
//    [self performCircleAnimationOnCell:(LITKBBaseCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath] withGestureRecognizer:gestureRecognizer];
    [self performFlashAnimationOnCell:(LITKBBaseCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath] withGestureRecognizer:gestureRecognizer];
//    [self performCurtainAnimationOnCell:(LITKBBaseCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath] withGestureRecognizer:gestureRecognizer];

}

- (void)performCircleAnimationOnCell:(LITKBBaseCollectionViewCell *)cell
               withGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer
{
    //NSInteger innerDiameter = 95;
    //NSInteger outerDiameter = 140;
    NSInteger initialSize = 10;
    
    UIView *innerCircleView = [[UIView alloc] initWithFrame:CGRectMake(0,0,initialSize,initialSize)];
    innerCircleView.center = [gestureRecognizer locationInView:cell.contentView];
    innerCircleView.alpha = 0.0;
    innerCircleView.layer.cornerRadius = initialSize/2;
    innerCircleView.backgroundColor = [UIColor whiteColor];
    
    UIView *outerCircleView = [[UIView alloc] initWithFrame:CGRectMake(0,0,initialSize,initialSize)];
    outerCircleView.center = [gestureRecognizer locationInView:cell.contentView];
    outerCircleView.alpha = 0.0;
    outerCircleView.layer.cornerRadius = initialSize/2;
    outerCircleView.backgroundColor = [UIColor whiteColor];
    
    [cell.contentView addSubview:innerCircleView];
    [cell.contentView addSubview:outerCircleView];
    
    
    /*
     
    // Animation 1 - Out-In
    
    [UIView animateWithDuration:.5 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        innerCircleView.alpha = .1;
        innerCircleView.transform = CGAffineTransformMakeScale(innerDiameter/initialSize, innerDiameter/initialSize);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            innerCircleView.alpha = 0;
            innerCircleView.transform = CGAffineTransformMakeScale(10,10);
        } completion:^(BOOL finished) {
            [innerCircleView removeFromSuperview];
        }];
    }];
    
    [UIView animateWithDuration:.15 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        outerCircleView.alpha = .1;
        outerCircleView.transform = CGAffineTransformMakeScale(outerDiameter/initialSize, outerDiameter/initialSize);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            outerCircleView.alpha = 0;
            outerCircleView.transform = CGAffineTransformMakeScale(10,10);
        } completion:^(BOOL finished) {
            [outerCircleView removeFromSuperview];
        }];
    }];
     
    */
    
    
    
    // Animation 2 - Expand and fade out
    
    [UIView animateWithDuration:.4 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        innerCircleView.alpha = .1;
        innerCircleView.transform = CGAffineTransformMakeScale(30,30);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.1 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            innerCircleView.alpha = 0;
        } completion:^(BOOL finished) {
            [innerCircleView removeFromSuperview];
            [outerCircleView removeFromSuperview];
        }];
    }];
    
    [UIView animateWithDuration:.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        outerCircleView.alpha = .1;
        outerCircleView.transform = CGAffineTransformMakeScale(40,40);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.1 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            outerCircleView.alpha = 0;
        } completion:^(BOOL finished) {
            //[outerCircleView removeFromSuperview];
        }];
    }];
     
    
}

- (void)performCurtainAnimationOnCell:(LITKBBaseCollectionViewCell *)cell
               withGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer
{
    UIView *curtainBottom = [[UIView alloc]
                             initWithFrame:CGRectMake(0,
                                                      cell.contentView.frame.size.height,
                                                      cell.contentView.frame.size.width,
                                                      cell.contentView.frame.size.height
                                                      )];
    curtainBottom.alpha = 0.0;
    curtainBottom.backgroundColor = [UIColor whiteColor];
    
    UIView *curtainTop = [[UIView alloc]
                             initWithFrame:CGRectMake(0,
                                                      -cell.contentView.frame.size.height,
                                                      cell.contentView.frame.size.width,
                                                      cell.contentView.frame.size.height
                                                      )];
    curtainTop.alpha = 0.0;
    curtainTop.backgroundColor = [UIColor whiteColor];
    
    [cell.contentView addSubview:curtainTop];
    [cell.contentView addSubview:curtainBottom];
    
    /*
    
    // Animation 1 - Fill from bottom - fade
    
    [curtainTop removeFromSuperview];
    
    [UIView animateWithDuration:.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        curtainBottom.alpha = .25;
        curtainBottom.frame = CGRectMake(0,
                                         0,
                                         cell.contentView.frame.size.width,
                                         cell.contentView.frame.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.4 delay:.2 options:UIViewAnimationOptionCurveLinear animations:^{
            curtainBottom.alpha = 0;
        } completion:^(BOOL finished) {
            [curtainBottom removeFromSuperview];
        }];
    }];
    
    */
    
    /*
    
    // Animation 2 - Fill from top - fade
    
    [curtainBottom removeFromSuperview];
    
    [UIView animateWithDuration:.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        curtainTop.alpha = .25;
        curtainTop.frame = CGRectMake(0,
                                      0,
                                      cell.contentView.frame.size.width,
                                      cell.contentView.frame.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.4 delay:.2 options:UIViewAnimationOptionCurveLinear animations:^{
            curtainTop.alpha = 0;
        } completion:^(BOOL finished) {
            [curtainTop removeFromSuperview];
        }];
    }];
     
    */
    
    
    
    // Animation 3 - Cross curtains - fade
    
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        curtainBottom.alpha = .1;
        curtainBottom.frame = CGRectMake(0,
                                         0,
                                         cell.contentView.frame.size.width,
                                         cell.contentView.frame.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.2 delay:.1 options:UIViewAnimationOptionCurveLinear animations:^{
            curtainBottom.alpha = 0;
        } completion:^(BOOL finished) {
            [curtainBottom removeFromSuperview];
        }];
    }];
    
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        curtainTop.alpha = .3;
        curtainTop.frame = CGRectMake(0,
                                      0,
                                      cell.contentView.frame.size.width,
                                      cell.contentView.frame.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.2 delay:.1 options:UIViewAnimationOptionCurveLinear animations:^{
            curtainTop.alpha = 0;
        } completion:^(BOOL finished) {
            [curtainTop removeFromSuperview];
        }];
    }];
    
}

- (void)performFlashAnimationOnCell:(LITKBBaseCollectionViewCell *)cell
               withGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer
{
    
    // Animation 1 - Blur + border
    
    //UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    //UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    UIView *blurEffectView = [[UIView alloc] initWithFrame:CGRectZero];
    blurEffectView.frame = cell.contentView.bounds;
    blurEffectView.backgroundColor = [UIColor whiteColor];
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blurEffectView.alpha = 0;
    
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectZero];
    borderView.frame = cell.contentView.bounds;
    borderView.backgroundColor = [UIColor clearColor];
    borderView.layer.borderColor = [UIColor blackColor].CGColor;
    borderView.layer.borderWidth = 3;
    borderView.alpha = 0;
    
    [cell.contentView addSubview:borderView];
    [cell.contentView addSubview:blurEffectView];
    
    [UIView animateWithDuration:.05 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        blurEffectView.alpha = .15;
        borderView.alpha = .10;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.50 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            blurEffectView.alpha = 0;
            borderView.alpha = 0;
        } completion:^(BOOL finished) {
            [blurEffectView removeFromSuperview];
        }];
    }];
    
}

- (void)previewObjectAtIndexPath:(NSIndexPath *)indexPath withCollectionView:(UICollectionView *)collectionView {
    
    NSLog(@"%@",NSStringFromClass([self.object class]));
    
    if([NSStringFromClass([self.object class]) isEqualToString:@"LITSoundbite"]){
        [_playerHelper getDataForSoundbite:(LITSoundbite *)self.object atIndexPath:indexPath withCompletionBlock:^(NSError *error) {
            if (!error) {
                __weak typeof(self) weakSelf = self;
                _playerHelper.silentBlock = ^(BOOL silent) {
                    if (silent) {
                        if (weakSelf.delegate && [weakSelf.delegate
                                                  respondsToSelector:@selector(keyboardViewController:didDetectMuteSwitchState:)]) {
                            [weakSelf.delegate keyboardViewController:weakSelf didDetectMuteSwitchState:silent];
                        }
                    }
                };
                [_playerHelper playSoundbite:(LITSoundbite *)self.object atIndexPath:indexPath withCollectionView:collectionView];
            } else {
                NSLog(@"Error previewing soundbite: %@", error.localizedDescription);
            }
        } trySharedCache:NO];
    }
    else if([NSStringFromClass([self.object class]) isEqualToString:@"LITDub"]){
        if (self.currentLITKeyboardType == LITKeyboard_Installed)
        {
            LITKBDubCollectionViewCell *dubCell = (LITKBDubCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
            __weak typeof(self) weakSelf = self;
            dubCell.silentBlock = ^(BOOL silent) {
                if (silent) {
                    if (weakSelf.delegate && [weakSelf.delegate
                                              respondsToSelector:@selector(keyboardViewController:didDetectMuteSwitchState:)]) {
                        [weakSelf.delegate keyboardViewController:weakSelf didDetectMuteSwitchState:silent];
                    }
                }
            };
            [dubCell playVideo];
        }
        else
        {
            [_playerHelper getDataForDub:(LITDub *)self.object atIndexPath:indexPath withCompletionBlock:^(NSError *error) {
                if (!error) {
                    LITKBDubCollectionViewCell *dubCell = (LITKBDubCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
                    __weak typeof(self) weakSelf = self;
                    dubCell.silentBlock = ^(BOOL silent) {
                        if (silent) {
                            if (weakSelf.delegate && [weakSelf.delegate
                                                      respondsToSelector:@selector(keyboardViewController:didDetectMuteSwitchState:)]) {
                                [weakSelf.delegate keyboardViewController:weakSelf didDetectMuteSwitchState:silent];
                            }
                        }
                    };
                    [dubCell playVideo];
                } else {
                    NSLog(@"Error previewing soundbite: %@", error.localizedDescription);
                }
            }];
        }
    }
}

- (void)favoriteObjectInTableView:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath {
    
    JGProgressHUD * hud = [LITProgressHud createHudWithMessage:@""];
    
    PFObject *favKB = [[PFUser currentUser] objectForKey:kUserFavKeyboardKey];
    NSString *favKBid = favKB.objectId;
    
    PFQuery *query = [PFQuery queryWithClassName:kUserFavKeyboardKey];
    [query getObjectInBackgroundWithId:favKBid block:^(PFObject *favKeyboard, NSError *error) {
        if ([[favKeyboard objectForKey:kFavKeyboardContentsKey] containsObject:self.object]) {
            
            NSString *objectId = self.keyboard.objectId;
            if (objectId == nil)
                objectId = @"";
            
            [[Mixpanel sharedInstance] track:kMixpanelAction_soundContentPreview_KExtension
                                  properties:@{kMixpanelPropertyContentId: self.objectId,
                                               kMixpanelPropertyKeyboardId:objectId}];
            NSMutableArray *arrayFavs = [NSMutableArray arrayWithArray:[favKeyboard objectForKey:kFavKeyboardContentsKey]];
            [arrayFavs removeObject:self.object];
            [favKeyboard setObject:arrayFavs forKey:kFavKeyboardContentsKey];
            
            [[favKeyboard saveEventually] continueWithBlock:^id(BFTask *task) {
                if (task.error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSString *hudMsg = @"";
                        
                        if(self.landscapeActive){
                            hudMsg = @"Error Removing";
                        }
                        else {
                            hudMsg = @"Error\nRemoving";
                        }
                        
                        [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError withMessage:hudMsg];
                        
                        if(self.landscapeActive){
                            hud.indicatorView.frame = CGRectMake(0, 0, 0, 0);
                            hud.square = NO;
                            [hud.indicatorView setHidden:YES];
                        }
                        
                        [hud showInView:self.view];
                        [hud dismissAfterDelay:1.5f];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[[tableView cellForRowAtIndexPath:indexPath] textLabel] setText:@"Add to your favorites"];
                        [[[tableView cellForRowAtIndexPath:indexPath] imageView] setImage:[UIImage imageNamed:@"addToFavs"]];
                        
                        NSString *hudMsg = @"";
                        
                        if(self.landscapeActive){
                            hudMsg = @"Removed";
                        }
                        else {
                            hudMsg = @"Removed";
                        }
                        
                        [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:hudMsg];
                        
                        if(self.landscapeActive){
                            hud.indicatorView.frame = CGRectMake(0, 0, 0, 0);
                            hud.square = NO;
                            [hud.indicatorView setHidden:YES];
                        }
                        
                        [hud showInView:self.view];
                        
                        [self.delegate didUpdateFavorites:self];
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            
                            [hud dismiss];
                            
                            NSUInteger cellHeight = [self.collectionView.subviews objectAtIndex:0].frame.size.height;
                            [self.targetCollectionView dismissOptionsViewWithNumberOfItems:self.collectionView.subviews.count-extraSubviews itemCellHeight:cellHeight andTopOffset:self.collectionView.contentOffset.y];
                        });
                    });
                }
                return nil;
            }];
        } else {
            
            NSString *objectId = self.keyboard.objectId;
            if (objectId == nil)
                objectId = @"";
            
            [[Mixpanel sharedInstance] track:kMixpanelAction_soundContentPreview_KExtension
                                  properties:@{kMixpanelPropertyContentId: self.objectId,
                                               kMixpanelPropertyKeyboardId:objectId}];
            
            //[[favKeyboard objectForKey:kFavKeyboardContentsKey] addObject:self.object];
            NSMutableArray *arrayFavs = [NSMutableArray arrayWithArray:[favKeyboard objectForKey:kFavKeyboardContentsKey]];
            [arrayFavs addObject:self.object];
            [favKeyboard setObject:arrayFavs forKey:kFavKeyboardContentsKey];
            
            [[favKeyboard saveEventually] continueWithBlock:^id(BFTask *task) {
                if (task.error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSString *hudMsg = @"";
                        
                        if(self.landscapeActive){
                            hudMsg = @"Error Adding";
                        }
                        else {
                            hudMsg = @"Error\nAdding";
                        }
                        
                        [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError withMessage:hudMsg];
                        
                        if(self.landscapeActive){
                            hud.indicatorView.frame = CGRectMake(0, 0, 0, 0);
                            hud.square = NO;
                            [hud.indicatorView setHidden:YES];
                        }
                        
                        [hud showInView:self.view];
                        [hud dismissAfterDelay:1.5f];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[[tableView cellForRowAtIndexPath:indexPath] textLabel] setText:@"Remove from your favorites"];
                        [[[tableView cellForRowAtIndexPath:indexPath] imageView] setImage:[UIImage imageNamed:@"removeFromFavs"]];
                        
                        NSString *hudMsg = @"";
                        
                        if(self.landscapeActive){
                            hudMsg = @"Favorites";
                        }
                        else {
                            hudMsg = @"Favorites";
                        }
                        
                        [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:hudMsg];
                        
                        if(self.landscapeActive){
                            hud.indicatorView.frame = CGRectMake(0, 0, 0, 0);
                            hud.square = NO;
                            [hud.indicatorView setHidden:YES];
                        }
                        
                        [hud showInView:self.view];
                                                
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            
                            [hud dismiss];
                            
                            NSUInteger cellHeight = [self.collectionView.subviews objectAtIndex:0].frame.size.height;
                            [self.targetCollectionView dismissOptionsViewWithNumberOfItems:self.collectionView.subviews.count-extraSubviews itemCellHeight:cellHeight andTopOffset:self.collectionView.contentOffset.y];
                            
                            [self.delegate didUpdateFavorites:self];
                        });

                    });
                }
                return nil;
            }];
        }
    }];
}


#pragma mark - Orientation
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    NSLog(@"keyboard controller will transition to %@", NSStringFromCGSize(size));
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    UICollectionViewLayout *layoutToSet;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenH = screenSize.height;
    CGFloat screenW = screenSize.width;
    BOOL isLandscape =  !(size.width ==
                          (screenW*(screenW<screenH))+(screenH*(screenW>screenH)));
    NSLog(isLandscape ? @"Screen: Landscape" : @"Screen: Portrait");
        
    if (!isLandscape) {
        
        self.landscapeActive = NO;
        
        //portrait
        if (((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).itemSize.width !=
            kLITKeyboardCellItemPortraitDimension) {
            //set the layout
            layoutToSet = [self collectionViewLayoutForOrientation:UIInterfaceOrientationPortrait
                                                     basedOnLayout:(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout];
        }
    } else {
        
        self.landscapeActive = YES;
        
        if (((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).itemSize.width !=
            kLITKeyboardCellItemLandscapeDimension) {
            //set the layout
            layoutToSet = [self collectionViewLayoutForOrientation:UIInterfaceOrientationLandscapeLeft
                                                     basedOnLayout:(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout];
        }
    }
    if (!layoutToSet) {
        return;
    }
    
    CGSize layoutSize = ((UICollectionViewFlowLayout *)layoutToSet).itemSize;
    NSLog(@"Size for layout is %@", NSStringFromCGSize(layoutSize));

    
    // Code here will execute before the rotation begins.
    // Equivalent to placing it in the deprecated method -[willRotateToInterfaceOrientation:duration:]
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.collectionView setCollectionViewLayout:layoutToSet animated:NO];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // Code here will execute after the rotation has finished.
        // Equivalent to placing it in the deprecated method -[didRotateFromInterfaceOrientation:]
    }];
}

- (UICollectionViewLayout *)collectionViewLayoutForOrientation:(UIInterfaceOrientation)orientation
                                                 basedOnLayout:(UICollectionViewFlowLayout *)layout
{
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        layout.minimumInteritemSpacing = kLITKeyboardCellItemSpacing;
        layout.minimumLineSpacing = kLITKeyboardCellItemSpacing;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        [layout setItemSize:CGSizeMake(kLITKeyboardCellItemLandscapeDimension, kLITKeyboardCellItemLandscapeDimension)];
    } else {
        layout.minimumInteritemSpacing = kLITKeyboardCellItemSpacing;
        layout.minimumLineSpacing = kLITKeyboardCellItemSpacing;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        [layout setItemSize:CGSizeMake(kLITKeyboardCellItemPortraitDimension, kLITKeyboardCellItemPortraitDimension)];
    }
    return layout;
}


#pragma mark Video Stamp Share

- (void)shareVideoFromVideoFileURL:(NSURL *)url
               usingWaterMarkImage:(UIImage *)watermarkImage
                      withAppIndex:(NSUInteger)appIndex
                               andHud:(JGProgressHUD *)hud
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
                NSURL *trueExportVideoPathURL;
                
                if(appIndex == kLITIndexShareMessages){
                    trueExportVideoPathURL = [NSURL URLWithString:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tmp/%@.mp4",timestamp]]];
                }
                else {
                    trueExportVideoPathURL = [NSURL URLWithString:exportVideoPath];
                }
                
                if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:exportVideoPathURL]) {
                    [library writeVideoAtPathToSavedPhotosAlbum:trueExportVideoPathURL completionBlock:^(NSURL *assetURL, NSError *error) {
                    
                        if(!error){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                if(appIndex == kLITIndexShareMessages){
                                    
                                    NSError *error;
                                    
                                    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:exportVideoPath] options:NSDataReadingUncached error:&error];
                                    NSLog(@"%@",[error localizedDescription]);
                                    [self.pasteboard setData:data forPasteboardType:@"public.mpeg-4"];
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        
                                        // Delete the dub from camera roll afterwards
                                        NSError *removeError;
                                        [[NSFileManager defaultManager] removeItemAtURL:assetURL  error:&removeError];
                                        if(removeError){NSLog(@"Error: %@",removeError.localizedDescription);}
                                        
                                        NSString *hudMsg = @"";
                                        
                                        if(self.landscapeActive){
                                            hudMsg = @"Paste as Message";
                                        }
                                        else {
                                            hudMsg = @"Paste as\nMessage";
                                        }
                                        
                                        [LITProgressHud changeStateOfHUD:hud to:kLITHUDStatePaste withMessage:hudMsg];
                                        
                                        if(self.landscapeActive){
                                            hud.indicatorView.frame = CGRectMake(0, 0, 0, 0);
                                            hud.square = NO;
                                            [hud.indicatorView setHidden:YES];
                                        }
                                        
                                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                            
                                            [hud dismiss];
                                            
                                            self.alreadySharing = NO;
                                            
                                            NSUInteger cellHeight = [self.collectionView.subviews objectAtIndex:0].frame.size.height;
                                            [self.targetCollectionView dismissOptionsViewWithNumberOfItems:self.collectionView.subviews.count-extraSubviews itemCellHeight:cellHeight andTopOffset:self.collectionView.contentOffset.y];
                                        });
                                    });
                                }
                                else {
                                    
                                    NSString *hudMsg = @"";
                                    
                                    if(self.landscapeActive){
                                        hudMsg = @"Get Video From Camera Roll";
                                    }
                                    else {
                                        hudMsg = @"Get Video From\nCamera Roll";
                                    }
                                    
                                    [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:hudMsg];
                                    
                                    if(self.landscapeActive){
                                        hud.indicatorView.frame = CGRectMake(0, 0, 0, 0);
                                        hud.square = NO;
                                        [hud.indicatorView setHidden:YES];
                                    }
                                    
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                        
                                        [hud dismiss];
                                        
                                        self.alreadySharing = NO;
                                        
                                        NSUInteger cellHeight = [self.collectionView.subviews objectAtIndex:0].frame.size.height;
                                        [self.targetCollectionView dismissOptionsViewWithNumberOfItems:self.collectionView.subviews.count-extraSubviews itemCellHeight:cellHeight andTopOffset:self.collectionView.contentOffset.y];
                                    });
                                }
                            });
                        }
                    }];
                }
            }
        });
    }];
}


@end
