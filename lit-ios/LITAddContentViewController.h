//
//  LITAddContentViewController.h
//  lit-ios
//
//  Created by ioshero on 19/11/2015.
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LITAddContentViewControllerDelegate;
@class LITKeyboard;
@interface LITAddContentViewController : UIViewController

@property (weak, nonatomic) id<LITAddContentViewControllerDelegate> delegate;
@property (strong, nonatomic) LITKeyboard *keyboard;

@end

@protocol LITAddContentViewControllerDelegate <NSObject>

- (void)addContentViewControllerDidRequestClose:(LITAddContentViewController *)controller;
- (void)addContentViewControllerDidSelectSoundbiteOption:(LITAddContentViewController *)controller;
- (void)addContentViewControllerDidSelectDubOption:(LITAddContentViewController *)controller;
- (void)addContentViewControllerDidSelectLyricOption:(LITAddContentViewController *)controller;

@end
