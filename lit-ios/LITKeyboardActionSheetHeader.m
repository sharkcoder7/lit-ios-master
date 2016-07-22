//
//  LITKeyboardActionSheetHeader.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITKeyboardActionSheetHeader.h"

@implementation LITKeyboardActionSheetHeader

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIView *mainView = [[NSBundle mainBundle] loadNibNamed:@"LITKeyboardActionSheetHeader" owner:self options:nil][0];
        [mainView setFrame:self.frame];
        [mainView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth)];
        [mainView setTag:100];
        [self addSubview:mainView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        UIView *mainView = [[NSBundle mainBundle] loadNibNamed:@"LITKeyboardActionSheetHeader" owner:self options:nil][0];
        [mainView setFrame:self.frame];
        [mainView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth)];
        [mainView setTag:100];
        [self addSubview:mainView];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
}


@end
