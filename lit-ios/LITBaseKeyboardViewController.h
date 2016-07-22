//
//  LITBaseKeyboardViewController.h
//  
//
//  Created by ioshero on 21/08/2015.
//
//

#import "UIViewController+LITKeyboardCellConfigurator.h"
#import "LITFeedDelegate.h"
#import "LITTableSearchHelper.h"
#import "LITKeyboardHeaderView.h"
#import "LITKeyboardFooterView.h"
#import "WSCoachMarksView.h"

#import "Parse/PFUser.h"
#import <ParseUI/PFQueryCollectionViewController.h>
#import <UIKit/UIKit.h>

extern NSUInteger const kLITIndexSectionOptions;
extern NSUInteger const kLITIndexSectionShare;
extern NSUInteger const kLITNumSections;
extern NSUInteger const kLITNumOptions;

typedef NS_ENUM(NSInteger, LITBaseKeyboardViewControllerOptionIndex) {
    kLITIndexAddToKeyboard,
    kLITIndexFav,
    kLITIndexReport
};

extern NSString *const kLITSoundbiteClass;
extern NSString *const kLITDubClass;
extern NSString *const kLITLyricClass;

@interface LITBaseKeyboardViewController : PFQueryCollectionViewController <LITKeyboardCellConfigurator, LITTableSearchHosting, UITableViewDataSource, UITableViewDelegate, LITKeyboardCellTouchDetector, UIDocumentInteractionControllerDelegate, WSCoachMarksViewDelegate>

@property (weak, nonatomic) id<LITFeedDelegate, LITObjectOptionDelegate> delegate;
@property (assign, nonatomic) BOOL shouldShowSearch;
@property (assign, nonatomic) BOOL optionsVisible;
@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) NSMutableDictionary *keyboardInstallationsMapping;


- (id)initWithCoder:(NSCoder *)aCoder;

@end
