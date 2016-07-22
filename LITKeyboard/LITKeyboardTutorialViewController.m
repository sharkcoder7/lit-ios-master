//
//  LITKeyboardTutorialViewController.m
//  lit-ios
//
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import "LITKeyboardTutorialViewController.h"
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"

@interface LITKeyboardTutorialViewController ()

@property (assign, nonatomic) NSInteger page;

@property (weak, nonatomic) IBOutlet UIButton *firstButton;
@property (weak, nonatomic) IBOutlet UIButton *secondButton;
@property (weak, nonatomic) IBOutlet UIButton *thirdButton;
@property (weak, nonatomic) IBOutlet UIButton *fourthButton;

@property (weak, nonatomic, readwrite) IBOutlet UILabel *nowPasteLabel;

@property (strong, nonatomic) NSTimer *firstOvalBlinkTimer;
@property (weak, nonatomic) IBOutlet UIImageView *firstViewTextBarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *firstViewPasteImageView;
@property (weak, nonatomic) IBOutlet UIImageView *firstViewOvalImageView;
@property (weak, nonatomic) IBOutlet UILabel *firstCopyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *firstViewArrowUp;

@property (weak, nonatomic) IBOutlet UIImageView *secondViewCellImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondViewOvalImageView;
@property (weak, nonatomic) IBOutlet UILabel *secondViewTextLabel;

@property (weak, nonatomic) IBOutlet UIImageView *thirdViewLeftKBImageView;
@property (weak, nonatomic) IBOutlet UIImageView *thirdViewRightKBImageView;
@property (weak, nonatomic) IBOutlet UIImageView *thirdViewHandImageView;
@property (weak, nonatomic) IBOutlet UILabel *thirdViewTextLabel;

@property (weak, nonatomic) IBOutlet UIImageView *fourthViewKBImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fourthViewHandImageView;
@property (weak, nonatomic) IBOutlet UILabel *fourthViewTextLabel;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation LITKeyboardTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.page = 0;
    
    self.nowPasteLabel.alpha = 0;
    self.firstViewOvalImageView.alpha = 0;
    self.firstViewTextBarImageView.alpha = 0;
    self.firstViewPasteImageView.alpha = 0;
    self.firstButton.alpha = 0;
    self.firstCopyLabel.alpha = 0;
    self.firstViewArrowUp.alpha = 0;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width*3,
                                               self.view.frame.size.height)];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width*3,
                                               self.view.frame.size.height)];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width*3,
                                               self.view.frame.size.height)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:.5 delay:.2 options: UIViewAnimationOptionCurveLinear animations:^
    {
        self.nowPasteLabel.alpha = 0;
        self.firstViewOvalImageView.alpha = 1;
        self.firstViewTextBarImageView.alpha = 1;
        self.firstViewPasteImageView.alpha = 1;
        self.firstCopyLabel.alpha = 1;
        self.firstButton.alpha = 1;
        self.firstViewArrowUp.alpha = 1;
    }
    completion:^(BOOL finished){}
    ];
    
    // Bar -> Paste -> OK -> Oval (then blinks once)
    [UIView animateWithDuration:.5 delay:0.5 options: UIViewAnimationOptionCurveLinear animations:^ {
        self.firstViewTextBarImageView.alpha = 1;
    }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0 delay:0 options: UIViewAnimationOptionCurveLinear animations:^ {
                             self.firstViewOvalImageView.alpha = 1;
                         }
                                          completion:^(BOOL finished){
                                              [UIView animateWithDuration:.5 delay:0 options: UIViewAnimationOptionCurveLinear animations:^ {
                                                  self.firstViewPasteImageView.alpha = 1;
                                                  self.firstViewOvalImageView.alpha = 0;
                                              }
                                                               completion:^(BOOL finished){
                                                                   [UIView animateWithDuration:.5 delay:0 options: UIViewAnimationOptionCurveLinear animations:^ {
                                                                       self.firstButton.alpha = 1;
                                                                   }
                                                                                    completion:^(BOOL finished){
                                                                                        [UIView animateWithDuration:0 delay:1 options: UIViewAnimationOptionCurveLinear animations:^ {
                                                                                            self.firstViewPasteImageView.alpha = 1;
                                                                                            self.firstViewOvalImageView.alpha = 0;
                                                                                        }
                                                                                                         completion:^(BOOL finished){
                                                                                                             /*
                                                                                                              self.firstOvalBlinkTimer =
                                                                                                              [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(animateFirstOvalBlink) userInfo:nil repeats:YES];
                                                                                                              [self.firstOvalBlinkTimer fire];
                                                                                                              */
                                                                                                             
                                                                                                             self.firstOvalBlinkTimer = [NSTimer timerWithTimeInterval:2
                                                                                                                                                                target:self
                                                                                                                                                              selector:@selector(animateFirstOvalBlink)
                                                                                                                                                              userInfo:nil repeats:YES];
                                                                                                             
                                                                                                             [[NSRunLoop mainRunLoop] addTimer:self.firstOvalBlinkTimer forMode:NSRunLoopCommonModes];
                                                                                                         }
                                                                                         ];
                                                                                    }
                                                                    ];
                                                               }
                                               ];
                                          }
                          ];
                     }
     ];
    
    
    // Now scroll
    [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width*self.page,
                                                  self.scrollView.contentOffset.y)
                             animated:YES];
}

- (void)animateFirstOvalBlink {
    self.firstViewPasteImageView.alpha = 1;
    self.firstViewOvalImageView.alpha = 0;
/*
    [UIView animateWithDuration:.2 delay:0 options: UIViewAnimationOptionCurveLinear animations:^
        {
            self.firstViewOvalImageView.alpha = 1;
        }
        completion:^(BOOL finished){
            [UIView animateWithDuration:.7 delay:0 options: UIViewAnimationOptionCurveLinear animations:^
                {
                    self.firstViewPasteImageView.alpha = 1;
                    self.firstViewOvalImageView.alpha = 0;
                }
                completion:^(BOOL finished){
                    [UIView animateWithDuration:.2 delay:.9 options: UIViewAnimationOptionCurveLinear animations:^
                        {
                            self.firstViewPasteImageView.alpha = 0;
                        }
                        completion:^(BOOL finished){}
                     ];
                }
             ];
        }
    ];
*/
}

#pragma mark UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"Scroll view did scroll");
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.page = page;
    [self.pageControl setCurrentPage:self.page];    
}


#pragma mark Actions

- (IBAction)buttonAction:(id)sender {
    self.page++;
    [self.pageControl setCurrentPage:self.page];
    
    switch (((UIButton *)sender).tag) {
        case 1:
        {
            [[Mixpanel sharedInstance] track:kMixpanelAction_keyExt_OK_Onboard1 properties:nil];
            
            /*
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.firstOvalBlinkTimer invalidate];
                self.firstOvalBlinkTimer = nil;
            });
             */
            self.firstOvalBlinkTimer = nil;
            self.secondViewCellImageView.alpha = 0;
            self.secondViewOvalImageView.alpha = 0;
            self.secondViewTextLabel.alpha = 0;
            self.secondButton.alpha = 1;
            self.secondButton.enabled = YES;
            
            [UIView animateWithDuration:.3 delay:.1 options: UIViewAnimationOptionCurveLinear animations:^
                {
                    self.secondViewCellImageView.alpha = 1;
                    self.secondViewOvalImageView.alpha = 1;
                    self.secondViewTextLabel.alpha = 1;
                }
                completion:^(BOOL finished){
                    [UIView animateWithDuration:0 delay:.3 options: UIViewAnimationOptionCurveLinear animations:^
                        {
                            self.secondViewOvalImageView.alpha = 0;
                        }
                        completion:^(BOOL finished){
                            [UIView animateWithDuration:.8 delay:0 options: UIViewAnimationOptionCurveLinear animations:^
                                {
                                    self.secondViewOvalImageView.alpha = 1;
                                }
                                completion:^(BOOL finished){
                                    [UIView animateWithDuration:.5 delay:.5 options: UIViewAnimationOptionCurveLinear animations:^
                                     {
                                         self.secondButton.alpha = 1;
                                     }
                                     completion:^(BOOL finished) {
                                         self.secondButton.enabled = YES;
                                     }
                                     ];
                                }
                             ];
                        }
                     ];
                }
            ];
            
            break;
        }
        case 2:
        {
            [[Mixpanel sharedInstance] track:kMixpanelAction_keyExt_OK_Onboard2 properties:nil];
            
            self.thirdViewHandImageView.alpha = 0;
            self.thirdViewLeftKBImageView.alpha = 0;
            self.thirdViewRightKBImageView.alpha = 0;
            self.thirdViewTextLabel.alpha = 0;
            self.thirdButton.alpha = 1;
            self.thirdButton.enabled = YES;
            
            [UIView animateWithDuration:.3 delay:.1 options: UIViewAnimationOptionCurveLinear animations:^
             {
                 self.thirdViewHandImageView.alpha = 1;
                 self.thirdViewLeftKBImageView.alpha = 1;
                 self.thirdViewRightKBImageView.alpha = 1;
                 self.thirdViewTextLabel.alpha = 1;
             }
             completion:^(BOOL finished){
                 [UIView animateWithDuration:.3 delay:1 options: UIViewAnimationOptionCurveLinear animations:^
                    {
                        self.thirdButton.alpha = 1;
                    }
                    completion:^(BOOL finished){
                        self.thirdButton.enabled = YES;
                    }
                  ];
                  }
             ];
            
            break;
        }
        case 3:
        {
            [[Mixpanel sharedInstance] track:kMixpanelAction_keyExt_OK_Onboard3 properties:nil];
            
            [UIView animateWithDuration:.3 delay:0 options: UIViewAnimationOptionCurveLinear animations:^
             {
                 self.view.alpha = 0;
             }
             completion:^(BOOL finished) {
                 //NSLog(@"calling delegate to dissmiss this controller");
                 //[self.delegate didTapLastButtonOfTutorial:self];
                 [self.view removeFromSuperview];
             }];
            
            break;
        }
    }
    
    // After the animations have been set to be done, we scroll the content
    if(((UIButton *)sender).tag < 4)
    [self.scrollView setContentOffset:
     CGPointMake(self.view.frame.size.width*self.page,
                 self.scrollView.contentOffset.y)
                             animated:YES];
}

# pragma mark Class Methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
