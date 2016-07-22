//
//  LITTaggingCollectionViewController.m
//  lit-ios
//
//  Created by ioshero on 20/07/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITTaggingCollectionViewController.h"
#import "LITTagCollectionViewCell.h"
#import "LITSoundbite.h"
#import "LITLyric.h"
#import "LITDub.h"
#import "LITTaggableContent.h"
#import "LITKeyboard.h"
#import "LITEmojiUtils.h"
#import "LITProgressHud.h"
#import "LITTheme.h"
#import "UIView+GradientBackground.h"
#import "LITAddToKeyboardViewController.h"
#import "LITCongratsKeyboardViewController.h"
#import "LITProgressHud.h"
#import "LITTaggingTutorialViewController.h"
#import "ParseGlobals.h"
#import <Bolts/BFTask.h>
#import <Parse/PFRelation.h>
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"

/*
NSString *const kLITPresentTagsForLyricSegueIdentifier = @"LITPresentTagsForLyricSegue";
NSString *const kLITPresentTagsForDubSegueIdentifier = @"LITPresentTagsForDubSegue";
NSString *const kLITPresentTagsForSoundbiteSegueIdentifier = @"LITPresentTagsForSoundbiteSegue";
*/
 
@interface LITTaggingCollectionViewController () <LITAddToKeyboardViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
    float screenWidth;
    float marginSize;
    float topBottomMargin;
    float cellSize;
}

@property (strong, nonatomic) NSString *emojiString;
@property (strong, nonatomic) NSArray *emojis;
@property (weak, nonatomic) id <LITAddToKeyboardViewControllerDelegate> delegate;

@end

@implementation LITTaggingCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.navigationItem.title = @"Emoji Tagging";
    
    self.emojis = [LITEmojiUtils allEmojis];
    
    self.collectionView.allowsMultipleSelection = YES;
    self.emojiString = [NSString string];
    
    UIBarButtonItem *uploadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    
    self.navigationItem.rightBarButtonItem = uploadButton;
    
    //[self.navigationItem setHidesBackButton:YES];
    
    //
    
    screenWidth = [[UIScreen mainScreen] bounds].size.width;
    marginSize = 9.0f;
    topBottomMargin = 16.0f;
    cellSize = (screenWidth-marginSize*5)/4; // 4 cells per row, 5 spaces per row
    
    //
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = marginSize;
    layout.minimumLineSpacing = marginSize;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [layout setItemSize:CGSizeMake(cellSize, cellSize)];
    [self.collectionView setCollectionViewLayout:layout];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    
    // If this is the first time tagging an element, we show the "tutorial"
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"taggingTutorialCompleted"]){
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"taggingTutorialCompleted"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        LITTaggingTutorialViewController *taggingTutorialVC = [self.storyboard   instantiateViewControllerWithIdentifier:@"taggingTutorialVC"];
        [self.navigationController presentViewController:taggingTutorialVC animated:YES completion:nil];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.view setupGradientBackground];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [[Mixpanel sharedInstance] track:kMixpanelAction_emojiSelected_TagView properties:nil];
    
    self.emojiString = [self.emojiString stringByAppendingString:self.emojis[indexPath.row]];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.emojiString = [self.emojiString stringByReplacingOccurrencesOfString:self.emojis[indexPath.row] withString:@""];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(topBottomMargin,marginSize,topBottomMargin,marginSize);
}

#pragma mark - UICollectionViewDataSource


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.emojis count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LITTagCollectionViewCell *tagCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kLITTagCollectionViewCellidentifier forIndexPath:indexPath];
    NSAssert([tagCell isKindOfClass:[LITTagCollectionViewCell class]], @"The cell must be of class LITTagCollectionViewCell");

    [[tagCell contentView] setFrame:[tagCell bounds]];
    [[tagCell contentView] setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    tagCell.emojiLabel.text = self.emojis[indexPath.row];
    return tagCell;
}

#pragma mark - Actions
- (void)doneButtonPressed:(UIBarButtonItem *)button
{
    if([self.emojiString length] == 0){
        JGProgressHUD *hud = [LITProgressHud createHudWithMessage:@""];
        [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError withMessage:[NSString stringWithFormat:@"%@\n%@\n%@",@"You need to tag",@"your content with",@"at least 1 emoji!"]];
        [hud showInView:self.view];
        [hud dismissAfterDelay:1.5];
        return;
    }
    
    [[Mixpanel sharedInstance] track:kMixpanelAction_uploadContent_TagView properties:nil];
    
    self.content.tags = self.emojiString;
    LITAddToKeyboardViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:kLITAddToKeyboardViewControllerStoryboardIdentifier];
    viewController.object = self.content;
    viewController.callingController = self;
    viewController.delegate = self;
    viewController.showsUploadButton = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - LITAddToKeyboardViewControllerDelegate
- (void)keyboardsController:(LITAddToKeyboardViewController *)controller didSelectKeyboard:(LITKeyboard *)keyboard forObject:(PFObject *)object showCongrats:(BOOL)show inViewController:viewController;
{
    [self.navigationController popViewControllerAnimated:YES];
    JGProgressHUD *hud = [LITProgressHud createHudWithMessage:@"Saving..."];
    [hud showInView:self.view];
    
    void(^finishBlock)(BOOL, NSError *) = ^(BOOL succeeded, NSError *__nullable error) {
        if (error) {
            [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError withMessage:@"Error while saving. Please try again."];
            [hud dismissAfterDelay:2.0];
        } else {
            if (show) {
                LITCongratsKeyboardViewController *congratsVC = [self.storyboard   instantiateViewControllerWithIdentifier:@"congratsVC"];
                [congratsVC assignKeyboard:keyboard];
                [congratsVC prepareControls];
                [self.navigationController presentViewController:congratsVC animated:YES completion:nil];
            }
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
    };
    if (!keyboard) {
        [object saveInBackgroundWithBlock:finishBlock];
    } else {
        NSLog(@"Selected keyboard");
        [self saveKeyboardInBackground:keyboard withObject:object andSaveBlock:finishBlock];
    }
}

#pragma mark - Object Saving
- (void)saveKeyboardInBackground:(LITKeyboard *)keyboard withObject:(PFObject *)object andSaveBlock:(PFBooleanResultBlock)saveBlock
{
    [keyboard addObject:object forKey:kLITKeyboardContentsKey];
    [keyboard saveInBackgroundWithBlock:saveBlock];
}

#pragma mark - UITextField validation
- (void)alertTextFieldDidChange:(UITextField *)sender {
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    static UIAlertAction *okAction;
    if (!okAction) {
        okAction = [alertController.actions objectAtIndex:1];
        [okAction setValue:[UIColor lit_coolGreyColor] forKey:@"titleTextColor"];
    }
    if (alertController) {
        UITextField *nameTextfield = alertController.textFields.firstObject;
        okAction.enabled = nameTextfield.text.length > 4;
    }
}



@end
