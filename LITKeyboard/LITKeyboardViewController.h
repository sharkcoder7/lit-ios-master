//
//  LITKeyboardViewController.h
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+LITKeyboardCellConfigurator.h"
#import "LITGlobals.h"

extern NSString *const kLITKeyboardViewControllerStoryboardID;

typedef NS_ENUM(NSInteger, LITBaseKeyboardViewControllerOptionIndex) {
    kLITIndexFav
};

@protocol LITKeyboardControllerDelegate;

@class LITKeyboard, PFImageView, PFObject;
@interface LITKeyboardViewController : UICollectionViewController <LITKeyboardCellConfigurator, LITKeyboardCellTouchDetector>

@property (strong, nonatomic) LITKeyboard *keyboard;
@property (strong, nonatomic) NSObject <UITextDocumentProxy> *textDocumentProxy;
@property (weak, nonatomic) id<LITKeyboardControllerDelegate> delegate;

@property (assign, nonatomic) NSUInteger index;

@property (assign, nonatomic) CGColorRef cellBackgroundColor;

@property (assign, nonatomic) BOOL landscapeActive;
@property (assign, nonatomic) LITKeyboard_Type currentLITKeyboardType;

@property (nonatomic, strong) NSMutableArray *arrayKeyboardContents;

- (UICollectionViewLayout *)collectionViewLayoutForOrientation:(UIInterfaceOrientation)orientation
                                                 basedOnLayout:(UICollectionViewFlowLayout *)layout;
@end

@protocol LITKeyboardControllerDelegate <NSObject>

- (void)didUpdateFavorites:(LITKeyboardViewController *)keyboardVC;
- (void)keyboardViewController:(LITKeyboardViewController *)keyboardVC
      didDetectMuteSwitchState:(BOOL)on;
- (BOOL)presentTutorialViewControllerForItem:(PFObject *)object;

@end