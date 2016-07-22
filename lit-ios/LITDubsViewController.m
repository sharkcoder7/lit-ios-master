//
//  LITDubsViewController.m
//  lit-ios
//
//  Created by ioshero on 20/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITDubsViewController.h"
#import "LITDub.h"
#import "LITDubTableViewCell.h"
#import "LITTheme.h"
#import "LITProgressHud.h"
#import "LITDubsPickSoundbiteViewController.h"
#import "ParseGlobals.h"
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"

@interface LITDubsViewController () {
    BOOL _alreadyPresented;
}

@property (strong, nonatomic) JGProgressHUD *hud;

@end

@implementation LITDubsViewController

- (instancetype)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        // Customize the table
        
        // The className to query on
        self.parseClassName = [LITDub parseClassName];
        
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
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([LITDubTableViewCell class])bundle:nil] forCellReuseIdentifier:kLITDubTableViewCellIdentifier];
    
    self.navigationItem.title = self.isAddingToKeyboard ? @"Add Dub" : @"Dubs";
    
    [searchHelper setSearchPlaceholderText:@"Search for Dubs"];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    self.hud = [LITProgressHud createHudWithMessage:@"Loading dubs..."];
    [self.hud showInView:self.view];
    
    if (_alreadyPresented) {
        [self loadObjects:0 clear:YES];
    }
    
    _alreadyPresented = YES;
    [self.hud dismiss];
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [self.objects count]) {
        return 50.0f;
    }
    return kLITDubCellHeight;
}

#pragma mark - UITableViewDataSource

- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    LITDubTableViewCell *cell = (LITDubTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:kLITDubTableViewCellIdentifier];
    NSAssert([cell isKindOfClass:[LITDubTableViewCell class]], @"cell must be of class LITDubTableViewCell");
    LITDub *dub = (LITDub *)object;
    [LITDub updateCell:cell withObject:dub];
    
    if(self.isAddingToKeyboard){
        [cell.optionsButton setHidden:YES];
    }
    else{
        [cell.optionsButton setHidden:NO];
        [cell.optionsButton setTag:indexPath.row];
        [cell.optionsButton addTarget:self action:@selector(optionsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [cell.addButton setHidden:YES];
    
    [cell.fullHeaderButton setTag:indexPath.row];
    [cell.fullHeaderButton addTarget:self action:@selector(headerPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return (PFTableViewCell *)cell;
}

#pragma mark - Actions
- (void)addButtonPressed:(UIBarButtonItem *)button
{
    [[Mixpanel sharedInstance] track:kMixpanelAction_addNew_Dubs properties:nil];
    
    self.definesPresentationContext = NO;
    [self performSegueWithIdentifier:kDubPickSoundbiteSegueIdentifier sender:nil];
}

- (void)headerPressed:(UIButton *)headerButton
{
//    NSString *referenceID = [[self.objects objectAtIndex:headerButton.tag] valueForKey:@"objectId"];
//    
//    [[PFQuery queryWithClassName:[LITDub parseClassName]] getObjectInBackgroundWithId:referenceID block:^(PFObject *object, NSError *error) {
//        NSAssert([NSThread isMainThread], @"This call must be run on the main thread");
//        if (!error) {
//            
//            PFUser *objectOwner = ((LITDub *)object).user;
//            
//            if (self.feedDelegate && [self.feedDelegate respondsToSelector:@selector(showProfileOfUser:)]) {
//                [self.feedDelegate showProfileOfUser:objectOwner];
//            }
//        }
//    }];
}

#pragma mark Segues

// Actions prior to segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kDubPickSoundbiteSegueIdentifier]) {
        LITDubsPickSoundbiteViewController *dubPickSoundbiteVC = (LITDubsPickSoundbiteViewController *)[segue destinationViewController];
        NSAssert([dubPickSoundbiteVC isKindOfClass:[LITDubsPickSoundbiteViewController class]],
                 @"Destination controller must be of class LITDubsPickSoundbiteViewController");
        [dubPickSoundbiteVC setOptionsDelegate:self.optionsDelegate];
        [dubPickSoundbiteVC setFeedDelegate:self.feedDelegate];
    }
}


@end
