//
//  LITLoginViewController.m
//  lit-ios
//
//  Created by ioshero on 10/07/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITLoginViewController.h"
#import "LITTheme.h"
#import "ParseGlobals.h"
#import "UIView+GradientBackground.h"
#import "UIViewController+ProfileUpdater.h"
#import "LITTermsOfServiceViewController.h"
#import <Parse/PFInstallation.h>
#import <ParseTwitterUtils/ParseTwitterUtils.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <MMMaterialDesignSpinner/MMMaterialDesignSpinner.h>
#import <Bolts/Bolts.h>
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"
#import <QuartzCore/QuartzCore.h>


static NSString *const kPresentMainSegueIdentifier = @"PresentMainFromLoginSegue";
static NSString *const kTermsOfServiceSegueIdentifier   = @"TermsOfServiceSegue";


@interface LITLoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet MMMaterialDesignSpinner *spinner;
@property (weak, nonatomic) IBOutlet UITextView *textViewTOS;
@property (weak, nonatomic) IBOutlet UIButton *questionButton;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIView *whiteView;

@property (assign, nonatomic) BOOL tappedTOS;
@property (assign, nonatomic) BOOL textViewTOSenabled;

@end


@implementation LITLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup and hide the overlay layer
    self.whiteView.layer.cornerRadius = 3;
    [self.whiteView.layer setMasksToBounds:YES];
    [self.overlayView setHidden:YES];
    
    [self.view setupGradientBackgroundFromPoint:CGPointMake(0.0f, 0.0f)
                               andStartingColor:[UIColor lit_fadedOrangeLightColor]
                                        toPoint:CGPointMake(0.5f, 1.0f)
                                  andFinalColor:[UIColor lit_fadedOrangeDarkColor]];
 
    [self.navigationController setNavigationBarHidden:YES];
    
    self.textViewTOSenabled = YES;
    
    // Prepare the view knowing that it's related to the signed in user
    [self setupView];
}


- (void)setupView {
    
    [_facebookButton setImage:nil forState:UIControlStateNormal];
    [[_facebookButton titleLabel] setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f]];
    
    [_facebookButton setBackgroundColor:[UIColor lit_facebookColor]];
    [_twitterButton setBackgroundColor:[UIColor lit_twitterColor]];
    
    _facebookButton.layer.cornerRadius = 2;
    _twitterButton.layer.cornerRadius = 2;
    
    _questionButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    _questionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    
    //
    
//    UIFont *fontRegular = [UIFont fontWithName:@"AvenirNext-Regular" size:10.0];
//    UIFont *fontBold = [UIFont fontWithName:@"AvenirNext-Bold" size:10.0];
//    [self.labelTOS setFont:nil];
//    
//    NSString *string = @"By logging in, you are indicating that you have read the Privacy Policy and agree to the Terms of Service";
//
//    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
//    [attrString setAttributes:@{ NSFontAttributeName: fontRegular } range:NSMakeRange(0, 57)];
//    [attrString setAttributes:@{ NSFontAttributeName: fontBold } range:NSMakeRange(57, 14)];
//    [attrString setAttributes:@{ NSFontAttributeName: fontRegular } range:NSMakeRange(71, 18)];
//    [attrString setAttributes:@{ NSFontAttributeName: fontBold } range:NSMakeRange(89, 16)];
//
//    
//    self.labelTOS.text = @"";
//    self.labelTOS.attributedText = attrString;
    
    //
    
    UIFont *fontRegular = [UIFont fontWithName:@"AvenirNext-Regular" size:10.0];
    UIFont *fontBold = [UIFont fontWithName:@"AvenirNext-Bold" size:10.0];
    [self.textViewTOS setFont:nil];
    
    NSString *string = @"By logging in, you are indicating that you have read the Privacy Policy and agree to the Terms of Service";
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    
    [attrString setAttributes:@{ NSFontAttributeName: fontRegular } range:NSMakeRange(0, 57)];
    [attrString setAttributes:@{ NSFontAttributeName: fontBold } range:NSMakeRange(57, 14)];
    [attrString setAttributes:@{ NSFontAttributeName: fontRegular } range:NSMakeRange(71, 18)];
    [attrString setAttributes:@{ NSFontAttributeName: fontBold } range:NSMakeRange(89, 16)];
    
    
    self.textViewTOS.text = @"";
    self.textViewTOS.attributedText = attrString;
    self.textViewTOS.textAlignment = NSTextAlignmentCenter;
    self.textViewTOS.textColor = [UIColor whiteColor];
    self.textViewTOS.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    self.textViewTOS.contentInset = UIEdgeInsetsMake(-4,-8,0,0);

    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnTOStextView:)];
    [gr setNumberOfTapsRequired:1];
    [self.textViewTOS addGestureRecognizer:gr];
}

#pragma mark Actions

- (IBAction)twitterButtonTapped:(id)sender
{
    [[Mixpanel sharedInstance] track:kMixpanelAction_twitterLogin properties:nil];
    
    //[self changeTitleLabelTo:@"Preparing your account & keyboards"];
    [self.twitterButton setEnabled:NO];
    [self.facebookButton setEnabled:NO];
    [self.questionButton setEnabled:NO];
    self.textViewTOSenabled = NO;
    
    // Get all Twitter accounts in Settings
//    ACAccountStore *account = [[ACAccountStore alloc] init];
//    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
//    NSArray *arrayOfAccons = [account accountsWithAccountType:accountType];
    [self loginWithTask:[PFTwitterUtils logInInBackground]];
//    if(!([[[[ACAccountStore alloc] init] accountTypeWithAccountTypeIdentifier: ACAccountTypeIdentifierTwitter] accessGranted]) &&
//       ([arrayOfAccons count] > 0)){
//
//    }
//    else {
//        
//        NSString *msg = @"";
//        
//        if(![[[[ACAccountStore alloc] init] accountTypeWithAccountTypeIdentifier: ACAccountTypeIdentifierTwitter] accessGranted])
//        {
//            msg = @"Please allow LIT to use your Twitter account through iOS Settings.";
//        }
//        else if([arrayOfAccons count] == 0)
//        {
//            msg = @"Please add a Twitter account through iOS Settings.";
//        }
//        
//        UIAlertController *alertController = [UIAlertController
//                                              alertControllerWithTitle:@"Error"
//                                              message:msg
//                                              preferredStyle:UIAlertControllerStyleAlert];
//        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
//        
//        [self presentViewController:alertController animated:YES completion:^{
//            [self.twitterButton setEnabled:YES];
//            [self.facebookButton setEnabled:YES];
//            [self.questionButton setEnabled:YES];
//            self.textViewTOSenabled = YES;
//        }];
//    }
}

- (IBAction)facebookButtonTapped:(id)sender
{
    [[Mixpanel sharedInstance] track:kMixpanelAction_facebookLogin properties:nil];

    //[self changeTitleLabelTo:@"Preparing your account & keyboards"];
    [self.twitterButton setEnabled:NO];
    [self.facebookButton setEnabled:NO];
    [self.questionButton setEnabled:NO];
    self.textViewTOSenabled = NO;
    [self loginWithTask:[PFFacebookUtils
                         logInInBackgroundWithReadPermissions:@[@"email", @"public_profile"]]];

}

-(void)handleTapOnTOStextView:(UITapGestureRecognizer *)gestureRecognizer
{
    if(self.textViewTOSenabled){
        
        CGPoint location = [gestureRecognizer locationInView:self.textViewTOS];
        
        NSString *textViewString = self.textViewTOS.text;
        
        NSRange privacyPolicyRange = [textViewString rangeOfString:@"Privacy Policy"];
        NSRange tosRange = [textViewString rangeOfString:@"Terms of Service"];
        
        [[Mixpanel sharedInstance] track:kMixpanelAction_termsOfService_Login properties:nil];
        
        if([self point:location touchesSomeCharacterInRange:privacyPolicyRange]){
            self.tappedTOS = NO;
            [self performSegueWithIdentifier:kTermsOfServiceSegueIdentifier sender:self];
        }
        else if([self point:location touchesSomeCharacterInRange:tosRange]){
            self.tappedTOS = YES;
            [self performSegueWithIdentifier:kTermsOfServiceSegueIdentifier sender:self];
        }
    }
}

- (BOOL)point:(CGPoint)point touchesSomeCharacterInRange:(NSRange)range
{
    NSRange glyphRange = [self.textViewTOS.layoutManager glyphRangeForCharacterRange:range actualCharacterRange:NULL];
    
    BOOL touches = NO;
    for (NSUInteger index = glyphRange.location; index < glyphRange.location + glyphRange.length; index++) {
        CGRect rectForGlyphInContainer = [self.textViewTOS.layoutManager boundingRectForGlyphRange:NSMakeRange(index, 1) inTextContainer:self.textViewTOS.textContainer];
        CGRect rectForGlyphInTextView = CGRectOffset(rectForGlyphInContainer, self.textViewTOS.textContainerInset.left, self.textViewTOS.textContainerInset.top);
        
        if (CGRectContainsPoint(rectForGlyphInTextView, point)) {
            touches = YES;
            break;
        }
    }
    
    return touches;
}

- (IBAction)questionButtonTapped:(id)sender
{
    [[Mixpanel sharedInstance] track:kMixpanelAction_loginQuestionMark properties:nil];
    
    [self.view bringSubviewToFront:self.overlayView];
    [self.overlayView setHidden:NO];
}

- (IBAction)crossButtonTapped:(id)sender
{
    [self.view sendSubviewToBack:self.overlayView];
    [self.overlayView setHidden:YES];
}

#pragma mark Interface Methods

- (void)changeTitleLabelTo:(NSString *)newTitle {
    CATransition *animation = [CATransition animation];
    animation.duration = .75;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.titleLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
    
    // Change the text
    self.titleLabel.text = newTitle;
}

#pragma mark Login Task

- (void)loginWithTask:(BFTask *)task
{
    [self.spinner startAnimating];
    //[self changeTitleLabelTo:@"Preparing your account & keyboards"];
    [[task continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
        PFUser *user = task.result;
        if (user.isNew) {
            NSLog(@"User signed up and logged in!");
            
        } else {
            NSLog(@"User logged in!");
        }
        [self changeTitleLabelTo:@"Preparing your account & keyboards"];
        NSDictionary *authData = [user valueForKey:@"authData"];
        return [self updateProfileDataWithAuthData:authData];
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        [self.spinner stopAnimating];
        if (task.error || task.isCancelled) {
            NSString *message = task.error ?
            [NSString stringWithFormat:@"Couldn't log you in. Error code: %ld \n Error description: \
             %@", (long)task.error.code, task.error.localizedDescription]
            : @"Couldn't log you in. Cancelled by user";
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Error"
                                                  message:message
                                                  preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
            [self.twitterButton setEnabled:YES];
            [self.facebookButton setEnabled:YES];
            [self.questionButton setEnabled:YES];
            self.textViewTOSenabled = YES;
        } else {
            [self.twitterButton setEnabled:NO];
            [self.facebookButton setEnabled:NO];
            [self.questionButton setEnabled:NO];
            self.textViewTOSenabled = NO;
            
            if(task.cancelled) {
                [self changeTitleLabelTo:@"Have a fire conversation"];
            }
            else {
                
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
                
                [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"extensionTutorialCompleted"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self.navigationController setNavigationBarHidden:NO];
                [self performSegueWithIdentifier:kPresentMainSegueIdentifier sender:nil];
            }
        }
        return nil;
    }];
}

# pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:kTermsOfServiceSegueIdentifier]) {
        
        LITTermsOfServiceViewController *tosController = (LITTermsOfServiceViewController *)[segue destinationViewController];
        
        if(self.tappedTOS){
            [tosController setMode:LITTermsOfServiceModeTOS];
        }
        else {
            [tosController setMode:LITTermsOfServiceModePrivacyPolicy];
        }
    }
}

@end
