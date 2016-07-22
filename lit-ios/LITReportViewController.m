//
//  LITReportViewController.m
//  lit-ios
//
//  Created by Antonio Losada on 28/8/15.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITReportViewController.h"
#import "LITProgressHUD.h"
#import "LITTheme.h"
#import "UIViewController+KeyboardAnimator.h"
#import <Parse/PFObject.h>
#import <Parse/Parse.h>
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"


NSString *const kLITKBSoundbiteCollectionViewCell = @"LITKBSoundbiteCollectionViewCell";
NSString *const kLITKBDubCollectionViewCell = @"LITKBDubCollectionViewCell";
NSString *const kLITKBLyricCollectionViewCell = @"LITKBLyricCollectionViewCell";


@interface LITReportViewController ()

@property (nonatomic) BOOL notEditedYet;
@property (weak, nonatomic) PFObject *object;
@property (weak, nonatomic) IBOutlet UIButton *sendReportButton;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation LITReportViewController

-(id)init {
    self = [super init];
    if(self) {
    }
    return self;
}

- (void)assignObject:(PFObject *)object{
    self.object = object;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.notEditedYet = YES;
    
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.modalPresentationStyle = UIModalPresentationFormSheet;
    
    self.emailTextField.text = [[PFUser currentUser] valueForKey:@"email"];
    
    self.emailTextField.layer.cornerRadius = 2;
    self.emailTextField.clipsToBounds = YES;
    self.emailTextField.tintColor = [UIColor lit_fadedOrangeLightColor];
    
    self.messageTextView.layer.cornerRadius = 2;
    self.messageTextView.clipsToBounds = YES;
    self.messageTextView.tintColor = [UIColor lit_fadedOrangeLightColor];
    self.messageTextView.delegate = self;
    
    self.sendReportButton.layer.cornerRadius = 2;
    self.sendReportButton.clipsToBounds = YES;
    
    [self setupKeyboardAnimations];
    
    // Tap the view to dismiss the keyboard
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(singleTapAction:)];
    [self.view addGestureRecognizer:singleFingerTap];
}

- (void)singleTapAction:(UITapGestureRecognizer *)recognizer {
    [self.messageTextView resignFirstResponder];
    [self.emailTextField resignFirstResponder];
}

- (IBAction)sendReportAction:(id)sender {
    
    NSString *objectId = self.object.objectId;
    NSString *className = [self.object parseClassName];
    NSString *email = self.emailTextField.text;
    NSString *text = self.messageTextView.text;
    
    if (!objectId || objectId.length == 0 ||
        !className || className.length == 0 ||
        !email || email.length == 0 ||
        !text || text.length == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error sending your report, please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    JGProgressHUD *reportHud = [LITProgressHud createHudWithMessage:@"Sending report..."];
    [reportHud showInView:self.view animated:YES];
    
    PFObject *newReport = [PFObject objectWithClassName:@"report"];
    newReport[@"user"] = [PFUser currentUser];
    newReport[@"referenceId"] = objectId;
    newReport[@"class"] = className;
    newReport[@"email"] = email;
    newReport[@"text"] = text;
    
    [newReport saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            
            [[Mixpanel sharedInstance] track:kMixpanelAction_sendFilledOutReport properties:nil];
            
            [LITProgressHud changeStateOfHUD:reportHud to:kLITHUDStateDone withMessage:@"Sent"];
            [reportHud dismissAfterDelay:1.5f];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.75 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
            
        } else {
            [LITProgressHud changeStateOfHUD:reportHud to:kLITHUDStateError withMessage:[NSString stringWithFormat:@"%@\n%@",@"Error sending report.",@"Please try again."]];
            [reportHud dismissAfterDelay:5.0];
        }
    }];
}


- (IBAction)dismissViewAction:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}


// Clear the message on first edit
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if(self.notEditedYet){
        self.messageTextView.text = @"";
        self.notEditedYet = NO;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
