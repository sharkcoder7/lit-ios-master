//
//  LITTutorialThirdViewController.m
//  lit-ios
//
//  Created by ioshero on 07/10/2015.
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import "LITTutorialThirdViewController.h"
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"
#import <AVFoundation/AVFoundation.h>

@interface LITTutorialThirdViewController ()

@property (weak, nonatomic) IBOutlet UIButton *goToSettingsButton;
@property (weak, nonatomic) IBOutlet UIView *videoPlayerView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;
@property (weak, nonatomic) IBOutlet UIView *fullAccessInfoView;
@property (weak, nonatomic) IBOutlet UILabel *blurViewText;

@end


@implementation LITTutorialThirdViewController
@dynamic videoPlayerView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.goToSettingsButton.backgroundColor = [UIColor whiteColor];
    self.goToSettingsButton.layer.cornerRadius = 3;
    
    [self.fullAccessInfoView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                                   initWithTarget:self
                                                   action:@selector(tapRecognized:)]];
    
    [self.blurView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                        initWithTarget:self
                                        action:@selector(dismissBlurView:)]];
    
    [self.blurViewText sizeToFit];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    // Animate the Settings button
    [self startAnimation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)startAnimation
{
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
    [shake setDuration:0.2];
    [shake setRepeatCount:5];
    [shake setAutoreverses:YES];
    [shake setFromValue:[NSValue valueWithCGPoint:
                         CGPointMake(self.goToSettingsButton.center.x - 7,self.goToSettingsButton.center.y)]];
    [shake setToValue:[NSValue valueWithCGPoint:
                       CGPointMake(self.goToSettingsButton.center.x + 7, self.goToSettingsButton.center.y)]];
    [self.goToSettingsButton.layer addAnimation:shake forKey:@"position"];
}




- (void)applicationWillEnterForeground {
//    [super applicationWillEnterForeground];
    [self startAnimation];
}

- (void)applicationWillResignActive {
//    [super applicationWillResignActive];
    [self.goToSettingsButton.layer removeAllAnimations];
}


#pragma mark - Action
- (void)tapRecognized:(UITapGestureRecognizer *)recognizer
{
    [[Mixpanel sharedInstance] track:kMixpanelAction_fullAccessInfo properties:nil];
    
    [self.view bringSubviewToFront:self.blurView];
    [self.blurView setHidden:NO];
}

- (void)dismissBlurView:(UITapGestureRecognizer *)recognizer
{
    [self.view sendSubviewToBack:self.blurView];
    [self.blurView setHidden:YES];
}

- (IBAction)goToSettingsAction:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"installationCompleted"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIViewController *pageVC = self.parentViewController;
        while([pageVC class] != [UIPageViewController class]){
            pageVC = [self.parentViewController parentViewController];
        }
        
        for (UIScrollView *view in pageVC.view.subviews) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                view.scrollEnabled = YES;
            }
        }
    });
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General&path=Keyboard/KEYBOARDS"]];
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
