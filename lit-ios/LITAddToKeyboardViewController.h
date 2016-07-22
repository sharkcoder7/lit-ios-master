//
//  LITAddToKeyboardTableViewController.h
//  lit-ios
//
//  Created by ioshero on 18/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kLITAddToKeyboardViewControllerStoryboardIdentifier;

@class PFObject, LITKeyboard;
@protocol LITAddToKeyboardViewControllerDelegate;
@interface LITAddToKeyboardViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) PFObject *object;
@property (strong, nonatomic) UIViewController *callingController;
@property (weak, nonatomic) id <LITAddToKeyboardViewControllerDelegate> delegate;
@property (assign, nonatomic) BOOL showsUploadButton;
@end

@protocol LITAddToKeyboardViewControllerDelegate <NSObject>
@required
- (void)keyboardsController:(LITAddToKeyboardViewController *)controller didSelectKeyboard:(LITKeyboard *)keyboard forObject:(PFObject *)object showCongrats:(BOOL)show inViewController:(UIViewController *)viewController;
@end
