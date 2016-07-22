//
//  LITDubPreviewViewController.m
//  lit-ios
//
//  Created by ioshero on 15/07/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITDubPreviewViewController.h"
#import "LITTaggingViewController.h"
#import "LITDub.h"
#import "LITSoundbite.h"
#import "UIViewController+CaptionInput.h"
#import "AVUtils.h"
#import "LITProgressHud.h"
#import "UIView+GradientBackground.h"
#import <Parse/PFUser.h>

NSString *const kLITDubPreviewSegueIdentifier = @"DubShowPreview";

@interface LITDubPreviewViewController()
@property (weak, nonatomic) IBOutlet SCVideoPlayerView *videoPlayerView;
@property (strong, nonatomic) SCPlayer *player;
@property (strong, nonatomic) LITDub *dub;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;

@property (assign, nonatomic) BOOL mute;

@property CGFloat currentKeyboardHeight;

@end


@implementation LITDubPreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.player = [SCPlayer player];

    [self.videoPlayerView setPlayer:self.player];
    self.videoPlayerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    self.player.loopEnabled = YES;
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"UPLOAD" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed:)];
    [button setTitleTextAttributes: @{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f], NSForegroundColorAttributeName: [UIColor whiteColor], NSBackgroundColorAttributeName : [UIColor clearColor]} forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItem = button;
    
    [self.view setupGradientBackground];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    self.currentKeyboardHeight = 0.0f;
    
    [self.muteButton setAlpha:1];
    self.mute = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.player setItem:self.mixedVideo];
    [self.player play];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeEffectViewFromNavigationBar];
    [self.player pause];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.currentKeyboardHeight = kbSize.height;
}

#pragma mark - actions 
- (void)doneButtonPressed:(UIBarButtonItem *)button
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.player pause];
    
    [self showKeyboardWithPlaceholder:@"Add dub name..." andCompletionBlock:^(NSString *text, NSError *error) {
        
        int textFieldHeight = 60;
        
        JGProgressHUD *savingHud = [LITProgressHud createHudWithMessage:@"Saving dub..."];
        int hudRectW = self.view.frame.size.width;
        int hudRectH;
        int hudRectX = 0;
        int hudRectY;
        if(self.view.window.rootViewController.navigationController.navigationBarHidden){
            hudRectY = 0;
            hudRectH = hudRectY + self.view.frame.size.height - self.currentKeyboardHeight - self.view.inputAccessoryView.frame.size.height - textFieldHeight;
        }
        else{
            hudRectY = self.navigationController.navigationBar.frame.size.height;
            hudRectH = hudRectY + self.view.frame.size.height - self.currentKeyboardHeight - self.view.inputAccessoryView.frame.size.height - textFieldHeight;
        }
        [savingHud showInRect:CGRectMake(hudRectX,hudRectY,hudRectW,hudRectH) inView:self.view];
        [AVUtils generateThumbnailForVideoAtURL:self.mixedVideoURL
                            withCompletionBlock:^(PFFile *image, NSError *anotherError) {
            if (image && !anotherError) {
                self.dub = [LITDub object];
                self.dub.user = [PFUser currentUser];
                self.dub.caption = text;
                self.dub.video = [PFFile fileWithName:@"dubVideo.mp4" contentsAtPath:self.mixedVideoURL.path];
                self.dub.snapshot = image;
                [self.soundbite.song incrementKey:kSongTimesUsedKey];
                self.dub.soundbite = self.soundbite;
                
                [savingHud dismiss];
                
                [self performSegueWithIdentifier:kLITPresentTagsForDubSegueIdentifier sender:nil];
            } else {
                NSLog(@"Error generating thumbnails: %@", error.localizedDescription);
            }
        }];
    }];
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kLITPresentTagsForDubSegueIdentifier]) {
        LITTaggingViewController *tagController = segue.destinationViewController;
        NSAssert([tagController isKindOfClass:[LITTaggingViewController class]], @"Destination controller must be of class LITTaggingViewController");
        tagController.content = self.dub;
    }
}

- (IBAction)muteButtonPressed:(id)sender {
    
    self.mute = !self.mute;
    
    if(self.mute){
        [self.muteButton setBackgroundImage:[UIImage imageNamed:@"soundOn"] forState:UIControlStateNormal];
    }
    else{
        [self.muteButton setBackgroundImage:[UIImage imageNamed:@"mute"] forState:UIControlStateNormal];
    }
    
    if (self.mute) {
        self.player.volume = 0.0f;
    } else
        self.player.volume = 1.0f;
}


@end
