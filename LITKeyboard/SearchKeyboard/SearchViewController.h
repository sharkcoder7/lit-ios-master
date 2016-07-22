//
//  SearchViewController.h
//  lit-ios
//
//  Created by user on 4/10/16.
//  Copyright © 2016 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LITKeyboardsBaseViewController.h"

@protocol SearchViewControllerDelegate <NSObject>

- (void)didEndSearch;

@end

@interface SearchViewController : UIViewController <LITKeyboardsBaseViewControllerDelegate>

@property (nonatomic, assign) id <SearchViewControllerDelegate> delegate;

@end
