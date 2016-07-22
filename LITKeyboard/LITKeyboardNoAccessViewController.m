//
//  LITKeyboardNoAccessViewController.m
//  lit-ios
//
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import "LITKeyboardNoAccessViewController.h"
#import "LITTheme.h"
#import "UIView+GradientBackground.h"
#import "UIView+BlurEffect.h"

static CGFloat const kTitleViewHeight = 40.0f;

static NSUInteger const kFireButtonHeight = 46;
static NSUInteger const kFireButtonWidth = 38;

static NSUInteger const kAppButtonHeight = 38;
static NSUInteger const kAppButtonWidth = 148;

@interface LITKeyboardNoAccessViewController ()

@property (nonatomic) NSLayoutConstraint *noAccessLabelOneConstraint;
@property (nonatomic) NSLayoutConstraint *noAccessLabelTwoConstraint;
@property (nonatomic) NSLayoutConstraint *noAccessButtonXConstraint;
@property (nonatomic) NSLayoutConstraint *noAccessButtonYConstraint;
@property (nonatomic) NSLayoutConstraint *noAccessButtonTopConstraint;
@property (nonatomic) NSLayoutConstraint *noAccessAppButtonXConstraint;
@property (nonatomic) NSLayoutConstraint *noAccessAppButtonBottomConstraint;

@property (nonatomic) CGFloat topMargin;

@end

@implementation LITKeyboardNoAccessViewController

- (id)init {
    self = [super init];
    if(self) {
        self.noAccessAppButtonXConstraint = nil;
        self.noAccessAppButtonBottomConstraint = nil;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.lineOneLabel setNeedsDisplay];
    [self.lineTwoLabel setNeedsDisplay];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.lineOneLabel setNeedsDisplay];
    [self.lineTwoLabel setNeedsDisplay];
}

- (void)setupControllerWithHeight:(CGFloat)height andAppButtonVisible:(BOOL)appButtonVisible
{
    UIView *noAccessView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, height)];
    
    self.topMargin = 20;
    
    self.view = noAccessView;
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.parentController.view setupGradientBackgroundFromPoint:CGPointMake(0.0f, 0.0f)
                               andStartingColor:[UIColor lit_kbNoAccessBackgroundDark]
                                        toPoint:CGPointMake(0.0f, 1.0f)
                                  andFinalColor:[UIColor lit_kbNoAccessBackgroundLight]];
    
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    
    NSString * lineOneText = @"Keyboard setup incomplete";
    self.lineOneLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 20)];
    [self.lineOneLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    self.lineOneLabel.text = lineOneText;
    self.lineOneLabel.textColor = [UIColor whiteColor];
    self.lineOneLabel.textAlignment = NSTextAlignmentCenter;
    [self.lineOneLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSString * lineTwoText = @"Turn on Full Access in Settings";
    self.lineTwoLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 20)];
    [self.lineTwoLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    self.lineTwoLabel.text = lineTwoText;
    self.lineTwoLabel.textColor = [UIColor whiteColor];
    self.lineTwoLabel.textAlignment = NSTextAlignmentCenter;
    [self.lineTwoLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.fireButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fireButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.fireButton setBackgroundImage:[UIImage imageNamed:@"fireEmoji"] forState:UIControlStateNormal];
    [self.fireButton setFrame:CGRectMake(0, 0, kFireButtonWidth, kFireButtonHeight)];
    
    [self.fireButton addConstraint:[NSLayoutConstraint constraintWithItem:self.fireButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:kFireButtonWidth]];
    [self.fireButton addConstraint:[NSLayoutConstraint constraintWithItem:self.fireButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:kFireButtonHeight]];
    
    [self.fireButton addTarget:self action:@selector(fireButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if(appButtonVisible) {
        self.appButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.appButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.appButton setTitle:@"Open Lit App" forState:UIControlStateNormal];
        [self.appButton setTitleColor:[UIColor colorWithRed:190.0f/255.0f green:60.0f/255.0f blue:30.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [self.appButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18.0f]];
        [self.appButton setBackgroundColor:[UIColor whiteColor]];
        [self.appButton setContentEdgeInsets:UIEdgeInsetsMake(12.0f, 12.0f, 12.0f, 12.0f)];
        [self.appButton.layer setCornerRadius:6.0f];
        [self.appButton setFrame:CGRectMake(0, 0, kAppButtonWidth, kAppButtonHeight)];
        
        [self.appButton addConstraint:[NSLayoutConstraint constraintWithItem:self.appButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:kAppButtonWidth]];
        [self.appButton addConstraint:[NSLayoutConstraint constraintWithItem:self.appButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:kAppButtonHeight]];
        
        [self.appButton addTarget:self action:@selector(appButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.view addSubview:self.lineOneLabel];
    [self.view addSubview:self.lineTwoLabel];
    [self.view addSubview:self.fireButton];
    
    if(appButtonVisible)
        [self.view addSubview:self.appButton];

    if([self isKeyboardPortrait]){
        self.noAccessLabelOneConstraint = [NSLayoutConstraint
                                           constraintWithItem:self.lineOneLabel
                                           attribute:NSLayoutAttributeCenterX
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:self.view
                                           attribute:NSLayoutAttributeCenterX
                                           multiplier:1.0
                                           constant:0];
        
        self.noAccessLabelTwoConstraint = [NSLayoutConstraint
                                           constraintWithItem:self.lineTwoLabel
                                           attribute:NSLayoutAttributeCenterX
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:self.view
                                           attribute:NSLayoutAttributeCenterX
                                           multiplier:1.0
                                           constant:0];
        
        self.noAccessButtonXConstraint = [NSLayoutConstraint
                                          constraintWithItem:self.fireButton
                                          attribute:NSLayoutAttributeCenterX
                                          relatedBy:NSLayoutRelationEqual
                                          toItem:self.view
                                          attribute:NSLayoutAttributeCenterX
                                          multiplier:1.0
                                          constant:0];
        
        self.noAccessButtonYConstraint = [NSLayoutConstraint
                                          constraintWithItem:self.fireButton
                                          attribute:NSLayoutAttributeCenterY
                                          relatedBy:NSLayoutRelationEqual
                                          toItem:self.view
                                          attribute:NSLayoutAttributeCenterY
                                          multiplier:1.0
                                          constant:0.0-44/2]; // Half the title height
        
        if(appButtonVisible) {
            self.noAccessAppButtonXConstraint = [NSLayoutConstraint
                                                 constraintWithItem:self.appButton
                                                 attribute:NSLayoutAttributeCenterX
                                                 relatedBy:NSLayoutRelationEqual
                                                 toItem:self.view
                                                 attribute:NSLayoutAttributeCenterX
                                                 multiplier:1.0
                                                 constant:0];
            
            self.noAccessAppButtonBottomConstraint = [NSLayoutConstraint
                                                      constraintWithItem:self.appButton
                                                      attribute:NSLayoutAttributeBottom
                                                      relatedBy:NSLayoutRelationEqual
                                                      toItem:self.view
                                                      attribute:NSLayoutAttributeBottom
                                                      multiplier:1.0
                                                      constant:-44-8]; // 44 = H:titleView
        }
    }
    else {
        self.noAccessLabelOneConstraint = [NSLayoutConstraint
                                           constraintWithItem:self.lineOneLabel
                                           attribute:NSLayoutAttributeCenterX
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:self.view
                                           attribute:NSLayoutAttributeCenterX
                                           multiplier:1.0
                                           constant:-40];
        
        self.noAccessLabelTwoConstraint = [NSLayoutConstraint
                                           constraintWithItem:self.lineTwoLabel
                                           attribute:NSLayoutAttributeCenterX
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:self.view
                                           attribute:NSLayoutAttributeCenterX
                                           multiplier:1.0
                                           constant:-40];
        
        self.noAccessButtonXConstraint = [NSLayoutConstraint
                                          constraintWithItem:self.fireButton
                                          attribute:NSLayoutAttributeCenterX
                                          relatedBy:NSLayoutRelationEqual
                                          toItem:self.view
                                          attribute:NSLayoutAttributeCenterX
                                          multiplier:1.0
                                          constant:120];
        
        self.noAccessButtonYConstraint = [NSLayoutConstraint
                                          constraintWithItem:self.fireButton
                                          attribute:NSLayoutAttributeCenterY
                                          relatedBy:NSLayoutRelationEqual
                                          toItem:self.view
                                          attribute:NSLayoutAttributeCenterY
                                          multiplier:1.0
                                          constant:0.0];
        
        if(appButtonVisible){
            self.noAccessAppButtonXConstraint = [NSLayoutConstraint
                                                 constraintWithItem:self.appButton
                                                 attribute:NSLayoutAttributeCenterX
                                                 relatedBy:NSLayoutRelationEqual
                                                 toItem:self.view
                                                 attribute:NSLayoutAttributeCenterX
                                                 multiplier:1.0
                                                 constant:0];
            
            self.noAccessAppButtonBottomConstraint = [NSLayoutConstraint
                                                      constraintWithItem:self.appButton
                                                      attribute:NSLayoutAttributeBottom
                                                      relatedBy:NSLayoutRelationEqual
                                                      toItem:self.view
                                                      attribute:NSLayoutAttributeBottom
                                                      multiplier:1.0
                                                      constant:-44-8];//40]; // Out of sight
        }
    }
    
    self.noAccessButtonTopConstraint = [NSLayoutConstraint
                                        constraintWithItem:self.fireButton
                                        attribute:NSLayoutAttributeTop
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                        attribute:NSLayoutAttributeTop
                                        multiplier:1.0
                                        constant:self.topMargin-6];
    
    
    if(appButtonVisible) {
        [self.view addConstraint:self.noAccessAppButtonXConstraint];
        [self.view addConstraint:self.noAccessAppButtonBottomConstraint];
    }
    
    
    [self.view addConstraint:self.noAccessButtonXConstraint];
    [self.view addConstraint:self.noAccessButtonYConstraint];
    [self.view addConstraint:self.noAccessButtonTopConstraint];
    
    if([self isKeyboardPortrait]){
        self.noAccessButtonTopConstraint.active = NO;
        self.noAccessButtonYConstraint.active = YES;
        [self.appButton setHidden:NO];
    }
    else{
        self.noAccessButtonTopConstraint.active = YES;
        self.noAccessButtonYConstraint.active = NO;
        [self.appButton setHidden:YES];
    }
    
    [self.view addConstraint:self.noAccessLabelOneConstraint];
    [self.view addConstraint:self.noAccessLabelTwoConstraint];
    
    // Space the labels
    [self.view addConstraint:[NSLayoutConstraint
                                                     constraintWithItem:self.lineOneLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                     attribute:NSLayoutAttributeTop
                                                     multiplier:1.0
                                                     constant:self.topMargin]];
    
    [self.view addConstraint:[NSLayoutConstraint
                                                     constraintWithItem:self.lineTwoLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                     toItem:self.lineOneLabel
                                                     attribute:NSLayoutAttributeTop
                                                     multiplier:1.0
                                                     constant:18]];

    [self.parentController addChildViewController:self];
    [self.parentController.view addSubview:self.view];
    [self didMoveToParentViewController:self.parentController];
    
    self.titleView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.titleView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.titleView addBlurEffectBehindOthers:YES];
    
    [self.view addSubview:self.titleView];
    
    UIView *view = self.parentController.view;
    UIView *accessView = self.view;
    UIView *titleView = self.titleView;
    UILabel *lineOneLabel = self.lineOneLabel;
    UILabel *lineTwoLabel = self.lineTwoLabel;
    
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view, accessView, titleView, lineOneLabel, lineTwoLabel);
    
    NSLayoutConstraint *titleViewConstraint = [NSLayoutConstraint
                                               constraintWithItem:titleView
                                               attribute:NSLayoutAttributeBottom
                                               relatedBy:NSLayoutRelationEqual
                                               toItem:view
                                               attribute:NSLayoutAttributeBottom
                                               multiplier:1.0
                                               constant:0.0];
    
    NSLayoutConstraint *titleViewHeightConstraint = [NSLayoutConstraint
                                                     constraintWithItem:titleView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                     toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                     multiplier:1.0
                                                     constant:kTitleViewHeight];
    
    NSArray *noAccessHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[accessView]|" options:0 metrics:nil views:bindings];
    NSArray *titleHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleView]|" options:0 metrics:nil views:bindings];
    NSArray *noAccessVConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[accessView]|" options:0 metrics:nil views:bindings];
    
    [self.parentController.view addConstraints:noAccessVConstraints];
    [self.parentController.view addConstraints:@[titleViewConstraint, titleViewHeightConstraint]];
    [self.parentController.view addConstraints:noAccessHConstraints];
    [self.parentController.view addConstraints:titleHConstraints];
    
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
    
    [self.titleView addSubview:self.deleteButton];
    
    [self.titleView addConstraint:[NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.titleView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self.titleView addConstraint:[NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.titleView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:12.5]];
    
    [self.nextKeyboardButton addConstraint:[NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20.0]];
    [self.nextKeyboardButton addConstraint:[NSLayoutConstraint constraintWithItem:self.nextKeyboardButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20.0]];
    
    [self.titleView addConstraint:[NSLayoutConstraint constraintWithItem:self.deleteButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.titleView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self.titleView addConstraint:[NSLayoutConstraint constraintWithItem:self.deleteButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.titleView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-12.5]];
    
    [self.deleteButton addConstraint:[NSLayoutConstraint constraintWithItem:self.deleteButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:17.0]];
    [self.deleteButton addConstraint:[NSLayoutConstraint constraintWithItem:self.deleteButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:23.0]];
}

- (void)setupNoFullAccessConstraints {
    
    if([self isKeyboardPortrait]){
        self.noAccessLabelOneConstraint.constant = 0;
        self.noAccessLabelTwoConstraint.constant = 0;
        self.noAccessButtonXConstraint.constant = 0;
        self.noAccessButtonTopConstraint.active = NO;
        self.noAccessButtonYConstraint.active = YES;

        [self.appButton setHidden:NO];
    }
    else {
        self.noAccessLabelOneConstraint.constant = -40;
        self.noAccessLabelTwoConstraint.constant = -40;
        self.noAccessButtonXConstraint.constant = 120;
        self.noAccessButtonYConstraint.active = NO;
        self.noAccessButtonTopConstraint.active = YES;

        [self.appButton setHidden:YES];
    }
}

- (BOOL) isKeyboardPortrait {
    if([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height){return YES;}
    else{return NO;}
}

- (void)fireButtonAction:(UIButton *)sender {
    [self.delegate didTapFireButton:self];
}

- (void)appButtonAction:(UIButton *)sender {
    [self.delegate didTapAppButton:self];
}

- (IBAction)deleteButtonAction:(id)sender {
    [self.delegate didTapDeleteButton:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
