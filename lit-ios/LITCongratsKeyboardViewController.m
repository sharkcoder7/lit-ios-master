//
//  LITCongratsKeyboardViewController.m
//  lit-ios
//
//  Created by Antonio Losada on 21/8/15.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITKeyboard.h"
#import "LITCongratsKeyboardViewController.h"
#import "LITProgressHud.h"
#import <Parse/Parse.h>
#import <ParseTwitterUtils/PFTwitterUtils.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "LITShareHelper.h"
#import <Social/Social.h>
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"
#import <FBSDKShareKit/FBSDKMessageDialog.h>
#import <FBSDKShareKit/FBSDKShareLinkContent.h>

@interface LITCongratsKeyboardViewController ()

@property (weak, nonatomic) LITKeyboard *keyboard;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *visualEffectView;
@property (strong, nonatomic) IBOutlet UIView *fullView;
@property (weak, nonatomic) IBOutlet UIButton *publishButton;
@property (weak, nonatomic) IBOutlet UILabel *congratsLabel;
@property (weak, nonatomic) IBOutlet UIButton *facebookCheckButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterCheckButton;

@property (nonatomic) BOOL facebookEnabled;
@property (nonatomic) BOOL twitterEnabled;

@end

@implementation LITCongratsKeyboardViewController

-(id)init {
    self = [super init];
    if(self) {
    }
    return self;
}

// The Main Controller assigns the new keyboard to the modal so it
// can show its name (and have access to all of its properties)
- (void)assignKeyboard:(LITKeyboard *)kb{
    self.keyboard = kb;
}

// This methods checks for the Facebook and Twitter permissions the
// user has granted the application. If the system has both accounts
// activated, then the user would be able to share content in both platforms.
- (void)prepareControls{
    
    if ([LITShareHelper checkTwitterLinked]) {self.twitterEnabled = YES;}
    else{self.twitterEnabled = NO;}
    
    if ([LITShareHelper checkFacebookLinked]) {self.facebookEnabled = YES;}
    else{self.facebookEnabled = NO;}
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.modalPresentationStyle = UIModalPresentationFormSheet;
        
    [self.publishButton.layer setBorderWidth:1.0];
    [self.publishButton.layer setCornerRadius:2.0];
    [self.publishButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
    self.congratsLabel.text = [NSString stringWithFormat:@"CONGRATS!\n\nYou have succesfully created\n\"%@\"", [self.keyboard valueForKey:@"displayName"]];
    
    /*
    if(self.facebookEnabled){[self.facebookCheckButton setAlpha:1];}
    else{[self.facebookCheckButton setAlpha:.5];}
    
    if(self.twitterEnabled){[self.twitterCheckButton setAlpha:1];}
    else{[self.twitterCheckButton setAlpha:.5];}
     */
    
    [self.facebookCheckButton setAlpha:1];
    [self.twitterCheckButton setAlpha:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)facebookAction:(id)sender {
    
    NSString *messageText = [NSString stringWithFormat:@"I've just created the \"%@\" keyboard on LIT! Download it for free on the App Store!",self.keyboard.displayName];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        /*
        [[UIPasteboard generalPasteboard] setString:messageText];
        
        JGProgressHUD * hud = [LITProgressHud createHudWithMessage:@""];
        hud = [LITProgressHud createCopyPasteHudWithMessage:[NSString stringWithFormat:@"%@\n%@", @"Message", @"Copied"]];
        [hud showInView:self.view animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [LITProgressHud changeStateOfHUD:hud to:kLITHUDStatePaste withMessage:[NSString stringWithFormat:@"%@\n%@", @"Paste it", @"and then share"]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [hud dismiss];
            });
        });
        
        SLComposeViewController *controller = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeFacebook];
        SLComposeViewControllerCompletionHandler myBlock =
        ^(SLComposeViewControllerResult result){
            [controller dismissViewControllerAnimated:YES completion:nil];
        };
        controller.completionHandler = myBlock;
        [controller setInitialText:messageText];
        //[controller addURL:[NSURL URLWithString:@"http://www.itslit.com"]];
        [self presentViewController:controller animated:YES completion:nil];
        */
        
        
        
        FBSDKShareLinkContent  *content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [NSURL URLWithString:@"http://www.itslit.com"];
        content.contentDescription = messageText;
        content.contentTitle = @"It's LIT";
        
        FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
        dialog.fromViewController = self;
        dialog.shareContent = content;
        dialog.mode = FBSDKShareDialogModeFeedWeb;
        dialog.delegate = self;
        
        [dialog show];
    }
    else {
        JGProgressHUD * hud = [LITProgressHud createHudWithMessage:@""];
        [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError withMessage:@"Please setup a\nFacebook account first."];
        [hud showInView:self.view];
        [hud dismissAfterDelay:1.5];
    }
}

- (IBAction)twitterAction:(id)sender {
    
    NSString *messageText = [NSString stringWithFormat:@"I've just created the \"%@\" keyboard on LIT! Download it for free on the App Store! http://www.itslit.com",self.keyboard.displayName];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:messageText];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    else {
        JGProgressHUD * hud = [LITProgressHud createHudWithMessage:@""];
        [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError withMessage:@"Please setup a\nTwitter account first."];
        [hud showInView:self.view];
        [hud dismissAfterDelay:1.5];
    }
}


- (IBAction)publishAction:(id)sender {
    
    [[Mixpanel sharedInstance] track:kMixpanelAction_publishKey_NewKey properties:nil];
    
    // Close the modal after sharing the content in FB or Twitter
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark Facebook Sharing Delegate

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    NSLog(@"Sharer did complete the operation");
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    NSLog(@"Sharer did cancel the operation");
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    NSLog(@"Sharer did failt at operation");
}

@end
