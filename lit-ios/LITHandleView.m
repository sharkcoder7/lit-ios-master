//
//  LITHandleView.m
//  ;
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITHandleView.h"
#import <VOXHistogramView/UIView+Autolayout.h>

@interface LITHandleView()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation LITHandleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupImageView];
        [self setupViewsConstraints];
    }
    return self;
}


- (void)setupImageView
{
    UIImage *handleImage = [UIImage imageNamed:@"handle"];
    _imageView = [UIImageView autolayoutView];
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_imageView setImage:handleImage];
    [self addSubview:_imageView];
}

- (void)setupViewsConstraints
{
    UIImageView *imageView = _imageView;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(imageView);
    NSArray *vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics:nil views:bindings];
    NSArray *hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:bindings];
    [self addConstraints:vConstraints];
    [self addConstraints:hConstraints];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
