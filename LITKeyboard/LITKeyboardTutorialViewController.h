//
//  LITKeyboardTutorialViewController.h
//  lit-ios
//
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LITKeyboardTutorialDelegate;

@interface LITKeyboardTutorialViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic, readonly) IBOutlet UILabel *nowPasteLabel;
@property (weak, nonatomic) id<LITKeyboardTutorialDelegate> delegate;

@end

@protocol LITKeyboardTutorialDelegate <NSObject>
- (void) didTapLastButtonOfTutorial:(LITKeyboardTutorialViewController *) tutorialVC;
@end