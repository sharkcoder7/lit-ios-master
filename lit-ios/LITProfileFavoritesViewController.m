//
//  LITProfileFavoritesViewController.m
//  lit-ios
//
//  Created by ioshero on 24/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITProfileFavoritesViewController.h"
#import "ParseGlobals.h"
#import "LITProgressHud.h"
#import "LITLyricsTableViewCell.h"
#import "LITSoundbiteTableViewCell.h"
#import "LITDubTableViewCell.h"
#import "LITDub.h"
#import "LITSoundbite.h"
#import "LITLyric.h"
#import "LITTheme.h"
#import <Bolts/Bolts.h>

@interface LITProfileFavoritesViewController () {}

@property (strong, nonatomic) JGProgressHUD *hud;
@property BOOL firstTime;

@end

@implementation LITProfileFavoritesViewController {
    LITSoundbitePlayerHelper *_playerHelper;
}

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        // Customize the table
        
        // The className to query on
        self.parseClassName = kFavKeyboardClassName;
        
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

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *favsArray = [[[[self.objects objectAtIndex:0] objectForKey:kFavKeyboardContentsKey] reverseObjectEnumerator] allObjects];
    if (indexPath.row >= [favsArray count]) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    PFObject *favObject = [favsArray objectAtIndex:indexPath.row];
    
    UITableViewCell *tableViewCell;
    
    if ([favObject isKindOfClass:[LITLyric class]]) {
        tableViewCell = [self.tableView dequeueReusableCellWithIdentifier:kLITLyricsTableViewCellIdentifier];
        
        [LITLyric updateCell:(LITLyricsTableViewCell *)tableViewCell withObject:(LITLyric *)favObject];
                    
        [((LITLyricsTableViewCell *)tableViewCell).addButton setHidden:NO];
        [((LITLyricsTableViewCell *)tableViewCell).likeButton setHidden:NO];
        [((LITLyricsTableViewCell *)tableViewCell).optionsButton setHidden:YES];
        
        [((LITLyricsTableViewCell *)tableViewCell).fullHeaderButton setTag:indexPath.row];
        [((LITLyricsTableViewCell *)tableViewCell).fullHeaderButton addTarget:self action:@selector(headerPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [((LITLyricsTableViewCell *)tableViewCell).likeButton setTag:indexPath.row];
        [((LITLyricsTableViewCell *)tableViewCell).likeButton addTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [((LITLyricsTableViewCell *)tableViewCell).addButton setTag:indexPath.row];
        [((LITLyricsTableViewCell *)tableViewCell).addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate updateLikeButtonForCell:tableViewCell andObject:favObject];
        });
    
    } else if ([favObject isKindOfClass:[LITSoundbite class]]) {
        tableViewCell = [self.tableView dequeueReusableCellWithIdentifier:kLITSoundbiteTableViewCellIdentifier];
        [_playerHelper getDataForSoundbite:(LITSoundbite *)favObject atIndexPath:indexPath withCompletionBlock:^(NSURL *fileURL, NSError *error) {
            if (!error) {
                [((LITSoundbiteTableViewCell *)tableViewCell) initHistogramViewWithFileURL:fileURL];
            } else {
                NSLog(@"Error setting histogram view: %@", error.localizedDescription);
            }
        }];
        
        [LITSoundbite updateCell:(LITSoundbiteTableViewCell *)tableViewCell withObject:(LITSoundbite *)favObject];
        
        [((LITSoundbiteTableViewCell *)tableViewCell).addButton setHidden:NO];
        [((LITSoundbiteTableViewCell *)tableViewCell).likeButton setHidden:NO];
        [((LITSoundbiteTableViewCell *)tableViewCell).optionsButton setHidden:YES];
        [((LITSoundbiteTableViewCell *)tableViewCell).playButton setTag:indexPath.row];
        [((LITSoundbiteTableViewCell *)tableViewCell).playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [((LITSoundbiteTableViewCell *)tableViewCell).fullHeaderButton setTag:indexPath.row];
        [((LITSoundbiteTableViewCell *)tableViewCell).fullHeaderButton addTarget:self action:@selector(headerPressed:) forControlEvents:UIControlEventTouchUpInside];

        [((LITSoundbiteTableViewCell *)tableViewCell).likeButton setTag:indexPath.row];
        [((LITSoundbiteTableViewCell *)tableViewCell).likeButton addTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [((LITSoundbiteTableViewCell *)tableViewCell).addButton setTag:indexPath.row];
        [((LITSoundbiteTableViewCell *)tableViewCell).addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate updateLikeButtonForCell:tableViewCell andObject:favObject];
        });
        
    } else if ([favObject isKindOfClass:[LITDub class]]) {
        tableViewCell = [self.tableView dequeueReusableCellWithIdentifier:kLITDubTableViewCellIdentifier];
        
        [LITDub updateCell:(LITDubTableViewCell *)tableViewCell withObject:(LITDub *)favObject];
        [((LITDubTableViewCell *)tableViewCell).addButton setHidden:NO];
        [((LITDubTableViewCell *)tableViewCell).likeButton setHidden:NO];
        [((LITDubTableViewCell *)tableViewCell).optionsButton setHidden:YES];

        [((LITDubTableViewCell *)tableViewCell).fullHeaderButton setTag:indexPath.row];
        [((LITDubTableViewCell *)tableViewCell).fullHeaderButton addTarget:self action:@selector(headerPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [((LITDubTableViewCell *)tableViewCell).likeButton setTag:indexPath.row];
        [((LITDubTableViewCell *)tableViewCell).likeButton addTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [((LITDubTableViewCell *)tableViewCell).addButton setTag:indexPath.row];
        [((LITDubTableViewCell *)tableViewCell).addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate updateLikeButtonForCell:tableViewCell andObject:favObject];
        });
        
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"Object doesn't match any of expected types"];
    }
    
    return tableViewCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.objects count] > 0) {
        return [[[self.objects objectAtIndex:0] objectForKey:kFavKeyboardContentsKey] count];
    } else return 0;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *favsArray = [[[[self.objects objectAtIndex:0]
                            objectForKey:kFavKeyboardContentsKey]
                           reverseObjectEnumerator]
                          allObjects];
                          
    PFObject *favObject = [favsArray objectAtIndex:indexPath.row];
    if ([favObject isKindOfClass:[LITSoundbite class]]) {
        return kLITSoundbiteCellHeight;
    } else if ([favObject isKindOfClass:[LITDub class]]) {
        return kLITDubCellHeight;
    } else if ([favObject isKindOfClass:[LITLyric class]]) {
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
    
    NSString *favKeyboardID = ((PFObject *)[self.user objectForKey:kUserFavKeyboardKey]).objectId;
    [baseQuery includeKey:kFavKeyboardContentsKey];
    
    return [baseQuery whereKey:@"objectId" equalTo:favKeyboardID];
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
        self.hud = [LITProgressHud createHudWithMessage:@"Loading favorites..."];
        [self.hud showInView:self.view];
        self.firstTime = NO;
    }
}

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
            
            // Prevent pushing the same profile already presented again
            if(objectOwner == self.user) {
                return;
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(showProfileOfUser:)]) {
                [self.delegate showProfileOfUser:objectOwner];
            }
        }
    }];
}

- (void)likeButtonPressed:(UIButton *)likeButton
{
    NSArray *favsArray = [[[[self.objects objectAtIndex:0]
                            objectForKey:kFavKeyboardContentsKey]
                           reverseObjectEnumerator]
                          allObjects];
    
    NSString *className = [[[favsArray objectAtIndex:likeButton.tag] class] description];
    NSString *referenceID = [[favsArray objectAtIndex:likeButton.tag] valueForKey:@"objectId"];
    
    if([className isEqualToString:@"LITSoundbite"]){className = @"soundbite";}
    else if([className isEqualToString:@"LITDub"]){className = @"dub";}
    else if([className isEqualToString:@"LITLyric"]){className = @"lyric";}
    
    [[PFQuery queryWithClassName:className] getObjectInBackgroundWithId:referenceID block:^(PFObject *object, NSError *error) {
        NSAssert([NSThread isMainThread], @"This call must be run on the main thread");
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:likeButton.tag inSection:0]];
        if (!error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(queryViewController:didTapLikeButton:forObject: withLikesLabel:)]) {
                [self.delegate queryViewController:self didTapLikeButton:likeButton forObject:object withLikesLabel:[cell valueForKey:@"likesLabel"]];
            }
        }
    }];
}

- (void)addButtonPressed:(UIButton *)addButton
{
    NSArray *favsArray = [[[[self.objects objectAtIndex:0]
                            objectForKey:kFavKeyboardContentsKey]
                           reverseObjectEnumerator]
                          allObjects];
    
    NSString *className = [[[favsArray objectAtIndex:addButton.tag] class] description];
    NSString *referenceID = [[favsArray objectAtIndex:addButton.tag] valueForKey:@"objectId"];
    
    if([className isEqualToString:@"LITSoundbite"]){className = @"soundbite";}
    else if([className isEqualToString:@"LITDub"]){className = @"dub";}
    else if([className isEqualToString:@"LITLyric"]){className = @"lyric";}
    
    [[PFQuery queryWithClassName:className] getObjectInBackgroundWithId:referenceID block:^(PFObject *object, NSError *error) {
        NSAssert([NSThread isMainThread], @"This call must be run on the main thread");
        if (!error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(queryViewController:didRequestAddingObject:)]) {
                [self.delegate queryViewController:self didRequestAddingObject:object];
            }
        }
    }];
}

#pragma mark Reloading Methods
-(void)reloadFavoritesCollection {
    [self loadObjects];
}


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
