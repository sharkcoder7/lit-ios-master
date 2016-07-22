//
//  LITTaggingViewController.m
//  lit-ios
//
//  Created by Antonio Losada on 16/11/15.
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import "LITTaggingViewController.h"
#import "LITAddToKeyboardViewController.h"
#import "LITCongratsKeyboardViewController.h"
#import "LITProgressHud.h"
#import "LITKeyboard.h"
#import "LITTaggableContent.h"
#import "ParseGlobals.h"
#import "UIView+GradientBackground.h"
#import "LITTheme.h"
#import <AFViewShaker/AFViewShaker.h>

#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"

NSString *const kLITtagCellIdentifier = @"LITtagCell";

NSString *const kLITPresentTagsForDubSegueIdentifier = @"LITPresentTagsForDubSegue";
NSString *const kLITPresentTagsForSoundbiteSegueIdentifier = @"LITPresentTagsForSoundbiteSegue";

long const maxTags = 3;

@interface LITTaggingViewController () <LITAddToKeyboardViewControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) id <LITAddToKeyboardViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *tagTextField;
@property (strong, nonatomic) NSString *storedTagString;
@property (strong, nonatomic) NSMutableArray *tagStrings;

@property (weak, nonatomic) IBOutlet UITableView *tagTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (assign, nonatomic) BOOL tableViewIsShortened;

@property (strong, nonatomic) NSMutableArray *retrievedTags;
@property (strong, nonatomic) NSMutableArray *filteredRetrievedTags;

@property (weak, nonatomic) IBOutlet UILabel *warningLabel;

@end

@implementation LITTaggingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.storedTagString = @"";
    self.retrievedTags = [NSMutableArray new];
    self.filteredRetrievedTags = [NSMutableArray new];
    self.tagStrings = [NSMutableArray new];
    
    
    self.tagTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter tag and hit return" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:.5]}];
    
    [self.warningLabel setHidden:YES];
    [self.tagTableView setHidden:YES];
    
    
    // Listen to keyboard (dis)appearing, so the scroll changes its size
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.tableViewIsShortened = NO;
    
    // .--

    
    [self.view setupGradientBackgroundFromPoint:CGPointMake(0.0f, 0.0f)
                               andStartingColor:[UIColor lit_fadedOrangeLightColor]
                                        toPoint:CGPointMake(0.5f, 1.0f)
                                  andFinalColor:[UIColor lit_fadedOrangeDarkColor]];


    self.tagTableView.separatorColor = [UIColor whiteColor];
    self.tagTableView.estimatedRowHeight = 43.0f;
    self.tagTableView.rowHeight = UITableViewAutomaticDimension;

    
    // Tap the view to dismiss the keyboard
    /*
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(singleTapAction:)];
    [self.view addGestureRecognizer:singleFingerTap];
     */
    
    
    self.navigationItem.title = @"Add Three Tags";
    
    self.tagTextField.delegate = self;
    
    [self.tagTextField addTarget:self
                  action:@selector(tagTextFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    UIBarButtonItem *uploadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    
    [self.tagTextField becomeFirstResponder];
    
    self.navigationItem.rightBarButtonItem = uploadButton;
    
    [self.navigationController setNavigationBarHidden:NO];
    
    // Update the table
    self.tagTableView.delegate = self;
    self.tagTableView.dataSource = self;
    
    // Query one time and no more
    
    PFQuery *query = [PFQuery queryWithClassName:kTagClassName];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            for (PFObject *object in objects) {
                NSString *tagText = [object valueForKey:kTagTextKey];
                [self.retrievedTags addObject:tagText];
            }
        } else {
            NSLog(@"Error Retrieving Tags: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.view setupGradientBackground];
}

#pragma mark UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filteredRetrievedTags count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kLITtagCellIdentifier forIndexPath:indexPath];
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    for (UIView *subview in [cell.accessoryView subviews])
    {
        if(subview.tag == 987){
            if(indexPath.row >= [self.filteredRetrievedTags count]){
                ((UITextField*)subview).text = @"";
            }
            else{
                ((UITextField*)subview).text = [self.filteredRetrievedTags objectAtIndex:indexPath.row];
            }
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Only if the user taps a tag, we paste it in the tag string, replacing
    // what he was typing at the moment
    
    if(indexPath.row < [self.filteredRetrievedTags count]){
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"," options:NSRegularExpressionCaseInsensitive error:nil];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:self.tagTextField.text options:0 range:NSMakeRange(0, [self.tagTextField.text length])];
        
        if(numberOfMatches == 0){
            self.tagTextField.text = [NSString stringWithFormat:@"%@, ",[self.filteredRetrievedTags objectAtIndex:indexPath.row]];
        }
        else {
            
            NSMutableArray *inputTags = [[self.tagTextField.text componentsSeparatedByString:@","] mutableCopy];
            
            NSString *tagsUntilLast = @"";
            
            for(NSInteger i=0; i<[inputTags count]; i++){
                if(i != [inputTags count]-1){
                    tagsUntilLast = [tagsUntilLast stringByAppendingString:[NSString stringWithFormat:@"%@, ",[inputTags objectAtIndex:i]]];
                }
            }
            
            tagsUntilLast = [tagsUntilLast stringByAppendingString:[NSString stringWithFormat:@"%@",[self.filteredRetrievedTags objectAtIndex:indexPath.row]]];
            
            if(numberOfMatches < maxTags-1){
                tagsUntilLast = [tagsUntilLast stringByAppendingString:@", "];
            }
            
            self.tagTextField.text = tagsUntilLast;
        }
        
        //[self.tagTextField resignFirstResponder];
        [self.tagTableView setHidden:YES];
    }
}


#pragma mark - Actions
- (void)doneButtonPressed:(UIBarButtonItem *)button
{
    [self.tagTextField resignFirstResponder];
    [self.tagTableView setHidden:YES];
    
    // Create the tag array here by splitting the tag string
    self.tagStrings = [[self.tagTextField.text componentsSeparatedByString:@","] mutableCopy];

    if([self.tagStrings count] < maxTags){
        
        [self.warningLabel setHidden:NO];
        AFViewShaker *shaker = [[AFViewShaker alloc] initWithView:self.warningLabel];
        [shaker shakeWithDuration:2 completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.warningLabel setHidden:YES];
            });
        }];
        
        return;
    }
    
    else {
        
        // If any tag is empty, we don't go forward
        for(NSInteger i=0; i<[self.tagStrings count]; i++){
            if([[self trimStartingSpacesFromString:[self.tagStrings objectAtIndex:i]] length] == 0) {
                
                [self.warningLabel setHidden:NO];
                AFViewShaker *shaker = [[AFViewShaker alloc] initWithView:self.warningLabel];
                [shaker shakeWithDuration:2 completion:^{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [self.warningLabel setHidden:YES];
                    });
                }];
                
                return;
            }
        }
        
        [[Mixpanel sharedInstance] track:kMixpanelAction_uploadContent_TagView properties:nil];
        
        NSString *contentTags = @"";
        
        for(NSInteger i=0; i<[self.tagStrings count]; i++){
            contentTags = [contentTags stringByAppendingString:[NSString stringWithFormat:@"%@",[((NSString *)[self.tagStrings objectAtIndex:i])lowercaseString]]];
            if(i != [self.tagStrings count]-1){
                contentTags = [contentTags stringByAppendingString:@";"];
            }
        }
        
        self.content.tags = contentTags;
        
        LITAddToKeyboardViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:kLITAddToKeyboardViewControllerStoryboardIdentifier];
        viewController.object = self.content;
        viewController.callingController = self;
        viewController.delegate = self;
        viewController.showsUploadButton = YES;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)singleTapAction:(UITapGestureRecognizer *)recognizer {
    self.tableViewBottomConstraint.constant = 20;
    [self.tagTableView setNeedsUpdateConstraints];
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSValue *endFrameValue = aNotification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardEndFrame = [self.view convertRect:endFrameValue.CGRectValue fromView:nil];
    CGFloat keyboardHeight = CGRectGetHeight(keyboardEndFrame);
    
    if(!self.tableViewIsShortened){
        self.tableViewIsShortened = YES;
        self.tableViewBottomConstraint.constant = keyboardHeight;
        [self.tagTableView setNeedsUpdateConstraints];
    }
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSValue *endFrameValue = aNotification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardEndFrame = [self.view convertRect:endFrameValue.CGRectValue fromView:nil];
    CGFloat keyboardHeight = CGRectGetHeight(keyboardEndFrame);
    
    if(self.tableViewIsShortened){
        self.tableViewIsShortened = NO;
        self.tableViewBottomConstraint.constant = keyboardHeight;
        [self.tagTableView setNeedsUpdateConstraints];
    }
}


#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // Check if there are already two tags typed
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"," options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:self.tagTextField.text options:0 range:NSMakeRange(0, [self.tagTextField.text length])];
    
    if(numberOfMatches < maxTags-1){
        self.tagTextField.text = [NSString stringWithFormat:@"%@, ", self.tagTextField.text];
    }
    
    //[self.tagTextField resignFirstResponder];
    [self.tagTableView setHidden:YES];
     
    return NO;
}


- (void)tagTextFieldDidChange:(id)sender {
    
    /*
    // If the user inserted a comma or semicolon, we remove it
    if([self.tagTextField.text hasSuffix:@","] ||
       [self.tagTextField.text hasSuffix:@";"] ||
       [self.tagTextField.text hasSuffix:@"."])
    {
        self.tagTextField.text = [self.tagTextField.text substringToIndex:[self.tagTextField.text length]-1];
        return;
    }
     */
    
    // If there are already 3 commas, this is 3 tags, we don't allow more
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"," options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:self.tagTextField.text options:0 range:NSMakeRange(0, [self.tagTextField.text length])];
    
    if(numberOfMatches == maxTags && [self.tagTextField.text hasSuffix:@","]){
        self.tagTextField.text = [self.tagTextField.text substringToIndex:[self.tagTextField.text length]-1];
        return;
    }
    
    // If the user inserts a comma manually, we add a space
    else if([self.tagTextField.text hasSuffix:@","] &&
            [self.storedTagString length] < [self.tagTextField.text length]){
        self.tagTextField.text = [self.tagTextField.text stringByAppendingString:@" "];
        self.storedTagString = self.tagTextField.text;
        return;
    }
    
    /*
    // If the user removed a character, and it was a comma, we clear the whole previous tag
    if([self.storedTagString hasSuffix:@","] && [self.storedTagString length] > [self.tagTextField.text length]){
        [self.tagStrings removeObjectAtIndex:[self.tagStrings count]-1];
        
        self.tagTextField.text = @"";
        
        for(NSInteger i=0; i<[self.tagStrings count]; i++){
            self.tagTextField.text = [self.tagTextField.text stringByAppendingString:(NSString *)[self.tagStrings objectAtIndex:i]];
            if(i != maxTags-1){
                self.tagTextField.text = [self.tagTextField.text stringByAppendingString:@", "];
            }
        }
        
        // Update the stored string for future reference
        self.storedTagString = self.tagTextField.text;
        
        if([self.tagTextField.text length] == 0){
            return;
        }
    }
     */
    
    /*
    // If the user already has inserted 3 tags, we don't allow no more
    if([self.tagStrings count] == maxTags){
        [self.tagTextField.text substringToIndex:[self.tagTextField.text length]-1];
        return;
    }
    */
    
    
    // Update the stored string for future reference
    self.storedTagString = self.tagTextField.text;
    
    
    // Check changes in the text field and update the table of tags
    
    // First of all we need to just work with the tag which is in progress,
    // removing the preceding ones
    
    // No text => no table
    if([self.tagTextField.text length] == 0){
        [self.tagTableView setHidden:YES];
        [self.filteredRetrievedTags removeAllObjects];
    }
    // Text => First coincidences must be shown
    else {
        
        // Text to look for
        NSString *newTag;
        
        if(numberOfMatches > 0){
            newTag = [[self.tagTextField.text componentsSeparatedByString:@","] objectAtIndex:numberOfMatches];
        }
        else{
            newTag = self.tagTextField.text;
        }
        
        newTag = [self trimStartingSpacesFromString:newTag];
        
        if([newTag length] == 0){
            [self.filteredRetrievedTags removeAllObjects];
            [self.tagTableView setHidden:YES];
            return;
        }
        
        NSLog(@"WORD: %@",newTag);
        
        // If we reach this point we must show the table, because we have characters
        [self.tagTableView setHidden:NO];
        
        [self.filteredRetrievedTags removeAllObjects];
        
        for(NSInteger i = 0; i<[self.retrievedTags count]; i++){
            
            if ([[self.retrievedTags objectAtIndex:i] containsString:[newTag lowercaseString]] &&
                [self.filteredRetrievedTags count] < 15) {
                [self.filteredRetrievedTags addObject:[self.retrievedTags objectAtIndex:i]];
                
                NSLog(@" - %@",[self.retrievedTags objectAtIndex:i]);
            }
        }
        
        if([self.filteredRetrievedTags count] > 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tagTableView reloadData];
                NSIndexSet * sections = [NSIndexSet indexSetWithIndex:0];
                [self.tagTableView reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
            });
        }
        else {
            [self.tagTableView setHidden:YES];
        }
    }
}

-(NSString *) trimStartingSpacesFromString:(NSString *)string
{
    NSInteger i;
    NSCharacterSet *cs = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    for(i = 0; i < [string length]; i++)
    {
        if ( ![cs characterIsMember: [string characterAtIndex: i]] ) break;
    }
    return [string substringFromIndex: i];
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
        [self saveKeyboardInBackground:keyboard withObject:object andSaveBlock:finishBlock];
    }
}

#pragma mark - Object Saving
- (void)saveKeyboardInBackground:(LITKeyboard *)keyboard withObject:(PFObject *)object andSaveBlock:(PFBooleanResultBlock)saveBlock
{
    [keyboard addObject:object forKey:kLITKeyboardContentsKey];
    [keyboard saveInBackgroundWithBlock:saveBlock];
}

@end
