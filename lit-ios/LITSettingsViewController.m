//
//  LITSettingsViewController.m
//  slit-ios
//
//  Created by ioshero on 09/07/2015.
//  Copyright (c) 2015 Slit Inc. All rights reserved.
//

#import "LITSettingsViewController.h"
#import "LITSettingsTableViewCell.h"
#import "LITTheme.h"
#import "LITCropperViewController.h"
#import "UIView+GradientBackground.h"
#import "LITTermsOfServiceViewController.h"
#import "LITProfileHeader.h"
#import "LITImageUtils.h"
#import "RSKImageCropViewController.h"
#import "LITProgressHud.h"
#import "LITShareHelper.h"
#import "LITActionSheet.h"

#import <ParseTwitterUtils/PFTwitterUtils.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <Social/Social.h>

#import <Parse/Parse.h>
#import <Bolts/Bolts.h>
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"

static NSString *const kFindFriendsSegueIdentifier      = @"FindFriendsSegue";
static NSString *const kAboutSegueIdentifier            = @"AboutSegue";
static NSString *const kFAQSegueIdentifier              = @"FAQSegue";
static NSString *const kGiveFeedbackSegueIdentifier     = @"GiveFeedbackSegue";
static NSString *const kTermsOfServiceSegueIdentifier   = @"TermsOfServiceSegue";
static NSString *const kLogoutSegueIdentifier           = @"LogoutSegue";
static NSString *const kEditPictureSegueIdentifier      = @"EditPictureSegue";


@interface LITSettingsViewController () <RSKImageCropViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *settingsTable;
@property (weak, nonatomic) IBOutlet LITProfileHeader *profileView;

@property (assign, nonatomic) BOOL tappedTOS;

@end

@implementation LITSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Data source and delegate binding to the settings table of options
    _settingsTable.dataSource = self;
    _settingsTable.delegate = self;
    
    // Prepare the view knowing that it's related to the signed in user
    [self setupView];
    self.settingsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void) setupView{
    
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
    
    
    // We're in the settings view, so we show both the option to go home and
    // the edition icon next to the profile picture. No icon atop left.
    
    _profileView.topLeftButton.hidden = true;
    
    [_profileView.topRightButton setImage:[UIImage imageNamed:@"iconHome.png"] forState:UIControlStateNormal];
    [self.profileView.topRightButton setEnabled:YES];
    [self.profileView.topRightButton setHidden:NO];
    
    
    // Change the label to the logged in user one
    _profileView.topLabel.text = @"Settings";
    
    // Change the picture to the logged in user one
    PFFile *profilePic = [[PFUser currentUser] objectForKey:@"picture"];
    [_profileView.profileImageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: profilePic.url]]]];
    
    
    // Close button action, dismissing the storyboard and getting back home
    [_profileView.topRightButton addTarget:self
                                   action:@selector(backToPreviousSlide)
                         forControlEvents:UIControlEventTouchUpInside];
    
    [_profileView.editButton addTarget:self
                                action:@selector(editPictureAction:)
                      forControlEvents:UIControlEventTouchUpInside];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // !!! Auto Layout activated therefore no custom positioning of elements !!!
    
    LITSettingsTableViewCell *cell = (LITSettingsTableViewCell *) [tableView dequeueReusableCellWithIdentifier:kLITSettingsCellIdentifier forIndexPath:indexPath];
    
    switch (indexPath.row) {
            
        case 0:
            cell.titleLabel.text = [NSString stringWithFormat:@"About LIT"];
            cell.titleLabel.frame = CGRectMake(47, 15, 59, 18);
            cell.iconImageView.image = [UIImage imageNamed:@"iconAbout.png"];
            cell.iconImageView.frame = CGRectMake(16, 19, 16, 12);
            cell.iconArrow.frame = CGRectMake(cell.frame.size.width-12-13, 19, 12, 12);
            break;
            
        case 1:
            cell.titleLabel.text = [NSString stringWithFormat:@"FAQ"];
            cell.titleLabel.frame = CGRectMake(47, 15, 27, 18);
            cell.iconImageView.image = [UIImage imageNamed:@"iconFaq.png"];
            cell.iconImageView.frame = CGRectMake(15, 18, 16, 17);
            cell.iconArrow.frame = CGRectMake(123, 19, 12, 12);
            break;
            
        case 2:
            cell.titleLabel.text = [NSString stringWithFormat:@"Give Feedback"];
            cell.titleLabel.frame = CGRectMake(47, 15, 90, 18);
            cell.iconImageView.image = [UIImage imageNamed:@"iconFeedback.png"];
            cell.iconImageView.frame = CGRectMake(15, 18, 16, 16);
            cell.iconArrow.frame = CGRectMake(cell.frame.size.width-12-13, 19, 12, 12);
            break;
            
        case 3:
            cell.titleLabel.text = [NSString stringWithFormat:@"Privacy Policy"];
            cell.titleLabel.frame = CGRectMake(47, 15, 170, 18);
            cell.iconImageView.image = [UIImage imageNamed:@"iconTOS.png"];
            cell.iconImageView.frame = CGRectMake(16, 15, 16, 16);
            cell.iconArrow.frame = CGRectMake(cell.frame.size.width-12-13, 19, 12, 12);
            break;
            
        case 4:
            cell.titleLabel.text = [NSString stringWithFormat:@"Terms of Service"];
            cell.titleLabel.frame = CGRectMake(47, 15, 170, 18);
            cell.iconImageView.image = [UIImage imageNamed:@"iconTOS.png"];
            cell.iconImageView.frame = CGRectMake(16, 15, 16, 16);
            cell.iconArrow.frame = CGRectMake(cell.frame.size.width-12-13, 19, 12, 12);
            break;
            
        case 5:
            cell.titleLabel.text = [NSString stringWithFormat:@"Logout"];
            cell.titleLabel.frame = CGRectMake(47, 15, 43, 18);
            cell.iconImageView.image = [UIImage imageNamed:@"iconLogout.png"];
            cell.iconImageView.frame = CGRectMake(16, 15, 16, 16);
            cell.iconArrow.frame = CGRectMake(cell.frame.size.width-12-13, 19, 12, 12);
            break;
        
        default:
            break;
    }
    
    // Clear the separator inset at the left, making the separators go full width
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = false;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertController *alertController;
    
    switch (indexPath.item) {
        case 0:
            [[Mixpanel sharedInstance] track:kMixpanelAction_aboutLIT_Settings properties:nil];
            [self performSegueWithIdentifier:kAboutSegueIdentifier sender:self];
            break;
            
        case 1:
            [[Mixpanel sharedInstance] track:kMixpanelAction_FAQ_Settings properties:nil];
            [self performSegueWithIdentifier:kFAQSegueIdentifier sender:self];
            break;
            
        case 2:
            [[Mixpanel sharedInstance] track:kMixpanelAction_feedback_Settings properties:nil];
            [self performSegueWithIdentifier:kGiveFeedbackSegueIdentifier sender:self];
            break;
            
        case 3:
            [[Mixpanel sharedInstance] track:kMixpanelAction_termsOfService_Settings properties:nil];
            self.tappedTOS = NO;
            [self performSegueWithIdentifier:kTermsOfServiceSegueIdentifier sender:self];
            break;
            
        case 4:
            [[Mixpanel sharedInstance] track:kMixpanelAction_termsOfService_Settings properties:nil];
            self.tappedTOS = YES;
            [self performSegueWithIdentifier:kTermsOfServiceSegueIdentifier sender:self];
            break;
            
        {case 5:
            [[Mixpanel sharedInstance] track:kMixpanelAction_logout_Settings properties:nil];
            
            alertController = [UIAlertController alertControllerWithTitle:@"Logout"
                                                                   message:@"Are you sure you want to logout? You will need to log in back again to continue using your keyboards."
                                                            preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [[PFUser logOutInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                    if (task.error) {
                        JGProgressHUD *hud = [LITProgressHud createHudWithMessage:@"Error"];
                        [LITProgressHud changeStateOfHUD:hud
                                                      to:kLITHUDStateError
                                             withMessage:@"Error logging you out"];
                        [hud showInView:self.view animated:YES];
                    } else {
                        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        [[[UIApplication sharedApplication].windows objectAtIndex:0] setRootViewController:                        [mainStoryboard instantiateInitialViewController]];
                    }
                    return nil;
                }];
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
            break;}
            
        default:
            break;
    }
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

#pragma mark - Edit profile
- (void)editPictureAction:(UIButton *)button
{
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


#pragma mark Actions

- (void)linkTwitterAction:(UIButton *)button {
    
    [[Mixpanel sharedInstance] track:kMixpanelAction_twitterLink_Settings properties:nil];
    
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
    
    [[Mixpanel sharedInstance] track:kMixpanelAction_facebookLink_Settings properties:nil];
    
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

-(void) backToPreviousSlide {
    [[Mixpanel sharedInstance] track:kMixpanelAction_homeToFeed properties:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

# pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:kTermsOfServiceSegueIdentifier]) {
        
        LITTermsOfServiceViewController *tosController = (LITTermsOfServiceViewController *)[segue destinationViewController];
        
        if(self.tappedTOS){
            [tosController setMode:LITTermsOfServiceModeTOS];
        }
        else {
            [tosController setMode:LITTermsOfServiceModePrivacyPolicy];
        }
    }
}


@end
