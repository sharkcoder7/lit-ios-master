//
//  LITTutorialFifthViewController.m
//  lit-ios
//
//  Created by ioshero on 07/10/2015.
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import "LITTutorialFifthViewController.h"
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"
#import "LITGlobals.h"

@interface LITTutorialFifthViewController ()

@property (weak, nonatomic) IBOutlet UIView *videoPlayerView;

@end


@implementation LITTutorialFifthViewController
@dynamic videoPlayerView;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)finishButtonTapped:(id)sender
{
    [[Mixpanel sharedInstance] track:kMixpanelAction_proceedToLit properties:nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"tutorialCompleted"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.onBoardingViewController finishOnboarding];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLITnotificationTutorialDismissed
                                                        object:nil
                                                      userInfo:nil];
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
