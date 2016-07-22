//
//  InitialViewController.m
//  slit-ios
//
//  Created by ioshero on 06/07/2015.
//  Copyright (c) 2015 Slit Inc. All rights reserved.
//

#import "LITInitialViewController.h"
#import "UIView+GradientBackground.h"
#import "UIViewController+ProfileUpdater.h"
#import "LITTheme.h"
#import "AVUtils.h"
#import <Bolts/Bolts.h>
#import <Parse/PFSession.h>
#import <Parse/PFUser.h>
#import <Parse/PFInstallation.h>
#import <MMMaterialDesignSpinner/MMMaterialDesignSpinner.h>
#import <ABOnboarding/ABOnboardingViewController.h>
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"


static NSString *const kPresentMainSegueIdentifier  = @"PresentMainSegue";
static NSString *const kPresentLoginSegueIdentifier = @"LoginSegue";
static NSString *const kPresentTutorialSegueIdentifier = @"TutorialSegue";
static NSString *const kPresentNoInternetConnectionSegueIdentifier = @"NoInternetConnectionSegue";

static CGFloat const kSpinnerDefaultTopDistance     = 305.0f;


@interface LITInitialViewController ()

@property (strong, nonatomic) UIView *launchScreenView;
@property (strong, nonatomic) MMMaterialDesignSpinner *spinnerView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end


@implementation LITInitialViewController

- (void)viewDidLoad
{
    [self setTitleLogo];
    
    UIView *launchScreenView = [[[NSBundle mainBundle] loadNibNamed:@"LaunchScreen"
                                                              owner:self
                                                            options:nil] objectAtIndex:0];
    [launchScreenView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:launchScreenView];
    
    NSDictionary *bindings = NSDictionaryOfVariableBindings(launchScreenView);
    [self.view
     addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[launchScreenView]|"
                                                            options:0
                                                            metrics:nil
                                                              views:bindings]];
    [self.view
     addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[launchScreenView]|"
                                                            options:0
                                                            metrics:nil
                                                              views:bindings]];
    self.launchScreenView = launchScreenView;
    
    [self.navigationController setNavigationBarHidden:YES];
    
    // Initialize the progress view
    self.spinnerView = [[MMMaterialDesignSpinner alloc]
                        initWithFrame:CGRectMake(0, kSpinnerDefaultTopDistance, 40, 40)];
    
    [self.spinnerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    // Set the line width of the spinner
    self.spinnerView.lineWidth = 1.5f;
    // Set the tint color of the spinner
    self.spinnerView.tintColor = [UIColor whiteColor];
    
    // Add it as a subview
    [self.view addSubview:self.spinnerView];
    
    [self.spinnerView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.spinnerView
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1.0
                                     constant:40.0f]];
    [self.spinnerView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:self.spinnerView
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1.0
                                     constant:40.0f]];
    
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.spinnerView
                              attribute:NSLayoutAttributeTop
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeTop
                              multiplier:1.0
                              constant:kSpinnerDefaultTopDistance]];
    
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.spinnerView
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1.0
                              constant:0.0f]];
    
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    self.versionLabel.text = [NSString stringWithFormat:@"v %@",version];
    [self.versionLabel setHidden:YES];
    [[self.view superview] bringSubviewToFront:self.versionLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.spinnerView startAnimating];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[[PFSession getCurrentSessionInBackground] continueWithSuccessBlock:^id(BFTask *task) {
        if (task.result && !task.error) {
            PFSession *session = task.result;
            if ([session isKindOfClass:[PFSession class]] && session.sessionToken) {
                NSDictionary *authData = [[PFUser currentUser] valueForKey:@"authData"];
                [[self updateProfileDataWithAuthData:authData] continueWithBlock:^id(BFTask *task) {
                    if (task.error) {
                        NSLog(@"Error updating user profile: %@", task.error);
                        return [BFTask taskWithError:task.error];
                    } else {
                        NSLog(@"Successfully updated user profile");
                        return nil;
                    }
                }];
                return [BFTask taskWithResult:@(YES)];
            } else {
                return [BFTask taskWithError:[NSError errorWithDomain:@"it.itsl" code:9 userInfo:@{NSLocalizedDescriptionKey : @"User is not authenticated"}]];
            }
        } else
            return [BFTask taskWithError:task.error];
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (task.error) {
//            if (![[NSUserDefaults standardUserDefaults] objectForKey:@"tutorialCompleted"]){
//                NSLog(@"%@", NSStringFromCGRect([UIScreen mainScreen].bounds));
//                NSString *storyboardName = CGRectGetHeight([UIScreen mainScreen].bounds) == 480 ?
//                @"Tutorial-iPhone4" : @"Tutorial";
//                ABOnboardingViewController *onBoardingViewController = [ABOnboardingViewController onboardingViewControllerWithChildrenStoryboardIds:@[@"FirstViewController",
//                                                                                                                                                       @"SecondViewController",
//                                                                                                                                                       @"ThirdViewController",
//                                                                                                                                                       @"FourthViewController",
//                                                                                                                                                       @"FifthViewController"]
//                                                                                                                                       forStoryboard:[UIStoryboard storyboardWithName:storyboardName bundle:nil]];
//                [[UIApplication sharedApplication] setStatusBarHidden:YES];
//                [self presentViewController:onBoardingViewController animated:YES completion:nil];
//            }
//            else {
                [self performSegueWithIdentifier:kPresentLoginSegueIdentifier sender:nil];
//            }
        } else {
            [self.navigationController setNavigationBarHidden:NO];
            
            // Bind all events to the current user from now on, and include his ID
            // as an event parameter always
            [[Mixpanel sharedInstance] identify:[PFUser currentUser].objectId];
            [[Mixpanel sharedInstance] registerSuperProperties:@{kMixpanelPropertyUserID:[PFUser currentUser].objectId}];
            
            
            [[PFInstallation currentInstallation] setValue:[PFUser currentUser] forKey:@"user"];
            [[[PFInstallation currentInstallation] saveInBackground] continueWithBlock:^id(BFTask<NSNumber *> *task) {
                if (!task.error) {
                    NSLog(@"User installation reference updated");
                }
                return nil;
            }];
            
            
            /*
             [[PFUser currentUser] setValue:[PFInstallation currentInstallation] forKey:@"installation"];
             [[[PFUser currentUser] saveInBackground] continueWithBlock:^id(BFTask<NSNumber *> *task) {
             if (!task.error) {
             NSLog(@"User installation reference updated");
             }
             return nil;
             }];
             */
            
            
            [self performSegueWithIdentifier:kPresentMainSegueIdentifier sender:nil];
        }
        return nil;
    }];
}
@end
