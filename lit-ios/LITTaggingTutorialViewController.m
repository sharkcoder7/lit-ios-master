
//
//  LITTaggingTutorialViewController.m
//  lit-ios
//
//  Created by Antonio Losada on 28/10/15.
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import "LITTaggingTutorialViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface LITTaggingTutorialViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation LITTaggingTutorialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contentView.layer.cornerRadius = 3;
}

- (IBAction)startTaggingAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
