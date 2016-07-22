//
//  LITAddToKeyboardTableViewController.m
//  lit-ios
//
//  Created by ioshero on 18/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITAddToKeyboardViewController.h"
#import "LITAddToKeyboardTableViewCell.h"
#import "LITKeyboard.h"
#import "LITCongratsKeyboardViewController.h"
#import "UIView+GradientBackground.h"
#import "LITTheme.h"
#import "LITKeyboardInstallerHelper.h"
#import "LITProfileViewController.h"
#import "ParseGlobals.h"
#import <Parse/PFQuery.h>
#import <Bolts/Bolts.h>
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"

NSString *const kLITAddToKeyboardViewControllerStoryboardIdentifier = @"LITAddToKeyboardViewController";

@interface LITAddToKeyboardViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *keyboards;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) PFObject *keyboardInstallationsObject;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation LITAddToKeyboardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.activityIndicator startAnimating];
    [self.activityIndicator setHidesWhenStopped:YES];
    [[[[PFQuery queryWithClassName:kKeyboardInstallationsClassName] includeKey:kKeyboardInstallationsKeyboardsKey] whereKey:kKeyboardInstallationsUserKey equalTo:[PFUser currentUser]]
     getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
         self.keyboardInstallationsObject = object;
         self.keyboards = [[self.keyboardInstallationsObject objectForKey:@"keyboards"] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(LITKeyboard *keyboard, NSDictionary *bindings) {
             NSAssert([keyboard isKindOfClass:[LITKeyboard class]],
                      @"keyboard must be of class LITKeyboard");
             return ![keyboard.objectId isEqualToString:kLITKeyboardObjectId];
         }]];

         [self.activityIndicator stopAnimating];
         [self.tableView reloadData];
    }];
    
    [self.view setupGradientBackground];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.addButton setTitleColor:[UIColor lit_lightOrangishColor] forState:UIControlStateNormal];
    [self.addButton setHidden:!self.showsUploadButton];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.keyboards count] >= kLITMaxKeyboardsNumber ? : [self.keyboards count] + 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if([self.callingController class] != [LITProfileViewController class]){
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LITAddToKeyboardTableViewCell *theCell = [self.tableView dequeueReusableCellWithIdentifier:kLITAddToKeyboardTableViewCellIdentifier forIndexPath:indexPath];
    
    if (indexPath.row == self.keyboards.count) {
        [theCell.titleLabel setText:@"New Keyboard"];
        [theCell.titleLabel setTextColor:[UIColor lit_lightOrangishColor]];
        [theCell.labelContainerView setBackgroundColor:[UIColor whiteColor]];
    } else {
        [theCell.titleLabel setText:[self.keyboards[indexPath.row] objectForKey:kLITKeyboardDisplayNameKey]];
        BOOL alreadyAdded = [((LITKeyboard *)self.keyboards[indexPath.row]).contents containsObject:self.object];
        BOOL isFull = [((LITKeyboard *)self.keyboards[indexPath.row]).contents count] == kLITKeyboardMaxItemCount;
        BOOL isOwner = [((LITKeyboard *)self.keyboards[indexPath.row]).user.objectId
                        isEqualToString:[PFUser currentUser].objectId];
        if ( alreadyAdded || isFull || !isOwner) {
//            [theCell.titleLabel setTextColor:[UIColor grayColor]];
            if (!isOwner) {
                [theCell.titleLabel setText:[NSString stringWithFormat:@"%@ (Not yours)", theCell.titleLabel.text]];
            }
            else if (alreadyAdded) {
                [theCell.titleLabel setText:[NSString stringWithFormat:@"%@ (Keyboard Full)", theCell.titleLabel.text]];
            } else if (isFull) {
                [theCell.titleLabel setText:[NSString stringWithFormat:@"%@ (Full)", theCell.titleLabel.text]];
            }
            [theCell.titleLabel setTextColor:[UIColor colorWithWhite:0.0f alpha:0.25f]];
            [theCell.labelContainerView.layer setBorderColor:[UIColor colorWithWhite:0.0f alpha:0.2f].CGColor];
            [theCell setUserInteractionEnabled:NO];
        } else {
            [theCell.titleLabel setTextColor:[UIColor colorWithWhite:1.0f alpha:1.0f]];
            [theCell.labelContainerView.layer setBorderColor:[UIColor colorWithWhite:1.0f alpha:.9f].CGColor];
        }
        [theCell.labelContainerView setBackgroundColor:[UIColor clearColor]];
    }
    return theCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0 ? kLITAddToKeyboardCellHeight : 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.keyboards.count) {
        //Save to new keyboard
        UIAlertController *newKeyboardController = [UIAlertController alertControllerWithTitle:@"Insert name" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [newKeyboardController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Name your new keyboard";
            [textField addTarget:self
                          action:@selector(alertTextFieldDidChange:)
                forControlEvents:UIControlEventEditingChanged];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [cancelAction setValue:[UIColor lit_darkOrangishColor] forKey:@"titleTextColor"];
        
        [newKeyboardController addAction:cancelAction];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            LITKeyboard *newKeyboard = [LITKeyboard object];
            UITextField *nameTextField = [newKeyboardController.textFields firstObject];
            [newKeyboard setDisplayName:nameTextField.text];
            [newKeyboard setUser:[PFUser currentUser]];
            
            /*
            [[LITKeyboardInstallerHelper installKeyboard:newKeyboard] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                if (!task.error) {
                    if (self.delegate) {
                        self.navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                        [self.delegate keyboardsController:self didSelectKeyboard:newKeyboard forObject:self.object showCongrats:YES];
                    }
                }
                return nil;
            }];
            */
            
            
            /*
             [[newKeyboard pinInBackground] continueWithSuccessBlock:^id(BFTask<NSNumber *> *task) {
             return [[LITKeyboardInstallerHelper installKeyboard:newKeyboard] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
             if (!task.error) {
             if (self.delegate) {
             self.navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
             [self.delegate keyboardsController:self didSelectKeyboard:newKeyboard forObject:self.object showCongrats:YES];
             }
             }
             return nil;
             }];
             }];
            */
            
            [[Mixpanel sharedInstance] track:kMixpanelAction_newKeyboard_AddToKey properties:nil];
            
            if (self.delegate) {
                self.navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                [self.delegate keyboardsController:self didSelectKeyboard:newKeyboard forObject:self.object showCongrats:YES inViewController:self.callingController];
            }
        }];
        
        [newKeyboardController addAction:okAction];
        [self presentViewController:newKeyboardController animated:YES completion:nil];
        
    } else {
        if (self.delegate) {
            
            [[Mixpanel sharedInstance] track:kMixpanelAction_keyboardSelected_AddToKey properties:nil];
            
            [self.delegate keyboardsController:self didSelectKeyboard:self.keyboards[indexPath.row] forObject:self.object showCongrats:NO inViewController:self.callingController];
        }
    }
}

- (IBAction)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addButtonPressed:(id)sender
{
    [[Mixpanel sharedInstance] track:kMixpanelAction_addToDatabase_AddToKey properties:nil];
    
    if (self.delegate) {
        [self.delegate keyboardsController:self didSelectKeyboard:nil forObject:self.object showCongrats:NO inViewController:self.callingController];
    }
}

#pragma mark - UITextField validation
- (void)alertTextFieldDidChange:(UITextField *)sender {
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    static UIAlertAction *okAction;
    if (!okAction) {
        okAction = [alertController.actions objectAtIndex:1];
    }
    if (alertController) {
        UITextField *nameTextfield = alertController.textFields.firstObject;
        okAction.enabled = nameTextfield.text.length > 4;
    }
}

@end
