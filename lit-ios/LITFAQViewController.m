//
//  LITFAQViewController.m
//  slit-ios
//
//  Created by ioshero on 09/07/2015.
//  Copyright (c) 2015 Slit Inc. All rights reserved.
//

#import "LITFAQViewController.h"
#import "LITFaqTableViewCell.h"
#import "LITTheme.h"
#import "UIView+GradientBackground.h"
#import <Parse/PFCloud.h>

NSString *const kLITfaqCellIdentifier = @"LITfaqCell";

@interface LITFAQViewController () {}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *faqTableView;

@property (strong, nonatomic) NSArray *questionsAnswers;
@property (strong, nonatomic) NSMutableArray *filteredQuestionsAnswers;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (assign, nonatomic) BOOL tableViewIsShortened;

@end


@implementation LITFAQViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    self.searchBar.delegate = self;
    self.searchBar.layer.cornerRadius  = 2;
    self.searchBar.backgroundImage = [[UIImage alloc] init];
    self.searchBar.backgroundColor = [UIColor whiteColor];
    self.searchBar.clipsToBounds       = YES;
    [self.searchBar.layer setBorderWidth:1.0];
    [self.searchBar.layer setBorderColor:[UIColor lit_lightGreyColor].CGColor];
    
    self.faqTableView.separatorColor = [UIColor whiteColor];
    self.faqTableView.allowsSelection = NO;
    self.faqTableView.estimatedRowHeight = 70.0f;
    self.faqTableView.rowHeight = UITableViewAutomaticDimension;
    
    // Tap the view to dismiss the keyboard
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(singleTapAction:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
    [PFCloud callFunctionInBackground:@"retrieveFAQdata"
                       withParameters:@{}
                                block:^(NSArray *results, NSError *error) {
                                    if (!error) {
                                        self.questionsAnswers = results;
                                        self.filteredQuestionsAnswers = [NSMutableArray arrayWithArray:self.questionsAnswers];
                                        self.faqTableView.delegate = self;
                                        self.faqTableView.dataSource = self;
                                        [self.faqTableView reloadData];
                                        NSIndexSet * sections = [NSIndexSet indexSetWithIndex:0];
                                        [self.faqTableView reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
                                    }
                                    
                                }];
}

#pragma mark UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filteredQuestionsAnswers count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    LITFaqTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kLITfaqCellIdentifier forIndexPath:indexPath];
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    cell.questionLabel.text = [NSString stringWithFormat:@"%ld. %@",((long)indexPath.row)+1,[[self.filteredQuestionsAnswers objectAtIndex:indexPath.row] valueForKey:@"question"]];
    cell.answerLabel.text = [[self.filteredQuestionsAnswers objectAtIndex:indexPath.row] valueForKey:@"answer"];

    return cell;
}

#pragma mark UISearchBar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if([searchText length] == 0) {
        self.filteredQuestionsAnswers = [NSMutableArray arrayWithArray:self.questionsAnswers];
        [self.faqTableView reloadData];
        NSIndexSet * sections = [NSIndexSet indexSetWithIndex:0];
        [self.faqTableView reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    
    
    [self.filteredQuestionsAnswers removeAllObjects];
    
    for(NSInteger i = 0; i<[self.questionsAnswers count]; i++){
        
        NSString *question = [[[self.questionsAnswers objectAtIndex:i] valueForKey:@"question"] lowercaseString];
        NSString *answer = [[[self.questionsAnswers objectAtIndex:i] valueForKey:@"answer"] lowercaseString];
        
        if ([question containsString:[searchText lowercaseString]] || [answer containsString:[searchText lowercaseString]]) {
            [self.filteredQuestionsAnswers addObject:[self.questionsAnswers objectAtIndex:i]];
        }
    }
    
    [self.faqTableView reloadData];
    NSIndexSet * sections = [NSIndexSet indexSetWithIndex:0];
    [self.faqTableView reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark Actions

- (void)singleTapAction:(UITapGestureRecognizer *)recognizer {
    [self.searchBar resignFirstResponder];
    self.tableViewBottomConstraint.constant = 20;
    [self.faqTableView setNeedsUpdateConstraints];
}

- (IBAction)backToPreviousSlide:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
        [self.faqTableView setNeedsUpdateConstraints];
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
        [self.faqTableView setNeedsUpdateConstraints];
    }
}

@end
