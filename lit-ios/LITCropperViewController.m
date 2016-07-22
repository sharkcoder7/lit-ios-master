//
//  LITCropper.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITCropperViewController.h"

#import <RSKImageCropper/RSKImageCropViewController.h>
#import <RSKImageCropper/UIApplication+RSKImageCropper.h>
#import <RSKImageCropper/CGGeometry+RSKImageCropper.h>
#import <RSKImageCropper/UIImage+RSKImageCropper.h>
#import <RSKImageCropper/RSKImageScrollView.h>
#import <RSKImageCropper/RSKTouchView.h>

@interface RSKImageCropViewController () <UIGestureRecognizerDelegate>

@property (assign, nonatomic) BOOL originalNavigationControllerNavigationBarHidden;
@property (strong, nonatomic) UIImage *originalNavigationControllerNavigationBarShadowImage;
@property (strong, nonatomic) UIColor *originalNavigationControllerViewBackgroundColor;
@property (assign, nonatomic) BOOL originalStatusBarHidden;

@end

@implementation LITCropperViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIApplication *application = [UIApplication rsk_sharedApplication];
    if (application) {
        self.originalStatusBarHidden = application.statusBarHidden;
        [application setStatusBarHidden:NO];
    }
    
//    self.originalNavigationControllerNavigationBarHidden = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
//    self.originalNavigationControllerNavigationBarShadowImage = self.navigationController.navigationBar.shadowImage;
//    self.navigationController.navigationBar.shadowImage = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UIApplication *application = [UIApplication rsk_sharedApplication];
    if (application) {
        [application setStatusBarHidden:NO];
    }
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    
//    self.navigationController.navigationBar.shadowImage = self.originalNavigationControllerNavigationBarShadowImage;
//    self.navigationController.view.backgroundColor = self.originalNavigationControllerViewBackgroundColor;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end
