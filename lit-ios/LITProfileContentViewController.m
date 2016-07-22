//
//  LITProfileContentViewController.m
//  lit-ios
//
//  Created by ioshero on 07/09/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "ParseGlobals.h"
#import "LITProfileContentViewController.h"
#import "LITLyricsTableViewCell.h"
#import "LITSoundbiteTableViewCell.h"
#import "LITDubTableViewCell.h"
#import "LITDub.h"
#import "LITSoundbite.h"
#import "LITLyric.h"
#import "LITProgressHud.h"
#import <Parse/PFUser.h>
#import <Parse/PFQuery.h>
#import <Parse/PFQuery+Synchronous.h>
#import <JGProgressHUD/JGProgressHUD.h>

@interface LITProfileContentViewController ()

@property (strong, nonatomic) JGProgressHUD *hud;
@property BOOL firstTime;

@end

@implementation LITProfileContentViewController {
    LITSoundbitePlayerHelper *_playerHelper;
}

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        // Customize the table
        
        // The className to query on
        self.parseClassName = kUserCreatedContentClassName;
        
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
        
        _playerHelper = [[LITSoundbitePlayerHelper alloc] initWithSoundbitePlayerHosting:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([LITSoundbiteTableViewCell class])bundle:nil] forCellReuseIdentifier:kLITSoundbiteTableViewCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([LITLyricsTableViewCell class])bundle:nil] forCellReuseIdentifier:kLITLyricsTableViewCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([LITDubTableViewCell class])bundle:nil] forCellReuseIdentifier:kLITDubTableViewCellIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
}

- (PFTableViewCell *)tableView:(UITableView * __nonnull)tableView
         cellForRowAtIndexPath:(NSIndexPath * __nonnull)indexPath
                        object:(nullable PFObject *)object
{
    NSString *referenceClass = [object objectForKey:kMainFeedClassKey];
    NSString *referenceId = [object objectForKey:kMainFeedReferenceKey];
    
    PFQuery *query = [PFQuery queryWithClassName:referenceClass];
    
    //    PFObject *object = [self.objects[indexPath.row] objectForKey:kMainFeedReferenceKey];
    
    UITableViewCell *tableViewCell;
    
    if ([referenceClass isEqualToString:[LITLyric parseClassName]]) {
        tableViewCell = [self.tableView dequeueReusableCellWithIdentifier:kLITLyricsTableViewCellIdentifier];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PFObject *lyricObject = [query getObjectWithId:referenceId];
            NSAssert([lyricObject isKindOfClass:[LITLyric class]], @"Unexpected class for object");
            dispatch_async(dispatch_get_main_queue(), ^{
                [LITLyric updateCell:(LITLyricsTableViewCell *)tableViewCell withObject:(LITLyric *)lyricObject];
            });
        });
        //        [((LITLyricsTableViewCell *)tableViewCell).addButton setTag:indexPath.row];
        //        [((LITLyricsTableViewCell *)tableViewCell).likeButton setTag:indexPath.row];
        //        [((LITLyricsTableViewCell *)tableViewCell).optionsButton setTag:indexPath.row];
        
        [((LITLyricsTableViewCell *)tableViewCell).addButton setHidden:YES];
        [((LITLyricsTableViewCell *)tableViewCell).likeButton setHidden:YES];
        [((LITLyricsTableViewCell *)tableViewCell).optionsButton setHidden:YES];
        
//        [((LITLyricsTableViewCell *)tableViewCell).fullHeaderButton setTag:indexPath.row];
//        [((LITLyricsTableViewCell *)tableViewCell).fullHeaderButton addTarget:self action:@selector(headerPressed:) forControlEvents:UIControlEventTouchUpInside];
        
    } else if ([referenceClass isEqualToString:[LITSoundbite parseClassName]]) {
        tableViewCell = [self.tableView dequeueReusableCellWithIdentifier:kLITSoundbiteTableViewCellIdentifier];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PFObject *soundbiteObject = [query getObjectWithId:referenceId];
            NSAssert([soundbiteObject isKindOfClass:[LITSoundbite class]], @"Unexpected class for object");
            [_playerHelper getDataForSoundbite:(LITSoundbite *)soundbiteObject atIndexPath:indexPath withCompletionBlock:^(NSURL *fileURL, NSError *error) {
                if (!error) {
                    [((LITSoundbiteTableViewCell *)tableViewCell) initHistogramViewWithFileURL:fileURL];
                } else {
                    NSLog(@"Error setting histogram view: %@", error.localizedDescription);
                }
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                [LITSoundbite updateCell:(LITSoundbiteTableViewCell *)tableViewCell withObject:(LITSoundbite *)soundbiteObject];
            });
        });
//        [((LITSoundbiteTableViewCell *)tableViewCell).addButton setTag:indexPath.row];
//        [((LITSoundbiteTableViewCell *)tableViewCell).likeButton setTag:indexPath.row];
        [((LITSoundbiteTableViewCell *)tableViewCell).playButton setTag:indexPath.row];
//        [((LITSoundbiteTableViewCell *)tableViewCell).optionsButton setTag:indexPath.row];
        
        [((LITSoundbiteTableViewCell *)tableViewCell).addButton setHidden:YES];
        [((LITSoundbiteTableViewCell *)tableViewCell).likeButton setHidden:YES];
        [((LITSoundbiteTableViewCell *)tableViewCell).optionsButton setHidden:YES];
        
        [((LITSoundbiteTableViewCell *)tableViewCell).playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
//        [((LITSoundbiteTableViewCell *)tableViewCell).fullHeaderButton setTag:indexPath.row];
//        [((LITSoundbiteTableViewCell *)tableViewCell).fullHeaderButton addTarget:self action:@selector(headerPressed:) forControlEvents:UIControlEventTouchUpInside];

    } else if ([referenceClass isEqualToString:[LITDub parseClassName]]) {
        tableViewCell = [self.tableView dequeueReusableCellWithIdentifier:kLITDubTableViewCellIdentifier];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PFObject *dubObject = [query getObjectWithId:referenceId];
            NSAssert([dubObject isKindOfClass:[LITDub class]], @"Unexpected class for object");
            dispatch_async(dispatch_get_main_queue(), ^{
                [LITDub updateCell:(LITDubTableViewCell *)tableViewCell withObject:(LITDub *)dubObject];
            });
        });
//        [((LITDubTableViewCell *)tableViewCell).addButton setTag:indexPath.row];
//        [((LITDubTableViewCell *)tableViewCell).likeButton setTag:indexPath.row];
//        [((LITDubTableViewCell *)tableViewCell).optionsButton setTag:indexPath.row];
        
        [((LITDubTableViewCell *)tableViewCell).addButton setHidden:YES];
        [((LITDubTableViewCell *)tableViewCell).likeButton setHidden:YES];
        [((LITDubTableViewCell *)tableViewCell).optionsButton setHidden:YES];
        
//        [((LITDubTableViewCell *)tableViewCell).fullHeaderButton setTag:indexPath.row];
//        [((LITDubTableViewCell *)tableViewCell).fullHeaderButton addTarget:self action:@selector(headerPressed:) forControlEvents:UIControlEventTouchUpInside];
        
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"Object doesn't match any of expected types"];
    }
    
    return (PFTableViewCell *)tableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [self.objects count]) {
        return 50.0f;
    }
    NSString *referenceClassName = [[self.objects objectAtIndex:indexPath.row] objectForKey:kMainFeedClassKey];
    if ([referenceClassName isEqualToString:[LITSoundbite parseClassName]]) {
        //Will get a soundbite
        return kLITSoundbiteCellHeight;
    } else if ([referenceClassName isEqualToString:[LITDub parseClassName]]) {
        return kLITDubCellHeight;
    } else if ([referenceClassName isEqualToString:[LITLyric parseClassName]]) {
        return kLITLyricsCellHeight;
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"Unexpected object class"];
    }
    return 0.0f;
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable
{
    PFQuery *baseQuery = [super queryForTable];
    //    [baseQuery fromLocalDatastore];
    
    return [baseQuery whereKey:kUserCreatedContentUserKey equalTo:self.user];
}

- (void)objectsDidLoad:(nullable NSError *)error
{
    [super objectsDidLoad:error];
    if (self.hud) {
        [self.hud dismiss];
        self.hud = nil;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if(self.objects && self.firstTime){
        self.hud = [LITProgressHud createHudWithMessage:@"Loading content..."];
        [self.hud showInView:self.view];
        self.firstTime = NO;
    }
}
/*
#pragma mark - Actions

- (void)headerPressed:(UIButton *)headerButton
{
    NSArray *favsArray = [[[[self.objects objectAtIndex:0] objectForKey:kFavKeyboardContentsKey] reverseObjectEnumerator] allObjects];
    
    Class class = [[favsArray objectAtIndex:headerButton.tag] class];
    
    NSString *className = @"";
    if(class == [LITSoundbite class]){
        className = @"soundbite";
    }
    else if(class == [LITDub class]){
        className = @"dub";
    }
    else if(class == [LITLyric class]){
        className = @"lyric";
    }
    
    NSString *referenceID = [[favsArray objectAtIndex:headerButton.tag] valueForKey:@"objectId"];
    
    [[PFQuery queryWithClassName:className] getObjectInBackgroundWithId:referenceID block:^(PFObject *object, NSError *error) {
        NSAssert([NSThread isMainThread], @"This call must be run on the main thread");
        if (!error) {
            
            PFUser *objectOwner;
            if([object isKindOfClass:[LITSoundbite class]]){
                objectOwner = ((LITSoundbite *)object).user;
            }
            else if([object isKindOfClass:[LITDub class]]){
                objectOwner = ((LITDub *)object).user;
            }
            else if([object isKindOfClass:[LITLyric class]]){
                objectOwner = ((LITLyric *)object).user;
            }
            
            // Prevent pushin the same profile already presented again
            if(objectOwner == self.user) {
                return;
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(showProfileOfUser:)]) {
                [self.delegate showProfileOfUser:objectOwner];
            }
        }
    }];
}
*/

#pragma mark Invocation Forwarding
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([_playerHelper respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:_playerHelper];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature* signature = [super methodSignatureForSelector:selector];
    if (!signature) {
        signature = [_playerHelper methodSignatureForSelector:selector];
    }
    return signature;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector] ||
        [_playerHelper respondsToSelector:aSelector])
    {
        return YES;
    }
    return NO;
}
@end
