//
//  LITTopSongsSelectionViewController.m
//  lit-ios
//
//  Created by ioshero on 23/07/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITTopSongsSelectionViewController.h"
#import "LITLyricCreationViewController.h"
#import "LITSongTableViewCell.h"
//#import "LITSong.h"
#import "LITTheme.h"
#import "ParseGlobals.h"
#import <Parse/PFQuery.h>

@interface LITTopSongsSelectionViewController ()
@property (strong, nonatomic) LITSong *selectedSong;
@end

@implementation LITTopSongsSelectionViewController

- (instancetype)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        // Customize the table
        
        // The className to query on
//        self.parseClassName = [LITSong parseClassName];
        
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
        
        self.loadingViewEnabled = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.navigationItem.title = @"Top Songs";
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.tableView setBackgroundColor:[UIColor lit_lightGreyColor]];
}



#pragma mark - PFQueryTableViewController
- (PFQuery *)queryForTable
{
    PFQuery *query = [super queryForTable];
//    [query whereKeyExists:kSongTitleKey];
//    [query whereKeyExists:kSongArtistKey];
//    [query whereKeyExists:kSongAlbumKey];
//    [query whereKey:kSongTitleKey notEqualTo:@""];
//    [query whereKey:kSongArtistKey notEqualTo:@""];
    return query;
}


#pragma mark - UITableViewDataSource

- (PFTableViewCell *)tableView:(UITableView * __nonnull)tableView cellForRowAtIndexPath:(NSIndexPath * __nonnull)indexPath object:(nullable PFObject *)object
{
    LITSongTableViewCell *cell = (LITSongTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:kLITSongTableViewCellIdentifier];
    NSAssert([cell isKindOfClass:[LITSongTableViewCell class]], @"cell must be of class LITSongTableViewCell");
//    [LITSong updateCell:cell withSoundbite:(LITSong *)object];
    return (PFTableViewCell *)cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [self.objects count]) {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    } else {
        self.selectedSong = [self.objects objectAtIndex:indexPath.item];
        [self performSegueWithIdentifier:kLITLyricCreationSegue sender:self];
    }
}

#pragma mark - PFQueryTableViewController

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kLITLyricCreationSegue]) {
        NSAssert([segue.destinationViewController
                  isKindOfClass:[LITLyricCreationViewController class]], @"Destination controller must be of class LITLyricCreationViewController");
        [((LITLyricCreationViewController *)segue.destinationViewController) setSong:self.selectedSong];
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
