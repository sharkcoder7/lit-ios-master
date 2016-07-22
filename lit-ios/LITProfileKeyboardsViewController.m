//
//  LITProfileKeyboardsViewController.m
//  lit-ios
//
//  Created by ioshero on 21/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITProfileKeyboardsViewController.h"
#import "ParseGlobals.h"
#import "LITTheme.h"
#import "LITProgressHud.h"
#import "LITKeyboard.h"
#import "LITKeyboardTableViewCell.h"
#import "UIViewController+LITKeyboardCellConfigurator.h"
#import "LITKeyboardInstallerHelper.h"
#import "LITSoundbite.h"
#import "LITDub.h"
#import "LITLyric.h"
#import "LITProfileViewController.h"
#import "LITKBSoundbiteCollectionViewCell.h"
#import "LITKBDubCollectionViewCell.h"
#import "LITKBLyricCollectionViewCell.h"
#import <DownloadButton/UIButton+PKDownloadButton.h>
#import <DownloadButton/UIImage+PKDownloadButton.h>
#import <Parse/PFQuery.h>
#import <ParseUI/PFImageView.h>
#import <DateTools/DateTools.h>
#import <Bolts/Bolts.h>
#import <objc/runtime.h>
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"


static void *kRemoveIndexPathPropertyKey;
@interface UIButton (IndexPathSave)

@property (assign, nonatomic) NSIndexPath *removeIndexPath;

@end

@implementation UIButton (IndexPathSave)

- (void)setRemoveIndexPath:(NSIndexPath *)indexPath
{
    objc_setAssociatedObject(indexPath, kRemoveIndexPathPropertyKey, indexPath, OBJC_ASSOCIATION_ASSIGN);
}

- (NSIndexPath *)removeIndexPath
{
    return objc_getAssociatedObject(self, kRemoveIndexPathPropertyKey);
}
@end

@interface LITProfileKeyboardsViewController ()

@property (strong, nonatomic) JGProgressHUD *hud;
@property BOOL firstTime;
@property (strong, nonatomic) UIView *optionsPresentationView;
@property (strong, nonatomic) UITableView *optionsTableView;

@property (assign, nonatomic) NSUInteger editingKeyboardSection;

@property (assign, nonatomic) NSInteger kbListUpdateCounter;

@property (strong, nonatomic) NSMutableDictionary *currentDownloadProperties;
@property (assign, nonatomic) CGRect originalDownloadButtonFrame;
@property (assign, nonatomic) CGRect originalStopDownloadButtonFrame;
@property (assign, nonatomic) CGRect originalStopButtonFrame;

@end

@implementation LITProfileKeyboardsViewController

@synthesize installedKeyboards = _installedKeyboards;

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        self.currentDownloadProperties = [NSMutableDictionary new];
        self.parseClassName = @"keyboard";
        self.firstTime = YES;
        self.shouldShowSearch = NO;
        self.objectsPerPage = 10;
        self.kbListUpdateCounter = 0;
        _editingKeyboardSection = -1;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.user == [PFUser currentUser])
        [self.delegate reloadUserInstalledKeyboards:self.parent];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
}



#pragma mark  - PFQueryTableViewController

- (PFQuery *)queryForCollection
{
    PFQuery *query = [super queryForCollection];
    NSAssert(self.installedKeyboards, @"Installed keyboards must be set before this is called");
    
    [query whereKey:@"objectId" containedIn:[self.installedKeyboards valueForKey:@"objectId"]];
    
    return query;
}

- (void)objectsDidLoad:(nullable NSError *)error
{
    [super objectsDidLoad:error];
    
    if([self.objects count] != [self.installedKeyboards count]) {
        [self.collectionView reloadData];
    }
    
    if(self.kbListUpdateCounter > 0){
        if (self.hud) {
            [self.hud dismiss];
            self.hud = nil;
        }
    }
    self.kbListUpdateCounter++;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if(self.objects && self.firstTime){
        self.hud = [LITProgressHud createHudWithMessage:@"Loading keyboards..."];
        [self.hud showInView:self.view];
        self.firstTime = NO;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
 {
     return [super tableView:tableView numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.optionsTableView) {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    } else {
        if (indexPath.row >= [[[self.objects firstObject] objectForKey:kKeyboardInstallationsKeyboardsKey] count]) {
            return 50.0f;
        } else return kLITKeyboardCellHeight;
    }
}

#pragma mark - UICollectionViewDataSource

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view = [super collectionView:collectionView
                                 viewForSupplementaryElementOfKind:kind
                                                       atIndexPath:indexPath];
    if (indexPath.section >= [[[self.objects firstObject] objectForKey:kKeyboardInstallationsKeyboardsKey] count] - 1) {
        return view;
    }
    
    LITKeyboard *keyboard = (LITKeyboard *)[self objectAtIndexPath:indexPath];
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        LITKeyboardHeaderView *headerView = (LITKeyboardHeaderView *)view;
        
        NSInteger originalCounter = [[keyboard valueForKey:kLITKeyboardLikesKey] integerValue];
        [headerView.likesLabel setText:[NSString stringWithFormat:@"%ld",(long)originalCounter]];
        
        if(self.user != [PFUser currentUser]){
            [headerView.downloadButton setTag:indexPath.section];
            [headerView.downloadButton setDelegate:self];
            
            NSValue *keyboardKey = [NSValue valueWithNonretainedObject:keyboard];
            
            // If we don't have the mapping set yet, we generate the download buttons attending to Parse data
            if([self.keyboardInstallationsMapping count] < [self.objects count]){
                [[LITKeyboardInstallerHelper checkKeyboardStatus:keyboard] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
                    [self configureButton:headerView.downloadButton
                       withKeyboardStatus:[task.result integerValue]];
                    
                    // Show the button only to install, not to remove, as that is
                    // managed from the user's own profile view
                    if([task.result integerValue] == LITKeyboardStatusInstalled){
                        [headerView.downloadButton setHidden:YES];
                    }
                    else {
                        [headerView.downloadButton setHidden:NO];
                    }
                    
                    return nil;
                }];
            }
            // If the mapping is ready, we use it to avoid loading times
            else {
                [self configureButton:headerView.downloadButton
                   withKeyboardStatus:[[self.keyboardInstallationsMapping objectForKey:keyboardKey] integerValue]];
                
                // Show the button only to install, not to remove, as that is
                // managed from the user's own profile view
                if([[self.keyboardInstallationsMapping objectForKey:keyboardKey] integerValue] == LITKeyboardStatusInstalled){
                    [headerView.downloadButton setHidden:YES];
                }
                else {
                    [headerView.downloadButton setHidden:NO];
                }
            }
        }
        else {
            [headerView.downloadButton setHidden:YES];
        }
        
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        LITKeyboardFooterView *footerView = (LITKeyboardFooterView *)view;
        [footerView.optionsButton setHidden:YES];
                
        if(keyboard.user == [PFUser currentUser] && self.user == [PFUser currentUser]){
            [footerView.editButton setTag:indexPath.section];
            [footerView.editButton addTarget:self
                                        action:@selector(editButtonTapped:)
                              forControlEvents:UIControlEventTouchUpInside];
            [footerView.editButton setHidden:NO];
            
            [footerView.removeButton setTag:indexPath.section];
            [footerView.removeButton addTarget:self
                                        action:@selector(deleteButtonTapped:)
                              forControlEvents:UIControlEventTouchUpInside];
            [footerView.removeButton setHidden:NO];
            
            // Uninstall + Edit
            footerView.labelLeadingConstraint.constant = 120;
            footerView.labelTrailingConstraint.constant = 120;
        }
        else if (keyboard.user == [PFUser currentUser] && self.user != [PFUser currentUser]) {
            /* EDIT YOUR OWN KEYBOARDS FOM OTHER USER PROFILE BLOCK
            [footerView.editButton setTag:indexPath.section];
            [footerView.editButton addTarget:self
                                      action:@selector(editButtonTapped:)
                            forControlEvents:UIControlEventTouchUpInside];
            [footerView.editButton setHidden:NO];
            [footerView.removeButton setHidden:YES];
             */
            [footerView.editButton setHidden:YES];
            [footerView.removeButton setHidden:YES];
            
            // Nothing
            footerView.labelLeadingConstraint.constant = 20;
            footerView.labelTrailingConstraint.constant = 20;
        }
        else if (keyboard.user != [PFUser currentUser] && self.user == [PFUser currentUser]) {
            [footerView.editButton setHidden:YES];
            
            [footerView.removeButton setTag:indexPath.section];
            [footerView.removeButton addTarget:self
                                        action:@selector(deleteButtonTapped:)
                              forControlEvents:UIControlEventTouchUpInside];
            [footerView.removeButton setHidden:NO];
            
            // Uninstall
            footerView.labelLeadingConstraint.constant = 70;
            footerView.labelTrailingConstraint.constant = 70;
        }
        else {
            [footerView.editButton setHidden:YES];
            [footerView.removeButton setHidden:YES];
            
            // Nothing
            footerView.labelLeadingConstraint.constant = 20;
            footerView.labelTrailingConstraint.constant = 20;
        }
        
        [footerView.titleLabel setNeedsUpdateConstraints];
    }

    return view;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - Getters Setters
- (void)setInstalledKeyboards:(NSArray *)installedKeyboards
{
    _installedKeyboards = installedKeyboards;
    [self loadObjects];
}

#pragma mark - Actions

- (void)deleteButtonTapped:(UIButton *)button
{
    [[Mixpanel sharedInstance] track:kMixpanelAction_uninstallKey_Profile properties:nil];
    
    LITKeyboard *targetKeyboard = self.objects[button.tag];
    NSString *targetKeyboardId = targetKeyboard.objectId;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:targetKeyboard.displayName
                                                                             message:@"Are you sure you want to uninstall the keyboard?"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive     handler:^(UIAlertAction *action) {
        [[LITKeyboardInstallerHelper removeKeyboard:targetKeyboard] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
            if (!task.error) {
                JGProgressHUD *hud = [LITProgressHud createHudWithMessage:@""];
                [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:@"Uninstalled"];
                [hud showInView:self.view animated:YES];
                if(hud != nil) [hud dismissAfterDelay:.8];
                NSMutableArray *newInstalledKeyboards = [NSMutableArray
                                                         arrayWithCapacity:[self.installedKeyboards count] - 1];
                [self.installedKeyboards
                 enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (![((LITKeyboard *)obj).objectId isEqualToString:targetKeyboardId]) {
                        [newInstalledKeyboards addObject:obj];
                    }
                }];
                self.installedKeyboards = [NSArray arrayWithArray:newInstalledKeyboards];
                ((LITProfileViewController *)self.parentViewController).installedKeyboards = self.installedKeyboards;
                [self loadObjects];
            } else {
                JGProgressHUD *hud = [LITProgressHud createHudWithMessage:@"Error"];
                [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError
                                     withMessage:@"Uninstall error"];
                [hud showInView:self.view animated:YES];
                if(hud != nil) [hud dismissAfterDelay:.8];
            }
            return nil;
        }];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"index path selected: %@", indexPath);
}

- (void)editButtonTapped:(UIButton *)button
{
    [[Mixpanel sharedInstance] track:kMixpanelAction_editKey_Profile properties:nil];
    
    NSInteger keyboardSection = button.tag;
    LITKeyboardFooterView *footerView;
    UIView *superView = button.superview;
    while (superView) {
        if ([superView isKindOfClass:[LITKeyboardFooterView class]]) {
            footerView = (LITKeyboardFooterView *)superView;
            break;
        }
        superView = superView.superview;
    }
    NSParameterAssert(footerView);
    
    if (keyboardSection == self.editingKeyboardSection) {
        [footerView.editButton setTitle:@"EDIT" forState:UIControlStateNormal];
        self.editingKeyboardSection = -1;
        for (LITKBBaseCollectionViewCell *cell in [self.collectionView visibleCells]) {
            UIButton *removeButton = [cell valueForKey:@"removeButton"];
            [removeButton setHidden:YES];
            [removeButton setEnabled:NO];
            if ([cell respondsToSelector:@selector(cellIcon)]) {
                [[cell valueForKey:@"cellIcon"] setHidden:NO];
            }
        }
        return;
    }
    self.editingKeyboardSection = keyboardSection;
    NSIndexPath *itemIndexPath;
    
    for (NSInteger item = 0; item < 6; item++) {
        itemIndexPath =[NSIndexPath
                                     indexPathForRow:item
                                     inSection:keyboardSection];
       LITKBBaseCollectionViewCell *collectionCell = (LITKBBaseCollectionViewCell *)[self.collectionView
                                                      cellForItemAtIndexPath:itemIndexPath];
        
        UIButton *removeButton = [collectionCell valueForKey:@"removeButton"];
        [removeButton setHidden:NO];
        [removeButton setEnabled:YES];
        if ([collectionCell respondsToSelector:@selector(cellIcon)]) {
            [[collectionCell valueForKey:@"cellIcon"] setHidden:YES];
        }
    }
    
    [footerView.editButton setTitle:@"SAVE" forState:UIControlStateNormal];
    
}

- (void)deleteActionDetectedOnCellAtIndexPathForCollectionView:(NSDictionary *)dictionary
{
    [self removeContentAtIndexPath:dictionary[kTouchDetectorIndexPathKey]];
}


- (void)removeContentAtIndexPath:(NSIndexPath *)itemIndexPath {
    
    NSAssert(itemIndexPath, @"Item index path cannot be nil at this point");
    
    NSInteger indexSection = [itemIndexPath section];
    
    LITKeyboard *keyboard = self.objects[indexSection];
    
    NSMutableArray *newKeyboardContents = [NSMutableArray arrayWithArray:keyboard.contents];
    [newKeyboardContents removeObjectAtIndex:itemIndexPath.row];
    keyboard.contents = newKeyboardContents;
    
    //[self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:itemIndexPath.section]];
    [self.collectionView reloadData];
 
    [keyboard saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"saved");
        } else {
            NSLog(@"error");
        }
    }];
}


#pragma mark - Helper
- (LITKeyboard *)reverseOrderKeyboardsInstallationObjectForIndexPath:(NSIndexPath *)indexPath
{
    return [[[[self.objects firstObject] objectForKey:kKeyboardInstallationsKeyboardsKey] reverseObjectEnumerator] allObjects][indexPath.section];
}

#pragma mark - PKDownloadButtonDelegate

- (void)downloadButtonTapped:(PKDownloadButton *)downloadButton
                currentState:(PKDownloadButtonState)state {
    
    LITKeyboard *targetKeyboard = self.objects[downloadButton.tag];
    UIAlertController *alertController;
    
    switch (state) {
        {case kPKDownloadButtonState_StartDownload:
            {
                [[Mixpanel sharedInstance] track:kMixpanelAction_installKeyboard properties:nil];
                
                NSLog(@"start download");
                self.originalDownloadButtonFrame = downloadButton.frame;
                self.originalStopDownloadButtonFrame = downloadButton.stopDownloadButton.frame;
                self.originalStopButtonFrame = downloadButton.stopDownloadButton.stopButton.frame;
                
                downloadButton.frame = CGRectMake(downloadButton.frame.origin.x+downloadButton.frame.size.width-26*2-7, downloadButton.frame.origin.y, 26*2+7, 26);
                
                downloadButton.stopDownloadButton.frame = downloadButton.frame;
                downloadButton.stopDownloadButton.stopButton.frame = downloadButton.frame;
                
                UIView *fullButton = downloadButton;
                UIView *stopButton = downloadButton.stopDownloadButton;
                
                NSDictionary *bindings = NSDictionaryOfVariableBindings(fullButton, stopButton);
                NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[stopButton]" options:0 metrics:nil views:bindings];
                [fullButton addConstraints:constraints];
                
                downloadButton.state = kPKDownloadButtonState_Pending;
                
                LITKeyboardInstallationProgressBlock progressBlock = ^(CGFloat progress) {
                    NSLog(@"Download progress: %f", progress);
                    if (downloadButton.state == kPKDownloadButtonState_Pending) {
                        downloadButton.state = kPKDownloadButtonState_Downloading;
                    }
                    [downloadButton.stopDownloadButton setProgress:progress];
                };
                
                BFCancellationTokenSource *cancelSource = [BFCancellationTokenSource cancellationTokenSource];
                
                [self.currentDownloadProperties setObject:cancelSource forKey:targetKeyboard.objectId];
                
                [[LITKeyboardInstallerHelper installKeyboard:targetKeyboard fromViewController:self withProgressBlock:progressBlock andCancellationToken:cancelSource.token]
                 continueWithExecutor:[BFExecutor mainThreadExecutor]
                 withBlock:^id(BFTask *task) {
                     if (task.isCancelled) {
                         NSLog(@"Installation was cancelled");
                         downloadButton.frame = self.originalDownloadButtonFrame;
                         downloadButton.stopDownloadButton.frame = self.originalStopDownloadButtonFrame;
                         downloadButton.stopDownloadButton.stopButton.frame = self.originalStopButtonFrame;
                         [[LITKeyboardInstallerHelper removeKeyboard:targetKeyboard] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                             if (!task.error) {
                                 NSLog(@"Installation successfully aborted");
                                 JGProgressHUD *hud = [LITProgressHud createHudWithMessage:@"Cancelled"];
                                 [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:@"Cancelled"];
                                 [hud showInView:self.view animated:YES];
                                 if(hud != nil) [hud dismissAfterDelay:.8];
                             } else {
                                 NSLog(@"Error reverting installation: %@", task.error);
                             }
                             return nil;
                         }];
                     } else if (!task.error) {
                         downloadButton.frame = self.originalDownloadButtonFrame;
                         downloadButton.stopDownloadButton.frame = self.originalStopDownloadButtonFrame;
                         downloadButton.stopDownloadButton.stopButton.frame = self.originalStopButtonFrame;
                         JGProgressHUD *hud = [LITProgressHud createHudWithMessage:@"Installed"];
                         [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:@"Installed"];
                         [hud showInView:self.view animated:YES];
                         if(hud != nil) [hud dismissAfterDelay:.8];
                         
                         NSValue *keyboardKey = [NSValue valueWithNonretainedObject:targetKeyboard];
                         [self.keyboardInstallationsMapping setObject:@(LITKeyboardStatusInstalled) forKey:keyboardKey];
                         [self configureButton:downloadButton withKeyboardStatus:LITKeyboardStatusInstalled];
                         
                         [downloadButton setHidden:YES];
                     } else {
                         downloadButton.frame = self.originalDownloadButtonFrame;
                         downloadButton.stopDownloadButton.frame = self.originalStopDownloadButtonFrame;
                         downloadButton.stopDownloadButton.stopButton.frame = self.originalStopButtonFrame;
                         JGProgressHUD *hud = [LITProgressHud createHudWithMessage:@"Error"];
                         if (task.error.code == 20) {
                             [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError
                                                  withMessage:task.error.localizedDescription];
                         } else {
                             [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError
                                                  withMessage:@"Install error"];
                         }
                         
                         [self configureButton:downloadButton withKeyboardStatus:LITKeyboardStatusInstalled];
                         [hud showInView:self.view animated:YES];
                         if(hud != nil) [hud dismissAfterDelay:.8];
                     }
                     return nil;
                 }];
            }
            //Start download
            break;
        }
        {case kPKDownloadButtonState_Pending:
            NSLog(@"pending");
            downloadButton.state = kPKDownloadButtonState_StartDownload;
            BFCancellationTokenSource *cancelSource = [self.currentDownloadProperties
                                                       objectForKey:targetKeyboard.objectId];
            [cancelSource cancel];
            [self.currentDownloadProperties removeObjectForKey:targetKeyboard.objectId];
            break;
        }
        {case kPKDownloadButtonState_Downloading:
            NSLog(@"downloading");
            
            downloadButton.frame = self.originalDownloadButtonFrame;
            downloadButton.stopDownloadButton.frame = self.originalStopDownloadButtonFrame;
            downloadButton.stopDownloadButton.stopButton.frame = self.originalStopButtonFrame;
            
            downloadButton.state = kPKDownloadButtonState_StartDownload;
            BFCancellationTokenSource *cancelSource = [self.currentDownloadProperties
                                                       objectForKey:targetKeyboard.objectId];
            [cancelSource cancel];
            [self.currentDownloadProperties removeObjectForKey:targetKeyboard.objectId];
            break;
        }
        {case kPKDownloadButtonState_Downloaded:
            
            NSLog(@"downloaded");
            alertController = [UIAlertController alertControllerWithTitle:targetKeyboard.displayName
                                                                  message:@"Are you sure you want to uninstall the keyboard?"
                                                           preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive     handler:^(UIAlertAction *action) {
                
                [[Mixpanel sharedInstance] track:kMixpanelAction_removeKeyboard properties:nil];
                
                downloadButton.state = kPKDownloadButtonState_StartDownload;
                [[LITKeyboardInstallerHelper removeKeyboard:targetKeyboard] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                    if (!task.error) {
                        JGProgressHUD *hud = [LITProgressHud createHudWithMessage:@""];
                        [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:@"Uninstalled"];
                        [hud showInView:self.view animated:YES];
                        if(hud != nil) [hud dismissAfterDelay:.8];
                        
                        NSValue *keyboardKey = [NSValue valueWithNonretainedObject:targetKeyboard];
                        [self.keyboardInstallationsMapping setObject:@(LITKeyboardStatusUninstalled) forKey:keyboardKey];
                        [self configureButton:downloadButton withKeyboardStatus:LITKeyboardStatusUninstalled];
                        
                        [downloadButton sizeToFit];
                    } else {
                        JGProgressHUD *hud = [LITProgressHud createHudWithMessage:@"Error"];
                        [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError
                                             withMessage:@"Uninstall error"];
                        [self configureButton:downloadButton withKeyboardStatus:LITKeyboardStatusInstalled];
                        [hud showInView:self.view animated:YES];
                        if(hud != nil) [hud dismissAfterDelay:.8];
                    }
                    return nil;
                }];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
            break;}
        default:
            NSAssert(NO, @"Unsupported state for download button");
            break;
    }
}

- (void)configureButton:(PKDownloadButton *)downloadButton withKeyboardStatus:(LITKeyboardStatus)status
{
    [downloadButton.downloadedButton cleanDefaultAppearance];
    [downloadButton.startDownloadButton cleanDefaultAppearance];
    [downloadButton.stopDownloadButton.stopButton cleanDefaultAppearance];
    
    [downloadButton.downloadedButton setTitle:@"" forState:UIControlStateNormal];
    [downloadButton.downloadedButton setTitle:@"" forState:UIControlStateHighlighted];
    [downloadButton.startDownloadButton setTitle:@"" forState:UIControlStateNormal];
    [downloadButton.startDownloadButton setTitle:@"" forState:UIControlStateHighlighted];
    [downloadButton.stopDownloadButton.stopButton setTitle:@"" forState:UIControlStateNormal];
    [downloadButton.stopDownloadButton.stopButton setTitle:@"" forState:UIControlStateHighlighted];
    
    [downloadButton.downloadedButton setImage:nil forState:UIControlStateNormal];
    [downloadButton.downloadedButton setImage:nil forState:UIControlStateHighlighted];
    [downloadButton.startDownloadButton setImage:nil forState:UIControlStateNormal];
    [downloadButton.startDownloadButton setImage:nil forState:UIControlStateHighlighted];
    
    switch (status) {
        case LITKeyboardStatusInstalled:
            [downloadButton.downloadedButton setTitle:@"  REMOVE  " forState:UIControlStateNormal];
            [downloadButton.downloadedButton setBackgroundImage:[UIImage buttonBackgroundWithColor:[UIColor redColor]] forState:UIControlStateNormal];
            [downloadButton.downloadedButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [downloadButton.downloadedButton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:15.0f]];
            [downloadButton setState:kPKDownloadButtonState_Downloaded];
            break;
        case LITKeyboardStatusNonInstalled:
            [downloadButton.downloadedButton setTitle:@"  REMOVE  " forState:UIControlStateNormal];
            [downloadButton.downloadedButton setBackgroundImage:[UIImage buttonBackgroundWithColor:[UIColor redColor]] forState:UIControlStateNormal];
            [downloadButton.downloadedButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [downloadButton.startDownloadButton setImage:nil
                                                forState:UIControlStateNormal];
            [downloadButton.startDownloadButton setBackgroundImage:[UIImage buttonBackgroundWithColor:[UIColor lit_lightOrangishColor]]
                                                          forState:UIControlStateNormal];
            [downloadButton.startDownloadButton setTitle:@"  INSTALL  " forState:UIControlStateNormal];
            downloadButton.startDownloadButton.titleLabel.textAlignment = NSTextAlignmentLeft;
            [downloadButton.startDownloadButton setTitleColor:[UIColor lit_lightOrangishColor] forState:UIControlStateNormal];
            [downloadButton.startDownloadButton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:15.0f]];
            
            // Align the text to the center side of the button
            downloadButton.startDownloadButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            
            [downloadButton setState:kPKDownloadButtonState_StartDownload];
            break;
        case LITKeyboardStatusUninstalled:
            [downloadButton.downloadedButton setTitle:@"  REMOVE  " forState:UIControlStateNormal];
            [downloadButton.downloadedButton setBackgroundImage:[UIImage buttonBackgroundWithColor:[UIColor redColor]] forState:UIControlStateNormal];
            [downloadButton.downloadedButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [downloadButton.startDownloadButton setImage:[UIImage imageNamed:@"icloudDownload"]
                                                forState:UIControlStateNormal];
            
            // Align the image to the right side of the button
            downloadButton.startDownloadButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            
            [downloadButton setState:kPKDownloadButtonState_StartDownload];
            break;
            
        default:
            break;
    }
    
    downloadButton.stopDownloadButton.frame = CGRectMake(downloadButton.stopDownloadButton.frame.origin.x,
                                                         downloadButton.stopDownloadButton.frame.origin.y,
                                                         10,
                                                         10);
    
    //downloadButton.stopDownloadButton.stopButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    [downloadButton setContentMode:UIViewContentModeRight];
    [downloadButton sizeToFit];
}


@end
