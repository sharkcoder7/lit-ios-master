//
//  LITKeyboardNoAccessViewController.h
//  lit-ios
//
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LITKeyboardsBaseViewController.h"

@protocol LITKeyboardNoAccessDelegate;

@interface LITKeyboardNoAccessViewController : UIViewController

@property (strong, nonatomic) UIButton *fireButton;
@property (strong, nonatomic) UIButton *appButton;
@property (strong, nonatomic) UILabel *lineOneLabel;
@property (strong, nonatomic) UILabel *lineTwoLabel;

@property (strong, nonatomic) LITKeyboardsBaseViewController *parentController;
@property (strong, nonatomic) UIView *titleView;
@property (nonatomic, strong) UIButton *nextKeyboardButton;
@property (nonatomic, strong) UIButton *deleteButton;

@property (weak, nonatomic) id<LITKeyboardNoAccessDelegate> delegate;

- (void)setupControllerWithHeight:(CGFloat)height andAppButtonVisible:(BOOL)appButtonVisible;
- (void)setupNoFullAccessConstraints;

@end

@protocol LITKeyboardNoAccessDelegate <NSObject>

- (void) didTapFireButton:(LITKeyboardNoAccessViewController *) noAccessVC;
- (void) didTapAppButton:(LITKeyboardNoAccessViewController *) noAccessVC;
- (void) didTapDeleteButton:(LITKeyboardNoAccessViewController *) noAccessVC;

@end
