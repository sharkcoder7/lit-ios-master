//
//  LITActionSheet.h
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JGActionSheet.h"

@interface LITActionSheet : JGActionSheet

@property (nonatomic, strong, readonly) NSArray *buttons;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *messageLabel;
@property (nonatomic, strong, readonly) UIView *contentView;

+ (void)setButtonStyle:(JGActionSheetButtonStyle)buttonStyle forButton:(UIButton *)button;

@end
