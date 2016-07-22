//
//  LITSearchController.h
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LITTableSearchHelper.h"

@interface LITSearchController : UISearchController

@property (weak, nonatomic) id<LITTableSearchHosting, UISearchControllerDelegate> litDelegate;
@property (weak, nonatomic) id<LITTableSearchHosting, UISearchControllerDelegate, UISearchBarDelegate> delegate;

@end
