//
//  LITProfileViewController.m
//  slit-ios
//
//  Created by ioshero on 09/07/2015.
//  Copyright (c) 2015 Slit Inc. All rights reserved.
//

#import "LITMainViewController.h"
#import "LITProfileViewController.h"
#import "LITProfileHeader.h"
#import "UIView+GradientBackground.h"
#import "LITTheme.h"
#import "LITCropperViewController.h"
#import "LITProfileKeyboardsViewController.h"
#import "LITProfileFavoritesViewController.h"
#import "LITProfileContentViewController.h"
#import "lit_ios-Swift.h"
#import "LITImageUtils.h"
#import "LITKeyboardTableViewCell.h"
#import "LITProgressHud.h"
#import "LITShareHelper.h"
#import "LITActionSheet.h"
#import "CUSSender.h"

#import <ParseTwitterUtils/PFTwitterUtils.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <Social/Social.h>

#import <HMSegmentedControl/HMSegmentedControl.h>
#import "RSKImageCropViewController.h"
#import <Parse/Parse.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"

#define KeyboardsSegmentIndex 0
#define FavsSegmentIndex 1
#define ContentsSegmentIndex 2

static NSString *const kEditPictureSegueIdentifier      = @"EditPictureSegue";

@interface LITProfileViewController () <RSKImageCropViewControllerDelegate> {
    BOOL _viewsSet;
    NSInteger _lastSegmentIndex;
}

@property (strong, nonatomic)   HMSegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet LITProfileHeader *profileView;
@property (weak, nonatomic) IBOutlet UIView *controlHolderView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (strong, nonatomic) LITProfileKeyboardsViewController *kbController;
@property (strong, nonatomic) LITProfileFavoritesViewController *favsController;
@property (strong, nonatomic) LITProfileContentViewController   *contentController;
@property (assign, nonatomic) BOOL controlCustomized;

@property (strong, nonatomic) UIView *pointsView;
@property (assign, nonatomic) BOOL pointsViewActive;

@end

@implementation LITProfileViewController

#pragma mark - UIViewDataSource

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Prepare the view knowing that it's related to the signed in user
    [self setupProfileView];
    
    self.pointsViewActive = NO;
    
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"KEYBOARDS", @"FAVORITES", @"CONTENT"]];
    [self.segmentedControl setSelectionIndicatorColor:[UIColor lit_darkOrangishColor]];
    //    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(4, -20, 3, -40);
    
    [self.segmentedControl setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        
        UIColor *color = selected ? [UIColor lit_darkOrangishColor] : [UIColor lit_coolGreyColor];
        return [[NSAttributedString alloc] initWithString:title
                                               attributes:@{NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-DemiBold" size:9],
                                                            NSForegroundColorAttributeName : color}];
    }];
    
    [self.segmentedControl setSelectedSegmentIndex:KeyboardsSegmentIndex];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.segmentedControl setFrame:CGRectMake(0, 0, CGRectGetWidth(self.controlHolderView.bounds), 36.0f)];
    [self.controlHolderView addSubview:self.segmentedControl];
    
    [self.kbController.view setFrame:self.containerView.frame];
    [self.kbController.view setBackgroundColor:[UIColor clearColor]];
    [self addChildViewController:self.kbController];
    [self.containerView addSubview:self.kbController.view];
    [self.kbController didMoveToParentViewController:self];
    
    [self.favsController.view setFrame:self.containerView.frame];
    [self.favsController.view setBackgroundColor:[UIColor clearColor]];
    [self addChildViewController:self.favsController];
    [self.containerView addSubview:self.favsController.view];
    [self.favsController didMoveToParentViewController:self];
    
    [self.contentController.view setFrame:self.containerView.frame];
    [self.contentController.view setBackgroundColor:[UIColor clearColor]];
    [self addChildViewController:self.contentController];
    [self.containerView addSubview:self.contentController.view];
    [self.contentController didMoveToParentViewController:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.segmentedControl setFrame:self.controlHolderView.bounds];
    if (!_viewsSet) {
        [self.containerView bringSubviewToFront:self.containerView];
        [self.containerView bringSubviewToFront:self.kbController.view];
        _viewsSet = YES;
    }
    
    if (!self.controlCustomized) {
        [self.segmentedControl setClipsToBounds:YES];
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.borderColor = [UIColor lit_lightGreyColor].CGColor;
        bottomBorder.borderWidth = 2;
        bottomBorder.frame = CGRectMake(-1, -2, CGRectGetWidth(self.controlHolderView.frame) + 4, CGRectGetHeight(self.controlHolderView.frame) + 2);
        
        [self.segmentedControl.layer insertSublayer:bottomBorder atIndex:0];
        self.controlCustomized = YES;
    }
}
// Depending on the case, we'll have to fill the user information with the
// logged in one or with whoever we're seing in the application, changing
// the things we can do in this view.
-(void) setupProfileView {
    
    // Two potential cases: Own user or other user
    
    // Case 1: Own user
    
    if([self.user.objectId isEqual:[PFUser currentUser].objectId]){
        
        // As we'll be showing the information related to the logged in user
        // in its profile view, we show both the Home and Edit buttons atop.
        
        
        [self.profileView.twitterButton addTarget:self
                                           action:@selector(linkTwitterAction:)
                                 forControlEvents:UIControlEventTouchUpInside];
        
        [self.profileView.facebookButton addTarget:self
                                           action:@selector(linkFacebookAction:)
                                 forControlEvents:UIControlEventTouchUpInside];
        
        
        // Change Twitter/Facebook buttons depending on the linking status
        
        if(![LITShareHelper checkTwitterLinked]){
            [_profileView.twitterButton setImage:[UIImage imageNamed:@"ovalTwitterGrey"] forState:UIControlStateNormal];
        }
        if(![LITShareHelper checkFacebookLinked]){
            [_profileView.facebookButton setImage:[UIImage imageNamed:@"ovalFacebookGrey"] forState:UIControlStateNormal];
        }
        
        
        self.profileView.editButton.hidden = true;
        
        
        [self.profileView.topRightButton setImage:[UIImage imageNamed:@"iconEdit.png"] forState:UIControlStateNormal];

        [self.profileView.topRightButton setEnabled:NO];
        [self.profileView.topRightButton setHidden:YES];
        
        
        [self.profileView.editButton addTarget:self
                                    action:@selector(editPictureAction:)
                          forControlEvents:UIControlEventTouchUpInside];
        
        // Change the label to the logged in user one
        self.profileView.topLabel.text = [PFUser currentUser].username;
        
        // Change the picture to the logged in user one
        PFFile *profilePic = [[PFUser currentUser] objectForKey:@"picture"];
        [self.profileView.profileImageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: profilePic.url]]]];
    }
    
    // Case 2: Other user
    
    else {
        
        self.profileView.editButton.hidden = YES;
        self.profileView.topRightButton.hidden = YES;
        self.profileView.facebookButton.hidden = YES;
        self.profileView.twitterButton.hidden = YES;
        
        
        // We need to get the user's information, so we need its object
        PFQuery *query = [PFQuery queryWithClassName:@"_User"];
        [query whereKey:@"objectId" equalTo:self.user.objectId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                
                PFUser *theUser = [objects objectAtIndex: 0];
                
                _profileView.topLabel.text = theUser.username;
                PFFile *profilePic = [theUser objectForKey:@"picture"];
                [self.profileView.profileImageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: profilePic.url]]]];
            } else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    
    // Top left button. House or back depending if we're at the first
    // profile view or not
    NSArray *controllerArray = self.navigationController.viewControllers;
    if([[controllerArray objectAtIndex:[controllerArray count]-2] class] == [LITProfileViewController class]){
        [self.profileView.topLeftButton setImage:[UIImage imageNamed:@"iconArrowLeft.png"] forState:UIControlStateNormal];
    }
    else{
        [self.profileView.topLeftButton setImage:[UIImage imageNamed:@"iconHome.png"] forState:UIControlStateNormal];
    }
    
    // Close button action, dismissing the storyboard and getting back to the last one
    [self.profileView.topLeftButton addTarget:self
                                   action:@selector(backToPreviousSlide)
                         forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark Data reload methods
- (void)reloadKeyboards:(NSArray *)keyboards
{
    self.installedKeyboards = keyboards;
    _kbController.installedKeyboards = self.installedKeyboards;
}

#pragma mark - Segmented Control
- (void)segmentedControlValueChanged:(UISegmentedControl *)control
{
    if (self.segmentedControl.selectedSegmentIndex == _lastSegmentIndex) {
        return;
    } if (self.segmentedControl.selectedSegmentIndex == KeyboardsSegmentIndex) {
        
        [[Mixpanel sharedInstance] track:kMixpanelAction_keySegment_Profile properties:nil];
        
        [self.containerView bringSubviewToFront:self.kbController.view];
        [self.containerView insertSubview:self.favsController.view belowSubview:self.separatorView];
        [self.containerView insertSubview:self.contentController.view belowSubview:self.separatorView];
    } else if (self.segmentedControl.selectedSegmentIndex == FavsSegmentIndex) {
        
        [[Mixpanel sharedInstance] track:kMixpanelAction_favSegment_Profile properties:nil];
        
        [self.profileView.topRightButton setHidden:YES];
        [self.containerView bringSubviewToFront:self.favsController.view];
        [self.containerView insertSubview:self.kbController.view belowSubview:self.separatorView];
        [self.containerView insertSubview:self.contentController.view belowSubview:self.separatorView];
    } else if (self.segmentedControl.selectedSegmentIndex == ContentsSegmentIndex) {
        
        [[Mixpanel sharedInstance] track:kMixpanelAction_contentSegment_Profile properties:nil];
        
        [self.profileView.topRightButton setHidden:YES];
        [self.containerView bringSubviewToFront:self.contentController.view];
        [self.containerView insertSubview:self.favsController.view belowSubview:self.separatorView];
        [self.containerView insertSubview:self.kbController.view belowSubview:self.separatorView];
    }
    
    _lastSegmentIndex = self.segmentedControl.selectedSegmentIndex;
}

#pragma mark - Lazy loading accessors

- (LITProfileKeyboardsViewController *)kbController
{
    if (!_kbController) {
        LITProfileKeyboardsViewController *kbController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([LITProfileKeyboardsViewController class])];
        [kbController setDelegate:self.delegate];
        [kbController setParent:self];
        [kbController setUser:self.user];
        [kbController setInstalledKeyboards:self.installedKeyboards];
        _kbController = kbController;
    }
    return _kbController;
}

- (LITProfileFavoritesViewController *)favsController
{
    if (!_favsController) {
        LITProfileFavoritesViewController *favsController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([LITProfileFavoritesViewController class])];
        [favsController setDelegate:self.delegate];
        [favsController setUser:self.user];
        _favsController = favsController;
    }
    return _favsController;
}

- (LITProfileContentViewController *)contentController
{
    if (!_contentController) {
        LITProfileContentViewController *contentController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([LITProfileContentViewController class])];
        [contentController setUser:self.user];
        _contentController = contentController;
    }
    return _contentController;
}


#pragma mark UIImagePicker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
    
    // Panorama picture resizing, thus preventing leakings
    if(selectedImage.size.width > 6000){
        
        float oldWidth = selectedImage.size.width;
        float scaleFactor = 2000 / oldWidth;
        
        float newHeight = selectedImage.size.height * scaleFactor;
        float newWidth = oldWidth * scaleFactor;
        
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
        [selectedImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        selectedImage = newImage;
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    self.navigationItem.title = @"";
    
    LITCropperViewController *imageCropVC = [[LITCropperViewController alloc] initWithImage:selectedImage];
    [imageCropVC setDelegate:self];
    [self.navigationController pushViewController:imageCropVC animated:YES];
    [imageCropVC.chooseButton setHidden:YES];
    [imageCropVC.cancelButton setHidden:YES];
    [imageCropVC.moveAndScaleLabel setHidden:YES];
        
    UIButton *cropButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cropButton setTitle:@"CROP" forState:UIControlStateNormal];
    [cropButton setTitleEdgeInsets:UIEdgeInsetsMake(5.0f, 0, 0, 0)];
    cropButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13];
    [cropButton sizeToFit];
    
    // Bind the CropController's action to the CROP button on the nav bar
    for (id target in imageCropVC.chooseButton.allTargets) {
        NSArray *actions = [imageCropVC.chooseButton actionsForTarget:target
                                                      forControlEvent:UIControlEventTouchUpInside];
        for (NSString *action in actions) {
            [cropButton addTarget:target action:NSSelectorFromString(action) forControlEvents:UIControlEventTouchUpInside];
        }
    }

    UIBarButtonItem *cropButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cropButton];
    imageCropVC.navigationItem.rightBarButtonItem = cropButtonItem;
    
    imageCropVC.navigationItem.title = @"Scale and Crop";
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
        
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark RSKImageCropViewController Delegate

// Crop image has been canceled.
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

// The original image has been cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
{
    self.profileView.profileImageView.image = croppedImage;
    [self.navigationController popViewControllerAnimated:YES];
    
    [[Mixpanel sharedInstance] track:kMixpanelAction_cropPhoto properties:nil];
    
    [LITImageUtils updateUserParsePicture:croppedImage];
}

// The original image has been cropped. Additionally provides a rotation angle used to produce image.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
                  rotationAngle:(CGFloat)rotationAngle
{
    self.profileView.profileImageView.image = croppedImage;
    [self.navigationController popViewControllerAnimated:YES];
    
    [[Mixpanel sharedInstance] track:kMixpanelAction_cropPhoto properties:nil];
    
    [LITImageUtils updateUserParsePicture:croppedImage];
}

// The original image will be cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                  willCropImage:(UIImage *)originalImage
{
    // Use when `applyMaskToCroppedImage` set to YES.
    //[SVProgressHUD show];
}

#pragma mark - Actions

- (void)editPictureAction:(UIButton *)sender {
    
    UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
    
    JGActionSheetSection *optionsSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"Upload from gallery",@"Take photo"] buttonStyle:JGActionSheetButtonStyleDefault];
    
    JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"Cancel"] buttonStyle:JGActionSheetButtonStyleCancel];
    
    
    // LIT Style
    
    for(int i=0; i<[optionsSection.buttons count]; i++){
        [LITActionSheet setButtonStyle:JGActionSheetButtonStyleDefault forButton:[optionsSection.buttons objectAtIndex:i]];
    }
    for(int i=0; i<[cancelSection.buttons count]; i++){
        [LITActionSheet setButtonStyle:JGActionSheetButtonStyleCancel forButton:[cancelSection.buttons objectAtIndex:i]];
    }
    
    // --.
    
    
    NSArray *sections = @[optionsSection, cancelSection];
    
    LITActionSheet *sheet = [LITActionSheet actionSheetWithSections:sections];
    
    [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
        
        // Action calls
        NSUInteger section = indexPath.section;
        NSUInteger item = indexPath.item;
        
        switch (section) {
            case 0: // Options
                if(item == 0){ // Gallery
                    
                    [[Mixpanel sharedInstance] track:kMixpanelAction_uploadFromGallery properties:nil];
                    
                    imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                    
                    [imagePickerController setDelegate:self];
                    imagePickerController.allowsEditing=NO;
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self presentViewController:imagePickerController animated:YES completion:nil];
                    }];
                }
                else if(item == 1){ // Take photo
                    
                    [[Mixpanel sharedInstance] track:kMixpanelAction_takePhoto properties:nil];
                    
                    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                    imagePickerController.showsCameraControls=YES;
                    
                    [imagePickerController setDelegate:self];
                    imagePickerController.allowsEditing=NO;
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self presentViewController:imagePickerController animated:YES completion:nil];
                    }];
                }
                break;
            case 1: // Cancel
                
                [[Mixpanel sharedInstance] track:kMixpanelAction_cancelNewPFPhoto properties:nil];
                break;
            default:
                break;
        }
        [sheet dismissAnimated:YES];
    }];
    
    [sheet showInView:self.view animated:YES];
    
    return;

}

- (void)linkTwitterAction:(UIButton *)button {
    
    [[Mixpanel sharedInstance] track:kMixpanelAction_twitterLink_Profile properties:nil];
    
    JGProgressHUD *hud = [LITProgressHud createHudWithMessage:@"Linking Twitter..."];
    
    if([LITShareHelper checkTwitterLinked]){
        
        [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:[NSString stringWithFormat:@"User already\nlinked to Twitter"]];
        [hud showInView:self.view];
        [hud dismissAfterDelay:1.5f];
        return;
    }
    else {
        
        [hud showInView:self.view];
        [[LITShareHelper linkTwitterAccount] continueWithBlock:^id(BFTask *task) {
            if([task.result integerValue] == LITSharingLinkOkTwitter){
                [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:@"Linked"];
                [hud dismissAfterDelay:1.5f];
                [_profileView.twitterButton setImage:[UIImage imageNamed:@"ovalTwitter"] forState:UIControlStateNormal];
            }
            else if([task.result integerValue] == LITSharingLinkErrorTwitter){
                [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:[NSString stringWithFormat:@"Couldn't link\nto Twitter"]];
                [hud dismissAfterDelay:1.5f];
            }
            return nil;
        }];
    }
}

- (void)linkFacebookAction:(UIButton *)button {
    
    [[Mixpanel sharedInstance] track:kMixpanelAction_facebookLink_Profile properties:nil];
    
    JGProgressHUD *hud = [LITProgressHud createHudWithMessage:@"Linking Facebook..."];
    
    if([LITShareHelper checkFacebookLinked]){
        
        [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:[NSString stringWithFormat:@"User already\nlinked to Facebook"]];
        [hud showInView:self.view];
        [hud dismissAfterDelay:1.5f];
        return;
    }
    else {
        [hud showInView:self.view];
        [[LITShareHelper linkFacebookAccount] continueWithBlock:^id(BFTask *task) {
            if([task.result integerValue] == LITSharingLinkOkFacebook){
                [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:@"Linked"];
                [hud dismissAfterDelay:1.5f];
                [_profileView.facebookButton setImage:[UIImage imageNamed:@"ovalFacebook"] forState:UIControlStateNormal];
            }
            else if([task.result integerValue] == LITSharingLinkErrorFacebook){
                [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:[NSString stringWithFormat:@"Couldn't link\nto Facebook"]];
                [hud dismissAfterDelay:1.5f];
            }
            return nil;
        }];
    }
}

// Dismiss the current view and get back to the last one
-(void)backToPreviousSlide {
    [[Mixpanel sharedInstance] track:kMixpanelAction_homeToFeed properties:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) presentPointsView {
    
    if(!self.pointsViewActive){
        
        if(self.user == [PFUser currentUser]){
            [[PFUser currentUser] fetch]; // Reload the user points, which may have changed
        }
        
        [[Mixpanel sharedInstance] track:kMixpanelAction_viewPoints properties:nil];
        
        self.pointsViewActive = YES;
        
        self.pointsView = [[UIView alloc]initWithFrame:self.containerView.frame];
        [self.pointsView setFrame:CGRectMake(self.pointsView.frame.size.width,
                                             self.pointsView.frame.origin.y,
                                             self.pointsView.frame.size.width,
                                             self.pointsView.frame.size.height)];
        [self.pointsView setBackgroundColor:[UIColor lit_lighterGreyColor]];
        [self.pointsView setAlpha:0];
        [self.pointsView setClipsToBounds:YES];
        
        
        UILabel *pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 24)];
        [pointsLabel setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:36.0f]];
        pointsLabel.text = [self.user valueForKey:@"pointsCount"];
        pointsLabel.textColor = [UIColor lit_lightOrangishColor];
        pointsLabel.textAlignment = NSTextAlignmentCenter;
        [pointsLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self.pointsView addSubview:pointsLabel];
        
        NSLayoutConstraint *centerXconstraint = [NSLayoutConstraint
                                                 constraintWithItem:pointsLabel
                                                 attribute:NSLayoutAttributeCenterX
                                                 relatedBy:NSLayoutRelationEqual
                                                 toItem:self.pointsView
                                                 attribute:NSLayoutAttributeCenterX
                                                 multiplier:1.0
                                                 constant:0];
        
        NSLayoutConstraint *centerYconstraint = [NSLayoutConstraint
                                                 constraintWithItem:pointsLabel
                                                 attribute:NSLayoutAttributeCenterY
                                                 relatedBy:NSLayoutRelationEqual
                                                 toItem:self.pointsView
                                                 attribute:NSLayoutAttributeCenterY
                                                 multiplier:1.0
                                                 constant:0];
        
        [self.pointsView addConstraint:centerXconstraint];
        [self.pointsView addConstraint:centerYconstraint];
        
        [self.view addSubview:self.pointsView];
        [self.view bringSubviewToFront:self.pointsView];
        
        CALayer *layer = [[CUSSenderFireLayer alloc]init];
        [self.pointsView.layer addSublayer:layer];
        
        [UIView animateWithDuration:.35 animations:^{
            [self.pointsView setFrame:CGRectMake(0,
                                                 self.pointsView.frame.origin.y,
                                                 self.pointsView.frame.size.width,
                                                 self.pointsView.frame.size.height)];
            [self.pointsView setAlpha:1];
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:.2 delay:2 options:UIViewAnimationOptionCurveLinear animations:^{
                [self.pointsView setFrame:CGRectMake(self.pointsView.frame.size.width,
                                                     self.pointsView.frame.origin.y,
                                                     self.pointsView.frame.size.width,
                                                     self.pointsView.frame.size.height)];
                [self.pointsView setAlpha:0];
            } completion:^(BOOL finished) {
                self.pointsView = nil;
                self.pointsViewActive = NO;
            }];
        }];
    }
}


@end
