//
//  MainViewController.m
//  slit-ios
//
//  Created by ioshero on 06/07/2015.
//  Copyright (c) 2015 Slit Inc. All rights reserved.
//

#import "LITTheme.h"
#import "LITMainViewController.h"
#import "LITAddToKeyboardViewController.h"
#import "LITProfileViewController.h"
#import "LITProfileFavoritesViewController.h"
#import "LITProfileKeyboardsViewController.h"
#import "ParseGlobals.h"
#import "lit_ios-Swift.h"
#import "LITMainFeedViewController.h"
#import "LITKeyboardFeedViewController.h"
#import "LITKeyboardInstallerHelper.h"
#import "LITFeedDelegate.h"
#import "LITKeyboard.h"
#import "LITLyric.h"
#import "LITSoundbite.h"
#import "LITDub.h"
#import "LITCongratsKeyboardViewController.h"
#import "LITShareHelper.h"
#import "LITReportViewController.h"
#import "LITProgressHud.h"
#import "LITSettingsViewController.h"
#import "LITCustomPushAnimator.h"
#import "LITContentQueryTableViewController.h"
#import "LITKeyboardTableViewCell.h"
#import <DateTools/DateTools.h>
#import <HMSegmentedControl/HMSegmentedControl.h>
#import <Parse/Parse.h>
#import <Bolts/Bolts.h>
#import <MediaPlayer/MediaPlayer.h>
#import <ParseUI/PFImageView.h>
#import <CoreGraphics/CoreGraphics.h>
#import <JGActionSheet/JGActionSheet.h>
#import "LITActionSheet.h"
#import "LITKeyboardActionSheetHeader.h"
#import "LITSharedFileCache.h"
@import AssetsLibrary;
@import MessageUI;
@import Social;
#import <DMActivityInstagram/DMActivityInstagram.h>
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"
#import <ABOnboarding/ABOnboardingViewController.h>
#import "WSCoachMarksView.h"
#import "LITGlobals.h"


#define KeyboardsSegmentIndex 0
#define ContentSegmentIndex 1

static NSString *const kAddSoundbiteSegueIdentifier     = @"SoundbiteSegue";
static NSString *const kAddLyricsSegueIdentifier        = @"LyricsSegue";
static NSString *const kAddDubSegueIdentifier           = @"DubSegue";
static NSString *const kProfileSegueIdentifier          = @"ProfileSegue";
static NSString *const kSettingsSegueIdentifier         = @"SettingsSegue";

@interface LITMainViewController () < LITAddToKeyboardViewControllerDelegate, GooeyDelegate, LITFeedDelegate, UINavigationControllerDelegate, WSCoachMarksViewDelegate>  {
    NSInteger _lastSegmentIndex;
    BOOL _viewsSet;
    UIView *_savedView;
}

@property (strong, nonatomic)   Gooey *gMenu;
@property (strong, nonatomic)   HMSegmentedControl *segmentedControl;
@property (strong, nonatomic)   UIRefreshControl *refreshControl;
@property (strong, nonatomic)   LITKeyboardFeedViewController *keyboardsViewController;
@property (strong, nonatomic)   LITMainFeedViewController *feedViewController;

@property (strong, nonatomic) UIView *blackOverlayView;
@property (assign, nonatomic) BOOL isGooeyOpen;

@property (assign, nonatomic) BOOL willPerformSegueToCurrentUserProfile;
@property (strong, nonatomic) PFUser *segueUser;

@property (weak, nonatomic) IBOutlet UIView *controlHolderView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlHolderViewHeightConstraint;

@property (assign, nonatomic) CGFloat savedHeightConstraint;
@property (assign, nonatomic) BOOL controlCustomized;

@property (strong, nonatomic) JGProgressHUD *hud;

@property (strong, nonatomic) LITCustomPushAnimator *animator;
@property (strong, nonatomic) UIPercentDrivenInteractiveTransition *interactionController;
@property (strong, nonatomic) NSArray *installedKeyboards;

@property (strong, nonatomic) LITProfileViewController *activeProfileViewController;
@property (assign, nonatomic) NSInteger openProfilesCounter;

@end


@implementation LITMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissTutorialViewController)
                                                 name:kLITnotificationTutorialDismissed
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissLongPressCoach)
                                                 name:kLITnotificationLongPressCoachDismissed
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissContentCoach)
                                                 name:kLITnotificationContentCoachDismissed
                                               object:nil];
    
    // -..
 
    [self setTitleLogo];
    
    self.willPerformSegueToCurrentUserProfile = YES;
    self.openProfilesCounter = 0;
    
    self.isGooeyOpen = NO;
    
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController setDelegate:self];
    
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"KEYBOARD", @"CONTENT"]];
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
    
    [self.segmentedControl setSelectedSegmentIndex:KeyboardsSegmentIndex];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.segmentedControl setFrame:CGRectMake(0, 0, CGRectGetWidth(self.controlHolderView.bounds), 36.0f)];
    [self.controlHolderView addSubview:self.segmentedControl];
    
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton setImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
    [settingsButton sizeToFit];
    [settingsButton addTarget:self
                       action:@selector(settingsButtonPressed:)
             forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *settingsBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    self.navigationItem.leftBarButtonItem = settingsBarButtonItem;
    
    UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [profileButton setImage:[UIImage imageNamed:@"profile"] forState:UIControlStateNormal];
    [profileButton sizeToFit];
    [profileButton addTarget:self
                      action:@selector(profileButtonPressed:)
            forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *profileBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:profileButton];
    self.navigationItem.rightBarButtonItem = profileBarButtonItem;
    
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.keyboardsViewController = [mainStoryboard instantiateViewControllerWithIdentifier:NSStringFromClass([LITKeyboardFeedViewController class])];
    [self.keyboardsViewController setDelegate:self];
    
    self.feedViewController = [mainStoryboard instantiateViewControllerWithIdentifier:NSStringFromClass([LITMainFeedViewController class])];
    [self.feedViewController setDelegate:self];
    
    [self.keyboardsViewController.view setFrame:self.containerView.frame];
    [self.keyboardsViewController.view setBackgroundColor:[UIColor clearColor]];
    [self addChildViewController:self.keyboardsViewController];
    [self.containerView addSubview:self.keyboardsViewController.view];
    [self.keyboardsViewController didMoveToParentViewController:self];
    
    
    [self.feedViewController.view setFrame:self.containerView.frame];
    [self.feedViewController.view setBackgroundColor:[UIColor clearColor]];
    [self addChildViewController:self.feedViewController];
    [self.containerView addSubview:self.feedViewController.view];
    [self.feedViewController didMoveToParentViewController:self];
    
    [self createGooeyMenu];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:panRecognizer];
    
    
    
    
    
    self.installedKeyboards = @[];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kLITKeyboardWasRemovedNotificationName object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        self.installedKeyboards = note.object;
        //[self.keyboardsViewController loadObjects];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:kLITKeyboardWasInstalledNotificationName object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        self.installedKeyboards = note.object;
        //[self.keyboardsViewController loadObjects];
    }];
}

- (void) createGooeyMenu {
    
    double size = 120;
    
    //CGRect frame = CGRectMake(self.view.frame.size.width/2-size/2, self.view.frame.size.height-size-30, size, size);
    CGRect frame = CGRectMake(self.view.frame.size.width/2-size/2, self.view.frame.size.height-size-10, size, size);
    self.gMenu = [[Gooey alloc] initWithFrame:frame];
    self.gMenu.color = [UIColor lit_lightOrangishColor];
    self.gMenu.delegate = self;
    self.gMenu.tag = 111;
    [self.view addSubview:self.gMenu];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.view bringSubviewToFront:self.gMenu];
    [self.segmentedControl setFrame:self.controlHolderView.bounds];
    if (!_viewsSet) {
        [self.containerView bringSubviewToFront:self.containerView];
        [self.containerView bringSubviewToFront:self.keyboardsViewController.view];
        _viewsSet = YES;
    }
    if (!self.controlCustomized) {
        [self.segmentedControl setClipsToBounds:YES];
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.borderColor = [UIColor lit_lightGreyColor].CGColor;
        bottomBorder.borderWidth = 2;
        bottomBorder.frame = CGRectMake(-1, -2, CGRectGetWidth(self.controlHolderView.frame) + 4, CGRectGetHeight(self.controlHolderView.frame) + 2);
        
        [self.segmentedControl.layer insertSublayer:bottomBorder atIndex:0];
        self.controlCustomized = YES;
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"tutorialCompleted"]){
        NSLog(@"%@", NSStringFromCGRect([UIScreen mainScreen].bounds));
        NSString *storyboardName = CGRectGetHeight([UIScreen mainScreen].bounds) == 480 ?
        @"Tutorial-iPhone4" : @"Tutorial";
        ABOnboardingViewController *onBoardingViewController = [ABOnboardingViewController onboardingViewControllerWithChildrenStoryboardIds:@[@"FirstViewController",@"SecondViewController"/*,@"ThirdPrevViewController"*/,@"ThirdViewController",@"ThirdNextViewController",@"FourthViewController",@"FifthViewController"] forStoryboard:[UIStoryboard storyboardWithName:storyboardName bundle:nil]];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self presentViewController:onBoardingViewController animated:NO completion:^{
            if(self.segmentedControl.selectedSegmentIndex == KeyboardsSegmentIndex) {
                [self.keyboardsViewController viewWillAppear:animated];
            } else if (self.segmentedControl.selectedSegmentIndex == ContentSegmentIndex) {
                [self.feedViewController viewWillAppear:animated];
            }
        }];
    } else {
        if(self.segmentedControl.selectedSegmentIndex == KeyboardsSegmentIndex) {
            [self.keyboardsViewController viewWillAppear:animated];
        } else if (self.segmentedControl.selectedSegmentIndex == ContentSegmentIndex) {
            [self.feedViewController viewWillAppear:animated];
        }
    }
    
}


-(void)didDismissTutorialViewController {
    
    // Coach Marks
    
    // Setup coach marks
    NSArray *coachMarks = @[
                            @{
                                @"rect": [NSValue valueWithCGRect:
                                          CGRectMake(self.segmentedControl.frame.origin.x,
                                                     self.segmentedControl.frame.origin.y+kLITheightMainDifference,
                                                     CGRectGetWidth(self.view.frame),
                                                     CGRectGetHeight(self.segmentedControl.frame))],
                                @"caption": @"The main feed has two streams: keyboards and content.\n\nContent feed shows individual songs, while keyboard feed shows the complete album, if you catch our drift...",
                                @"shape": @"square"
                                },
                            @{
                                @"rect": [NSValue valueWithCGRect:
                                          CGRectMake(self.gMenu.frame.origin.x,
                                                     self.gMenu.frame.origin.y+kLITheightMainDifference,
                                                     self.gMenu.frame.size.width,
                                                     self.gMenu.frame.size.height)],
                                @"caption": @"Whether you're ready to enter the big league and customize your own keyboard -- or just a piece of content -- this is the jumping off point for you to start.",
                                @"shape": @"circle"
                                }
                            ];
    WSCoachMarksView *coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.navigationController.view.bounds coachMarks:coachMarks];
    [self.navigationController.view addSubview:coachMarksView];
    [coachMarksView setMaskColor:[UIColor colorWithWhite:0 alpha:.75]];
    [coachMarksView setEnableSkipButton:NO];
    [coachMarksView setEnableContinueLabel:NO];
    [coachMarksView.lblCaption setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:14.0f]];
    [coachMarksView setDelegate:self];
    [coachMarksView start];
}

-(void)didDismissLongPressCoach {
    
    // Simulate tap on "Content Feed"
    [self.feedViewController viewWillAppear:NO];
    [self.containerView bringSubviewToFront:self.feedViewController.view];
    [self.containerView insertSubview:self.keyboardsViewController.view belowSubview:self.separatorView];
    _lastSegmentIndex = self.segmentedControl.selectedSegmentIndex;

    [[NSNotificationCenter defaultCenter] postNotificationName:kLITnotificationNeedContentCoach
                                                        object:nil
                                                      userInfo:nil];
}

-(void)didDismissContentCoach {
    
    // Simulate tap on "Keyboard Feed"
    [self.keyboardsViewController viewWillAppear:NO];
    [self.containerView bringSubviewToFront:self.keyboardsViewController.view];
    [self.containerView insertSubview:self.feedViewController.view belowSubview:self.separatorView];
    _lastSegmentIndex = self.segmentedControl.selectedSegmentIndex;
    
    /*
    // Coach Marks
    
    // Setup coach marks
    NSArray *coachMarks = @[
                            @{
                                @"rect": [NSValue valueWithCGRect:
                                          CGRectMake(50,120,0,0)],
                                @"caption": @"Now you can start using LIT!",
                                @"shape": @"circle"
                                }
                            ];
    WSCoachMarksView *coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.navigationController.view.bounds coachMarks:coachMarks];
    [self.navigationController.view addSubview:coachMarksView];
    [coachMarksView setMaskColor:[UIColor colorWithWhite:0 alpha:.75]];
    [coachMarksView setEnableSkipButton:NO];
    [coachMarksView setEnableContinueLabel:NO];
    [coachMarksView.lblCaption setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:30.0f]];
    [coachMarksView setDelegate:self];
    [coachMarksView start];
     */
}


#pragma mark - WSCoachMarks Delegate

- (void)coachMarksView:(WSCoachMarksView*)coachMarksView willNavigateToIndex:(NSUInteger)index {}
- (void)coachMarksView:(WSCoachMarksView*)coachMarksView didNavigateToIndex:(NSUInteger)index {}
- (void)coachMarksViewDidCleanup:(WSCoachMarksView*)coachMarksView {}
- (void)coachMarksViewWillCleanup:(WSCoachMarksView*)coachMarksView {
    [[NSNotificationCenter defaultCenter] postNotificationName:kLITnotificationMainCoachDismissed
                                                        object:nil
                                                      userInfo:nil];
}

#pragma mark - Actions

- (void)settingsButtonPressed:(UIBarButtonItem *)button
{
    [[Mixpanel sharedInstance] track:kMixpanelAction_settings_TopBar properties:nil];
    [self performSegueWithIdentifier:kSettingsSegueIdentifier sender:nil];
}

- (void)profileButtonPressed:(UIBarButtonItem *)button
{
    self.openProfilesCounter = 0;
    [[Mixpanel sharedInstance] track:kMixpanelAction_profile_TopBar properties:nil];
    self.willPerformSegueToCurrentUserProfile = YES;
    [self performSegueWithIdentifier:kProfileSegueIdentifier sender:nil];
}

- (void)segmentedControlValueChanged:(UISegmentedControl *)control
{
    if (self.segmentedControl.selectedSegmentIndex == _lastSegmentIndex) {
        return;
    } if (self.segmentedControl.selectedSegmentIndex == KeyboardsSegmentIndex) {
        
        [[Mixpanel sharedInstance] track:kMixpanelAction_keyboard_FeedSegment properties:nil];
        
        [self.keyboardsViewController viewWillAppear:NO];
        [self.containerView bringSubviewToFront:self.keyboardsViewController.view];
        [self.containerView insertSubview:self.feedViewController.view belowSubview:self.separatorView];
    } else if (self.segmentedControl.selectedSegmentIndex == ContentSegmentIndex) {
        
        [[Mixpanel sharedInstance] track:kMixpanelAction_content_FeedSegment properties:nil];
        
        [self.feedViewController viewWillAppear:NO];
        [self.containerView bringSubviewToFront:self.feedViewController.view];
        [self.containerView insertSubview:self.keyboardsViewController.view belowSubview:self.separatorView];
    }
    _lastSegmentIndex = self.segmentedControl.selectedSegmentIndex;
}

-(void)didSelectMenuItem:(NSUInteger)index{
    switch (index) {
        case 0:
            [[Mixpanel sharedInstance] track:kMixpanelAction_soundbitesButton_Gooey properties:nil];
            [self performSegueWithIdentifier:kAddSoundbiteSegueIdentifier sender:nil];
            break;
        case 1:
            [[Mixpanel sharedInstance] track:kMixpanelAction_lyricsButton_Gooey properties:nil];
            [self performSegueWithIdentifier:kAddLyricsSegueIdentifier sender:nil];
            break;
        case 2:
            [[Mixpanel sharedInstance] track:kMixpanelAction_dubsButton_Gooey properties:nil];
            [self performSegueWithIdentifier:kAddDubSegueIdentifier sender:nil];
            break;
        default:
            break;
    }
    
}

// Actions prior to the segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kAddSoundbiteSegueIdentifier] ||
        [[segue identifier] isEqualToString:kAddLyricsSegueIdentifier] ||
        [[segue identifier] isEqualToString:kAddDubSegueIdentifier]) {
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        NSAssert([navController isKindOfClass:[UINavigationController class]], @"Unexepected class type");
        LITContentQueryTableViewController *contentsController = (LITContentQueryTableViewController *)navController.topViewController;
        [contentsController setOptionsDelegate:self];
        [contentsController setFeedDelegate:self];
        
    }
    else if ([[segue identifier] isEqualToString:kProfileSegueIdentifier]
               && self.willPerformSegueToCurrentUserProfile) {
        
        self.installedKeyboards = @[];
        
        self.activeProfileViewController = [segue destinationViewController];
        self.activeProfileViewController.delegate = self;
        self.activeProfileViewController.user = [PFUser currentUser];
        self.activeProfileViewController.installedKeyboards = self.installedKeyboards;
        self.segueUser = nil;
        
        self.activeProfileViewController.numberOfProfileView = self.openProfilesCounter;
        self.openProfilesCounter++;
        
        PFQuery *queryForInstallations = [[[PFQuery
                                            queryWithClassName:kKeyboardInstallationsClassName]
                                           whereKey:kKeyboardInstallationsUserKey
                                           equalTo:[PFUser currentUser]] fromLocalDatastore];
        [[queryForInstallations findObjectsInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
            NSMutableArray *installedKeyboardsRaw = [NSMutableArray arrayWithArray:[task.result[0] objectForKey:@"keyboards"]];
            [installedKeyboardsRaw removeObjectAtIndex:0];
            self.installedKeyboards = [NSArray arrayWithArray:[[installedKeyboardsRaw reverseObjectEnumerator] allObjects]];
            [self.activeProfileViewController reloadKeyboards:self.installedKeyboards];
            
            self.segueUser = nil;
            return nil;
        }];
    }
    else if ([[segue identifier] isEqualToString:kProfileSegueIdentifier]
             && !self.willPerformSegueToCurrentUserProfile) {
        
        self.installedKeyboards = @[];
        self.activeProfileViewController = [segue destinationViewController];
        self.activeProfileViewController.delegate = self;
        self.activeProfileViewController.user = self.segueUser;
        self.activeProfileViewController.installedKeyboards = self.installedKeyboards;
        
        self.activeProfileViewController.numberOfProfileView = self.openProfilesCounter;
        self.openProfilesCounter++;
        
        PFQuery *queryForInstallations = [[PFQuery
                                            queryWithClassName:kKeyboardInstallationsClassName]
                                           whereKey:kKeyboardInstallationsUserKey
                                           equalTo:self.segueUser];
        [[queryForInstallations findObjectsInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
            NSMutableArray *installedKeyboardsRaw = [NSMutableArray arrayWithArray:[task.result[0] objectForKey:@"keyboards"]];
            [installedKeyboardsRaw removeObjectAtIndex:0];
            self.installedKeyboards = [NSArray arrayWithArray:[[installedKeyboardsRaw reverseObjectEnumerator] allObjects]];
            [self.activeProfileViewController reloadKeyboards:self.installedKeyboards];
            
            self.segueUser = nil;
            return nil;
        }];
    }
    
}

#pragma mark - Menu
- (void)gooeyDidSelectIndex:(NSInteger)index
{
    self.isGooeyOpen = NO;
    
    [UIView animateWithDuration:.4 animations:^{
        self.blackOverlayView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.blackOverlayView removeFromSuperview];
    }];
    
    [self.gMenu animateClose:0.13];
    
    switch (index) {
        case 0:
            [self performSegueWithIdentifier:kAddSoundbiteSegueIdentifier sender:nil];
            break;
        case 1:
            [self performSegueWithIdentifier:kAddDubSegueIdentifier sender:nil];
            break;
        case 2:
            [self performSegueWithIdentifier:kAddLyricsSegueIdentifier sender:nil];
            break;
        default:
            break;
    }
}

- (void)gooeyDidTapMainButton
{
    self.isGooeyOpen = !self.isGooeyOpen;
    
    // The Gooey has been opened => Black overlay
    if(self.isGooeyOpen){
        
        if(!self.blackOverlayView) {
            
            // Insert the overlay UIView under the Gooey button
            self.blackOverlayView =[[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            [self.blackOverlayView setBackgroundColor:[UIColor colorWithWhite:0 alpha:.6]];
            self.blackOverlayView.tag = 222;
            
            // Gooey Button Labels
            
            float textSize = 12.0f;
            float labelWidth = 100.0f;
            float gooeyHeight = 220.0f;
            float gooeyHeightMargin = 35.0f;
            float centralDistance = 50.0f;
            
            UILabel *labelSb = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-centralDistance-labelWidth,
                                                                        [UIScreen mainScreen].bounds.size.height-gooeyHeight+gooeyHeightMargin,
                                                                        labelWidth,
                                                                        20)];
            [labelSb setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:textSize]];
            labelSb.text = @"SOUNDBITES";
            labelSb.textColor = [UIColor whiteColor];
            labelSb.textAlignment = NSTextAlignmentRight;
            
            UILabel *labelDb = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-labelWidth/2,
                                                                        [UIScreen mainScreen].bounds.size.height-gooeyHeight,
                                                                        labelWidth,
                                                                        20)];
            [labelDb setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:textSize]];
            labelDb.text = @"DUBS";
            labelDb.textColor = [UIColor whiteColor];
            labelDb.textAlignment = NSTextAlignmentCenter;
            
            UILabel *labelLy = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2+centralDistance,
                                                                        [UIScreen mainScreen].bounds.size.height-gooeyHeight+gooeyHeightMargin,
                                                                        labelWidth,
                                                                        20)];
            [labelLy setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:textSize]];
            labelLy.text = @"LYRICS";
            labelLy.textColor = [UIColor whiteColor];
            labelLy.textAlignment = NSTextAlignmentLeft;
            
            [self.blackOverlayView addSubview:labelSb];
            [self.blackOverlayView addSubview:labelDb];
            [self.blackOverlayView addSubview:labelLy];
        }
        
        self.blackOverlayView.alpha = 0;
        [UIView animateWithDuration:.4 animations:^() {
            self.blackOverlayView.alpha = 1.0f;
        }];
        
        [self.view addSubview:self.blackOverlayView];
        [self.view bringSubviewToFront:self.gMenu];
    }
    
    // The Gooey has been closed => Overlay out
    else {
        [UIView animateWithDuration:.4 animations:^{
            self.blackOverlayView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self.blackOverlayView removeFromSuperview];
        }];
    }
}

#pragma mark - LITFeedDelegate

- (void)showProfileOfUser:(PFUser *)user
{
    if(user == self.segueUser) {
        return;
    }
    else {
        self.segueUser = user;
        if(user == [PFUser currentUser]){
            self.willPerformSegueToCurrentUserProfile = YES;
            [self performSegueWithIdentifier:kProfileSegueIdentifier sender:self];
        }
        else{
            self.willPerformSegueToCurrentUserProfile = NO;
            if([user.objectId isEqualToString:kLITUserId]){
                PFQuery *query = [PFQuery queryWithClassName:@"_User"];
                [query getObjectInBackgroundWithId:kLITUserId block:^(PFObject *user, NSError *error) {
                    self.segueUser = (PFUser*)user;
                    [self performSegueWithIdentifier:kProfileSegueIdentifier sender:self];
                }];
            }
            else {
                [self performSegueWithIdentifier:kProfileSegueIdentifier sender:self];
            }
        }
        
    }
}

- (void)queryViewController:(UIViewController *)queryViewController didRequestAddingObject:(PFObject *)object
{
    if (queryViewController == self.feedViewController || queryViewController == self.keyboardsViewController) {
        [self presentAddToKeyboardControllerForObject:object inQueryViewController:queryViewController];
    } else if ([queryViewController class] == [LITProfileFavoritesViewController class]) {
        [self presentAddToKeyboardControllerForObject:object inQueryViewController:self.activeProfileViewController];
    } else if ([queryViewController class] == [LITProfileKeyboardsViewController class]) {
        [self presentAddToKeyboardControllerForObject:object inQueryViewController:self.activeProfileViewController];
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"Unexpected query controller received"];
    }
}

- (void)presentAddToKeyboardControllerForObject:(PFObject *)object inQueryViewController:(UIViewController *)queryViewController {
    LITAddToKeyboardViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:kLITAddToKeyboardViewControllerStoryboardIdentifier];
    viewController.object = object;
    viewController.callingController = queryViewController;
    viewController.delegate = self;
    viewController.showsUploadButton = NO;
    [queryViewController.navigationController pushViewController:viewController animated:YES];
}

- (void)queryViewController:(UIViewController *)queryViewController didTapLikeButton:(UIButton *)button forObject:(PFObject *)object withLikesLabel:(UILabel *)likesLabel
{
    if([[self objectIsFavorited:object].result boolValue]){
        [[Mixpanel sharedInstance] track:kMixpanelAction_removeFav_Heart_ContentFeed properties:nil];
    }
    else{
        [[Mixpanel sharedInstance] track:kMixpanelAction_addToFav_Heart_ContentFeed properties:nil];
    }
    
    self.hud = nil;
    
    // Change the heart prior to do anything in Parse
    [self _updateLikeButton:button withState:![[self objectIsFavorited:object].result boolValue] animated:YES];
    
    // Change the counter prior to do anything in Parse
    int originalCounter = (int)[[object valueForKey:kLITKeyboardLikesKey] integerValue];
    if([[self objectIsFavorited:object].result boolValue]){ // Already faved = Unfaving = -1
        if(originalCounter!=0)
            [likesLabel setText:[NSString stringWithFormat:@"%d",originalCounter-1]];
    }
    else{ // Not yet faved = Faving = +1
        [likesLabel setText:[NSString stringWithFormat:@"%d",originalCounter+1]];
    }
    
    
    if (queryViewController == self.keyboardsViewController) {
        NSAssert([object isKindOfClass:[LITKeyboard class]], @"object must be of class LITKeyboard");
//    } else if (queryViewController == self.feedViewController) {
    } else {
        [[[self objectIsFavorited:object] continueWithSuccessBlock:^id(BFTask *taskFaved) {
            return [self objectFavorite:object addOrRemove:![taskFaved.result boolValue] fromQueryViewController:queryViewController];
        }] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
            if (task.error) {
                //[LITProgressHud changeStateOfHUD:self.hud to:kLITHUDStateError withMessage:@"Error saving favorite"];
                //if(self.hud != nil) [self.hud dismissAfterDelay:1.5f];
                NSLog(@"Error saving favorite: %@", task.error.localizedDescription);
                // Error == back to original heart status
                [self _updateLikeButton:button withState:[[self objectIsFavorited:object].result boolValue] animated:YES];
                // Error == back to original counter
                [likesLabel setText:[NSString stringWithFormat:@"%d",originalCounter]];
            } else {
                NSLog(@"Task result: %@", task.result);
                // Heart is already changed
                //[self _updateLikeButton:button withState:[task.result boolValue]];
                // Counter is already changed
                //[likesLabel setText:[[object valueForKey:kLITObjectLikesKey] stringValue]];
                NSLog(@"Favorite updated successfully");
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    // Only if we're managing our favorites from our profile view,
                    // we reload the collection
                    if([queryViewController class] == [LITProfileFavoritesViewController class]){
                        if (((LITProfileFavoritesViewController *)queryViewController).user == [PFUser currentUser]) {
                            [((LITProfileFavoritesViewController *)queryViewController) reloadFavoritesCollection];
                        }
                    }
                    
                    
                    //self.hud = [LITProgressHud createHudWithMessage:@""];
                    if([task.result boolValue]){
                        //[LITProgressHud changeStateOfHUD:self.hud to:kLITHUDStateDone withMessage:@"Favorites"];
                    }
                    else{
                        //[LITProgressHud changeStateOfHUD:self.hud to:kLITHUDStateDone withMessage:@"Removed"];
                    }
                    //[self.hud showInView:self.view animated:YES];
                    //if(self.hud != nil) [self.hud dismissAfterDelay:.8];
                });
            }
            return nil;
        }];
    }
}

- (void)updateLikeButtonForCell:(UITableViewCell *)tableViewCell andObject:(PFObject *)object {
    
    [[self objectIsFavorited:object] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
        BOOL resultValue = [task.result boolValue];
        UIButton *button = [tableViewCell valueForKey:@"likeButton"];
        [button setHidden:NO];
        NSAssert(button, @"button cannot be nil");
        [self _updateLikeButton:button withState:resultValue animated:NO];
        return nil;
    }];
}

- (void)_updateLikeButton:(UIButton *)button withState:(BOOL)faved animated:(BOOL)animated
{
    UIImage *presentImage =  [UIImage imageNamed:(faved ? @"likeButton" : @"likeButtonFilled")];
    UIImage *futureImage =  [UIImage imageNamed:(faved ? @"likeButtonFilled" : @"likeButton")];
    
    if(animated){
        CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
        crossFade.duration = 0.2;
        crossFade.fromValue = (id)presentImage.CGImage;
        crossFade.toValue = (id)futureImage.CGImage;
        crossFade.removedOnCompletion = YES;
        crossFade.fillMode = kCAFillModeForwards;
        [button.imageView.layer addAnimation:crossFade forKey:@"animateContents"];
    }
    
    //Make sure to add Image normally after so when the animation
    //is done it is set to the new Image
    [button setImage:futureImage forState:UIControlStateNormal];
}

- (void)queryViewController:(PFQueryCollectionViewController *)queryViewController
   didTapKeyboardLikeButton:(UIButton *)button
                forKeyboard:(PFObject *)object
             withFooterView:(LITKeyboardFooterView *)footerView
                 headerView:(LITKeyboardHeaderView *)headerView
                andFavorite:(BOOL)isFavorite
{
    self.hud = nil;
    
    // Change the heart prior to do anything in Parse
    [self _updateKeyboardLikeButton:button withState:!isFavorite animated:YES];
    
    // Change the counter prior to do anything in Parse
    int originalCounter = (int)[[object valueForKey:kLITKeyboardLikesKey] integerValue];
    if(isFavorite){ // Already faved = Unfaving = -1
        if(originalCounter!=0)
            [headerView.likesLabel setText:[NSString stringWithFormat:@"%ld",(long)originalCounter-1]];
    }
    else{ // Not yet faved = Faving = +1
            [headerView.likesLabel setText:[NSString stringWithFormat:@"%ld",(long)originalCounter+1]];
    }
    
    if (queryViewController == self.keyboardsViewController) {
        NSAssert([object isKindOfClass:[LITKeyboard class]], @"object must be of class LITKeyboard");
    
        [[self keyboardFavorite:object addOrRemove:!isFavorite fromQueryViewController:queryViewController]
          continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
            if (task.error) {
                NSLog(@"Error saving favorite: %@", task.error.localizedDescription);
                // Error == back to original heart status
                [self _updateKeyboardLikeButton:button withState:isFavorite animated:YES];
                // Error == back to original counter
                [headerView.likesLabel setText:[NSString stringWithFormat:@"%ld",(long)originalCounter]];
            } else {
                NSLog(@"Favorite updated successfully");
            }
            return nil;
        }];
    }
}

- (void)updateLikeButtonForKeyboardFooterView:(LITKeyboardFooterView *)footerView andKeyboard:(PFObject *)keyboard {
    
    if(!keyboard) return;
    [[self keyboardIsFavorited:keyboard] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
        BOOL resultValue = [task.result boolValue];
        UIButton *button = footerView.likeButton;
        NSAssert(button, @"button cannot be nil");
        [self _updateKeyboardLikeButton:button withState:resultValue animated:NO];
        return nil;
    }];
}

- (void)_updateKeyboardLikeButton:(UIButton *)button withState:(BOOL)faved animated:(BOOL)animated
{
    UIImage *presentImage =  [UIImage imageNamed:(faved ? @"whiteHeartEmpty" : @"whiteHeartFilled")];
    UIImage *futureImage =  [UIImage imageNamed:(faved ? @"whiteHeartFilled" : @"whiteHeartEmpty")];
    
    if(animated){
        CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
        crossFade.duration = 0.2;
        crossFade.fromValue = (id)presentImage.CGImage;
        crossFade.toValue = (id)futureImage.CGImage;
        crossFade.removedOnCompletion = YES;
        crossFade.fillMode = kCAFillModeForwards;
        [button.imageView.layer addAnimation:crossFade forKey:@"animateContents"];
    }
    
    //Make sure to add Image normally after so when the animation
    //is done it is set to the new Image
    [button setImage:futureImage forState:UIControlStateNormal];
    [button setNeedsDisplay];
}

- (void)queryViewController:(UIViewController *)queryViewController didTapOptionsButton:(UIButton *)button forObject:(PFObject *)object withImage:(UIImage *)image
{    
    if ([queryViewController isKindOfClass:[LITKeyboardFeedViewController class]]) {
        
        [[LITKeyboardInstallerHelper checkKeyboardStatus:(LITKeyboard *)object] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
            
            int headerHeight = 40;
            
            LITKeyboardActionSheetHeader * sheetHeader = [[LITKeyboardActionSheetHeader alloc]initWithFrame:CGRectMake(0, 0, 80, headerHeight)];
            sheetHeader.keyboardLabel.text = [NSString stringWithFormat:@"%@",object[@"displayName"]];
            sheetHeader.authorLabel.text = [NSString stringWithFormat:@"by %@",object[@"user"][@"username"]];
            
            sheetHeader.keyboardImageView.image = image;
            [sheetHeader.keyboardImageView setContentMode:UIViewContentModeScaleAspectFill];
            sheetHeader.keyboardImageView.clipsToBounds = YES;
            
            JGActionSheetSection *titleSection = [JGActionSheetSection sectionWithTitle:nil message:nil contentView:sheetHeader];
            
            NSString *downloadOrRemove;
            
            if([task.result integerValue] == LITKeyboardStatusInstalled){
                downloadOrRemove = @"Remove Keyboard";
            }
            else if([task.result integerValue] == LITKeyboardStatusNonInstalled ||
                    [task.result integerValue] == LITKeyboardStatusUninstalled) {
                downloadOrRemove = @"Download Keyboard";
            }
            
            JGActionSheetSection *optionsSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"Send Report",downloadOrRemove,@"Share Keyboard"] buttonStyle:JGActionSheetButtonStyleDefault];
            
            JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"Cancel"] buttonStyle:JGActionSheetButtonStyleCancel];
            
            
            // LIT Style
            
            [titleSection.titleLabel setTextColor:[UIColor lit_coolGreyColor]];
            [titleSection.messageLabel setTextColor:[UIColor lit_coolGreyColor]];
            
            for(int i=0; i<[optionsSection.buttons count]; i++){
                [LITActionSheet setButtonStyle:JGActionSheetButtonStyleDefault forButton:[optionsSection.buttons objectAtIndex:i]];
            }
            for(int i=0; i<[cancelSection.buttons count]; i++){
                [LITActionSheet setButtonStyle:JGActionSheetButtonStyleCancel forButton:[cancelSection.buttons objectAtIndex:i]];
            }
            
            // --.
            
            
            NSArray *sections = @[titleSection, optionsSection, cancelSection];
            
            LITActionSheet *sheet = [LITActionSheet actionSheetWithSections:sections];
            
            [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
                
                // Action calls
                NSUInteger section = indexPath.section;
                NSUInteger item = indexPath.item;
                
                switch (section) {
                    case 0: // Title
                        break;
                        
                    case 1: // Options
                        if(item == 0){ // Report
                            
                            [[Mixpanel sharedInstance] track:kMixpanelAction_report_3dots_KFeed properties:nil];
                            
                            [self sendReportForObject:object fromViewController:queryViewController];
                        }
                        else if(item == 1){ // Download OR Remove
                            if([task.result integerValue] == LITKeyboardStatusInstalled){
                                
                                [[Mixpanel sharedInstance] track:kMixpanelAction_removeKey_3dots_KFeed properties:nil];
                                
                                [self removeKeyboard:(LITKeyboard *)object withViewController:(LITKeyboardFeedViewController *)queryViewController];
                            }
                            else if([task.result integerValue] == LITKeyboardStatusNonInstalled ||
                                    [task.result integerValue] == LITKeyboardStatusUninstalled) {
                                
                                [[Mixpanel sharedInstance] track:kMixpanelAction_installKey_3dots_KFeed properties:nil];
                                
                                [self downloadKeyboard:(LITKeyboard *)object withViewController:(LITKeyboardFeedViewController *)queryViewController];
                            }
                        }
                        else if(item == 2){ // Share
                            
                            [[Mixpanel sharedInstance] track:kMixpanelAction_shareKey_3dots_KFeed properties:nil];
                            
                            [self shareObject:object fromQueryViewController:queryViewController];
                        }
                        break;
                    case 2: // Cancel
                        
                        [[Mixpanel sharedInstance] track:kMixpanelAction_cancel_3dots_KFeed properties:nil];
                        
                        break;
                    default:
                        break;
                }
                [sheet dismissAnimated:YES];
                [button setEnabled:YES];
                ((LITBaseKeyboardViewController *)queryViewController).optionsVisible = NO;
                [self.gMenu setHidden:NO];
            }];
            
            [self.gMenu setHidden:YES];
            [sheet showInView:self.view animated:YES];
            
            return nil;
        }];
        
        // Any object not a keyboard (no preview in the title)
    } else {
        
        // First of all we need to get the user information, just in case
        // it has not been obtained yet in the app, preventing crashes
        // while creating the sheet's title
        [[PFUser query] getObjectInBackgroundWithId:[[object valueForKey:@"user"] valueForKey:@"objectId"] block:^(PFObject * _Nullable user, NSError * _Nullable error) {
            
            [[self objectIsFavorited:object] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
                
                JGActionSheetSection *titleSection;
                
                if(object.class == [LITLyric class]){
                    titleSection = [JGActionSheetSection sectionWithTitle:[NSString stringWithFormat:@"%@",object[@"text"]] message:[NSString stringWithFormat:@"by %@",user[@"username"]] buttonTitles:nil buttonStyle:JGActionSheetButtonStyleDefault];
                }
                else if(object.class == [LITSoundbite class] || object.class == [LITDub class]){
                    titleSection = [JGActionSheetSection sectionWithTitle:[NSString stringWithFormat:@"%@",object[@"caption"]] message:[NSString stringWithFormat:@"by %@",user[@"username"]] buttonTitles:nil buttonStyle:JGActionSheetButtonStyleDefault];
                }
                
                NSString *favTitle = [task.result boolValue] ? @"Remove from Favorites" : @"Add to Favorites";
                
                JGActionSheetSection *optionsSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"Send Report",@"Add to Keyboard",favTitle,@"Share Content"] buttonStyle:JGActionSheetButtonStyleDefault];
                
                JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"Cancel"] buttonStyle:JGActionSheetButtonStyleCancel];
                
                
                // LIT Style
                
                [titleSection.titleLabel setTextColor:[UIColor lit_coolGreyColor]];
                [titleSection.messageLabel setTextColor:[UIColor lit_coolGreyColor]];
                
                for(int i=0; i<[optionsSection.buttons count]; i++){
                    [LITActionSheet setButtonStyle:JGActionSheetButtonStyleDefault forButton:[optionsSection.buttons objectAtIndex:i]];
                }
                for(int i=0; i<[cancelSection.buttons count]; i++){
                    [LITActionSheet setButtonStyle:JGActionSheetButtonStyleCancel forButton:[cancelSection.buttons objectAtIndex:i]];
                }
                
                // --.
                
                
                NSArray *sections = @[titleSection, optionsSection, cancelSection];
                
                LITActionSheet *sheet = [LITActionSheet actionSheetWithSections:sections];
                
                [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
                    
                    // Action calls
                    NSUInteger section = indexPath.section;
                    NSUInteger item = indexPath.item;
                    
                    switch (section) {
                        case 0: // Title
                            break;
                            
                        case 1: // Options
                            if(item == 0){ // Report
                                
                                if([queryViewController class] == [LITMainFeedViewController class]){
                                    [[Mixpanel sharedInstance] track:kMixpanelAction_report_3dots_CFeed properties:nil];
                                }
                                else {
                                    if(object.class == [LITLyric class]){
                                        [[Mixpanel sharedInstance] track:kMixpanelAction_report_3dots_Lyrics properties:nil];
                                    }
                                    else if(object.class == [LITSoundbite class]){
                                        [[Mixpanel sharedInstance] track:kMixpanelAction_report_3dots_Soundbites properties:nil];
                                    }
                                    else if(object.class == [LITDub class]){
                                        [[Mixpanel sharedInstance] track:kMixpanelAction_report_3dots_Dubs properties:nil];
                                    }
                                }
                                
                                [self sendReportForObject:object fromViewController:queryViewController];
                            }
                            else if(item == 1){ // Add to Keyboard
                                
                                if([queryViewController class] == [LITMainFeedViewController class]){
                                    [[Mixpanel sharedInstance] track:kMixpanelAction_addToKey_3dots_CFeed properties:nil];
                                }
                                else {
                                    if(object.class == [LITLyric class]){
                                        [[Mixpanel sharedInstance] track:kMixpanelAction_addToKey_3dots_Lyrics properties:nil];
                                    }
                                    else if(object.class == [LITSoundbite class]){
                                        [[Mixpanel sharedInstance] track:kMixpanelAction_addToKey_3dots_Soundbites properties:nil];
                                    }
                                    else if(object.class == [LITDub class]){
                                        [[Mixpanel sharedInstance] track:kMixpanelAction_addToKey_3dots_Dubs properties:nil];
                                    }
                                }
                                
                                [self presentAddToKeyboardControllerForObject:object inQueryViewController:queryViewController];
                            }
                            else if(item == 2){ // Favs
                                
                                if([queryViewController class] == [LITMainFeedViewController class]){
                                    if([task.result boolValue]){
                                        [[Mixpanel sharedInstance] track:kMixpanelAction_removeFav_3dots_CFeed properties:nil];
                                    }
                                    else{
                                        [[Mixpanel sharedInstance] track:kMixpanelAction_addToFavs_3dots_CFeed properties:nil];
                                    }
                                }
                                else {
                                    if(object.class == [LITLyric class]){
                                        if([task.result boolValue]){
                                            [[Mixpanel sharedInstance] track:kMixpanelAction_removeFav_3dots_Lyrics properties:nil];
                                        }
                                        else{
                                            [[Mixpanel sharedInstance] track:kMixpanelAction_addToFavs_3dots_Lyrics properties:nil];
                                        }
                                    }
                                    else if(object.class == [LITSoundbite class]){
                                        if([task.result boolValue]){
                                            [[Mixpanel sharedInstance] track:kMixpanelAction_removeFav_3dots_Soundbites properties:nil];
                                        }
                                        else{
                                            [[Mixpanel sharedInstance] track:kMixpanelAction_addToFavs_3dots_Soundbites properties:nil];
                                        }
                                    }
                                    else if(object.class == [LITDub class]){
                                        if([task.result boolValue]){
                                            [[Mixpanel sharedInstance] track:kMixpanelAction_removeFav_3dots_Dubs properties:nil];
                                        }
                                        else{
                                            [[Mixpanel sharedInstance] track:kMixpanelAction_addToFavs_3dots_Dubs properties:nil];
                                        }
                                    }
                                }
                                
                                [self objectFavorite:object addOrRemove:![task.result boolValue] fromQueryViewController:queryViewController];
                            }
                            else if(item == 3){ // Share
                                
                                if([queryViewController class] == [LITMainFeedViewController class]){
                                    [[Mixpanel sharedInstance] track:kMixpanelAction_shareCont_3dots_CFeed properties:nil];
                                }
                                else {
                                    if(object.class == [LITLyric class]){
                                        [[Mixpanel sharedInstance] track:kMixpanelAction_share_3dots_Lyrics properties:nil];
                                    }
                                    else if(object.class == [LITSoundbite class]){
                                        [[Mixpanel sharedInstance] track:kMixpanelAction_share_3dots_Soundbites properties:nil];
                                    }
                                    else if(object.class == [LITDub class]){
                                        [[Mixpanel sharedInstance] track:kMixpanelAction_share_3dots_Dubs properties:nil];
                                    }
                                }
                                
                                [self shareObject:object fromQueryViewController:queryViewController];
                            }
                            break;
                        case 2: // Cancel
                            
                            if([queryViewController class] == [LITMainFeedViewController class]){
                                [[Mixpanel sharedInstance] track:kMixpanelAction_cancel_3dots_CFeed properties:nil];
                            }
                            else {
                                if(object.class == [LITLyric class]){
                                    [[Mixpanel sharedInstance] track:kMixpanelAction_cancel_3dots_Lyrics properties:nil];
                                }
                                else if(object.class == [LITSoundbite class]){
                                    [[Mixpanel sharedInstance] track:kMixpanelAction_cancel_3dots_Soundbites properties:nil];
                                }
                                else if(object.class == [LITDub class]){
                                    [[Mixpanel sharedInstance] track:kMixpanelAction_cancel_3dots_Dubs properties:nil];
                                }
                            }
                            
                            break;
                        default:
                            break;
                    }
                    [sheet dismissAnimated:YES];
                    [button setEnabled:YES];
                    ((LITBaseKeyboardViewController *)queryViewController).optionsVisible = NO;
                    [self.gMenu setHidden:NO];
                }];
                
                [self.gMenu setHidden:YES];
                
                // Show in one or other way depending on where it's called
                if ([queryViewController isKindOfClass:[LITContentQueryTableViewController class]])
                {
                    [sheet showInView:[queryViewController.view superview] animated:YES];
                } else {
                    [sheet showInView:self.view animated:YES];
                }
                
                return nil;
            }];
            
            
        }];
        
    }
}

#pragma mark - LITSearchPresentationDelegate

- (void)searchHelper:(LITTableSearchHelper *)searchHelper
didRequestPresentingSearchController:(UISearchController *)searchController;
{
    _savedView = self.navigationItem.titleView;
    
    id <LITTableSearchHosting> controller = searchHelper.host;

    if([controller class] == [LITKeyboardFeedViewController class]){
        [[Mixpanel sharedInstance] track:kMixpanelAction_keyboardFeed_Search properties:nil];
    }
    else if([controller class] == [LITMainFeedViewController class]){
        [[Mixpanel sharedInstance] track:kMixpanelAction_contentFeed_Search properties:nil];
    }
    
    self.savedHeightConstraint = self.controlHolderViewHeightConstraint.constant;
    self.controlHolderViewHeightConstraint.constant = 0;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
        [searchHelper.searchController.searchBar setAlpha:0.0f];
        [self.navigationItem.titleView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        controller.headerView = nil;
        [controller.scrollView layoutIfNeeded];
        self.navigationItem.titleView = nil;
        searchHelper.searchController.searchBar.layer.borderColor = [UIColor clearColor].CGColor;
        [self.navigationController.navigationBar addSubview:searchHelper.searchController.searchBar];
        [searchHelper.searchController.searchBar setShowsCancelButton:YES animated:YES];
        [UIView animateWithDuration:0.3 animations:^{
            [self.navigationController.navigationBar layoutIfNeeded];
            [self.view layoutIfNeeded];
            [searchHelper.searchController.searchBar setAlpha:1.0f];
            [self.navigationItem.leftBarButtonItem.customView setAlpha:0.0f];
            [self.navigationItem.rightBarButtonItem.customView setAlpha:0.0f];
            [self.gMenu setAlpha:0.0f];
            [self resetSearchBarForSearchHelper:searchHelper];
        } completion:^(BOOL finished) {
            [searchHelper.searchController.searchBar becomeFirstResponder];
            [self.navigationItem.leftBarButtonItem.customView setHidden:YES];
            [self.navigationItem.rightBarButtonItem.customView setHidden:YES];
            [self.gMenu setHidden:YES];
        }];
    }];
}

- (void)searchHelper:(LITTableSearchHelper *)searchHelper
willDismissSearchController:(UISearchController *)searchController;
{
    id <LITTableSearchHosting> controller = searchHelper.host;
    
    [self.navigationItem.leftBarButtonItem.customView setHidden:NO];
    [self.navigationItem.rightBarButtonItem.customView setHidden:NO];
    self.controlHolderViewHeightConstraint.constant = self.savedHeightConstraint;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.titleView = _savedView;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
        [self.navigationItem.leftBarButtonItem.customView setAlpha:1.0f];
        [self.navigationItem.rightBarButtonItem.customView setAlpha:1.0f];
        [self.gMenu setAlpha:1.0f];
        [self.navigationItem.titleView setAlpha:1.0f];
        //[self resetSearchBarForSearchHelper:searchHelper];
    } completion:^(BOOL finished) {
        [self.gMenu setHidden:NO];
        [self.navigationItem setTitleView:_savedView];
        [searchHelper.searchController.searchBar setAlpha:1.0f];
        [controller setHeaderView:searchHelper.searchController.searchBar];
        [controller.scrollView layoutIfNeeded];
        [self resetSearchBarForSearchHelper:searchHelper];
    }];
}

- (void)resetSearchBarForSearchHelper:(LITTableSearchHelper *)searchHelper
{
    searchHelper.searchController.view.frame = CGRectMake(searchHelper.searchController.view.frame.origin.x+10,
                                                          searchHelper.searchController.view.frame.origin.y,
                                                          searchHelper.searchController.view.frame.size.width-10-5,
                                                          searchHelper.searchController.view.frame.size.height);
    searchHelper.searchController.searchBar.frame = CGRectMake(searchHelper.searchController.searchBar.frame.origin.x+10,
                                                               searchHelper.searchController.searchBar.frame.origin.y,
                                                               searchHelper.searchController.searchBar.frame.size.width-10-5,
                                                               searchHelper.searchController.searchBar.frame.size.height);
}

#pragma mark - Object Actions

- (void)sendReportForObject:(PFObject *)object fromViewController:(UIViewController *)viewController{
    
    NSLog(@"Sending report");
    
    LITReportViewController *reportVC = [self.storyboard   instantiateViewControllerWithIdentifier:@"reportVC"];
    [reportVC assignObject:object];
    
    if ([viewController isKindOfClass:[LITContentQueryTableViewController class]]) {
        [viewController presentViewController:reportVC animated:YES completion:nil];
    } else {
        [self presentViewController:reportVC animated:YES completion:nil];
    }
}

- (void)shareObject:(PFObject *)object fromQueryViewController:(UIViewController *)queryViewController {
    
    if([object class] == [LITKeyboard class]){
        
        /*
         NSString *message = [NSString stringWithFormat:@"I'm using the keyboard \"%@\" on Lit!",((LITKeyboard *)object).displayName];
         [LITShareHelper shareMessage:message inView:self.view];
         */
        
        // Save the object "use" reference
        PFObject *objectUse = [PFObject objectWithClassName:kKeyboardUseClassName];
        objectUse[kKeyboardUseKeyboardKey] = object;
        objectUse[kKeyboardUseUserKey] = [PFUser currentUser];
        [objectUse saveInBackground];
        
        NSString *message = [NSString stringWithFormat:@"I'm using the \"%@\" keyboard on LIT. Download it for free on the App Store!",((LITKeyboard *)object).displayName];
        [[UIPasteboard generalPasteboard] setString:message];
        [self forwardShareToAppWithText:message fromQueryViewController:queryViewController];
    }
    else if([object class] == [LITLyric class]){
        
        self.hud = [LITProgressHud createHudWithMessage:[NSString stringWithFormat:@"Preparing\nlyric"]];
        [self.hud showInView:self.view];
        
        // Save the object "use" reference
        PFObject *objectUse = [PFObject objectWithClassName:kKeyboardUseClassName];
        objectUse[kKeyboardUseKeyboardKey] = object;
        objectUse[kKeyboardUseUserKey] = [PFUser currentUser];
        [objectUse saveInBackground];
        
        NSString *lyricText = object[@"text"];
        [[UIPasteboard generalPasteboard] setString:lyricText];
        [self forwardShareToAppWithText:lyricText fromQueryViewController:queryViewController];
    }
    else if([object class] == [LITSoundbite class] || [object class] == [LITDub class]){
        
        if([object class] == [LITSoundbite class]){
            self.hud = [LITProgressHud createHudWithMessage:[NSString stringWithFormat:@"Preparing\nsoundbite"]];
            
            // Save the object "use" reference
            PFObject *objectUse = [PFObject objectWithClassName:kSoundbiteUseClassName];
            objectUse[kSoundbiteUseSoundbiteKey] = object;
            objectUse[kSoundbiteUseUserKey] = [PFUser currentUser];
            [objectUse saveInBackground];
        }
        else{
            self.hud = [LITProgressHud createHudWithMessage:[NSString stringWithFormat:@"Preparing\ndub"]];
            
            // Save the object "use" reference
            PFObject *objectUse = [PFObject objectWithClassName:kDubUseClassName];
            objectUse[kDubUseDubKey] = object;
            objectUse[kDubUseUserKey] = [PFUser currentUser];
            [objectUse saveInBackground];
        }
        
        if ([queryViewController isKindOfClass:[LITContentQueryTableViewController class]])
        {
            [self.hud showInView:[queryViewController.view superview]];
        } else {
            [self.hud showInView:self.view];
        }
        
        
        PFFile *video = object[@"video"];
        NSURL *videoURL = [NSURL URLWithString:video.url];
        
        
        if([object class] == [LITDub class]){
            [self shareVideoFromVideoFileURL:videoURL usingWaterMarkImage:[UIImage imageNamed:@"watermark"] andViewController:queryViewController];
        }
        else {
            NSURLRequest *request = [NSURLRequest requestWithURL:videoURL];
            
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                
                if(connectionError){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.hud dismiss];
                        
                        JGProgressHUD * hud = [LITProgressHud createHudWithMessage:@""];
                        [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError withMessage:@"Error sharing"];
                        
                        if ([queryViewController isKindOfClass:[LITContentQueryTableViewController class]])
                        {
                            [hud showInView:[queryViewController.view superview]];
                        } else {
                            [hud showInView:self.view];
                        }
                        
                        [hud dismissAfterDelay:1.5f];
                        return;
                    });
                }
                else{
                    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
                    NSURL *tempURL = [documentsURL URLByAppendingPathComponent:[videoURL lastPathComponent]];
                    
                    [data writeToURL:tempURL atomically:YES];
                    //UISaveVideoAtPathToSavedPhotosAlbum(tempURL.path, nil, NULL, NULL);
                    
                    [self forwardShareToAppWithURL:tempURL fromQueryViewController:queryViewController];
                }
            }];
        }
    }
}

- (void)forwardShareToAppWithURL:(NSURL *)url fromQueryViewController:(UIViewController *)queryViewController
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
                        
                        if ([queryViewController isKindOfClass:[LITContentQueryTableViewController class]])
                        {
                            [hud showInView:[queryViewController.view superview] animated:YES];
                        } else {
                            [hud showInView:self.view animated:YES];
                        }
                        
                        [hud dismissAfterDelay:1.5f];
                    });
                }];
            }
        };
    }

    [self.hud dismiss];
    
    // Show the social picker
    if ([queryViewController isKindOfClass:[LITContentQueryTableViewController class]])
    {
        [queryViewController presentViewController:activityViewController animated:YES completion:nil];
    } else {
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    
    return;
}

- (void)forwardShareToAppWithText:(NSString *)text fromQueryViewController:(UIViewController *)queryViewController
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
                        
                        if ([queryViewController isKindOfClass:[LITContentQueryTableViewController class]])
                        {
                            [hud showInView:[queryViewController.view superview] animated:YES];
                        } else {
                            [hud showInView:self.view animated:YES];
                        }
                        
                        [hud dismissAfterDelay:1.5f];
                    });
                }];
            }
        };
    }
    
    [self.hud dismiss];
    
    // Show the social picker
    if ([queryViewController isKindOfClass:[LITContentQueryTableViewController class]])
    {
        [queryViewController presentViewController:activityViewController animated:YES completion:nil];
    } else {
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    
    return;
}


#pragma mark - Un/Favorite Contents

- (BFTask *)objectIsFavorited:(PFObject *)object
{
    return [[[[PFUser currentUser] objectForKey:kUserFavKeyboardKey] fetchFromLocalDatastoreInBackground] continueWithBlock:^id(BFTask *task) {
        PFObject *favKeyboard = task.result;
        return [BFTask taskWithResult:@([[favKeyboard objectForKey:kFavKeyboardContentsKey] containsObject:object])];
    }];
}


- (BFTask *)objectFavorite:(PFObject *)object addOrRemove:(BOOL)addOrRemove fromQueryViewController:(UIViewController *)queryViewController
{
    JGProgressHUD *hud = [LITProgressHud createHudWithMessage:@""];
    
    return [[[[[[PFUser currentUser] objectForKey:kUserFavKeyboardKey] fetchFromLocalDatastoreInBackground]continueWithSuccessBlock:^id(BFTask *task) {
        PFObject *keyboardObject = task.result;
        NSMutableArray *array = [NSMutableArray
                                 arrayWithArray:[keyboardObject objectForKey:kFavKeyboardContentsKey]];
        if (addOrRemove) {
            [array addObject:object];
        } else {
            [array removeObject:object];
        }
        [keyboardObject setObject:array forKey:kFavKeyboardContentsKey];
        return [[keyboardObject saveEventually] continueWithBlock:^id(BFTask *task) {
            if (task.error) {
                return task;
            } else {
                if (addOrRemove) {
                    [object setValue:[NSString stringWithFormat:@"%ld",(long)[[object valueForKey:kLITObjectLikesKey] integerValue]+1] forKey:kLITObjectLikesKey];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:@"Favorited"];
                    });

                } else {
                    if([[object valueForKey:kLITObjectLikesKey] integerValue] <= 0){
                        [object setValue:[NSString stringWithFormat:@"0"] forKey:kLITObjectLikesKey];
                    }
                    else{
                        [object setValue:[NSString stringWithFormat:@"%ld",(long)[[object valueForKey:kLITObjectLikesKey] integerValue]-1] forKey:kLITObjectLikesKey];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:@"Removed"];
                    });
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([queryViewController isKindOfClass:[LITContentQueryTableViewController class]])
                    {
                        [hud showInView:[queryViewController.view superview] animated:YES];
                    }
                    else if([queryViewController isKindOfClass:[LITProfileFavoritesViewController class]])
                    {
                        [hud showInView:queryViewController.view animated:YES];
                    }
                    else {
                        [hud showInView:self.view animated:YES];
                    }
                    [hud dismissAfterDelay:1.5f];
                });
                return [object saveInBackground];
            }
        }];
    }] continueWithSuccessBlock:^id(BFTask *task) {
        if (addOrRemove) {
            if ([object isKindOfClass:[LITSoundbite class]] ||
                [object isKindOfClass:[LITDub class]]) {
                BFTask *addToCache = [((id)object) addToSharedCache];
                return [BFTask taskForCompletionOfAllTasks:@[addToCache, [object pinInBackground]]];
            } else
                return [object pinInBackground];
        } else {
            if ([object isKindOfClass:[LITSoundbite class]] ||
                [object isKindOfClass:[LITDub class]]) {
                NSError *error;
                [((id)object) removeFromSharedCacheWithError:&error];
                if (error) {
                    NSLog(@"Error removing item from cache: %@", error.localizedDescription);
                    return [BFTask taskWithError:error];
                }
                return [object unpinInBackground];
            } else
                return [object unpinInBackground];
        }
    }] continueWithBlock:^id(BFTask *task) {
        if(task.error){
            dispatch_async(dispatch_get_main_queue(), ^{
                [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError withMessage:@"Error"];
                
                if ([queryViewController isKindOfClass:[LITContentQueryTableViewController class]])
                {
                    [hud showInView:[queryViewController.view superview] animated:YES];
                }
                else if([queryViewController isKindOfClass:[LITProfileFavoritesViewController class]])
                {
                    [hud showInView:queryViewController.view animated:YES];
                }
                else {
                    [hud showInView:self.view animated:YES];
                }
                [hud dismissAfterDelay:2.0f];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(addOrRemove){
                    // Save the object "like" reference
                    if([object isKindOfClass:[LITSoundbite class]]){
                        PFObject *objectLike = [PFObject objectWithClassName:kSoundbiteLikeClassName];
                        objectLike[kSoundbiteLikeSoundbiteKey] = object;
                        objectLike[kSoundbiteLikeUserKey] = [PFUser currentUser];
                        [objectLike saveInBackground];
                    }
                    else if([object isKindOfClass:[LITDub class]]){
                        PFObject *objectLike = [PFObject objectWithClassName:kDubLikeClassName];
                        objectLike[kDubLikeDubKey] = object;
                        objectLike[kDubLikeUserKey] = [PFUser currentUser];
                        [objectLike saveInBackground];
                    }
                    else if([object isKindOfClass:[LITLyric class]]){
                        PFObject *objectLike = [PFObject objectWithClassName:kLyricLikeClassName];
                        objectLike[kLyricLikeLyricKey] = object;
                        objectLike[kLyricLikeUserKey] = [PFUser currentUser];
                        [objectLike saveInBackground];
                    }
                }
            });
        }
        
        return [BFTask taskWithResult:@(addOrRemove)];
    }];
}

#pragma mark Un/Favorite Keyboard

- (BFTask *)keyboardIsFavorited:(PFObject *)keyboard
{
    return [[[[[PFQuery queryWithClassName:kKeyboardLikesClassName]
               whereKey:kKeyboardLikesUserKey equalTo:[PFUser currentUser]]
               whereKey:kKeyboardLikesKeyboardKey equalTo:keyboard]
               findObjectsInBackground]
    continueWithBlock:^id(BFTask *task) {
        if([(NSArray *)task.result count] != 0){
            return [BFTask taskWithResult:@(YES)];
        }
        else{
            return [BFTask taskWithResult:@(NO)];
        }
    }];
}


- (BFTask *)keyboardFavorite:(PFObject *)object addOrRemove:(BOOL)addOrRemove fromQueryViewController:(UIViewController *)queryViewController
{
    // New fav
    if(addOrRemove){
        
        [object setValue:[NSString stringWithFormat:@"%ld",(long)[[object valueForKey:kLITKeyboardLikesKey] integerValue]+1] forKey:kLITKeyboardLikesKey];
        [object saveInBackground];
        
        PFObject *kbFav = [PFObject objectWithClassName:kKeyboardLikesClassName];
        kbFav[kKeyboardLikesKeyboardKey] = object;
        kbFav[kKeyboardLikesUserKey] = [PFUser currentUser];
        return [[kbFav saveInBackground] continueWithBlock:^id(BFTask *task) {
            if (task.error) {
                return [BFTask taskWithError:task.error];
            } else {
                return [BFTask taskWithResult:@(addOrRemove)];
            }
        }];
    }
    // Remove fav
    else {
        
        [object setValue:[NSString stringWithFormat:@"%ld",(long)[[object valueForKey:kLITKeyboardLikesKey] integerValue]-1] forKey:kLITKeyboardLikesKey];
        [object saveInBackground];
        
        return [[[[[PFQuery queryWithClassName:kKeyboardLikesClassName]
                   whereKey:kKeyboardLikesUserKey equalTo:[PFUser currentUser]]
                  whereKey:kKeyboardLikesKeyboardKey equalTo:object]
                 findObjectsInBackground]
                continueWithBlock:^id(BFTask *task) {
                    if([(NSArray *)task.result count] != 0){
                        PFObject *keyboardLike = [(NSArray *)task.result objectAtIndex:0];
                        return [[keyboardLike deleteInBackground] continueWithBlock:^id(BFTask *task) {
                            if(task.error){
                                return [BFTask taskWithError:task.error];
                            }
                            else{
                                return [BFTask taskWithResult:@(addOrRemove)];
                            }
                        }];
                    }
                    else{
                        return [BFTask taskWithResult:@(NO)];
                    }
                }];
    }
}


#pragma mark Keyboard Manipulation

- (void)downloadKeyboard:(LITKeyboard *)targetKeyboard withViewController:(LITKeyboardFeedViewController *)viewController {
    
    [[LITKeyboardInstallerHelper installKeyboard:targetKeyboard fromViewController:viewController] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (!task.error) {
            JGProgressHUD *hud = [LITProgressHud createHudWithMessage:@"Installed"];
            [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:@"Installed"];
            [hud showInView:self.view animated:YES];
            if(hud != nil) [hud dismissAfterDelay:.8];
            [viewController.collectionView reloadData];
            //            [self configureButton:downloadButton withKeyboardStatus:LITKeyboardStatusInstalled];
        } else {
            JGProgressHUD *hud = [LITProgressHud createHudWithMessage:@"Error"];
            if (task.error.code == 20) {
                [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError
                                     withMessage:task.error.localizedDescription];
            } else {
                [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError
                                     withMessage:@"Install error"];
            }
            
            //            downloadButton.state = kPKDownloadButtonState_StartDownload;
            [hud showInView:self.view animated:YES];
            if(hud != nil) [hud dismissAfterDelay:.8];
        }
        return nil;
    }];
}

- (void)removeKeyboard:(LITKeyboard *)targetKeyboard withViewController:(LITKeyboardFeedViewController *)viewController {
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:targetKeyboard.displayName
                                                                              message:@"Are you sure you want to uninstall the keyboard?"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive     handler:^(UIAlertAction *action) {
        //        downloadButton.state = kPKDownloadButtonState_StartDownload;
        [[LITKeyboardInstallerHelper removeKeyboard:targetKeyboard] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
            if (!task.error) {
                JGProgressHUD *hud = [LITProgressHud createHudWithMessage:@""];
                [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:@"Uninstalled"];
                [hud showInView:self.view animated:YES];
                if(hud != nil) [hud dismissAfterDelay:.8];
                [viewController.collectionView reloadData];
                //                [self configureButton:downloadButton withKeyboardStatus:LITKeyboardStatusUninstalled];
            } else {
                JGProgressHUD *hud = [LITProgressHud createHudWithMessage:@"Error"];
                [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError
                                     withMessage:@"Uninstall error"];
                //                [self configureButton:downloadButton withKeyboardStatus:LITKeyboardStatusInstalled];
                [hud showInView:self.view animated:YES];
                if(hud != nil) [hud dismissAfterDelay:.8];
            }
            return nil;
        }];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - LITAddToKeyboardViewControllerDelegate
- (void)keyboardsController:(LITAddToKeyboardViewController *)controller didSelectKeyboard:(LITKeyboard *)keyboard forObject:(PFObject *)object showCongrats:(BOOL)show inViewController:(UIViewController *)viewController
{
    NSLog(@"Selected keyboard");
    [self saveKeyboardInBackground:keyboard withObject:object andSaveBlock:^(BOOL succeeded, NSError * __nullable error) {
        
        [[LITKeyboardInstallerHelper installKeyboard:keyboard fromViewController:controller] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
            if (!task.error) {
                NSLog(@"Keyboard installed successfully");
            }
            return nil;
        }];
    }];
    if (show) {
        LITCongratsKeyboardViewController *congratsVC = [self.storyboard   instantiateViewControllerWithIdentifier:@"congratsVC"];
        [congratsVC assignKeyboard:keyboard];
        [congratsVC prepareControls];
        [viewController.navigationController presentViewController:congratsVC animated:YES completion:nil];
    }
    else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            JGProgressHUD *hud = [LITProgressHud createHudWithMessage:@""];
            [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:[NSString stringWithFormat:@"Keyboard\nUpdated"]];
            if ([viewController isKindOfClass:[LITContentQueryTableViewController class]])
            {
                [hud showInView:[viewController.view superview]];
                [hud dismissAfterDelay:2];
            } else {
                [hud showInView:viewController.view];
                [hud dismissAfterDelay:1.5];
            }
        });
    }
    [viewController.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Object Saving
- (void)saveKeyboardInBackground:(LITKeyboard *)keyboard withObject:(PFObject *)object andSaveBlock:(PFBooleanResultBlock)saveBlock
{
    // Save the keyboard with the object
    [keyboard addObject:object forKey:kLITKeyboardContentsKey];
    [keyboard saveInBackgroundWithBlock:saveBlock];
    
    // Save the object "download" reference
    if([object isKindOfClass:[LITSoundbite class]]){
        PFObject *objectDownload = [PFObject objectWithClassName:kSoundbiteDownloadClassName];
        objectDownload[kSoundbiteDownloadSoundbiteKey] = object;
        objectDownload[kSoundbiteDownloadUserKey] = [PFUser currentUser];
        [objectDownload saveInBackground];
    }
    else if([object isKindOfClass:[LITDub class]]){
        PFObject *objectDownload = [PFObject objectWithClassName:kDubDownloadClassName];
        objectDownload[kDubDownloadDubKey] = object;
        objectDownload[kDubDownloadUserKey] = [PFUser currentUser];
        [objectDownload saveInBackground];
    }
    else if([object isKindOfClass:[LITLyric class]]){
        PFObject *objectDownload = [PFObject objectWithClassName:kLyricDownloadClassName];
        objectDownload[kLyricDownloadLyricKey] = object;
        objectDownload[kLyricDownloadUserKey] = [PFUser currentUser];
        [objectDownload saveInBackground];
    }
}


#pragma mark - UINavigationControllerDelegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPush &&
        ([toVC isKindOfClass:[LITSettingsViewController class]] ||
         [toVC isKindOfClass:[LITProfileViewController class]])) {
            self.animator.reverse = NO;
            if ([toVC isKindOfClass:[LITSettingsViewController class]]) {
                self.animator.direction = LITCustomPushAnimatorDirectionLeft;
            } else if ([toVC isKindOfClass:[LITProfileViewController class]]) {
                self.animator.direction = LITCustomPushAnimatorDirectionRight;
            }
            return self.animator;
        } else if (operation == UINavigationControllerOperationPop &&
                   [toVC isKindOfClass:[self class]]) {
            self.animator.reverse = YES;
            [[self navigationController] setNavigationBarHidden:NO];
            if ([fromVC isKindOfClass:[LITSettingsViewController class]]) {
                self.animator.direction = LITCustomPushAnimatorDirectionLeft;
            } else if ([fromVC isKindOfClass:[LITProfileViewController class]]) {
                self.animator.direction = LITCustomPushAnimatorDirectionRight;
            }
            return self.animator;
        } else {
            return nil;
        }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController isKindOfClass:[LITProfileViewController class]] ||
        [viewController isKindOfClass:[LITSettingsViewController class]]) {
        [viewController.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]];
    }
}


#pragma mark - Custom Push

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController*)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController
{
    return self.interactionController;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    CGPoint location;
    
    location = [panGestureRecognizer locationInView:self.navigationController.view];
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.interactionController = [[UIPercentDrivenInteractiveTransition alloc] init];
        if ([[self.navigationController topViewController]
             isKindOfClass:[LITSettingsViewController class]] &&
            panGestureRecognizer.view == [self.navigationController topViewController].view &&
            location.x > CGRectGetMidX(panGestureRecognizer.view.frame)) {
            [self.navigationController popViewControllerAnimated:YES];
            
        } else if ([[self.navigationController topViewController]
                    isKindOfClass:[LITProfileViewController class]] &&
                   panGestureRecognizer.view == [self.navigationController topViewController].view &&
                   location.x < CGRectGetMidX(panGestureRecognizer.view.frame)) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if (location.x >  CGRectGetMidX(self.view.bounds)) {
            if(![[self.navigationController topViewController] isKindOfClass:[LITProfileViewController class]]){
                self.willPerformSegueToCurrentUserProfile = YES;
                [self performSegueWithIdentifier:kProfileSegueIdentifier sender:self];
            }
            else{
                [self.activeProfileViewController presentPointsView];
            }
        } else {
            if(![[self.navigationController topViewController] isKindOfClass:[LITSettingsViewController class]])
                [self performSegueWithIdentifier:kSettingsSegueIdentifier sender:self];
        }
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat d;
        if ((self.animator.direction == LITCustomPushAnimatorDirectionRight &&
             !self.animator.isReverse) ||
            (self.animator.direction == LITCustomPushAnimatorDirectionLeft &&
             self.animator.isReverse)) {
                d = 1 - (location.x / CGRectGetWidth(panGestureRecognizer.view.frame));
            } else {
                d = location.x / CGRectGetWidth(panGestureRecognizer.view.bounds);
            }
        [self.interactionController updateInteractiveTransition:d];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat d;
        if ((self.animator.direction == LITCustomPushAnimatorDirectionRight &&
             !self.animator.isReverse) ||
            (self.animator.direction == LITCustomPushAnimatorDirectionLeft &&
             self.animator.isReverse)) {
                d = 1 - (location.x / CGRectGetWidth(panGestureRecognizer.view.frame));
            } else {
                d = location.x / CGRectGetWidth(panGestureRecognizer.view.frame);
            }
        if (d > .20) {
            [self.interactionController finishInteractiveTransition];
        } else {
            [self.interactionController cancelInteractiveTransition];
        }
        self.interactionController = nil;
    }
}

- (LITCustomPushAnimator *)animator
{
    if (!_animator) {
        _animator = [[LITCustomPushAnimator alloc] init];
    }
    return _animator;
}



#pragma mark Video Stamp Share

- (void)shareVideoFromVideoFileURL:(NSURL *)url usingWaterMarkImage:(UIImage *)watermarkImage andViewController:(UIViewController *)viewController
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
                        
                        [self forwardShareToAppWithURL:assetURL fromQueryViewController:viewController];
                    }];
                }
            }
        });
    }];
}

- (void)reloadUserInstalledKeyboards:(LITProfileViewController *)profileViewController
{
    PFQuery *queryForInstallations = [[[PFQuery
                                        queryWithClassName:kKeyboardInstallationsClassName]
                                       whereKey:kKeyboardInstallationsUserKey
                                       equalTo:[PFUser currentUser]] fromLocalDatastore];
    [[queryForInstallations findObjectsInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
        NSMutableArray *installedKeyboardsRaw = [NSMutableArray arrayWithArray:[task.result[0] objectForKey:@"keyboards"]];
        [installedKeyboardsRaw removeObjectAtIndex:0];
        self.installedKeyboards = [NSArray arrayWithArray:[[installedKeyboardsRaw reverseObjectEnumerator] allObjects]];
        [profileViewController reloadKeyboards:self.installedKeyboards];
        return nil;
    }];
}



#pragma
@end
