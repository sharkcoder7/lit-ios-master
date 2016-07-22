//
//  KeyboardViewController.h
//  LITKeyboard
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LITKeyboardsBaseViewControllerDelegate;

@interface LITKeyboardsBaseViewController : UIInputViewController

@property (assign, nonatomic) id<LITKeyboardsBaseViewControllerDelegate> delegate;

@end

@protocol LITKeyboardsBaseViewControllerDelegate <NSObject>

- (void)didCloseSearch;

@optional
- (void)didUpdateTags;

@end