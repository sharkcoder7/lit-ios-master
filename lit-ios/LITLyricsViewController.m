//
//  LITAddLyricViewController.m
//  slit-ios
//
//  Created by ioshero on 08/07/2015.
//  Copyright (c) 2015 Slit Inc. All rights reserved.
//

#import "LITLyricsViewController.h"
#import "LITSimpleLyricsTableViewCell.h"
#import "ParseGlobals.h"
#import "LITLyric.h"
#import "LITLyricCreationViewController.h"
#import "LITProgressHud.h"


NSString *const kLITPresentTopSongsForLyricsSegueIdentifier = @"PresentTopSongsForLyricsSegue";
NSString *const kLITLyricCreationSegueIdentifier = @"LyricCreationSegue";

@interface LITLyricsViewController() {
    BOOL _alreadyPresented;
}

@property (strong, nonatomic) JGProgressHUD *hud;

@end


@implementation LITLyricsViewController

- (instancetype)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        // Customize the table
        
        // The className to query on
        self.parseClassName = [LITLyric parseClassName];
        
        // The key of the PFObject to display in the label of the default cell style
        //        self.textKey = @"text";
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
        // self.imageKey = @"image";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = kLITObjectsPerPage;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.searchKey = kMainFeedSearchDataKey;
    
//    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([LITSimpleLyricsTableViewCell class])bundle:nil] forCellReuseIdentifier:kLITSimpleLyricsTableViewCellIdentifier];
    
    self.navigationItem.title = self.isAddingToKeyboard ? @"Add Lyric" : @"Lyrics";
    
    [searchHelper setSearchPlaceholderText:@"Search for Lyrics"];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    self.hud = [LITProgressHud createHudWithMessage:@"Loading Lyrics..."];
    [self.hud showInView:self.view];
    
    if (_alreadyPresented) {
        [self loadObjects:0 clear:YES];
    }
    
    _alreadyPresented = YES;
    
    [self.hud dismiss];
}

#pragma mark - Actions
- (void)addButtonPressed:(UIBarButtonItem *)button
{
    //[self performSegueWithIdentifier:kLITPresentTopSongsForLyricsSegueIdentifier sender:nil];
    [self performSegueWithIdentifier:kLITLyricCreationSegueIdentifier sender:nil];
}

#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row >= [self.objects count]) {
        return 50.0f;
    }
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row >= [self.objects count]) {
        return 50.0f;
    }
    return UITableViewAutomaticDimension;
}

- (PFTableViewCell *)tableView:(UITableView * __nonnull)tableView cellForRowAtIndexPath:(NSIndexPath * __nonnull)indexPath object:(nullable PFObject *)object
{
    LITSimpleLyricsTableViewCell *cell = (LITSimpleLyricsTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:kLITSimpleLyricsTableViewCellIdentifier];
    NSAssert([cell isKindOfClass:[LITSimpleLyricsTableViewCell class]], @"cell must be of class LITSimpleLyricsTableViewCell");
    [LITLyric updateSimpleCell:cell withObject:(LITLyric *)object];
    
    if(self.isAddingToKeyboard){
        [cell.optionsButton setHidden:YES];
    }
    else{
        [cell.optionsButton setHidden:NO];
        [cell.optionsButton setTag:indexPath.row];
        [cell.optionsButton addTarget:self action:@selector(optionsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return (PFTableViewCell *)cell;
}


#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kLITLyricCreationSegue]) {
        NSAssert([segue.destinationViewController
                  isKindOfClass:[LITLyricCreationViewController class]], @"Destination controller must be of class LITLyricCreationViewController");
        ((LITLyricCreationViewController *)segue.destinationViewController).destinationKeyboard = self.keyboard;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:kLITLyricCreationSegue]) {
        if([sender class] == [self class]){
            return YES;
        }
        else return NO;
    }
    return YES;
}

@end
