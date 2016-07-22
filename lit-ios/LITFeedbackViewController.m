//
//  LITFeedbackViewController.m
//  lit-ios
//
//  Created by Antonio Losada on 28/8/15.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITFeedbackViewController.h"
#import "LITProgressHUD.h"
#import "LITTheme.h"
#import "UIViewController+KeyboardAnimator.h"
#import <Parse/Parse.h>
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"

@interface LITFeedbackViewController ()

@property (nonatomic) BOOL notEditedYet;
@property (weak, nonatomic) IBOutlet UIButton *sendFeedbackButton;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation LITFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.notEditedYet = YES;
    
    self.emailTextField.text = [[PFUser currentUser] valueForKey:@"email"];
    
    self.emailTextField.layer.cornerRadius = 2;
    self.emailTextField.layer.borderColor = [UIColor lit_greyColor].CGColor;
    self.emailTextField.layer.borderWidth = 1.0f;
    self.emailTextField.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.emailTextField.clipsToBounds = YES;
    self.emailTextField.tintColor = [UIColor lit_fadedOrangeLightColor];
    
    self.messageTextView.layer.cornerRadius = 2;
    self.messageTextView.layer.borderColor = [UIColor lit_greyColor].CGColor;
    self.messageTextView.layer.borderWidth = 1.0f;
    self.messageTextView.clipsToBounds = YES;
    self.messageTextView.tintColor = [UIColor lit_fadedOrangeLightColor];
    self.messageTextView.delegate = self;
    
    self.sendFeedbackButton.layer.cornerRadius = 2;
    self.sendFeedbackButton.clipsToBounds = YES;
    
    [self.navigationItem setTitle:@"Feedback"];
    
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    //    [self.navigationController.navigationItem setTitle:@""];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

-(IBAction)sendFeedbackAction:(id)sender {
    
    NSString *email = self.emailTextField.text;
    NSString *text = self.messageTextView.text;
    
    JGProgressHUD *feedbackHud = [LITProgressHud createHudWithMessage:@"Sending feedback..."];
    [feedbackHud showInView:self.view animated:YES];
    
    PFObject *newFeedback = [PFObject objectWithClassName:@"feedback"];
    newFeedback[@"user"] = [PFUser currentUser];
    newFeedback[@"email"] = email;
    newFeedback[@"text"] = text;
    
    [newFeedback saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            
            [[Mixpanel sharedInstance] track:kMixpanelAction_sendFeedbackFilledOut_Settings properties:nil];
            
            [LITProgressHud changeStateOfHUD:feedbackHud to:kLITHUDStateDone withMessage:@"Sent"];
            [feedbackHud dismissAfterDelay:1.5f];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.75 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
            
        } else {
            [LITProgressHud changeStateOfHUD:feedbackHud to:kLITHUDStateError withMessage:[NSString stringWithFormat:@"%@\n%@",@"Error sending feedback.",@"Please try again."]];
            [feedbackHud dismissAfterDelay:5.0];
        }
    }];
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
    // Dispose of any resources that can be recreated.
}

@end
