//
//  LITAddDubmashViewController.m
//  slit-ios
//
//  Created by ioshero on 08/07/2015.
//  Copyright (c) 2015 Slit Inc. All rights reserved.
//

#import "LITDubsPickSoundbiteViewController.h"
#import "LITBaseSoundbiteTableViewCell.h"
#import "LITSimpleSoundbiteTableViewCell.h"
#import "LITSoundbiteCropSongViewController.h"
#import "LITDubCreationViewController.h"
#import "LITSoundbite.h"
#import "AVUtils.h"
#import "ParseGlobals.h"
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"

NSString *const kDubPickSoundbiteSegueIdentifier = @"DubPickSoundbiteSegue";

@interface LITDubsPickSoundbiteViewController ()

@property (strong, nonatomic) LITSoundbite *selectedSounbite;
@property (strong, nonatomic) NSURL *soundURL;

@end


@implementation LITDubsPickSoundbiteViewController {
    LITSoundbitePlayerHelper *_playerHelper;
}

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        // Customize the table
        
        // The className to query on
        self.parseClassName = [LITSoundbite parseClassName];
        
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
        
        _playerHelper = [[LITSoundbitePlayerHelper alloc] initWithSoundbitePlayerHosting:self];
        
        self.showsAddButton = NO;
        self.showsSegmentedHeader = NO;
        
        self.optionsVisible = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchKey = kMainFeedSearchDataKey;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([LITSimpleSoundbiteTableViewCell class])bundle:nil] forCellReuseIdentifier:kLITSimpleSoundbiteTableViewCellIdentifier];
    
    [searchHelper setSearchPlaceholderText:@"Search for Soundbites"];
    
    self.definesPresentationContext = YES;
    
    self.navigationItem.title = @"Select a base Soundbite";
}


#pragma mark - UITableViewDataSource

- (PFTableViewCell *)tableView:(UITableView * __nonnull)tableView cellForRowAtIndexPath:(NSIndexPath * __nonnull)indexPath object:(nullable PFObject *)object
{
    LITSimpleSoundbiteTableViewCell *cell = (LITSimpleSoundbiteTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:kLITSimpleSoundbiteTableViewCellIdentifier];
    NSAssert([cell isKindOfClass:[LITSimpleSoundbiteTableViewCell class]], @"cell must be of class LITSimpleSongTableViewCell");
    
    [LITSoundbite updateCell:cell withObject:self.objects[indexPath.row]];
    
    [_playerHelper getDataForSoundbite:(LITSoundbite *)object atIndexPath:indexPath withCompletionBlock:^(NSURL *fileURL, NSError *error) {
        if (!error) {
            [cell initHistogramViewWithFileURL:fileURL];
        } else {
            NSLog(@"Error setting histogram view: %@", error.localizedDescription);
        }
    }];
    [cell.playButton setTag:indexPath.row];
    [cell.playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.optionsButton setHidden:NO];
    [cell.optionsButton setTag:indexPath.row];
    [cell.optionsButton addTarget:self action:@selector(optionsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return (PFTableViewCell *)cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [self.objects count]) {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    } else {
        self.selectedSounbite = self.objects[indexPath.row];
        [self.selectedSounbite.audio getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (data && !error) {
                NSURL *url = [AVUtils PFFileCacheURLForContentName:self.selectedSounbite.audio.name];
                if (url) {
                    self.soundURL = url;
                    [self performSegueWithIdentifier:kDubCreationSegueIdentifier sender:nil];
                } else {
                    NSLog(@"Error getting cached file for:%@", self.selectedSounbite.audio.name);
                }
            }
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kLITSimpleSoundbiteCellHeight;
}

#pragma mark Soundbite Player Helper
- (void)playButtonPressed:(UIButton *)sender {
    
    [[Mixpanel sharedInstance] track:kMixpanelAction_previewSound_New_Dubs properties:nil];
    
    [_playerHelper playButtonPressed:sender];
}


#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kDubCreationSegueIdentifier]) {
        LITDubCreationViewController *creationViewController = segue.destinationViewController;
        NSAssert([creationViewController isKindOfClass:[LITDubCreationViewController class]],
                 @"Destination controller must be of class LITDubCreationViewController");
        creationViewController.soundURL = self.soundURL;
        creationViewController.soundbite = self.selectedSounbite;
        
    }
}

#pragma mark Invocation Forwarding
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([_playerHelper respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:_playerHelper];
    }else if ([searchHelper respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:searchHelper];
    }else {
        [super forwardInvocation:anInvocation];
    }
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature* signature = [super methodSignatureForSelector:selector];
    if (!signature) {
        signature = [_playerHelper methodSignatureForSelector:selector];
        if (!signature) {
            signature = [searchHelper methodSignatureForSelector:selector];
        }
    }
    return signature;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector] ||
        [_playerHelper respondsToSelector:aSelector] ||
        [searchHelper respondsToSelector:aSelector])
    {
        return YES;
    }
    return NO;
}


@end
