//
//  LITAddToKeyboardTableViewCell.h
//  lit-ios
//
//  Created by ioshero on 18/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kLITAddToKeyboardTableViewCellIdentifier;
extern CGFloat const kLITAddToKeyboardCellHeight;

@interface LITAddToKeyboardTableViewCell : UITableViewCell

@property (weak, nonatomic, readonly) UIView *labelContainerView;
@property (weak, nonatomic, readonly) UILabel *titleLabel;

@end
