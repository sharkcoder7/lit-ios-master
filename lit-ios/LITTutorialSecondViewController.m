//
//  LITTutorialSecondViewController.m
//  lit-ios
//
//  Created by ioshero on 07/10/2015.
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import "LITTutorialSecondViewController.h"

@interface LITTutorialSecondViewController ()

@property (assign, nonatomic) BOOL pushRequested;
@property (weak, nonatomic) IBOutlet UILabel *continueLabel;

@end

@implementation LITTutorialSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)requestEnablePushNotifications:(id)sender
{
    //Push
    _pushRequested = YES;
    [self.onBoardingViewController requestPushNotifications];
    [self.continueLabel setHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (!_pushRequested) {
        [self.onBoardingViewController requestPushNotifications];
    }
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
