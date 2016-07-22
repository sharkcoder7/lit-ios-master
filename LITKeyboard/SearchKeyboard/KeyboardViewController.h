//
//  KeyboardViewController.h
//  Keyboard
//
//  Created by star on 2/20/16.
//  Copyright © 2016 star. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KeyboardViewController;

@protocol KeyboardViewControllerDelegate <NSObject>

@optional
- (void)returnKeyPressed:(KeyboardViewController*) kv;
- (void)didChangedKeyboardMode:(BOOL)isNumerical;

@end

@interface KeyboardViewController : UIInputViewController

@property (nonatomic, weak) id<KeyboardViewControllerDelegate> delegate;

@end
