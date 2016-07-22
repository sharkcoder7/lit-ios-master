//
//  KeyboardViewController.m
//  LITKeyboard
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITKeyboardsBaseViewController.h"
#import "LITKeyboardViewController.h"
#import "LITKeyboardNoAccessViewController.h"
#import "LITKeyboardTutorialViewController.h"
#import "UIView+GradientBackground.h"
#import "LITTheme.h"
#import "LITKeyboard.h"
#import "ParseGlobals.h"
#import "UIView+BlurEffect.h"
#import <Parse/Parse.h>
#import <Parse/PFUser.h>
#import <Bolts/Bolts.h>
#import <AFViewShaker/AFViewShaker.h>
#import <GBVersionTracking/GBVersionTracking.h>
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"
#import "LITLyric.h"
#import "DataKeeper.h"
#import "LITSoundBite.h"
#import "LITDub.h"
#import "LITEmoji.h"
#import "SearchViewController.h"
#import "AKTagCell.h"

typedef NS_ENUM(NSInteger, LITKBScrollDirection) {
    LITKBScrollDirectionLeft    = -1,
    LITKBScrollDirectionCenter  = 0,
    LITKBScrollDirectionRight   = 1
};


static CGFloat const kTitleViewHeight = 44.0f;

static NSString *const kTurnOnSoundMessage = @"Turn on your sound";
static NSString *const AppBundleIdentifier = @"it.itsl.lit-ios";

@interface LITKeyboardsBaseViewController () <LITKeyboardControllerDelegate, LITKeyboardNoAccessDelegate, LITKeyboardTutorialDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate, SearchViewControllerDelegate> {
    BOOL _constraintsSet;
    BOOL _gradientSet;
    NSUInteger _numberOfPages;
    NSUInteger _originIndex;
    
    LITKBScrollDirection _currentDirection;
}

@property (nonatomic, assign) CGFloat portraitHeight;
@property (nonatomic, assign) CGFloat landscapeHeight;
@property (nonatomic) BOOL isLandscape;
@property (nonatomic) BOOL fullAccessGranted;
@property (nonatomic) NSLayoutConstraint *heightConstraint;

@property (strong, nonatomic) UIView *titleView;
@property (strong, nonatomic) UIScrollView *titleScrollView;
@property (assign, nonatomic) NSUInteger currentPage;

@property (strong, nonatomic) UIScrollView *pageScrollView;

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) LITKeyboardNoAccessViewController *noAccessViewController;

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIView *titleContentView;

@property (strong, nonatomic) NSArray *keyboards;

@property (nonatomic, strong) UIButton *nextKeyboardButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *soundbiteButton;
@property (nonatomic, strong) UIButton *lyricButton;
@property (nonatomic, strong) UIButton *dubButton;
@property (nonatomic, strong) UIButton *favButton;
@property (nonatomic, strong) UIButton *emojiButton;
@property (nonatomic, strong) UIButton *searchButton;

@property (nonatomic, strong) UIView *viewLyric;
@property (nonatomic, strong) UIView *viewSoundBite;
@property (nonatomic, strong) UIView *viewDub;
@property (nonatomic, strong) UIView *viewFav;
@property (nonatomic, strong) UIView *viewEmoji;
@property (nonatomic, strong) UIView *viewSearch;

@property (strong, nonatomic) CAKeyframeAnimation *currentAnimation;

@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSUInteger timerCounter;


@property (assign ,nonatomic, getter=isRotating)    BOOL rotating;
@property (assign, nonatomic, getter=isScrolling)   BOOL scrolling;
@property (assign, nonatomic) BOOL lock;
@property (assign, nonatomic) BOOL viewsAdded;

@property (assign, nonatomic) CGFloat originContentOffset;
@property (assign, nonatomic) CGFloat lastAnimationOffset;

@property (strong, nonatomic) NSArray *titleLabels;
@property (strong, nonatomic) NSArray *titleLabelShakers;

@property (strong, nonatomic) UIView *titleScrollIndicator;

@property (strong, nonatomic) NSMutableArray *keyboardViewControllers;


@property (assign, nonatomic) CGFloat lastFrameHeight;

@property (nonatomic, strong) NSMutableArray *arrayLyrics;
@property (nonatomic, strong) NSMutableArray *arraySoundBites;
@property (nonatomic, strong) NSMutableArray *arrayDubs;
@property (nonatomic, strong) NSMutableArray *arrayEmojis;
@property (nonatomic, strong) NSMutableArray *arrayTags;

@property (nonatomic, strong) PFObject *favoriteObject;

@property (assign, nonatomic) LITKeyboard_Type currentLITKeyboardType;

@property (strong, nonatomic) UIView *viewButtons;

@property (strong, nonatomic) UIView *searchView;
@property (strong, nonatomic) NSLayoutConstraint *searchViewLeftLS;

@property (strong, nonatomic) SearchViewController *searchVC;

@end


@interface LITKeyboardsBaseViewController () <UIScrollViewDelegate>

@end

@implementation LITKeyboardsBaseViewController

static NSArray *kLITKBGradientColors;

+ (void)initialize
{
    [super initialize];
    
    kLITKBGradientColors = @[@[(id)[UIColor lit_kbFadeOrangeDark].CGColor,
                               (id)[UIColor lit_kbFadeOrangeLight].CGColor],
                             @[(id)[UIColor lit_kbFadeFavoritesDark].CGColor,
                               (id)[UIColor lit_kbFadeFavoritesLight].CGColor],
                             @[(id)[UIColor lit_kbFadePurpleDark].CGColor,
                               (id)[UIColor lit_kbFadePurpleLight].CGColor],
                             @[(id)[UIColor lit_kbFadeBlueDark].CGColor,
                               (id)[UIColor lit_kbFadeBlueLight].CGColor],
                             @[(id)[UIColor lit_kbFadeGreenDark].CGColor,
                               (id)[UIColor lit_kbFadeGreenLight].CGColor],
                             @[(id)[UIColor lit_kbFadeRedDark].CGColor,
                               (id)[UIColor lit_kbFadeRedLight].CGColor],
                             @[(id)[UIColor lit_kbFadeOrangeDark].CGColor,
                               (id)[UIColor lit_kbFadeOrangeLight].CGColor]];
}

+ (NSArray *)kLITKBGradientColors
{
    return kLITKBGradientColors;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Perform custom initialization work here
        self.portraitHeight = floorf(kLITKeyboardCellItemPortraitDimension * 2 + kLITKeyboardCellItemSpacing * 2 + 30);
        self.landscapeHeight = floorf(kLITKeyboardCellItemLandscapeDimension + 32);
        
        self.arrayDubs = [NSMutableArray array];
        self.arrayLyrics = [NSMutableArray array];
        self.arraySoundBites = [NSMutableArray array];
        self.arrayEmojis = [NSMutableArray array];
        self.arrayTags = [NSMutableArray array];
        
        self.currentLITKeyboardType = LITKeyboard_Lyric;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.timerCounter = 0;
    
    if([self isFullAccessGranted]){
        self.fullAccessGranted = YES;
        
        if (![Parse isLocalDatastoreEnabled]) {
            [Parse enableLocalDatastore];
            
            // Enable data sharing in app extensions.
            [Parse enableDataSharingWithApplicationGroupIdentifier:kLITAppGroupSharingIdentifier
                                             containingApplication:AppBundleIdentifier];
            // Setup Parse
            [Parse setApplicationId:kLITApplicationIdentifier
                          clientKey:kLITApplicationClientKey];
        }
    
        // Prevents the error caused by opening the keyboard prior to launching the app once
        if([self isExtensionConfigured]){
            // Get installed keyboards for a user
            PFQuery *installedKeyboardsQuery = [[[[PFQuery queryWithClassName:kKeyboardInstallationsClassName] includeKey:kKeyboardInstallationsKeyboardsKey] whereKey:kKeyboardInstallationsUserKey equalTo:[PFUser currentUser]] fromLocalDatastore];
            
            [self.inputView setBackgroundColor:[UIColor blackColor]];
            //    [self.inputView setupGradientBackground];
                             
            [[[installedKeyboardsQuery getFirstObjectInBackground] continueWithSuccessBlock:^id(BFTask *task) {
                NSArray *installedKeyboards = [task.result objectForKey:@"keyboards"];
                BFTask *installedKeyboardsTask = [BFTask taskWithResult:installedKeyboards];
                BFTask *favKeyboardTask = [[[PFUser currentUser] objectForKey:kUserFavKeyboardKey] fetchFromLocalDatastoreInBackground];
                return [BFTask taskForCompletionOfAllTasksWithResults:@[favKeyboardTask, installedKeyboardsTask]];
            }] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
                NSAssert([NSThread isMainThread], @"This call must be executed on the main thread");
                
                self.favoriteObject = [task.result objectAtIndex:0];
                NSLog(@"Content List : %@", self.favoriteObject[@"contents"]);
                NSArray *installedKeyboards = [task.result objectAtIndex:1];
                NSMutableArray *keyboards = [NSMutableArray arrayWithArray:installedKeyboards];
                PFObject *litKeyboard;
                for(int i=0; i<[keyboards count]; i++){
                    if([[[keyboards objectAtIndex:i] valueForKey:@"objectId"] isEqualToString:kLITKeyboardObjectId]){
                        litKeyboard = [keyboards objectAtIndex:i];
                        [keyboards removeObjectAtIndex:i];
                        break;
                    }
                }
                
                [keyboards insertObject:litKeyboard atIndex:0];
                self.keyboards = [NSArray arrayWithArray:keyboards];
                self.keyboardViewControllers = [NSMutableArray arrayWithCapacity:self.keyboards.count];
                for (NSInteger j = 0; j < [self.keyboards count]; j++) {
                    [self.keyboardViewControllers addObject:[NSNull null]];
                }
                
                [self getTagsData:NO];
                [self getLyricsData:NO];
                [self getSoundBitesData:NO];
                [self getDubData:NO];
                [self getEmojiData];
                
                return nil;
            }];
        }
    }
    else {
        self.fullAccessGranted = NO;
    }
    
    UIView *dummyView = [[UILabel alloc] initWithFrame:CGRectZero];
    [dummyView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:dummyView];
    
    self.heightConstraint = [NSLayoutConstraint
                             constraintWithItem:self.inputView
                             attribute:NSLayoutAttributeHeight
                             relatedBy:NSLayoutRelationEqual
                             toItem:nil
                             attribute:NSLayoutAttributeNotAnAttribute
                             multiplier:0.0
                             constant:[self heightConstraintForCurrentOrientation]];
    
    NSLog(@"H Constraint: %f", self.heightConstraint.constant);
    
    
    self.heightConstraint.priority = UILayoutPriorityRequired - 1; // This will eliminate the constraint conflict warning.
    
    self.heightConstraint.priority = 999;

    
    NSLog(@"Added dummy view: %f", [self heightConstraintForCurrentOrientation]);
    
    [self addObserver:self forKeyPath:@"view.frame" options:NSKeyValueObservingOptionOld context:NULL];
    
    _originIndex = 0;
}

- (void)getLyricsData:(BOOL)fulldownload
{
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    
    PFQuery *query = [[[PFQuery queryWithClassName:kLyricClassName] selectKeys:@[kLyricTextKey, kParseTagsKey, kLITKeyboardPriorityKey]] whereKey:kLITObjectHiddenKey equalTo:[NSNumber numberWithBool:NO]];
    [query orderByDescending:kLITKeyboardPriorityKey];
    [query setLimit:1000];
    if (!fulldownload)
    {
        query.limit = 24;
        query.skip = dataKeeper.arrayLyrics.count;
    }
    
    [[query findObjectsInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        if (task.error == nil && task.result)
        {
            NSMutableArray *array = [NSMutableArray arrayWithArray:task.result];
            for (NSInteger i = 0 ; i < array.count ; i ++) {
                LITLyric *lyric = [array objectAtIndex:i];
                [dataKeeper.arrayLyrics addObject:lyric];
            }
            
            if (array.count != 0) {
                if (self.currentPage == 0 && self.currentLITKeyboardType == LITKeyboard_Lyric)
                {
                    LITKeyboardViewController * kbC = [self.keyboardViewControllers objectAtIndex:0];
                    if (kbC && [kbC isKindOfClass:[NSNull class]] == NO) {
                        LITKeyboard *keyboard = [[LITKeyboard alloc] init];
                        keyboard.contents = [NSMutableArray arrayWithArray:self.arrayLyrics];
                        [kbC setKeyboard:keyboard];
                        [kbC.collectionView reloadData];
                    }
                }
                
                if (!fulldownload)
                {
                    [self getLyricsData:NO];
                }
            }
        }
        
        return nil;
    }];
}

- (void)getSoundBitesData:(BOOL)fulldownload
{
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    
    PFQuery *query = [[[PFQuery queryWithClassName:kSoundBiteClassName] selectKeys:@[kSoundbiteCaptionKey, kParseTagsKey, kLITKeyboardPriorityKey]] whereKey:kLITObjectHiddenKey equalTo:[NSNumber numberWithBool:NO]];
    [query orderByDescending:kLITKeyboardPriorityKey];
    [query setLimit:1000];
    
    if (!fulldownload) {
        query.limit = 24;
        query.skip = dataKeeper.arraySoundBites.count;
    }
    [[query findObjectsInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        if (task.error == nil && task.result)
        {
            NSMutableArray *array = [NSMutableArray arrayWithArray:task.result];
            for (NSInteger i = 0 ; i < array.count ; i ++) {
                LITSoundbite *soundBite = [array objectAtIndex:i];
                [dataKeeper.arraySoundBites addObject:soundBite];
            }
            
            if (array.count != 0)
            {
                if (self.currentPage == 0 && self.currentLITKeyboardType == LITKeyboard_SoundBit)
                {
                    LITKeyboardViewController * kbC = [self.keyboardViewControllers objectAtIndex:0];
                    if (kbC && [kbC isKindOfClass:[NSNull class]] == NO) {
                        LITKeyboard *keyboard = [[LITKeyboard alloc] init];
                        keyboard.contents = [NSMutableArray arrayWithArray:self.arraySoundBites];
                        [kbC setKeyboard:keyboard];
                        [kbC.collectionView reloadData];
                    }
                }
                
                if (!fulldownload)
                    [self getSoundBitesData:NO];
            }
        }
        
        return nil;
    }];
}

- (void)getDubData:(BOOL)fulldownload
{
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    
    PFQuery *query = [[[PFQuery queryWithClassName:kDubClassName] selectKeys:@[kDubCaptionKey, kParseTagsKey, kLITKeyboardPriorityKey]] whereKey:kLITObjectHiddenKey equalTo:[NSNumber numberWithBool:NO]];
    [query orderByDescending:kLITKeyboardPriorityKey];
    [query setLimit:1000];
    
    if (!fulldownload) {
        query.limit = 24;
        query.skip = dataKeeper.arrayDubs.count;
    }
    
    [[query findObjectsInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        if (task.error == nil && task.result)
        {
            NSMutableArray *array = [NSMutableArray arrayWithArray:task.result];
            for (NSInteger i = 0 ; i < array.count ; i ++) {
                LITDub *dub = [array objectAtIndex:i];
                [dataKeeper.arrayDubs addObject:dub];
            }
            
            if (array.count != 0)
            {
                if (self.currentPage == 0 && self.currentLITKeyboardType == LITKeyboard_Dub)
                {
                    LITKeyboardViewController * kbC = [self.keyboardViewControllers objectAtIndex:0];
                    if (kbC && [kbC isKindOfClass:[NSNull class]] == NO) {
                        LITKeyboard *keyboard = [[LITKeyboard alloc] init];
                        keyboard.contents = [NSMutableArray arrayWithArray:self.arrayDubs];
                        [kbC setKeyboard:keyboard];
                        [kbC.collectionView reloadData];
                    }
                }
                
                if (!fulldownload)
                    [self getDubData:NO];
            }
        }
        
        return nil;
    }];
}

- (void)getEmojiData
{
    PFQuery *query = [[[PFQuery queryWithClassName:kEmojiClassName] selectKeys:@[kEmojiEmojiKey, kEmojiEmojiPreviewKey]] whereKey:kLITObjectHiddenKey equalTo:[NSNumber numberWithBool:NO]];
    [query orderByDescending:kLITKeyboardPriorityKey];
    [query setLimit:1000];
    
    [[query findObjectsInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        if (task.error == nil && task.result)
        {
            NSMutableArray *array = [NSMutableArray arrayWithArray:task.result];
            for (NSInteger i = 0 ; i < array.count ; i ++) {
                LITEmoji *emoji = [array objectAtIndex:i];
                [self.arrayEmojis addObject:emoji];
            }
            
            if (self.currentPage == 0 && self.currentLITKeyboardType == LITKeyboard_Emoji)
            {
                LITKeyboardViewController * kbC = [self.keyboardViewControllers objectAtIndex:0];
                if (kbC && [kbC isKindOfClass:[NSNull class]] == NO) {
                    LITKeyboard *keyboard = [[LITKeyboard alloc] init];
                    keyboard.contents = [NSMutableArray arrayWithArray:self.arrayEmojis];
                    [kbC setKeyboard:keyboard];
                    [kbC.collectionView reloadData];
                }
            }
        }
        
        return nil;
    }];
}

- (void)getTagsData:(BOOL)fullDownload
{
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    PFQuery *query = [[PFQuery queryWithClassName:kTagClassName] selectKeys:@[kTagTextKey]];
    [query orderByDescending:kLITObjectUsesKey];
    [query setLimit:1000];
    if (!fullDownload)
    {
        query.limit = 20;
        query.skip = dataKeeper.arrayTags.count;
    }
    
    [[query findObjectsInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        if (task.error == nil && task.result)
        {
            NSMutableArray *array = [NSMutableArray arrayWithArray:task.result];
            for (NSInteger i = 0 ; i < array.count ; i ++) {
                PFObject *object = [array objectAtIndex:i];
                NSString *tagText = [object objectForKey:@"text"];
                DataKeeper *dataKeeper = [DataKeeper sharedInstance];
                [dataKeeper.arrayTags addObject:tagText];
            }
            
            if (array.count != 0)
            {
                if (self.currentPage == 0 && self.searchViewLeftLS.constant == 0)
                {
                    if ([self.delegate respondsToSelector:@selector(didUpdateTags)])
                        [self.delegate didUpdateTags];
                }
                
                if (!fullDownload)
                    [self getTagsData:NO];
            }
        }
        
        return nil;
    }];
}

- (BOOL)isFullAccessGranted
{
    return !![UIPasteboard generalPasteboard];
}

- (BOOL)isExtensionConfigured
{
    if([PFUser currentUser] != nil){return YES;}
    else{return NO;}
}

- (void)setupNoFullAccessController {
    
    self.noAccessViewController = [[LITKeyboardNoAccessViewController alloc] init];
    self.noAccessViewController.parentController = self;
    self.noAccessViewController.titleView = self.titleView;
    self.noAccessViewController.nextKeyboardButton = self.nextKeyboardButton;
    self.noAccessViewController.deleteButton = self.deleteButton;
    [self.noAccessViewController setDelegate:self];
}   

- (void)fireButtonAction:(UIButton *)sender {
    [self.textDocumentProxy insertText:@"🔥"];
}

- (IBAction)deleteButtonAction:(id)sender {
    
    if([sender class] == [UIButton class]){
        self.timerCounter = 0;
    }
    else{
        self.timerCounter++;
    }
    
    if(self.timerCounter < 8) {
        [self.textDocumentProxy deleteBackward];
    }
    else if(self.timerCounter < 24) {
        NSString *fieldTextBeforeDeletion = [self.textDocumentProxy documentContextBeforeInput];
        NSString *fieldTextAfterDeletion = [self removeLastWordFromString:fieldTextBeforeDeletion];
        
        for(int i=0; i<[fieldTextBeforeDeletion length]-[fieldTextAfterDeletion length]; i++){
            [self.textDocumentProxy deleteBackward];
        }
    }
    else{
        while([self.textDocumentProxy hasText]){
            [self.textDocumentProxy deleteBackward];
        }
    }
}

- (NSString *)removeLastWordFromString:(NSString *)str
{
    __block NSRange lastWordRange = NSMakeRange([str length], 0);
    NSStringEnumerationOptions opts = NSStringEnumerationByWords | NSStringEnumerationReverse | NSStringEnumerationSubstringNotRequired;
    [str enumerateSubstringsInRange:NSMakeRange(0, [str length]) options:opts usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        lastWordRange = substringRange;
        *stop = YES;
    }];
    return [str substringToIndex:lastWordRange.location];
}

- (void)deleteButtonPressed:(UILongPressGestureRecognizer*)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(deleteButtonAction:) userInfo:nil repeats:YES];
            
            NSRunLoop * theRunLoop = [NSRunLoop currentRunLoop];
            [theRunLoop addTimer:self.timer forMode:NSDefaultRunLoopMode];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self.timer invalidate];
            self.timer = nil;
            self.timerCounter = 0;
        }
            break;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [super viewWillAppear:animated];
    [self.inputView addConstraint:self.heightConstraint];
    
    [self.soundbiteButton setSelected:(self.currentLITKeyboardType == LITKeyboard_SoundBit)];
    [self.lyricButton setSelected:(self.currentLITKeyboardType == LITKeyboard_Lyric)];
    [self.dubButton setSelected:(self.currentLITKeyboardType == LITKeyboard_Dub)];
    [self.favButton setSelected:(self.currentLITKeyboardType == LITKeyboard_Favorite)];
    [self.emojiButton setSelected:(self.currentLITKeyboardType == LITKeyboard_Emoji)];
    [self.searchButton setSelected:(self.currentLITKeyboardType == LITKeyboard_Search)];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    NSLog(@"%@", NSStringFromSelector(_cmd));
    // Add custom view sizing constraints here
    if (!self.heightConstraint || self.view.frame.size.width == 0 ||
        self.view.frame.size.height == 0 || !self.heightConstraint.active) {
        NSLog(@"Returning");
        return;
    }
    
    CGFloat currentHeight = [self heightConstraintForCurrentOrientation];
    if (self.heightConstraint.constant != currentHeight) {
        NSLog(@"Setting heightConstraint to %f", currentHeight);
        self.heightConstraint.constant = currentHeight;
    }
    
//    NSLog(@"Update View constraints: %f, %f", CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    if (!_constraintsSet && CGRectGetHeight(self.view.frame) == self.heightConstraint.constant) {
        NSLog(@"Constraints set");
//        NSLog(@"Setting views at Update View constraints: %f, %f", CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
//
        _constraintsSet = YES;
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [super viewDidAppear:animated];
    
//    NSLog(@"View did appear: %f, %f", CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    
//    
}

//- (void)didReceiveMemoryWarning
//{
//    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
//    [self.keyboardViewControllers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ((idx != self.currentPage && idx + 1 != self.currentPage  && idx - 1 != self.currentPage) ||
//            ![self.pageViewController.viewControllers containsObject:obj]) {
//            [indexSet addIndex:idx];
//        }
//    }];
//    NSMutableArray *nulls = [NSMutableArray arrayWithCapacity:indexSet.count];
//    for (NSInteger i = 0; i < [indexSet count]; i++) {
//        [nulls addObject:[NSNull null]];
//    }
//    [self.keyboardViewControllers replaceObjectsAtIndexes:indexSet withObjects:nulls];
//}

- (void)viewWillLayoutSubviews
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [super viewWillLayoutSubviews];
    
    if (!self.viewsAdded && CGRectGetHeight(self.view.frame) == self.heightConstraint.constant &&
        CGRectGetWidth(self.titleContentView.frame) != 0 &&
        CGRectGetWidth(self.titleContentView.frame) == [self.keyboards count] * CGRectGetWidth(self.titleScrollView.frame)) {
        
        NSInteger i = 0;
        NSMutableArray *labels = [NSMutableArray new];
        NSMutableArray *shakers = [NSMutableArray new];
        for (id<LITKeyboard>keyboard in self.keyboards) {
            NSLog(@"viewWillLayoutSubviews():%@", keyboard.displayName);
            UILabel *titleLabel = [self instantiateNewTitleLabelWithTitle:keyboard.displayName];
            PFObject *obj = (PFObject*)keyboard;
            if([[obj valueForKey:@"objectId"] isEqualToString:kLITKeyboardObjectId])
                [titleLabel setText:@""];
            [labels addObject:titleLabel];
            [shakers addObject:[[AFViewShaker alloc] initWithView:titleLabel]];
            [self.titleContentView addSubview:titleLabel];
            
            NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint
                                                     constraintWithItem:titleLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                     toItem:self.titleContentView
                                                     attribute:NSLayoutAttributeCenterY
                                                     multiplier:1.0
                                                     constant:0];
            CGFloat multiplier =  (1 / (float)self.keyboards.count) * (float)(2*i + 1);
            NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint
                                                     constraintWithItem:titleLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                     toItem:self.titleContentView
                                                     attribute:NSLayoutAttributeCenterX
                                                     multiplier:multiplier
                                                     constant:0];
            
            [self.titleContentView addConstraints:@[centerXConstraint, centerYConstraint]];
            i++;
        }
        
        [self.titleScrollIndicator
         setFrame:CGRectMake(0 , 0, CGRectGetWidth(self.titleView.frame) / [self.keyboards count], 1)];
        
        self.titleLabels = [NSArray arrayWithArray:labels];
        self.titleLabelShakers = [NSArray arrayWithArray:shakers];
        _numberOfPages = i;
        self.viewsAdded = YES;
    }
}

- (void)viewDidLayoutSubviews
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [super viewDidLayoutSubviews];
    
    if (self.isRotating || self.isScrolling) {
        return;
    }
    if (CGRectGetWidth(self.view.frame) == 0 || CGRectGetHeight(self.view.frame) == 0 ||
        CGRectGetHeight(self.view.frame) != self.heightConstraint.constant || !self.keyboards)
        return;
    if (CGRectGetWidth(self.pageViewController.view.frame) == 0 || CGRectGetHeight(self.pageViewController.view.frame) == 0) {
        return;
    }
    
    NSLog(@"Did Layout subviews: %@", NSStringFromCGRect(self.view.frame));
    
    //Wait until our main view has the desired height
    if (!_gradientSet && (CGRectGetHeight(self.view.frame) == self.landscapeHeight || CGRectGetHeight(self.view.frame) == self.portraitHeight)) {
        UIColor *startColor = [UIColor colorWithCGColor:(__bridge CGColorRef)([LITKeyboardsBaseViewController kLITKBGradientColors][0][0])];
        UIColor *endColor = [UIColor colorWithCGColor:(__bridge CGColorRef)([LITKeyboardsBaseViewController kLITKBGradientColors][0][1])];
        [self.view setupGradientBackgroundFromPoint:CGPointMake(0, 0) andStartingColor:startColor toPoint:CGPointMake(0, 1) andFinalColor:endColor];
        [self.titleView addBlurEffectBehindOthers:YES];
        _gradientSet = YES;
    }
}

- (void)setupScrollViews
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    self.pageViewController = [[UIPageViewController alloc]
                               initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                               navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                               options:nil];
    [self.pageViewController setDelegate:self];
    [self.pageViewController setDataSource:self];
    UIScrollView *scrollView;
    for (UIView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            scrollView = (UIScrollView *)view;
            [scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [(UIScrollView *)view setDelegate:self];
        }
    }
    
    NSDictionary *scrollBinding  = NSDictionaryOfVariableBindings(scrollView);
    
    NSArray *scrollVConstraints = [NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:|[scrollView]|"
                                   options:0
                                   metrics:nil
                                   views:scrollBinding];
    
    NSArray *scrollHConstraints = [NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:|[scrollView]|"
                                   options:0
                                   metrics:nil
                                   views:scrollBinding];
    
    [self.pageViewController.view setBackgroundColor:[UIColor clearColor]];
    [self.pageViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.pageViewController.view addConstraints:scrollVConstraints];
    [self.pageViewController.view addConstraints:scrollHConstraints];
    
    LITKeyboardViewController *litKeyboardViewController = [self instantiateKeyboardControllerForIndex:0];
    [self.pageViewController setViewControllers:@[litKeyboardViewController]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    
    self.titleView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.titleView setTranslatesAutoresizingMaskIntoConstraints:NO];
    UIScrollView *titleScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    titleScrollView.scrollEnabled = NO;
    [titleScrollView setUserInteractionEnabled:YES];
    [titleScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.titleScrollView = titleScrollView;
    
    [self.titleScrollView setShowsVerticalScrollIndicator:NO];
    [self.titleScrollView setShowsHorizontalScrollIndicator:NO];
    [self.titleScrollView setBackgroundColor:[UIColor clearColor]];
    
    [self addChildViewController:self.pageViewController];
    
    [self.view addSubview:self.pageViewController.view];
    
    [self.pageViewController didMoveToParentViewController:self];
    
    
    [self.view addSubview:self.titleView];
    [self.titleView addSubview:titleScrollView];
    
    
    self.titleScrollIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 1)];
    [self.titleScrollIndicator setBackgroundColor:[UIColor whiteColor]];
    [self.titleView addSubview:self.titleScrollIndicator];
    
    
    UIView *view = self.view;
    UIView *pageView = self.pageViewController.view;
    UIView *titleView = self.titleView;
    
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view, pageView, titleView, titleScrollView);
    
    NSLayoutConstraint *titleViewConstraint = [NSLayoutConstraint constraintWithItem:self.titleView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    NSLayoutConstraint *titleViewHeightConstraint = [NSLayoutConstraint
                                                     constraintWithItem:self.titleView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                     toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                     multiplier:1.0
                                                     constant:kTitleViewHeight];
    
    NSArray *pageHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pageView]|" options:0 metrics:nil views:bindings];
    NSArray *titleHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleView]|" options:0 metrics:nil views:bindings];
    
    NSArray *pageVConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[pageView]-30-|" options:0 metrics:nil views:bindings];
    [self.view addConstraints:pageVConstraints];
    [self.view addConstraints:@[titleViewConstraint, titleViewHeightConstraint]];
    [self.view addConstraints:pageHConstraints];
    [self.view addConstraints:titleHConstraints];
    
    NSArray *titleScrollVConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleScrollView]|" options:0 metrics:nil views:bindings];
    [self.titleView addConstraints:titleScrollVConstraints];
    
    NSArray *titleScrollHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleScrollView]|" options:0 metrics:nil views:bindings];
    [self.titleView addConstraints:titleScrollHConstraints];
    
    self.nextKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nextKeyboardButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.nextKeyboardButton setImage:[UIImage imageNamed:@"kbGlobe"] forState:UIControlStateNormal];
    [self.nextKeyboardButton sizeToFit];
    [self.titleView addSubview:self.nextKeyboardButton];
    [self.nextKeyboardButton addTarget:self action:@selector(advanceToNextInputMode) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.deleteButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.deleteButton setImage:[UIImage imageNamed:@"kbDelete"] forState:UIControlStateNormal];
    [self.deleteButton sizeToFit];
    [self.deleteButton addTarget:self
                          action:@selector(deleteButtonAction:)
                forControlEvents:UIControlEventTouchDown];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteButtonPressed:)];
    [self.deleteButton addGestureRecognizer:longPress];
    
    [self.titleView addSubview:self.deleteButton];
    
    [self.titleView addConstraint:[NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.titleView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self.titleView addConstraint:[NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.titleView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:12.5]];
    
    [self.nextKeyboardButton addConstraint:[NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20.0]];
    [self.nextKeyboardButton addConstraint:[NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20.0]];
    
    [self.titleView addConstraint:[NSLayoutConstraint constraintWithItem:self.deleteButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.titleView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self.titleView addConstraint:[NSLayoutConstraint constraintWithItem:self.deleteButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.titleView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-12.5]];
    
    [self.deleteButton addConstraint:[NSLayoutConstraint constraintWithItem:self.deleteButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:17.0]];
    [self.deleteButton addConstraint:[NSLayoutConstraint constraintWithItem:self.deleteButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:23.0]];
    
    self.titleContentView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.titleContentView setBackgroundColor:[UIColor clearColor]];
    [self.titleContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.titleScrollView addSubview:self.titleContentView];
    
    UIView *titleContentView = self.titleContentView;
    
    NSDictionary *titleBinding = NSDictionaryOfVariableBindings(titleContentView);
    
    NSLayoutConstraint *titleContentViewHeightConstraint = [NSLayoutConstraint
                                                            constraintWithItem:self.titleContentView
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                            toItem:self.titleView
                                                            attribute:NSLayoutAttributeHeight
                                                            multiplier:1.0
                                                            constant:0.0];
    NSLayoutConstraint *titleContentViewWidthConstraint = [NSLayoutConstraint
                                                           constraintWithItem:self.titleContentView
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                           toItem:self.titleView
                                                           attribute:NSLayoutAttributeWidth
                                                           multiplier:self.keyboards.count
                                                           constant:0.0];
    
    NSArray *titleContentVConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleContentView]|" options:0 metrics:nil views:titleBinding];
    [self.titleView addConstraints:titleScrollVConstraints];
    
    NSArray *titleContentHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleContentView]|" options:0 metrics:nil views:titleBinding];
    [self.titleView addConstraints:titleScrollHConstraints];
    
    [self.titleScrollView addConstraints:titleContentVConstraints];
    [self.titleScrollView addConstraints:titleContentHConstraints];
    
    [self.titleView
     addConstraints:@[titleContentViewHeightConstraint, titleContentViewWidthConstraint]];
    
    CGFloat offsetWidth = (self.view.bounds.size.width - 90) / 6;
    
    self.viewButtons = [[UIView alloc] init];
    self.viewButtons.backgroundColor = [UIColor clearColor];
    self.viewButtons.translatesAutoresizingMaskIntoConstraints = NO;
    [self.titleContentView addSubview:self.viewButtons];
    
    [self.titleContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.viewButtons attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.titleContentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:45]];
    [self.titleContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.viewButtons attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleContentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.titleContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.viewButtons attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.titleContentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewButtons attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:self.view.bounds.size.width - 90]];
    
    // Lyric button
    self.viewLyric = [[UIView alloc] init];
    [self.viewLyric setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.viewLyric.backgroundColor = [UIColor clearColor];
    [self.viewButtons addSubview:self.viewLyric];
    
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewLyric attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self.viewLyric addConstraint:[NSLayoutConstraint constraintWithItem:self.viewLyric attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:offsetWidth]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewLyric attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewLyric attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    self.lyricButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.lyricButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.lyricButton setImage:[UIImage imageNamed:@"LyricIcon"] forState:UIControlStateNormal];
    [self.lyricButton setImage:[UIImage imageNamed:@"LyricSelectedIcon"] forState:UIControlStateSelected];
    [self.lyricButton sizeToFit];
    [self.viewLyric addSubview:self.lyricButton];
    [self.lyricButton addTarget:self action:@selector(lyricAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.viewLyric addConstraint:[NSLayoutConstraint constraintWithItem:self.lyricButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.viewLyric attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.viewLyric addConstraint:[NSLayoutConstraint constraintWithItem:self.lyricButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.viewLyric attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    // SoundBite button
    self.viewSoundBite = [[UIView alloc] init];
    [self.viewSoundBite setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.viewSoundBite.backgroundColor = [UIColor clearColor];
    [self.viewButtons addSubview:self.viewSoundBite];
    
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewSoundBite attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.viewLyric attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    [self.viewSoundBite addConstraint:[NSLayoutConstraint constraintWithItem:self.viewSoundBite attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:offsetWidth]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewSoundBite attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewSoundBite attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    self.soundbiteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.soundbiteButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.soundbiteButton setImage:[UIImage imageNamed:@"SoundBitIcon"] forState:UIControlStateNormal];
    [self.soundbiteButton setImage:[UIImage imageNamed:@"SoundBitSelectedIcon"] forState:UIControlStateSelected];
    [self.soundbiteButton sizeToFit];
    [self.viewSoundBite addSubview:self.soundbiteButton];
    [self.soundbiteButton addTarget:self action:@selector(soundBiteAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.viewSoundBite addConstraint:[NSLayoutConstraint constraintWithItem:self.soundbiteButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.viewSoundBite attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.viewSoundBite addConstraint:[NSLayoutConstraint constraintWithItem:self.soundbiteButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.viewSoundBite attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    // Dub button
    self.viewDub = [[UIView alloc] init];
    [self.viewDub setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.viewDub.backgroundColor = [UIColor clearColor];
    [self.viewButtons addSubview:self.viewDub];
    
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewDub attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.viewSoundBite attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [self.viewDub addConstraint:[NSLayoutConstraint constraintWithItem:self.viewDub attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:offsetWidth]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewDub attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewDub attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    self.dubButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.dubButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.dubButton setImage:[UIImage imageNamed:@"DubIcon"] forState:UIControlStateNormal];
    [self.dubButton setImage:[UIImage imageNamed:@"DubSelectedIcon"] forState:UIControlStateSelected];
    [self.dubButton sizeToFit];
    [self.viewDub addSubview:self.dubButton];
    [self.dubButton addTarget:self action:@selector(dubAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.viewDub addConstraint:[NSLayoutConstraint constraintWithItem:self.dubButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.viewDub attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.viewDub addConstraint:[NSLayoutConstraint constraintWithItem:self.dubButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.viewDub attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    // Emoji button
    self.viewEmoji = [[UIView alloc] init];
    [self.viewEmoji setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.viewEmoji.backgroundColor = [UIColor clearColor];
    [self.viewButtons addSubview:self.viewEmoji];
    
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewEmoji attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.viewDub attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [self.viewEmoji addConstraint:[NSLayoutConstraint constraintWithItem:self.viewEmoji attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:offsetWidth]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewEmoji attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewEmoji attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    self.emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.emojiButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.emojiButton setImage:[UIImage imageNamed:@"EmojiIcon"] forState:UIControlStateNormal];
    [self.emojiButton setImage:[UIImage imageNamed:@"EmojiSelectedIcon"] forState:UIControlStateSelected];
    [self.emojiButton sizeToFit];
    [self.viewEmoji addSubview:self.emojiButton];
    [self.emojiButton addTarget:self action:@selector(emojiAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.viewEmoji addConstraint:[NSLayoutConstraint constraintWithItem:self.emojiButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.viewEmoji attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.viewEmoji addConstraint:[NSLayoutConstraint constraintWithItem:self.emojiButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.viewEmoji attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    // Favorite button
    self.viewFav = [[UIView alloc] init];
    [self.viewFav setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.viewFav.backgroundColor = [UIColor clearColor];
    [self.viewButtons addSubview:self.viewFav];
    
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewFav attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.viewEmoji attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [self.viewFav addConstraint:[NSLayoutConstraint constraintWithItem:self.viewFav attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:offsetWidth]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewFav attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewFav attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    self.favButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.favButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.favButton setImage:[UIImage imageNamed:@"FavIcon"] forState:UIControlStateNormal];
    [self.favButton setImage:[UIImage imageNamed:@"FavSelectedIcon"] forState:UIControlStateSelected];
    [self.favButton sizeToFit];
    [self.viewFav addSubview:self.favButton];
    [self.favButton addTarget:self action:@selector(favAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.viewFav addConstraint:[NSLayoutConstraint constraintWithItem:self.favButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.viewFav attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.viewFav addConstraint:[NSLayoutConstraint constraintWithItem:self.favButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.viewFav attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    // Search button
    self.viewSearch = [[UIView alloc] init];
    [self.viewSearch setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.viewSearch.backgroundColor = [UIColor clearColor];
    [self.viewButtons addSubview:self.viewSearch];
    
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewSearch attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.viewFav attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [self.viewSearch addConstraint:[NSLayoutConstraint constraintWithItem:self.viewSearch attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:offsetWidth]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewSearch attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewSearch attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    self.searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.searchButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.searchButton setImage:[UIImage imageNamed:@"SearchIcon"] forState:UIControlStateNormal];
    [self.searchButton setImage:[UIImage imageNamed:@"searchIconSelected"] forState:UIControlStateSelected];
    [self.searchButton sizeToFit];
    [self.viewSearch addSubview:self.searchButton];
    [self.searchButton addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.viewSearch addConstraint:[NSLayoutConstraint constraintWithItem:self.searchButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.viewSearch attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.viewSearch addConstraint:[NSLayoutConstraint constraintWithItem:self.searchButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.viewSearch attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    self.searchView = [[UIView alloc] init];
    self.searchView.translatesAutoresizingMaskIntoConstraints = NO;
    self.searchView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.searchView];
    
    self.searchViewLeftLS = [NSLayoutConstraint constraintWithItem:self.searchView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:self.view.bounds.size.width];
    [self.view addConstraint:self.searchViewLeftLS];
    [self.view addConstraint:self.searchViewLeftLS];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.searchView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.searchView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.searchView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    
    [self.soundbiteButton setSelected:(self.currentLITKeyboardType == LITKeyboard_SoundBit)];
    [self.lyricButton setSelected:(self.currentLITKeyboardType == LITKeyboard_Lyric)];
    [self.dubButton setSelected:(self.currentLITKeyboardType == LITKeyboard_Dub)];
    [self.favButton setSelected:(self.currentLITKeyboardType == LITKeyboard_Favorite)];
    [self.emojiButton setSelected:(self.currentLITKeyboardType == LITKeyboard_Emoji)];
    [self.searchButton setSelected:(self.currentLITKeyboardType == LITKeyboard_Search)];
    
    self.currentLITKeyboardType = LITKeyboard_Lyric;
}

- (void)updateButtons
{
    if (!self.viewButtons)
        return;
    
    for (UIView *subView in [self.viewButtons subviews]) {
        [subView removeFromSuperview];
    }
    
    CGFloat offsetWidth = (self.view.bounds.size.width - 90) / 6;
    
    // Lyric button
    self.viewLyric = [[UIView alloc] init];
    [self.viewLyric setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.viewLyric.backgroundColor = [UIColor clearColor];
    [self.viewButtons addSubview:self.viewLyric];
    
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewLyric attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self.viewLyric addConstraint:[NSLayoutConstraint constraintWithItem:self.viewLyric attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:offsetWidth]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewLyric attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewLyric attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    self.lyricButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.lyricButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.lyricButton setImage:[UIImage imageNamed:@"LyricIcon"] forState:UIControlStateNormal];
    [self.lyricButton setImage:[UIImage imageNamed:@"LyricSelectedIcon"] forState:UIControlStateSelected];
    [self.lyricButton sizeToFit];
    [self.viewLyric addSubview:self.lyricButton];
    [self.lyricButton addTarget:self action:@selector(lyricAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.viewLyric addConstraint:[NSLayoutConstraint constraintWithItem:self.lyricButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.viewLyric attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.viewLyric addConstraint:[NSLayoutConstraint constraintWithItem:self.lyricButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.viewLyric attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    // SoundBite button
    self.viewSoundBite = [[UIView alloc] init];
    [self.viewSoundBite setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.viewSoundBite.backgroundColor = [UIColor clearColor];
    [self.viewButtons addSubview:self.viewSoundBite];
    
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewSoundBite attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.viewLyric attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    [self.viewSoundBite addConstraint:[NSLayoutConstraint constraintWithItem:self.viewSoundBite attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:offsetWidth]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewSoundBite attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewSoundBite attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    self.soundbiteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.soundbiteButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.soundbiteButton setImage:[UIImage imageNamed:@"SoundBitIcon"] forState:UIControlStateNormal];
    [self.soundbiteButton setImage:[UIImage imageNamed:@"SoundBitSelectedIcon"] forState:UIControlStateSelected];
    [self.soundbiteButton sizeToFit];
    [self.viewSoundBite addSubview:self.soundbiteButton];
    [self.soundbiteButton addTarget:self action:@selector(soundBiteAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.viewSoundBite addConstraint:[NSLayoutConstraint constraintWithItem:self.soundbiteButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.viewSoundBite attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.viewSoundBite addConstraint:[NSLayoutConstraint constraintWithItem:self.soundbiteButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.viewSoundBite attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    // Dub button
    self.viewDub = [[UIView alloc] init];
    [self.viewDub setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.viewDub.backgroundColor = [UIColor clearColor];
    [self.viewButtons addSubview:self.viewDub];
    
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewDub attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.viewSoundBite attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [self.viewDub addConstraint:[NSLayoutConstraint constraintWithItem:self.viewDub attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:offsetWidth]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewDub attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewDub attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    self.dubButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.dubButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.dubButton setImage:[UIImage imageNamed:@"DubIcon"] forState:UIControlStateNormal];
    [self.dubButton setImage:[UIImage imageNamed:@"DubSelectedIcon"] forState:UIControlStateSelected];
    [self.dubButton sizeToFit];
    [self.viewDub addSubview:self.dubButton];
    [self.dubButton addTarget:self action:@selector(dubAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.viewDub addConstraint:[NSLayoutConstraint constraintWithItem:self.dubButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.viewDub attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.viewDub addConstraint:[NSLayoutConstraint constraintWithItem:self.dubButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.viewDub attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    // Emoji button
    self.viewEmoji = [[UIView alloc] init];
    [self.viewEmoji setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.viewEmoji.backgroundColor = [UIColor clearColor];
    [self.viewButtons addSubview:self.viewEmoji];
    
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewEmoji attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.viewDub attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [self.viewEmoji addConstraint:[NSLayoutConstraint constraintWithItem:self.viewEmoji attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:offsetWidth]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewEmoji attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewEmoji attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    self.emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.emojiButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.emojiButton setImage:[UIImage imageNamed:@"EmojiIcon"] forState:UIControlStateNormal];
    [self.emojiButton setImage:[UIImage imageNamed:@"EmojiSelectedIcon"] forState:UIControlStateSelected];
    [self.emojiButton sizeToFit];
    [self.viewEmoji addSubview:self.emojiButton];
    [self.emojiButton addTarget:self action:@selector(emojiAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.viewEmoji addConstraint:[NSLayoutConstraint constraintWithItem:self.emojiButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.viewEmoji attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.viewEmoji addConstraint:[NSLayoutConstraint constraintWithItem:self.emojiButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.viewEmoji attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    // Favorite button
    self.viewFav = [[UIView alloc] init];
    [self.viewFav setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.viewFav.backgroundColor = [UIColor clearColor];
    [self.viewButtons addSubview:self.viewFav];
    
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewFav attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.viewEmoji attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [self.viewFav addConstraint:[NSLayoutConstraint constraintWithItem:self.viewFav attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:offsetWidth]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewFav attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewFav attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    self.favButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.favButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.favButton setImage:[UIImage imageNamed:@"FavIcon"] forState:UIControlStateNormal];
    [self.favButton setImage:[UIImage imageNamed:@"FavSelectedIcon"] forState:UIControlStateSelected];
    [self.favButton sizeToFit];
    [self.viewFav addSubview:self.favButton];
    [self.favButton addTarget:self action:@selector(favAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.viewFav addConstraint:[NSLayoutConstraint constraintWithItem:self.favButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.viewFav attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.viewFav addConstraint:[NSLayoutConstraint constraintWithItem:self.favButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.viewFav attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    // Search button
    self.viewSearch = [[UIView alloc] init];
    [self.viewSearch setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.viewSearch.backgroundColor = [UIColor clearColor];
    [self.viewButtons addSubview:self.viewSearch];
    
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewSearch attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.viewFav attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [self.viewSearch addConstraint:[NSLayoutConstraint constraintWithItem:self.viewSearch attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:offsetWidth]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewSearch attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.viewButtons addConstraint:[NSLayoutConstraint constraintWithItem:self.viewSearch attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.viewButtons attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    self.searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.searchButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.searchButton setImage:[UIImage imageNamed:@"SearchIcon"] forState:UIControlStateNormal];
    [self.favButton setImage:[UIImage imageNamed:@"SearchIconSelected"] forState:UIControlStateSelected];
    [self.searchButton sizeToFit];
    [self.viewSearch addSubview:self.searchButton];
    [self.searchButton addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.viewSearch addConstraint:[NSLayoutConstraint constraintWithItem:self.searchButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.viewSearch attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.viewSearch addConstraint:[NSLayoutConstraint constraintWithItem:self.searchButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.viewSearch attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    [self.searchView layoutIfNeeded];
    
    [self.soundbiteButton setSelected:(self.currentLITKeyboardType == LITKeyboard_SoundBit)];
    [self.lyricButton setSelected:(self.currentLITKeyboardType == LITKeyboard_Lyric)];
    [self.dubButton setSelected:(self.currentLITKeyboardType == LITKeyboard_Dub)];
    [self.favButton setSelected:(self.currentLITKeyboardType == LITKeyboard_Favorite)];
    [self.emojiButton setSelected:(self.currentLITKeyboardType == LITKeyboard_Emoji)];
    [self.searchButton setSelected:(self.currentLITKeyboardType == LITKeyboard_Search)];
}

- (void)lyricAction:(id)sender
{
    [self.soundbiteButton setSelected:NO];
    [self.lyricButton setSelected:YES];
    [self.dubButton setSelected:NO];
    [self.favButton setSelected:NO];
    [self.emojiButton setSelected:NO];
    [self.searchButton setSelected:NO];
    
    self.currentLITKeyboardType = LITKeyboard_Lyric;
    
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    
    LITKeyboardViewController * kbC = [self.keyboardViewControllers objectAtIndex:0];
    if (kbC && [kbC isKindOfClass:[NSNull class]] == NO) {
        LITKeyboard *keyboard = [[LITKeyboard alloc] init];
        keyboard.contents = [NSMutableArray arrayWithArray:dataKeeper.arrayLyrics];
        [kbC setKeyboard:keyboard];
        [self instantiateKeyboardControllerForIndex:0];
    }
}

- (void)soundBiteAction:(id)sender
{
    [self.soundbiteButton setSelected:YES];
    [self.lyricButton setSelected:NO];
    [self.dubButton setSelected:NO];
    [self.favButton setSelected:NO];
    [self.emojiButton setSelected:NO];
    
    self.currentLITKeyboardType = LITKeyboard_SoundBit;

    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    
    LITKeyboardViewController * kbC = [self.keyboardViewControllers objectAtIndex:0];
    if (kbC && [kbC isKindOfClass:[NSNull class]] == NO) {
        LITKeyboard *keyboard = [[LITKeyboard alloc] init];
        keyboard.contents = [NSMutableArray arrayWithArray:dataKeeper.arraySoundBites];
        [kbC setKeyboard:keyboard];
        [self instantiateKeyboardControllerForIndex:0];
    }
}

- (void)dubAction:(id)sender
{
    [self.soundbiteButton setSelected:NO];
    [self.lyricButton setSelected:NO];
    [self.dubButton setSelected:YES];
    [self.favButton setSelected:NO];
    [self.emojiButton setSelected:NO];
    [self.searchButton setSelected:NO];
    
    self.currentLITKeyboardType = LITKeyboard_Dub;
    
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    
    LITKeyboardViewController * kbC = [self.keyboardViewControllers objectAtIndex:0];
    if (kbC && [kbC isKindOfClass:[NSNull class]] == NO) {
        LITKeyboard *keyboard = [[LITKeyboard alloc] init];
        keyboard.contents = [NSMutableArray arrayWithArray:dataKeeper.arrayDubs];
        [kbC setKeyboard:keyboard];
        [self instantiateKeyboardControllerForIndex:0];
    }
}

- (void)favAction:(id)sender
{
    [self.soundbiteButton setSelected:NO];
    [self.lyricButton setSelected:NO];
    [self.dubButton setSelected:NO];
    [self.favButton setSelected:YES];
    [self.emojiButton setSelected:NO];
    [self.searchButton setSelected:NO];
    
    self.currentLITKeyboardType = LITKeyboard_Favorite;
    
    LITKeyboardViewController * kbC = [self.keyboardViewControllers objectAtIndex:0];
    if (kbC && [kbC isKindOfClass:[NSNull class]] == NO) {
        [kbC setKeyboard:(LITKeyboard*)self.favoriteObject];
        [self instantiateKeyboardControllerForIndex:0];
    }
}

- (void)emojiAction:(id)sender
{
    [self.soundbiteButton setSelected:NO];
    [self.lyricButton setSelected:NO];
    [self.dubButton setSelected:NO];
    [self.favButton setSelected:NO];
    [self.emojiButton setSelected:YES];
    self.currentLITKeyboardType = LITKeyboard_Emoji;
    
    LITKeyboardViewController * kbC = [self.keyboardViewControllers objectAtIndex:0];
    if (kbC && [kbC isKindOfClass:[NSNull class]] == NO) {
        LITKeyboard *keyboard = [[LITKeyboard alloc] init];
        keyboard.contents = [NSMutableArray arrayWithArray:self.arrayEmojis];
        [kbC setKeyboard:keyboard];
        [self instantiateKeyboardControllerForIndex:0];
    }
}

- (void)searchAction:(id)sender
{
    if (!self.searchVC) {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Keyboard" bundle:nil];
        self.searchVC = [storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
        self.searchVC.view.frame = self.view.bounds;
        self.delegate = self.searchVC;
        self.searchVC.delegate = self;
        [self.searchView addSubview:self.searchVC.view];
        [self addChildViewController:self.searchVC];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        self.searchViewLeftLS.constant = self.view.bounds.size.width;
        [self.view layoutIfNeeded];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.searchViewLeftLS.constant = 0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.view layoutIfNeeded];
            [self.searchVC didMoveToParentViewController:self];
        }];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
    
    UIColor *textColor = nil;
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor blackColor];
    }
    [self.nextKeyboardButton setTitleColor:textColor forState:UIControlStateNormal];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.isScrolling) {
        NSLog(@"---ALREADY SCROLLING----");
    }
    
    self.originContentOffset = scrollView.contentOffset.x;
    self.lastAnimationOffset = scrollView.contentOffset.x;
    CGFloat pageWidth =  CGRectGetWidth(self.titleScrollView.frame);
    _originIndex = floor((self.titleScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    NSLog(@"Origin index is %lu", (unsigned long)_originIndex);
    self.scrolling = YES;
}

// this just calculates the percentages and passes the calculated values off to another method.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isRotating) {
        return;
    }
    NSLog(@"Scroll view did scroll: %@", NSStringFromCGPoint(scrollView.contentOffset));
//    self.hasScrolled = YES;
    
    
    if (fabs(scrollView.contentOffset.x - self.lastAnimationOffset) > 200) {
        //This is to deal with UIPageViewController's particular implementation of scrolling. Its internal
        //scrollview resets content offset when reaching a new page
        NSLog(@"====JUMP=====");
        self.originContentOffset = scrollView.contentOffset.x;
        self.lastAnimationOffset = scrollView.contentOffset.x;
        CGFloat pageWidth =  CGRectGetWidth(self.titleScrollView.frame);
        _originIndex = floor((self.titleScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        return;
    }
    CGFloat maxPageHorizontalOffset = CGRectGetWidth(self.pageViewController.view.frame);
    
    [self.titleScrollView setContentOffset:CGPointMake(self.currentPage * maxPageHorizontalOffset + scrollView.contentOffset.x - maxPageHorizontalOffset, 0.0f)];
    
    NSLog(@"Title Scroll View: %@", NSStringFromCGPoint(self.titleScrollView.contentOffset));
    
    CGFloat offsetDiference = scrollView.contentOffset.x - self.originContentOffset;
    
    self.lastAnimationOffset = scrollView.contentOffset.x;
    
    if (offsetDiference > 0) {
        if (_originIndex == [self.keyboards count] - 1) {
            NSLog(@"====RETURNING 1=====");
            return;
        }
        _currentDirection = LITKBScrollDirectionRight;
    } else {
        if (_originIndex == 0) {
            NSLog(@"====RETURNING 2=====");
            return;
        }
        _currentDirection = LITKBScrollDirectionLeft;
    }
    
    NSUInteger nextPage = [self nextPageForIndex:_originIndex andDirection:_currentDirection];

    CGFloat currentOffsetProgress = fabs(offsetDiference);
    
    CGFloat percent = currentOffsetProgress / maxPageHorizontalOffset;
    
    NSLog(@"Origin: %f, current: %f, offsetDifference: %f progress: %f, nextPage: %lu, originIndex: %lu", self.originContentOffset, currentOffsetProgress, offsetDiference, percent, (unsigned long)nextPage, (unsigned long)_originIndex);
    
    if (percent == 0) {
        return;
    }
    
    UILabel *originLabel = self.titleLabels[_originIndex];
    UILabel *destinationLabel = self.titleLabels[nextPage];
    
    [originLabel setAlpha:1 - percent];
    [destinationLabel setAlpha:percent];

    self.currentAnimation = [self keyframeAnimationForGradientLayer:self.view.gradientLayer nextPage:nextPage];
    if (percent >= 1) {
        percent = 0.99;
    }
    self.currentAnimation.timeOffset = percent;
    // Replace the current animation with a new one having the desired timeOffset
    [self.view.gradientLayer addAnimation:self.currentAnimation forKey:@"colors"];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"Did end decelerating");
    if (self.currentAnimation) {
        if (self.currentAnimation.timeOffset <= 0.5) {
            [[self.view gradientLayer] setColors:self.currentAnimation.values[0]];
        } else {
            [[self.view gradientLayer] setColors:self.currentAnimation.values[1]];
        }
    }

    self.currentAnimation = nil;
    
    self.scrolling = NO;
//    self.hasScrolled = NO;
    self.lock = NO;
    
    CGFloat titleScrollIndicatorWidth = CGRectGetWidth(self.titleView.frame) / [self.keyboards count];
    NSUInteger currentPage = self.currentPage;
    
    [UIView animateWithDuration:0.4 animations:^{
        [self.titleScrollIndicator
         setFrame:CGRectMake(titleScrollIndicatorWidth * currentPage, 0, titleScrollIndicatorWidth, 1)];
    }];
}

#pragma mark - UIPageControllerDelegate 

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    if (completed) {
        UIViewController *controller = [pageViewController.viewControllers lastObject];
        self.currentPage = [self.keyboardViewControllers indexOfObject:controller];
        NSLog(@"pageViewDidFinish - Keyboard with ID: %@",((LITKeyboardViewController*)controller).keyboard.objectId);
        if(_currentDirection == LITKBScrollDirectionLeft){
            if([self.keyboardViewControllers count] >= self.currentPage+1) {
                // We come from currentPage+1, so we save that keyboard ID in the event
                [[Mixpanel sharedInstance] track:kMixpanelAction_swipeKeyboard_KExtension
                                      properties:@{kMixpanelPropertyKeyboardId: ((LITKeyboardViewController*)[self.keyboardViewControllers objectAtIndex:self.currentPage+1]).keyboard.objectId}];
                // And launch a new timer for the new keyboard the user is seeing now
                [[Mixpanel sharedInstance] timeEvent:kMixpanelAction_swipeKeyboard_KExtension];
            }
        }
        else if(_currentDirection == LITKBScrollDirectionRight){
            if([self.keyboardViewControllers count] <= self.currentPage-1) {
                // We come from currentPage-1, so we save that keyboard ID in the event
                [[Mixpanel sharedInstance] track:kMixpanelAction_swipeKeyboard_KExtension
                                      properties:@{kMixpanelPropertyKeyboardId: ((LITKeyboardViewController*)[self.keyboardViewControllers objectAtIndex:self.currentPage-1]).keyboard.objectId}];
                // And launch a new timer for the new keyboard the user is seeing now
                [[Mixpanel sharedInstance] timeEvent:kMixpanelAction_swipeKeyboard_KExtension];
            }
        }
    }
}

- (UIInterfaceOrientationMask)pageViewControllerSupportedInterfaceOrientations:(UIPageViewController *)pageViewController
{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)pageViewControllerPreferredInterfaceOrientationForPresentation:(UIPageViewController *)pageViewController
{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if (((LITKeyboardViewController *)viewController).index == 0) {
        return nil;
    } else
        return [self
           instantiateKeyboardControllerForIndex:((LITKeyboardViewController *)viewController).index -1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    if (((LITKeyboardViewController *)viewController).index == [self.keyboards count] - 1) {
        return nil;
    } else
    return [self
            instantiateKeyboardControllerForIndex:((LITKeyboardViewController *)viewController).index +1];
}


#pragma mark - Private

- (CAKeyframeAnimation *)keyframeAnimationForGradientLayer:(CAGradientLayer *)gradientLayer nextPage:(NSUInteger)nextPage
{
    CAKeyframeAnimation *colorsAnimation = [CAKeyframeAnimation animationWithKeyPath:@"colors"];
    
    if(nextPage >= [kLITKBGradientColors count]){
        nextPage = ((nextPage-2)%5)+2;
    }
    
    [colorsAnimation setValues:@[gradientLayer.colors,[LITKeyboardsBaseViewController kLITKBGradientColors][nextPage]]];
    [colorsAnimation setKeyTimes:@[@(0.5),@(1)]];
    colorsAnimation.autoreverses = NO;
    colorsAnimation.repeatCount = 0;
    colorsAnimation.removedOnCompletion = NO;
    colorsAnimation.duration = 1;
    colorsAnimation.speed = 0.0;
    colorsAnimation.calculationMode = kCAAnimationLinear;
    colorsAnimation.fillMode = kCAFillModeForwards;
    
    return colorsAnimation;
}

- (NSUInteger)nextPageForIndex:(NSUInteger)index andDirection:(LITKBScrollDirection)leftOrRight
{
    if ((index == 0 && leftOrRight == LITKBScrollDirectionLeft) ||
        (index == [self.keyboards count] -1 && leftOrRight == LITKBScrollDirectionRight)) {
        return index;
    } else return index + leftOrRight;
}

//#pragma mark - Orientation
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    NSLog(@"Size is %@", NSStringFromCGSize(size));
    
    self.rotating = YES;

    BOOL isLandscape = size.height != self.landscapeHeight;

    CGRect gradientFrame = isLandscape ? CGRectMake(0, 0, size.width, self.landscapeHeight) :
    CGRectMake(0, 0, size.width, self.portraitHeight);

    CGFloat frameHeight = isLandscape ? self.landscapeHeight - 30 : self.portraitHeight -32;
//
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        // Place code here to perform animations during the rotation.
        // You can pass nil or leave this block empty if not necessary.
        [self.view.gradientLayer setFrame:gradientFrame];
        [self.titleView setFrame:CGRectMake(0, frameHeight, size.width, size.height)];
        [self updateButtons];
        
        [self.noAccessViewController setupNoFullAccessConstraints];
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        [self.titleScrollView setContentOffset:CGPointMake(size.width * self.currentPage, 0)];
        
        for (NSInteger i = 0; i < [self.keyboardViewControllers count]; i++) {
            if ([self.keyboardViewControllers[i] isKindOfClass:[NSNull class]] ||
                i == self.currentPage) {
                continue;
            }
            LITKeyboardViewController *kbController = self.keyboardViewControllers[i];
            kbController.landscapeActive = isLandscape;
            UICollectionViewLayout *layout = [kbController collectionViewLayoutForOrientation:isLandscape ? UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationPortrait
                                                                                basedOnLayout:(UICollectionViewFlowLayout *)kbController.collectionView.collectionViewLayout];
            [kbController.collectionView setCollectionViewLayout:layout animated:NO];
        }
        self.rotating = NO;
    }];
}

- (CGFloat)heightConstraintForCurrentOrientation
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenH = screenSize.height;
    CGFloat screenW = screenSize.width;
    BOOL isLandscape =  !(self.view.frame.size.width ==
                          (screenW*(screenW<screenH))+(screenH*(screenW>screenH)));
    self.isLandscape = isLandscape;

    return isLandscape ? self.landscapeHeight : self.portraitHeight;
}


- (UILabel *)instantiateNewTitleLabelWithTitle:(NSString *)title
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f];
    label.textColor= [UIColor lit_keyboardTitleColor];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:title];
    [label sizeToFit];
    [self.titleView addSubview:label];
    return label;
}



#pragma mark LITKeyboardFavoritesReload Delegate

- (void)didUpdateFavorites:(LITKeyboardViewController *) keyboardVC {
    dispatch_async(dispatch_get_main_queue(), ^ {
        if (self.currentLITKeyboardType == LITKeyboard_Favorite) {
            LITKeyboardViewController * kbC = [self.keyboardViewControllers objectAtIndex:0];
            [kbC.collectionView reloadData];
        }
    });
}

- (void)keyboardViewController:(LITKeyboardViewController *)keyboardVC didDetectMuteSwitchState:(BOOL)on
{
    NSInteger index = [self.keyboardViewControllers indexOfObject:keyboardVC];
    if (index != NSNotFound) {
        if (on) {
            NSString *originalText = [self.titleLabels[index] text];
            [self.titleLabels[index] setText:kTurnOnSoundMessage];
            AFViewShaker *shaker = self.titleLabelShakers[index];
            if (self.viewButtons)
                self.viewButtons.hidden = YES;
            [shaker shakeWithDuration:2 completion:^{
                [self.titleLabels[index] setText:originalText];
                if (self.viewButtons)
                    self.viewButtons.hidden = NO;
            }];
        }
    } else {
        [self.titleLabels[index] setText:[self.keyboards[index] displayName]];
    }
}

- (BOOL)presentTutorialViewControllerForItem:(PFObject *)object
{
    BOOL isTutorialCompleted = [[[NSUserDefaults standardUserDefaults] objectForKey:@"extensionTutorialCompleted"] boolValue];
    if (isTutorialCompleted == NO){
        if([NSStringFromClass([object class]) isEqualToString:@"LITLyric"] || [NSStringFromClass([object class]) isEqualToString:@"LITEmoji"]){
            return NO;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"extensionTutorialCompleted"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        LITKeyboardTutorialViewController *tutorialController = [[UIStoryboard storyboardWithName:@"LITKeyboard" bundle:nil]
                                                                 instantiateViewControllerWithIdentifier:@"LITKeyboardTutorialViewController"];
        [tutorialController willMoveToParentViewController:self];
        [tutorialController.view setFrame:CGRectMake(0, 0,
                                                     CGRectGetWidth(self.inputView.frame),
                                                     CGRectGetHeight(self.inputView.frame) - CGRectGetHeight(self.titleScrollView.frame))];
        [tutorialController.view setTag:989];
        
        if([NSStringFromClass([object class]) isEqualToString:@"LITSoundbite"]){
            tutorialController.nowPasteLabel.text = @"Now paste the Soundbite in a message!";
        }
        else if([NSStringFromClass([object class]) isEqualToString:@"LITDub"]){
            tutorialController.nowPasteLabel.text = @"Now paste the Dub in a message!";
        }
        
        [self.inputView addSubview:tutorialController.view];
        
        [tutorialController didMoveToParentViewController:self];
        
        // The tutorial is presented, so the keyboard won't preview the object
        return YES;
    }
    
    // The tutorial is not presented, so the object will be previewed
    return NO;
}

#pragma mark LITKeyboardNoAccess Delegate

- (void) didTapFireButton:(LITKeyboardNoAccessViewController *) noAccessVC {
    [self.textDocumentProxy insertText:@"🔥"];
}

- (void) didTapAppButton:(LITKeyboardNoAccessViewController *) noAccessVC {
    
    UIResponder* responder = self;
    while ((responder = [responder nextResponder]) != nil)
    {
        if([responder respondsToSelector:@selector(openURL:)] == YES)
        {
            [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:@"itslit://"]];
        }
    }
}

- (void) didTapDeleteButton:(LITKeyboardNoAccessViewController *) noAccessVC {
    [self.textDocumentProxy deleteBackward];
}

#pragma mark LITKeyboardTutorial Delegate

- (void) didTapLastButtonOfTutorial:(LITKeyboardTutorialViewController *)tutorialVC
{
    //[self didMoveToParentViewController:self];
    //[[[self.view subviews] viewWithTag:989] removeFromSuperview];
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if([keyPath isEqualToString:@"view.frame"]) {
        NSAssert([NSThread isMainThread], @"This call must be executed on the main thread");
        NSLog(@"Change: Frame is %@", NSStringFromCGRect(self.inputView.frame));
        
        CGFloat frameHeight = CGRectGetHeight(self.view.frame);
        if (self.lastFrameHeight == frameHeight + 20) {
            [self.view setFrame:CGRectMake(self.view.frame.origin.x,
                                           self.view.frame.origin.y - 20,
                                           CGRectGetWidth(self.view.frame),
                                           self.lastFrameHeight)];
            return;
        } else {
            self.lastFrameHeight = frameHeight;
        }
        if (frameHeight == self.heightConstraint.constant) {
            
            [[self.inputView viewWithTag:1000] removeFromSuperview];
            [self removeObserver:self forKeyPath:@"view.frame"];
            
            if(self.fullAccessGranted){
                
                if([self isExtensionConfigured]){
                    
                    [Mixpanel sharedInstanceWithToken:kMixpanelToken];
                    [[Mixpanel sharedInstance] identify:[PFUser currentUser].objectId];
                    [[Mixpanel sharedInstance] registerSuperProperties:@{kMixpanelPropertyUserID:[PFUser currentUser].objectId}];
                    
                    // We start tracking the keyboard times since the app launch (allows to track LIT keyboard)
                    [[Mixpanel sharedInstance] timeEvent:kMixpanelAction_swipeKeyboard_KExtension];
                    
                    if (self.keyboards) {
                        [GBVersionTracking track];
                        [self setupScrollViews];
                    } else {
                        [GBVersionTracking track];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self setupScrollViews];
                        });
                    }
                }
                else {
                    [self setupNoFullAccessController];
                    [self.noAccessViewController setupControllerWithHeight:[self heightConstraintForCurrentOrientation] andAppButtonVisible:YES];
                    [self.noAccessViewController.lineOneLabel setText:@"Keyboard setup incomplete"];
                    [self.noAccessViewController.lineTwoLabel setText:@"Open the Lit App to complete setup"];
                }
            }
            else{
                [self setupNoFullAccessController];
                [self.noAccessViewController setupControllerWithHeight:[self heightConstraintForCurrentOrientation] andAppButtonVisible:NO];
            }
        }
    }
}

#pragma mark - Child creation
- (LITKeyboardViewController *)instantiateKeyboardControllerForIndex:(NSInteger)index
{
    if ([[self.keyboardViewControllers objectAtIndex:index] isKindOfClass:[LITKeyboardViewController class]]) {
        LITKeyboardViewController *kbViewController = [self.keyboardViewControllers objectAtIndex:index];
        kbViewController.collectionView.scrollsToTop = YES;
        if (self.currentLITKeyboardType > LITKeyboard_Favorite)
            kbViewController.currentLITKeyboardType = LITKeyboard_Installed;
        else
            kbViewController.currentLITKeyboardType = self.currentLITKeyboardType;
        
        [kbViewController.collectionView reloadData];
        
        if ([kbViewController.keyboard.contents count] != 0) {
            [kbViewController.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        }
        
        return kbViewController;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LITKeyboard" bundle:nil];
    LITKeyboardViewController *kbViewController = [storyboard instantiateViewControllerWithIdentifier:kLITKeyboardViewControllerStoryboardID];
    
    if (index != 0)
    {
        [kbViewController setKeyboard:self.keyboards[index]];
        [kbViewController setCurrentLITKeyboardType:LITKeyboard_Installed];
    }
    else
    {
        [kbViewController setCurrentLITKeyboardType:self.currentLITKeyboardType];
        
        LITKeyboard *keyboard = [[LITKeyboard alloc] init];
        if (self.currentLITKeyboardType == LITKeyboard_Lyric) {
            keyboard.contents = [NSMutableArray arrayWithArray:self.arrayLyrics];
            [kbViewController setKeyboard:keyboard];
        }
        else if (self.currentLITKeyboardType == LITKeyboard_SoundBit) {
            keyboard.contents = [NSMutableArray arrayWithArray:self.arraySoundBites];
            [kbViewController setKeyboard:keyboard];
        }
        else if (self.currentLITKeyboardType == LITKeyboard_Dub) {
            keyboard.contents = [NSMutableArray arrayWithArray:self.arrayDubs];
            [kbViewController setKeyboard:keyboard];
        }
        else if (self.currentLITKeyboardType == LITKeyboard_Emoji) {
            keyboard.contents = [NSMutableArray arrayWithArray:self.arrayEmojis];
            [kbViewController setKeyboard:keyboard];
        }
        else if (self.currentLITKeyboardType == LITKeyboard_Favorite) {
            [kbViewController setKeyboard:(LITKeyboard*)self.favoriteObject];
        }
    }
 
    kbViewController.collectionView.scrollsToTop = YES;
    
    if ([kbViewController.keyboard.contents count] != 0)
        [kbViewController.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    
    [kbViewController setTextDocumentProxy:self.textDocumentProxy];
    [kbViewController setIndex:index];
    [kbViewController setDelegate:self];
    [kbViewController setLandscapeActive:self.isLandscape];
    kbViewController.view.backgroundColor = [UIColor clearColor];
    
    NSInteger colorIndex = 0;
    
    if(index >= [kLITKBGradientColors count]){
        colorIndex = ((index-2)%5)+2;
    }
    else {
        colorIndex = index;
    }

    [self.keyboardViewControllers replaceObjectAtIndex:index withObject:kbViewController];
    
    return kbViewController;
}

#pragma mark - SearchViewControllerDelegate

- (void)didEndSearch
{
    [self.soundbiteButton setSelected:(self.currentLITKeyboardType == LITKeyboard_SoundBit)];
    [self.lyricButton setSelected:(self.currentLITKeyboardType == LITKeyboard_Lyric)];
    [self.dubButton setSelected:(self.currentLITKeyboardType == LITKeyboard_Dub)];
    [self.favButton setSelected:(self.currentLITKeyboardType == LITKeyboard_Favorite)];
    [self.emojiButton setSelected:(self.currentLITKeyboardType == LITKeyboard_Emoji)];
    [self.searchButton setSelected:(self.currentLITKeyboardType == LITKeyboard_Search)];
    
    [self.view layoutIfNeeded];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            self.searchViewLeftLS.constant = self.view.bounds.size.width;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.view layoutIfNeeded];
            
            if ([self.delegate respondsToSelector:@selector(didCloseSearch)])
                [self.delegate didCloseSearch];
            
            [self.searchVC.view removeFromSuperview];
            [self.searchVC removeFromParentViewController];
            self.searchVC = nil;
        }];
    });
}

@end
