//
// Created by Nickolay Sheika on 10/8/14.
// Copyright (c) 2014 Coppertino Inc. All rights reserved. (http://coppertino.com/)
//
// VOX, VOX Player, LOOP for VOX are registered trademarks of Coppertino Inc in US.
// Coppertino Inc. 910 Foulk Road, Suite 201, Wilmington, County of New Castle, DE, 19803, USA.
// Contact phone: +1 (888) 765-7069
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "LITHistogramView.h"
@import QuartzCore;



@interface LITHistogramView ()


@property (strong, nonatomic) UIView *rectangleView;
@property (strong, nonatomic) UIView *touchesView;

@property(nonatomic, weak) UIImageView *completeImageView;
//@property(nonatomic, weak) UIImageView *notCompleteImageView;
//@property(nonatomic, weak) UIImageView *downloadedImageView;
@property (assign, nonatomic) CGRect lastProgressBounds;
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (assign, nonatomic, getter=isDragging) BOOL dragging;

@end



@implementation LITHistogramView


#pragma mark - Accessors

- (void)setCompleteColor:(UIColor *)completeColor
{
    _completeColor = completeColor;
    self.completeImageView.tintColor = completeColor;
}

//- (void)setNotCompleteColor:(UIColor *)notCompleteColor
//{
//    _notCompleteColor = notCompleteColor;
//    self.notCompleteImageView.tintColor = notCompleteColor;
//}
//
//- (void)setDownloadedColor:(UIColor *)downloadedColor
//{
//    _downloadedColor = downloadedColor;
//    self.downloadedImageView.tintColor = downloadedColor;
//}

- (void)setShowRectangleView:(BOOL)showRectangleView
{
    _showRectangleView = showRectangleView;
    [self setNeedsLayout];
}

- (void)setScale:(NSTimeInterval)scale
{
    NSParameterAssert(scale);
    _scale = scale;
    [self addSubview:self.rectangleView];
    [self addSubview:self.touchesView];
    [self setNeedsLayout];
}


//- (void)setPlaybackProgress:(CGFloat)playbackProgress
//{
//    _playbackProgress = [self _normalizedValue:playbackProgress];
////    CGFloat start = CGRectGetWidth(self.bounds) * self.playbackStart;
////    CGFloat end = CGRectGetWidth(self.bounds) * self.playbackEnd;
////    [self setNeedsDisplayInRect:CGRectMake(self.playbackStart, 0, end - start, CGRectGetHeight(self.bounds))];
//    [self setNeedsDisplay];
//}

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];

    }
    return self;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.image) {
        return;
    }
    if (self.showRectangleView && CGRectIsEmpty(self.rectangleView.frame)) {
        [self.rectangleView
         setFrame:CGRectMake(self.rectangleView.frame.origin.x, self.rectangleView.frame.origin.y, CGRectGetWidth(self.frame) / self.scale, CGRectGetHeight(self.frame))];
    }
}

#pragma mark - Setup

- (void)setup
{
    _scale = 1;
    _completeImageView = [self _buildImageView];
    [self setupGestureRecognizers];
}

- (void)setupGestureRecognizers
{
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTapGesture:)];
    [self addGestureRecognizer:self.tapRecognizer];
}

- (UIView *)rectangleView
{
    if (!_rectangleView) {
        self.clipsToBounds = NO;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame) / self.scale, CGRectGetHeight(self.frame))];
        [view setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.2]];
        view.layer.borderColor = [UIColor whiteColor].CGColor;
        view.layer.borderWidth = 1.0f;

        _rectangleView = view;
    }
    return _rectangleView;
}

- (UIView *)touchesView
{
    if (!_touchesView) {
        self.clipsToBounds = NO;
        int touchesViewArea = 70;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(_rectangleView.frame.origin.x+_rectangleView.frame.size.width/2-touchesViewArea/2, 0, touchesViewArea, CGRectGetHeight(self.frame))];
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePanGesture:)];
        [panRecognizer setCancelsTouchesInView:YES];
        [view addGestureRecognizer:panRecognizer];
        
        _touchesView = view;
    }
    return _touchesView;
}

- (UIImageView *)_buildImageView
{
    UIImageView *imageView = [[UIImageView alloc] init];
//    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeLeft;
    [self addSubview:imageView];
    return imageView;
}

#pragma mark - Accessors

- (void)setImage:(UIImage *)image
{
    if ([_image isEqual:image])
        return;

    _image = image;

    self.completeImageView.image = image;
    CGRect imageFrame = CGRectMake(self.completeImageView.frame.origin.x, self.completeImageView.frame.origin.x
                                   , image.size.width, image.size.height);
    [self setFrame:imageFrame];
    [self.completeImageView setFrame:imageFrame];

    [self setNeedsLayout];
}

#pragma mark - Private
- (void)_handleTapGesture:(UITapGestureRecognizer *)tapRecognizer
{
    if (tapRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [tapRecognizer locationInView:self];
        [self _animateRectangleViewToPoint:&location];
        if (self.delegate && [self.delegate respondsToSelector:@selector(histogramView:didRecognizeTapAtLocation:withPanRecognizerActive:)]) {
            //NSLog(@"Tap recognized at: %f", location.x);
            [self.delegate histogramView:self didRecognizeTapAtLocation:location.x / CGRectGetWidth(self.frame) withPanRecognizerActive:NO];
        }
    }
}

- (void)_handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self];
    CGPoint destinationPoint = CGPointMake(location.x, CGRectGetHeight(self.frame) / 2.0);
    if(destinationPoint.x - CGRectGetWidth(self.rectangleView.frame) / 2 < 0) {
        destinationPoint.x = CGRectGetWidth(self.rectangleView.frame) / 2;
    }
    else if (destinationPoint.x + CGRectGetWidth(self.rectangleView.frame) / 2 > CGRectGetWidth(self.frame)) {
        destinationPoint.x = CGRectGetWidth(self.frame) - CGRectGetWidth(self.rectangleView.frame) / 2;
    }
    else{
        destinationPoint.x = floor(location.x);
    }

    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.dragging = YES;
        [self.delegate cancelScrollInDetailView];
        //NSLog(@"Touches began at %@", NSStringFromCGPoint(location));
        [self.rectangleView setCenter:destinationPoint];
        [self.touchesView setCenter:destinationPoint];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(histogramView:didRecognizeTapAtLocation:withPanRecognizerActive:)]) {
            //NSLog(@"Tap recognized at: %f", location.x);
            [self.delegate histogramView:self didRecognizeTapAtLocation:destinationPoint.x / CGRectGetWidth(self.frame) withPanRecognizerActive:YES];
        }
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"%@", NSStringFromCGPoint(destinationPoint));
        [self.rectangleView setCenter:destinationPoint];
        [self.touchesView setCenter:destinationPoint];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(histogramView:didRecognizeTapAtLocation:withPanRecognizerActive:)]) {
            //NSLog(@"Tap recognized at: %f", location.x);
            [self.delegate histogramView:self didRecognizeTapAtLocation:destinationPoint.x / CGRectGetWidth(self.frame) withPanRecognizerActive:YES];
        }
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded ||
               recognizer.state == UIGestureRecognizerStateCancelled ||
               recognizer.state == UIGestureRecognizerStateFailed) {
        [self.delegate activateScrollInDetailView];
        //NSLog(@"Touches finished at %@", NSStringFromCGPoint(location));
        [self.rectangleView setCenter:destinationPoint];
        [self.touchesView setCenter:destinationPoint];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.dragging = NO;
        });
        if (self.delegate && [self.delegate respondsToSelector:@selector(histogramView:didRecognizeTapAtLocation:withPanRecognizerActive:)]) {
            //NSLog(@"Tap recognized at: %f", location.x);
            [self.delegate histogramView:self didRecognizeTapAtLocation:destinationPoint.x / CGRectGetWidth(self.frame) withPanRecognizerActive:YES];
            [self.delegate setScrubFinished];
        }
    }
}

- (void)_animateRectangleViewToPoint:(CGPoint *)point
{
    CGPoint destinationPoint = CGPointMake(point->x, CGRectGetHeight(self.frame) / 2.0);
    if(destinationPoint.x - CGRectGetWidth(self.rectangleView.frame) / 2 < 0) {
        destinationPoint.x = CGRectGetWidth(self.rectangleView.frame) / 2;
        point->x = destinationPoint.x;
    }
    if (destinationPoint.x + CGRectGetWidth(self.rectangleView.frame) / 2 > CGRectGetWidth(self.frame)) {
        destinationPoint.x = CGRectGetWidth(self.frame) - CGRectGetWidth(self.rectangleView.frame) / 2;
        point->x = destinationPoint.x;
    }
    point->y = CGRectGetHeight(self.frame) / 2;
    //NSLog(@"Destination: %@", NSStringFromCGPoint(*point));
    [UIView animateWithDuration:0.2 animations:^{
        [self.rectangleView setCenter:destinationPoint];
        [self.touchesView setCenter:destinationPoint];
    }];
}

#pragma mark - Public

- (void)moveRectangleViewToLocation:(CGFloat)location
{
    if (self.isDragging) {
        return;
    }
    CGPoint destinationPoint = CGPointMake(CGRectGetWidth(self.bounds) * location, CGRectGetHeight(self.bounds));
    [self _animateRectangleViewToPoint:&destinationPoint];
}

#pragma mark - Helpers

- (CGFloat)_normalizedValue:(CGFloat)value
{
    return MAX(MIN(value, 1), 0);
}

- (CGFloat)_normalizedDownloadProgressValue:(CGFloat)downloadProgressValue
{
    return MAX(MIN(downloadProgressValue, 1), self.playbackProgress);
}

@end