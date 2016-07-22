//
//  LITAddSoundbiteViewController.m
//  slit-ios
//
//  Created by ioshero on 07/07/2015.
//  Copyright (c) 2015 Slit Inc. All rights reserved.
//

#import "LITTheme.h"
#import "LITProgressHud.h"
#import "LITSoundbitesViewController.h"
#import "LITSimpleSoundbiteTableViewCell.h"
#import "LITSoundbiteCropSongViewController.h"
#import "LITSoundbite.h"
#import "AVUtils.h"
#import "LITActionSheet.h"
#import "ParseGlobals.h"
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"

NSString *const kSoundbiteCropSongSegueIdentifier         = @"SoundbiteCropSongSegue";
NSString *const kSoundbiteRecordSoundSegueIdentifier      = @"SoundbiteRecordSoundSegue";

@class EZAudioFile;
@interface LITSoundbitesViewController ()

@property (strong, nonatomic) MPMediaPickerController *mediaPickerController;
@property (strong, nonatomic) MPMediaItem *selectedMediaItem;
@property (strong, nonatomic) EZAudioFile *selectedAudioFile;

@property (strong, nonatomic) UIView *sheetHolderView;

@property (strong, nonatomic) JGProgressHUD *hud;

@end


@implementation LITSoundbitesViewController {
    BOOL _alreadyPresented;
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

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchKey = kMainFeedSearchDataKey;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([LITSimpleSoundbiteTableViewCell class])bundle:nil] forCellReuseIdentifier:kLITSimpleSoundbiteTableViewCellIdentifier];
    
    if (self.isAddingToKeyboard) {
        
    }
    self.navigationItem.title = self.isAddingToKeyboard ? @"Add Soundbite" : @"Soundbites";
    
    [searchHelper setSearchPlaceholderText:@"Search for Soundbites"];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    if (_alreadyPresented && ![self.presentedViewController isKindOfClass:[MPMediaPickerController class]]) {
        [self loadObjects:0 clear:YES];
    }
    else if(![self.presentedViewController isKindOfClass:[MPMediaPickerController class]]){
        self.hud = [LITProgressHud createHudWithMessage:@"Loading soundbites..."];
        [self.hud showInView:self.view];
        [self loadObjects:0 clear:YES];
        [self.hud dismiss];
    }
    
    _alreadyPresented = YES;
    
}


#pragma mark - UITableViewDataSource

- (PFTableViewCell *)tableView:(UITableView * __nonnull)tableView cellForRowAtIndexPath:(NSIndexPath * __nonnull)indexPath object:(nullable PFObject *)object
{
    LITSimpleSoundbiteTableViewCell *cell = (LITSimpleSoundbiteTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:kLITSimpleSoundbiteTableViewCellIdentifier];
    NSAssert([cell isKindOfClass:[LITSimpleSoundbiteTableViewCell class]], @"cell must be of class LITSimpleSoundbiteTableViewCell");
    [_playerHelper getDataForSoundbite:(LITSoundbite *)object atIndexPath:indexPath withCompletionBlock:^(NSURL *fileURL, NSError *error) {
        if (!error) {
            [cell initHistogramViewWithFileURL:fileURL];
        } else {
            NSLog(@"Error setting histogram view: %@", error.localizedDescription);
        }
    }];
    [LITSoundbite updateCell:cell withObject:self.objects[indexPath.row]];
    [cell.playButton setTag:indexPath.row];
    [cell.playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
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

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kLITSimpleSoundbiteCellHeight;
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

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kSoundbiteCropSongSegueIdentifier]) {
        LITSoundbiteCropSongViewController *cropController = segue.destinationViewController;
        NSAssert([cropController isKindOfClass:[LITSoundbiteCropSongViewController class]], @"Destination view controller must be of class LITSoundbiteCropSongViewController");
        cropController.mediaItem = self.selectedMediaItem;
        cropController.audioFile = self.selectedAudioFile;
    }
}

#pragma mark Soundbite Player Helper
- (void)playButtonPressed:(UIButton *)sender {
    
    [[Mixpanel sharedInstance] track:kMixpanelAction_previewSound_Soundbites properties:nil];
    
    [_playerHelper playButtonPressed:sender];
}

#pragma mark - Actions
- (void)addButtonPressed:(UIBarButtonItem *)button
{
    [[Mixpanel sharedInstance] track:kMixpanelAction_addNew_Soundbites properties:nil];
    
    JGActionSheetSection *titleSection = [JGActionSheetSection sectionWithTitle:@"Add new Soundbite" message:@"Please select" buttonTitles:nil buttonStyle:JGActionSheetButtonStyleDefault];
    
    JGActionSheetSection *optionsSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"Record",@"Upload from iTunes"] buttonStyle:JGActionSheetButtonStyleDefault];
    
    JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"Cancel"] buttonStyle:JGActionSheetButtonStyleCancel];
    
    
    // LIT Style
    
    [titleSection.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f]];
    [titleSection.titleLabel setTextColor:[UIColor lit_coolGreyColor]];
    [titleSection.messageLabel setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:13.0f]];
    [titleSection.messageLabel setTextColor:[UIColor lit_coolGreyColor]];
    
    for(int i=0; i<[optionsSection.buttons count]; i++){
        [LITActionSheet setButtonStyle:JGActionSheetButtonStyleDefault forButton:[optionsSection.buttons objectAtIndex:i]];
    }
    for(int i=0; i<[cancelSection.buttons count]; i++){
        [LITActionSheet setButtonStyle:JGActionSheetButtonStyleCancel forButton:[cancelSection.buttons objectAtIndex:i]];
    }
    
    // --.
    
    
    NSArray *sections = @[titleSection, optionsSection, cancelSection];
    
    LITActionSheet *sheet = [LITActionSheet actionSheetWithSections:sections];
    
    [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
        
        // Action calls
        NSUInteger section = indexPath.section;
        NSUInteger item = indexPath.item;
        
        switch (section) {
            case 0: // Title
                break;
            case 1: // Options
                if(item == 0){ // Record
                    
                    [[Mixpanel sharedInstance] track:kMixpanelAction_record_Create_Soundbites properties:nil];
                    
                    // Move to record storyboard
                    [self performSegueWithIdentifier:kSoundbiteRecordSoundSegueIdentifier sender:nil];
                }
                else if(item == 1){ // Select song
                    
                    [[Mixpanel sharedInstance] track:kMixpanelAction_useiTunes_Create_Soundbites properties:nil];
                    
                    // Present picker controller
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"JUST KNOW" message:@"You can only create soundbites from songs synced from your computer" preferredStyle:UIAlertControllerStyleAlert];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self.navigationController presentViewController:self.mediaPickerController animated:YES completion:nil];
                    }]];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
                break;
            case 2: // Cancel
                
                [[Mixpanel sharedInstance] track:kMixpanelAction_cancel_Create_Soundbites properties:nil];
                
                break;
            default:
                break;
        }
        
        [sheet dismissAnimated:YES];
        [self.sheetHolderView removeFromSuperview];
    }];
    
    self.sheetHolderView = [[UIView alloc] initWithFrame:CGRectMake(0,-62+self.tableView.contentOffset.y,[[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    [self.sheetHolderView setBackgroundColor:[UIColor clearColor]];

    [self.view addSubview:self.sheetHolderView];
    
    [sheet showInView:self.sheetHolderView animated:YES];
}

#pragma mark - Getters

- (MPMediaPickerController *)mediaPickerController
{
    if (!_mediaPickerController) {
        _mediaPickerController = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
        [_mediaPickerController setDelegate:self];
        //[_mediaPickerController setPrompt:@"Select a song to create a soundbite"];
        [_mediaPickerController setShowsCloudItems:NO];
    }
    
    return _mediaPickerController;
}

 
#pragma mark - MPMediaPickerControllerDelegate
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    NSAssert([mediaItemCollection count] == 1, @"The collection can only contain one element");
    
    self.selectedMediaItem = mediaItemCollection.items[0];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        JGProgressHUD *analysingHud = [LITProgressHud createHudWithMessage:@"Analyzing your song..."];
        [analysingHud showInView:self.view.superview];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [AVUtils openMediaItem:mediaItemCollection.items[0]
                        completion:^(EZAudioFile *audioFile, NSError *error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                if (!error) {
                                    self.selectedAudioFile = audioFile;
                                    [analysingHud dismiss];
                                    [self performSegueWithIdentifier:kSoundbiteCropSongSegueIdentifier sender:nil];
                                }
                                else {
                                    [LITProgressHud changeStateOfHUD:analysingHud to:kLITHUDStateError withMessage:@"Error while saving. Please try again."];
                                    [analysingHud dismissAfterDelay:5.0];
                                }
                            });
                        }];
        });
    }];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark Invocation Forwarding
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([_playerHelper respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:_playerHelper];
    } else if ([searchHelper respondsToSelector:[anInvocation selector]]) {
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
