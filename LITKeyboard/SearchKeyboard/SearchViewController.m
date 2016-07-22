//
//  SearchViewController.m
//  lit-ios
//
//  Created by user on 4/10/16.
//  Copyright © 2016 Lit Inc. All rights reserved.
//

#import "SearchViewController.h"
#import "KeyboardViewController.h"
#import "LITKeyboardViewController.h"
#import "LITKeyboard.h"
#import "UIViewController+LITKeyboardCellConfigurator.h"
#import "UIView+GradientBackground.h"
#import "UIView+BlurEffect.h"
#import "LITTheme.h"
#import "AKTagsLookup.h"
#import "AKTagCell.h"
#import "AKTagsListView.h"

#import "ParseGlobals.h"
#import <Parse/Parse.h>
#import <Parse/PFUser.h>
#import <Bolts/Bolts.h>
#import "LITLyric.h"
#import "LITSoundBite.h"
#import "LITDub.h"
#import "LITKeyboard.h"
#import "DataKeeper.h"

static CGFloat const kSearchViewHeight = 44.0f;

@interface SearchViewController ()<UITextFieldDelegate, AKTagsLookupDelegate, AKTagCellDelegate, KeyboardViewControllerDelegate>
{
    int keyboardHeight;
    BOOL _gradientSet;
    BOOL bSelectedTag;
}

@property (strong, nonatomic) LITKeyboard *keyboard;
@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) UIView *resultView;
@property (nonatomic, strong) UIView *keyboardView;
@property (nonatomic, strong) UIButton *chevronButton;
@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, strong) AKTagsLookup *tagScrollView;
@property (nonatomic, strong) AKTagCell *tagFloatingView;
@property (nonatomic)         BOOL isLandScape;
@property (assign ,nonatomic, getter=isRotating)    BOOL rotating;
@property (nonatomic, assign) CGFloat portraitHeight;
@property (nonatomic, assign) CGFloat landscapeHeight;
@property (nonatomic, strong) KeyboardViewController *kvController;
@property (nonatomic, strong) LITKeyboardViewController *kbViewController;
@property (nonatomic, assign) BOOL isNumerical;

- (void)searchMatchingContent;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.portraitHeight = floorf(kLITKeyboardCellItemPortraitDimension * 2 + kLITKeyboardCellItemSpacing * 2 + 30);
    self.landscapeHeight = floorf(kLITKeyboardCellItemLandscapeDimension * 2 + 30);
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenH = screenSize.height;
    CGFloat screenW = screenSize.width;
    self.isLandScape =  !(self.view.frame.size.width ==
                          (screenW*(screenW<screenH))+(screenH*(screenW>screenH)));
    
    bSelectedTag = NO;
    self.isNumerical = NO;
    _gradientSet = NO;
    
    [self.view setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self setConstraint];
    [self.searchField becomeFirstResponder];
    
    [self updateTagsScrollView];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)updateTagsScrollView
{
    [self.tagScrollView removeFromSuperview];
    
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    NSMutableArray *arrayTagCell = [NSMutableArray array];
    for (NSInteger i = 0 ; i < dataKeeper.arrayTags.count ; i ++) {
        AKTagCell *tag = [[AKTagCell alloc] init];
        tag.usedCount = 0;
        tag.tagName = [dataKeeper.arrayTags objectAtIndex:i];
        [arrayTagCell addObject:tag];
    }
    
    [arrayTagCell sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
       
        AKTagCell *p1 = (AKTagCell*)obj1;
        AKTagCell *p2 = (AKTagCell*)obj2;
        if (p1.usedCount < p2.usedCount) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if (p1.usedCount > p2.usedCount) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];

    self.tagScrollView = [[AKTagsLookup alloc] initWithTags:arrayTagCell];
    
    [self.view addSubview:self.tagScrollView];
    self.tagScrollView.delegate = self;
}

- (void)sortTags {
    
}

- (void)viewDidLayoutSubviews
{
    if (!_gradientSet && self.keyboardView) {
        [self.keyboardView setupGradientBackgroundFromPoint:CGPointMake(0, 0.3) andStartingColor:[UIColor lit_kbOrangeDark] toPoint:CGPointMake(0, 1) andFinalColor:[UIColor lit_kbOrangeLight]];
        _gradientSet = YES;
    }
}

#pragma mark - Orientation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    NSLog(@"Size is %@", NSStringFromCGSize(size));
    
    self.rotating = YES;
    
    BOOL isLandscape = size.height != self.landscapeHeight;
    
    CGRect gradientFrame = isLandscape ? CGRectMake(0, 0, size.width, self.landscapeHeight) :
    CGRectMake(0, 0, size.width, self.portraitHeight);
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.view.gradientLayer setFrame:gradientFrame];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.rotating = NO;
    }];
}

- (void)setConstraint {

    int offset = self.view.frame.size.width;
    
    int height = self.isLandScape ? self.landscapeHeight: self.portraitHeight;
    
    self.searchView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.searchView setBackgroundColor:[UIColor colorWithRed:150.0/255.0 green:39.0/255.0 blue:27.0/255.0 alpha:1]];
    [self.searchView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.searchView];
    
    UIView *view = self.view;
    UIView *searchView = self.searchView;
    
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view, searchView);
    NSLayoutConstraint *searchViewConstraint = [NSLayoutConstraint constraintWithItem:self.searchView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    NSLayoutConstraint *searchViewHeightConstraint = [NSLayoutConstraint
                                                      constraintWithItem:self.searchView
                                                      attribute:NSLayoutAttributeHeight
                                                      relatedBy:NSLayoutRelationEqual
                                                      toItem:nil
                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:1.0
                                                      constant:kSearchViewHeight];

    NSArray *searchHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[searchView]|" options:0 metrics:nil views:bindings];
    [self.view addConstraints:searchHConstraints];
    [self.view addConstraints:@[searchViewConstraint, searchViewHeightConstraint]];
    
    ///////--------------------------//////
    self.keyboardView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.keyboardView setBackgroundColor:[UIColor clearColor]];
    [self.keyboardView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.keyboardView];
    
    self.resultView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.resultView setBackgroundColor:[UIColor clearColor]];
    [self.resultView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.resultView];
    
    UIView *tempView1 = self.resultView;
    NSDictionary *bindings2 = NSDictionaryOfVariableBindings(tempView1, view);
    NSLayoutConstraint *keyboardViewConstraint1 = [NSLayoutConstraint constraintWithItem:self.resultView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    NSLayoutConstraint *keyboardViewHeightConstraint1 = [NSLayoutConstraint
                                                         constraintWithItem:self.resultView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                         toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                         constant:height - kSearchViewHeight];
    [self.view addConstraints:@[keyboardViewConstraint1, keyboardViewHeightConstraint1]];
    
    NSArray *keyboardHConstraints1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tempView1]|" options:0 metrics:nil views:bindings2];
    [self.view addConstraints:keyboardHConstraints1];
    self.resultView.hidden = YES;
    
    UIView *tempView = self.keyboardView;
    NSDictionary *bindings1 = NSDictionaryOfVariableBindings(tempView, view);
    NSLayoutConstraint *keyboardViewConstraint = [NSLayoutConstraint constraintWithItem:self.keyboardView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    NSLayoutConstraint *keyboardViewHeightConstraint = [NSLayoutConstraint
                                                      constraintWithItem:self.keyboardView
                                                      attribute:NSLayoutAttributeHeight
                                                      relatedBy:NSLayoutRelationEqual
                                                      toItem:nil
                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:1.0
                                                      constant:height - kSearchViewHeight];
    [self.view addConstraints:@[keyboardViewConstraint, keyboardViewHeightConstraint]];
    
    NSArray *keyboardHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tempView]|" options:0 metrics:nil views:bindings1];
    [self.view addConstraints:keyboardHConstraints];
    
    //add keyboard view
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Keyboard" bundle:nil];
    self.kvController = [sb instantiateViewControllerWithIdentifier:@"KeyboardViewController"];
    [self.keyboardView addSubview:self.kvController.view];
    [self.kvController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.kvController.delegate = self;
    
    UIView *kvControllerView = self.kvController.view;
    [self.keyboardView addConstraint:[NSLayoutConstraint constraintWithItem:kvControllerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.keyboardView attribute:NSLayoutAttributeTop multiplier:1.0 constant:30]];
    [self.keyboardView addConstraint:[NSLayoutConstraint constraintWithItem:kvControllerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.keyboardView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    [self.keyboardView addConstraint:[NSLayoutConstraint constraintWithItem:kvControllerView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.keyboardView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [self.keyboardView addConstraint:[NSLayoutConstraint constraintWithItem:kvControllerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.keyboardView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    
    //---------------keyboard code -------------///end
    
    self.chevronButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.chevronButton setImage:[UIImage imageNamed:@"backIcon"] forState:UIControlStateNormal];
    [self.chevronButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.chevronButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.searchView addSubview:self.chevronButton];
    
    [self.searchView addConstraint:[NSLayoutConstraint constraintWithItem:self.chevronButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.searchView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:12.0]];
    [self.searchView addConstraint:[NSLayoutConstraint constraintWithItem:self.chevronButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.searchView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    self.searchField = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.searchField setBackgroundColor:[UIColor clearColor]];
    [self.searchField setTextColor:[UIColor whiteColor]];
    [self.searchField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.searchView addSubview:self.searchField];
    self.searchField.delegate = self;
    
    [self.searchView addConstraint:[NSLayoutConstraint constraintWithItem:self.searchField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.searchView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:1.0 * offset / 15 + 15]];
    [self.searchField addConstraint:[NSLayoutConstraint constraintWithItem:self.searchField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:1.0 * offset / 7.0]];
    [self.searchView addConstraint:[NSLayoutConstraint constraintWithItem:self.searchField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.searchView attribute:NSLayoutAttributeTop multiplier:1.0 constant:2.0]];
    [self.searchView addConstraint:[NSLayoutConstraint constraintWithItem:self.searchField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.searchView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    _tagFloatingView = [[AKTagCell alloc] initWithFrame:CGRectZero];
    self.tagFloatingView.delegate = self;
    [self.searchView addSubview:_tagFloatingView];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backAction:(id)sender {
    
    if (bSelectedTag)
    {
        bSelectedTag = NO;
        self.searchField.text = @"";
        self.searchField.hidden = NO;
        self.tagScrollView.hidden = NO;
        [self.tagFloatingView removeFromSuperview];
        
        [self.tagScrollView filterLookupWithPredicate: [self.tagScrollView predicateExcludingTags: nil]];
        
        CGRect initialFrame = self.keyboardView.frame;
        initialFrame.origin.x = 0;
        self.keyboardView.frame = initialFrame;
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(moveFrom:) userInfo:@0 repeats:NO];
        self.resultView.hidden = YES;
        
        [self.kbViewController.view removeFromSuperview];
    }
    else
    {
        [self didMoveToParentViewController:self.parentViewController];
        
        if ([self.delegate respondsToSelector:@selector(didEndSearch)])
            [self.delegate didEndSearch];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString *newText = (NSMutableString*)[textField.text stringByReplacingCharactersInRange:range withString:string];
    NSMutableString *mutableText = [newText mutableCopy];
    
    newText = [NSMutableString stringWithString:mutableText];
    if (newText.length > 0){
        [self.tagScrollView filterLookupWithPredicate:[self.tagScrollView predicateExcludingTags:nil andFilterByString:newText]];
    }
    else {
        [self.tagScrollView filterLookupWithPredicate: [self.tagScrollView predicateExcludingTags: nil]];
    }
    
    return YES;
}

#pragma AKTagsLookup delegate

-(void)tagsLookup:(AKTagsLookup *)lookup didSelectTag:(AKTagCell *)tag
{
    tag.usedCount ++;
    
    if(bSelectedTag) return;
    self.searchField.hidden = YES;
    self.tagScrollView.hidden = YES;
    
    CGRect initialFrame = self.keyboardView.frame;
    initialFrame.origin.x = initialFrame.size.width;
    self.keyboardView.frame = initialFrame;
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(moveFrom:) userInfo:@1 repeats:NO];
    
    //floating tag on search bar
    _tagFloatingView = [[AKTagCell alloc] initWithFrame:CGRectZero];
    self.tagFloatingView.delegate = self;
    
    CGSize itemSize = [AKTagCell preferredSizeWithTag:[tag.tagName uppercaseString] deleteButtonEnabled:YES];
    [_tagFloatingView setFrame:CGRectMake(self.searchField.frame.origin.x, 10, itemSize.width, itemSize.height)];
    [_tagFloatingView setShowDeleteButton:YES];
    [_tagFloatingView setTagName:[tag.tagName uppercaseString]];
    
    [_tagFloatingView setBackgroundColor:[UIColor tag_cellColor]];
    
    [self.searchView addSubview:_tagFloatingView];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(_tagFloatingView.tagLabel.frame.size.width - 14, 0, 1, _tagFloatingView.tagLabel.frame.size.height)
                         ];

    lineView.backgroundColor = [UIColor colorWithRed:147.0 / 255.0 green:200.0 / 255.0 blue: 254.0 / 255.0 alpha:1.0f];
    [_tagFloatingView addSubview:lineView];
    
    bSelectedTag = YES;
    [self searchMatchingContent];
}

#pragma KeyboardViewController delegate method
- (void)returnKeyPressed:(KeyboardViewController *)kv{
    if([self.searchField.text isEqualToString:@""]){
        return;
    }
    
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.tagScrollView.tagsView.selectedTags];
    
    for (AKTagCell* tag in temp) {
        tag.usedCount ++;
    }
    
    if(bSelectedTag) return;
    self.searchField.hidden = YES;
    self.tagScrollView.hidden = YES;
    
    //-----floating tag on the search bar------//
    _tagFloatingView = [[AKTagCell alloc] initWithFrame:CGRectZero];
    self.tagFloatingView.delegate = self;
    
    CGSize itemSize = [AKTagCell preferredSizeWithTag:self.searchField.text deleteButtonEnabled:YES];
    [_tagFloatingView setFrame:CGRectMake(self.searchField.frame.origin.x , 10 , itemSize.width, itemSize.height)];
    [_tagFloatingView setShowDeleteButton:YES];
    [_tagFloatingView setTagName:self.searchField.text];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(_tagFloatingView.tagLabel.frame.size.width - 16, 0, 1, _tagFloatingView.tagLabel.frame.size.height)
                         ];
    
    lineView.backgroundColor = [UIColor colorWithRed:147.0 / 255.0 green:200.0 / 255.0 blue: 254.0 / 255.0 alpha:1.0f];
    [_tagFloatingView addSubview:lineView];
    
    UIColor *searchBarColor = [UIColor tag_cellColor];
    [_tagFloatingView setBackgroundColor:searchBarColor];
    
    [self.searchView addSubview:_tagFloatingView];
    
    bSelectedTag = YES;
    
    [self searchMatchingContent];//start search...
}

- (void)didChangedKeyboardMode:(BOOL)isNumerical
{
    self.isNumerical = isNumerical;
    
    if (isNumerical) {
        [self.searchView setBackgroundColor:[UIColor blackColor]];
        [self.keyboardView.gradientLayer removeFromSuperlayer];
        [self.keyboardView setBackgroundColor:[UIColor blackColor]];
    }
    else {
        [self.searchView setBackgroundColor:[UIColor colorWithRed:150.0/255.0 green:39.0/255.0 blue:27.0/255.0 alpha:1]];
        [self.keyboardView setupGradientBackgroundFromPoint:CGPointMake(0, 0.3) andStartingColor:[UIColor lit_kbOrangeDark] toPoint:CGPointMake(0, 1) andFinalColor:[UIColor lit_kbOrangeLight]];
    }
}

- (void)searchMatchingContent{
    
    //-------wipe out keyboard with animation---------//
    CGRect initialFrame = self.keyboardView.frame;
    initialFrame.origin.x = initialFrame.size.width;
    self.keyboardView.frame = initialFrame;
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(moveFrom:) userInfo:@1 repeats:NO];
    
    //------search routine-------//
    [self getSearchResult];
}

- (void)getSearchResult{
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    NSString *searchKeyword = _tagFloatingView.tagLabel.text;
    searchKeyword = [searchKeyword lowercaseString];
    
    NSMutableArray *arrayTotal = [NSMutableArray array];
    [arrayTotal addObjectsFromArray:dataKeeper.arrayLyrics];
    [arrayTotal addObjectsFromArray:dataKeeper.arraySoundBites];
    [arrayTotal addObjectsFromArray:dataKeeper.arrayDubs];
    
    NSInteger result = 0;
    NSMutableArray *finalArray = [NSMutableArray array];
    for (NSInteger i = 0 ; i < arrayTotal.count - 1 ; i ++) {
        PFObject *object1 = arrayTotal[i];
        result = i;
        NSInteger priority1 = [[object1 objectForKey:kLITObjectPriorityKey] integerValue];
        
        for (NSInteger j = i + 1; j < arrayTotal.count; j ++) {
            PFObject *object2 = arrayTotal[j];
            NSInteger priority2 = [[object2 objectForKey:kLITObjectPriorityKey] integerValue];
            if (priority2 > priority1)
                result = j;
        }

        if (result != i) {
            [arrayTotal replaceObjectAtIndex:i withObject:arrayTotal[result]];
            [arrayTotal replaceObjectAtIndex:result withObject:object1];
        }
    }
    
    for(NSInteger i = 0 ; i < [arrayTotal count]; i ++){
        PFObject *obj = [arrayTotal objectAtIndex:i];
        NSString *text = [obj objectForKey:kParseTagsKey];
        if (text && [text rangeOfString:searchKeyword].location != NSNotFound)
            [finalArray addObject:obj];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LITKeyboard" bundle:nil];
    _kbViewController = [storyboard instantiateViewControllerWithIdentifier:kLITKeyboardViewControllerStoryboardID];
    
    LITKeyboard *keyboard = [[LITKeyboard alloc] init];
    keyboard.contents = [NSArray arrayWithArray:finalArray];
    [_kbViewController setKeyboard:keyboard];
    
    _kbViewController.collectionView.scrollsToTop = YES;
    
    if ([_kbViewController.keyboard.contents count] != 0)
        [_kbViewController.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    
    [_kbViewController setIndex:0];
    [_kbViewController setLandscapeActive:0];
    _kbViewController.view.backgroundColor = [UIColor clearColor];
    
    [self.resultView setupGradientBackgroundFromPoint:CGPointMake(0, 0) andStartingColor:[UIColor lit_kbOrangeDark] toPoint:CGPointMake(0, 1) andFinalColor:[UIColor lit_kbOrangeLight]];
    
    self.resultView.hidden = NO;

    [_kbViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.resultView addSubview:_kbViewController.view];
    [self addChildViewController:_kbViewController];

    [self.resultView addConstraint:[NSLayoutConstraint constraintWithItem:_kbViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.resultView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.resultView addConstraint:[NSLayoutConstraint constraintWithItem:_kbViewController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.resultView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    [self.resultView addConstraint:[NSLayoutConstraint constraintWithItem:_kbViewController.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.resultView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [self.resultView addConstraint:[NSLayoutConstraint constraintWithItem:_kbViewController.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.resultView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
}

- (void)moveFrom:(NSTimer*) timer{
    BOOL isLeft = [timer.userInfo boolValue];
    CGFloat bounceDistance = 700;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.keyboardView.center = CGPointMake(self.keyboardView.frame.size.width / 2 + isLeft * bounceDistance, self.keyboardView.center.y);
    } completion:^(BOOL finished) {
    }];
}

#pragma AKTagCell delegate

-(void)tagCellDidPressedDelete:(AKTagCell*)cell{
    bSelectedTag = NO;
    self.searchField.text = @"";
    self.searchField.hidden = NO;
    self.tagScrollView.hidden = NO;
    //self.tagFloatingView.hidden = YES;
    [self.tagFloatingView removeFromSuperview];
 
    //*****-------- refresh scroll view ------****//
    [self.tagScrollView filterLookupWithPredicate: [self.tagScrollView predicateExcludingTags: nil]];
    
    /////////////
    CGRect initialFrame = self.keyboardView.frame;
    initialFrame.origin.x = 0;
    self.keyboardView.frame = initialFrame;
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(moveFrom:) userInfo:@0 repeats:NO];
    self.resultView.hidden = YES;
    
    //remove litkeyboard view
    [self.kbViewController.view removeFromSuperview];
    [self updateTagsScrollView];
}

#pragma mark LITKeyboardBaseViewControllerDelegate

- (void)didUpdateTags
{
    [self updateTagsScrollView];
}

- (void)didCloseSearch
{
}

@end
