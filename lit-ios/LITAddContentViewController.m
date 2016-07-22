//
//  LITAddContentViewController.m
//  lit-ios
//
//  Created by ioshero on 19/11/2015.
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import "LITAddContentViewController.h"
#import "LITKeyboard.h"

@interface LITAddContentViewController ()
@property (weak, nonatomic) IBOutlet UILabel *congratsLabel;
@property (weak, nonatomic) IBOutlet UIButton *soundbiteButton;
@property (weak, nonatomic) IBOutlet UIButton *dubButton;
@property (weak, nonatomic) IBOutlet UIButton *lyricButton;

@end

@implementation LITAddContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.congratsLabel.text = [NSString stringWithFormat:@"Add content to keyboard \"%@\"", self.keyboard.displayName];
    
    self.soundbiteButton.layer.borderWidth = self.dubButton.layer.borderWidth = self.lyricButton.layer.borderWidth = 1.0;
    self.soundbiteButton.layer.cornerRadius = self.dubButton.layer.cornerRadius = self.lyricButton.layer.cornerRadius = 2.0;
    self.soundbiteButton.layer.borderColor = self.dubButton.layer.borderColor = self.lyricButton.layer.borderColor
        = [[UIColor whiteColor] CGColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Actions
- (IBAction)soundbiteButtonTapped:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(addContentViewControllerDidSelectSoundbiteOption:)]) {
        [self.delegate addContentViewControllerDidSelectSoundbiteOption:self];
    }
}

- (IBAction)dubButtonTapped:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(addContentViewControllerDidSelectDubOption:)]) {
        [self.delegate addContentViewControllerDidSelectDubOption:self];
    }
}

- (IBAction)lyricButtonTapped:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(addContentViewControllerDidSelectLyricOption:)]) {
        [self.delegate addContentViewControllerDidSelectLyricOption:self];
    }
}
- (IBAction)closeButtonTapped:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(addContentViewControllerDidRequestClose:)]) {
        [self.delegate addContentViewControllerDidRequestClose:self];
    }
}

@end
