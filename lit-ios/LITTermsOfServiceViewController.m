//
//  LITTermsOfServiceViewController.m
//  lit-ios
//
//  Created by Antonio Losada on 15/10/15.
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import "LITTermsOfServiceViewController.h"
#import "LITTheme.h"
#import "UIView+GradientBackground.h"

NSString *const kLITPrivacyPolicyURL = @"http://itslit.com/privacy-policy.html";
NSString *const kLITTOSURL = @"http://itslit.com/terms-of-use.html";

@interface LITTermsOfServiceViewController()

@end

@implementation LITTermsOfServiceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setupGradientBackgroundFromPoint:CGPointMake(0.0f, 0.0f)
                               andStartingColor:[UIColor lit_fadedOrangeLightColor]
                                        toPoint:CGPointMake(0.5f, 1.0f)
                                  andFinalColor:[UIColor lit_fadedOrangeDarkColor]];
    
    [self.navigationItem setTitle:self.mode == LITTermsOfServiceModeTOS ? @"Terms of Service" : @"Privacy Policy"];
    
    
//    NSString *urlAddress = [[NSBundle mainBundle] pathForResource:self.documentName
//                                                           ofType:@"pdf"];
    NSURL *url = [NSURL URLWithString:self.mode == LITTermsOfServiceModeTOS ? kLITTOSURL : kLITPrivacyPolicyURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webViewTOS loadRequest:requestObj];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

#pragma mark - Setter
- (void)setMode:(LITTermsOfServiceMode)mode
{
    if (mode != LITTermsOfServiceModeTOS && mode != LITTermsOfServiceModePrivacyPolicy) {
        [NSException raise:NSInvalidArgumentException
                    format:@"mode must be LITTermsOfServiceModeTOS or LITTermsOfServiceModePrivacyPolicy"];
    }
    _mode = mode;
}

@end
