//
//  LITLyricCreationViewController.m
//  lit-ios
//
//  Created by ioshero on 23/07/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITLyricCreationViewController.h"
#import "LITKeyboard.h"
#import "LITLyric.h"
#import "LITSong.h"
#import "LITTheme.h"
#import "UIView+GradientBackground.h"
#import "UIViewController+KeyboardAnimator.h"
#import "LITAddToKeyboardViewController.h"
#import "LITKeyboardInstallerHelper.h"
#import "LITProgressHud.h"
#import "LITGlobals.h"

#import "ParseGlobals.h"
#import <Bolts/Bolts.h>
#import <JVFloatLabeledTextField.h>
#import <JVFloatLabeledTextView.h>
#import <AFViewShaker/AFViewShaker.h>
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"



#import <UITextView+Placeholder/UITextView+Placeholder.h>

NSString *const kLITLyricCreationSegue = @"LyricCreationSegue";
static NSString *const kLITCharsLeftFormatString = @"%lu characters left";

@interface LITLyricCreationViewController () <LITAddToKeyboardViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *charactersLabel;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextView *lyricTextView;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *artistTextField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *songTextField;

@property (weak, nonatomic) IBOutlet UILabel *warningLabel;

@property (strong, nonatomic) LITLyric *lyric;

@property (strong, nonatomic) JGProgressHUD *hud;

@end

@implementation LITLyricCreationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.warningLabel setHidden:YES];
    
    UIColor *floatingColor = [UIColor whiteColor];
    UIColor *placeholderColor = [UIColor colorWithWhite:1 alpha:.5];
    
    self.artistTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"ARTIST NAME" attributes:@{NSForegroundColorAttributeName: placeholderColor}];
    self.artistTextField.floatingLabelTextColor = floatingColor;
    self.artistTextField.translatesAutoresizingMaskIntoConstraints = NO;

    self.songTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"SONG NAME" attributes:@{NSForegroundColorAttributeName: placeholderColor}];
    self.songTextField.floatingLabelTextColor = floatingColor;
    self.songTextField.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.lyricTextView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"LYRIC" attributes:@{NSForegroundColorAttributeName: placeholderColor}];
    self.lyricTextView.floatingLabelTextColor = floatingColor;
    
    // iPhone 4s has a smaller font for the lyric creation
    if([[UIScreen mainScreen] bounds].size.height < 560){
        self.artistTextField.font = [UIFont fontWithName:@"AvenirNext-Medium" size:14.0f];
        self.songTextField.font = [UIFont fontWithName:@"AvenirNext-Medium" size:14.0f];
        self.lyricTextView.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:11.0f];
    }
    // iPhone 5/5s
    else if([[UIScreen mainScreen] bounds].size.height < 600){
        self.artistTextField.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
        self.songTextField.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
        self.lyricTextView.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:14.0f];
    }
    // iPhone 6/6s
    else{
        self.artistTextField.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
        self.songTextField.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
        self.lyricTextView.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:18.0f];
    }
    
    
    self.artistTextField.delegate = self;
    self.songTextField.delegate = self;
    self.lyricTextView.delegate = self;
    
    
    [self.lyricTextView setBackgroundColor:[UIColor clearColor]];
    [self.charactersLabel setText:[NSString stringWithFormat:kLITCharsLeftFormatString, (unsigned long)kLyricsMaxLenght]];
    
    self.navigationItem.title = @"New Lyric";
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(nextButtonTapped:)];
    self.navigationItem.rightBarButtonItem = nextButton;
    
    [self setupKeyboardAnimations];
    
    [self.view setupGradientBackground];
    // Tap the view to dismiss the keyboard
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(singleTapAction:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
    //
    
    [self.artistTextField becomeFirstResponder];
}

- (void)singleTapAction:(UITapGestureRecognizer *)recognizer {
    [self.lyricTextView resignFirstResponder];
    [self.artistTextField resignFirstResponder];
    [self.songTextField resignFirstResponder];
}

- (void)dealloc
{
    [self discardKeyboardAnimations];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [[Mixpanel sharedInstance] track:kMixpanelAction_newLyric_lyricForm properties:nil];
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSUInteger length;
    length = [textView.text length];
    [self.charactersLabel setText:[NSString stringWithFormat:kLITCharsLeftFormatString, (unsigned long)kLyricsMaxLenght - length]];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if ([text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location != NSNotFound) {
        return NO;
    }
    
    if(range.length + range.location > textView.text.length)
        return NO;
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return (newLength > kLyricsMaxLenght) ? NO : YES;
}

#pragma mark UITextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if(textField == self.artistTextField){
        [[Mixpanel sharedInstance] track:kMixpanelAction_newLyric_artist properties:nil];
    }
    else if(textField == self.songTextField){
        [[Mixpanel sharedInstance] track:kMixpanelAction_newLyric_songName properties:nil];
    }
}

#pragma mark - Actions

- (void)nextButtonTapped:(UIBarButtonItem *)button
{
    // If the artist, the song, or the lyric are not inserted, we
    // shake the warning message and block the operation
    
    if([self.artistTextField.text length] == 0 ||
       [self.songTextField.text length] == 0 ||
       [self.lyricTextView.text length] == 0){
        [self.lyricTextView setHidden:YES];
        
        if([self.artistTextField.text length] == 0 ||
           [self.songTextField.text length] == 0){
            self.warningLabel.text = @"Please enter an artist and song name 😅";
        }
        else if([self.lyricTextView.text length] == 0){
            self.warningLabel.text = @"Please enter the lyric text 😅";
        }
        
        [self.warningLabel setHidden:NO];
        
        AFViewShaker *shaker = [[AFViewShaker alloc] initWithView:self.warningLabel];
        [shaker shakeWithDuration:2 completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.warningLabel setHidden:YES];
                [self.lyricTextView setHidden:NO];
            });
        }];
    }
    
    else {
     
        // Look for the song, just in case it has already been created
        PFQuery *query = [PFQuery queryWithClassName:kParseSongPath];
        [query whereKey:kLITSongTitle equalTo:self.songTextField.text];
        [query whereKey:kLITSongArtist equalTo:self.artistTextField.text];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                
                // The song exists
                if([objects count] > 0){
                    PFObject *theSong = [objects objectAtIndex:0];
                    LITLyric *lyric = [LITLyric object];
                    lyric.text = self.lyricTextView.text;
                    lyric.song = (LITSong *)theSong;
                    lyric.user = [PFUser currentUser];
                    lyric.tags = [NSString stringWithFormat:@"%@;%@;%@",[lyric.song.artist lowercaseString],[lyric.song.title lowercaseString], [lyric.text lowercaseString]];
                    [self.song incrementKey:kSongTimesUsedKey];
                    self.lyric = lyric;
                    
                    [[Mixpanel sharedInstance] track:kMixpanelAction_newLyric_Done properties:nil];
                    
                    LITAddToKeyboardViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:kLITAddToKeyboardViewControllerStoryboardIdentifier];
                    viewController.object = self.lyric;
                    viewController.callingController = self;
                    viewController.delegate = self;
                    viewController.showsUploadButton = YES;
                    [self.navigationController pushViewController:viewController animated:YES];
                }
                else{
                    
                    // Create the song
                    LITSong *song = [LITSong object];
                    song.timesUsed = 0;
                    song.albumName = @"N/A";
                    song.artist = self.artistTextField.text;
                    song.title = self.songTextField.text;
                    
                    LITLyric *lyric = [LITLyric object];
                    lyric.text = self.lyricTextView.text;
                    lyric.song = song;
                    lyric.user = [PFUser currentUser];
                    lyric.tags = [NSString stringWithFormat:@"%@;%@;%@",[lyric.song.artist lowercaseString],[lyric.song.title lowercaseString], [lyric.text lowercaseString]];
                    [self.song incrementKey:kSongTimesUsedKey];
                    self.lyric = lyric;
                    
                    [[Mixpanel sharedInstance] track:kMixpanelAction_newLyric_Done properties:nil];
                    
                    if (!self.destinationKeyboard) {
                        LITAddToKeyboardViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:kLITAddToKeyboardViewControllerStoryboardIdentifier];
                        viewController.object = self.lyric;
                        viewController.callingController = self;
                        viewController.delegate = self;
                        viewController.showsUploadButton = YES;
                        [self.navigationController pushViewController:viewController animated:YES];
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.hud = [LITProgressHud createHudWithMessage:@"Adding..."];
                            [self.hud showInView:self.view];
                        });
                        if(![self.destinationKeyboard.contents containsObject:lyric]){
                            [self saveKeyboardInBackground:self.destinationKeyboard withObject:lyric andSaveBlock:^(BOOL succeeded, NSError * __nullable error) {
                                [[LITKeyboardInstallerHelper installKeyboard:self.destinationKeyboard fromViewController:self] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                                    if (!task.error) {
                                        NSLog(@"Content added successfully");
                                        [[NSNotificationCenter defaultCenter] postNotificationName:kLITAddedContentToKeyboardNotificationName object:self userInfo:nil];
                                    }
                                    [self.hud removeFromSuperview];
                                    self.hud = nil;
                                    [self dismissViewControllerAnimated:YES completion:nil];
                                    return nil;
                                }];
                            }];
                        }
                    }
                }
                
                return;
            }
            return;
        }];
    }
}

#pragma mark - LITAddToKeyboardViewControllerDelegate
- (void)keyboardsController:(LITAddToKeyboardViewController *)controller didSelectKeyboard:(LITKeyboard *)keyboard forObject:(PFObject *)object showCongrats:(BOOL)show inViewController:viewController;
{
    [self.navigationController popViewControllerAnimated:YES];
    
    void(^finishBlock)(BOOL, NSError *) = ^(BOOL succeeded, NSError *__nullable error) {
        if (error) {
            self.hud = [LITProgressHud createHudWithMessage:@""];
            [LITProgressHud changeStateOfHUD:self.hud to:kLITHUDStateError withMessage:@"Error creating\nthe lyric"];
            [self.hud showInView:self.view];
            [self.hud dismissAfterDelay:1.5];
        } else {
            self.hud = [LITProgressHud createHudWithMessage:@""];
            [LITProgressHud changeStateOfHUD:self.hud to:kLITHUDStateDone withMessage:@"Lyric created"];
            [self.hud showInView:self.view];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .75 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.hud dismiss];
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        }
    };
    if (!keyboard) {
        [object saveInBackgroundWithBlock:finishBlock];
    } else {
        NSLog(@"Selected keyboard");
        [self saveKeyboardInBackground:keyboard withObject:object andSaveBlock:finishBlock];
    }
}

#pragma mark - Object Saving
- (void)saveKeyboardInBackground:(LITKeyboard *)keyboard withObject:(PFObject *)object andSaveBlock:(PFBooleanResultBlock)saveBlock
{
    [keyboard addObject:object forKey:kLITKeyboardContentsKey];
    [keyboard saveInBackgroundWithBlock:saveBlock];
}



@end
