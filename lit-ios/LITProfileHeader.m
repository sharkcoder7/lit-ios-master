//
//  LITProfileHeader.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITProfileHeader.h"
#import "UIView+GradientBackground.h"
#import "LITTheme.h"

@interface LITProfileHeader () {
    BOOL _gradientSet;
}

@end

@implementation LITProfileHeader


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        UIView *mainView = [[NSBundle mainBundle] loadNibNamed:@"LITProfileHeader" owner:self options:nil][0];
        [mainView setFrame:self.frame];
        [mainView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        [mainView setTag:100];
        [self addSubview:mainView];
        
        
        // Round the user's image and add a border to it
        _profileImageView.layer.cornerRadius = 50;
        _profileImageView.layer.masksToBounds = YES;
        _profileImageView.layer.borderWidth = 3;
        _profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!_gradientSet) {
        [[self viewWithTag:100] setupGradientBackgroundFromPoint:CGPointMake(0.0f, 0.0f)
                                  andStartingColor:[UIColor lit_fadedOrangeLightColor]
                                           toPoint:CGPointMake(1.0f, 1.0f)
                                     andFinalColor:[UIColor lit_fadedOrangeDarkColor]];
        _gradientSet = YES;
    }
}


@end
