//
//  LITAboutViewController.m
//  slit-ios
//
//  Created by ioshero on 09/07/2015.
//  Copyright (c) 2015 Slit Inc. All rights reserved.
//

#import "LITAboutViewController.h"
#import "LITTheme.h"
#import "UIView+GradientBackground.h"

@interface LITAboutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UITextView *textViewInfo;

@end

@implementation LITAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setupGradientBackgroundFromPoint:CGPointMake(0.0f, 0.0f)
                               andStartingColor:[UIColor lit_fadedOrangeLightColor]
                                        toPoint:CGPointMake(0.5f, 1.0f)
                                  andFinalColor:[UIColor lit_fadedOrangeDarkColor]];
    
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    
    self.versionLabel.text = [NSString stringWithFormat:@"Version %@",version];
    
    [self.textViewInfo setContentOffset:CGPointZero animated:YES];
}

- (IBAction)backToPreviousSlide:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
