//
//  LITHistogramControlView.m
//  lit-ios
//
//  Created by ioshero on 29/07/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITHistogramControlView.h"
#import "Constants.h"
#import "LITTheme.h"
#import "LITHandleView.h"
#import "LITHistogramView.h"

#import <VOXHistogramView/VOXHistogramAnimator.h>
#import <VOXHistogramView/VOXHistogramRenderer.h>
#import <VOXHistogramView/VOXHistogramRenderingConfiguration.h>
#import <VOXHistogramView/VOXHistogramLevelsConverter.h>
#import <VOXHistogramView/VOXProgressLineView.h>
#import <VOXHistogramView/UIView+Autolayout.h>


typedef NS_ENUM(NSInteger, LITHistogramViewType) {
    LITHistogramViewTypeFull,
    LITHistogramViewTypeDetail
};

static NSUInteger const LITHistogramControlViewDefaultPeakWidthFull = 3;
static NSUInteger const LITHistogramControlViewDefaultMarginWidthFull = 2;
static NSUInteger const LITHistogramControlViewDefaultPeakWidthDetail = 6;
static NSUInteger const LITHistogramControlViewDefaultMarginWidthDetail = 3;

@interface LITHistogramControlView () < UIScrollViewDelegate,
                                        UIGestureRecognizerDelegate,
                                        LITHistogramViewDelegate>

#pragma mark - Public
@property(nonatomic, assign, readwrite, getter=isTracking) BOOL tracking;
@property(nonatomic, assign, readwrite) CGFloat scrubbingSpeed;
@property(nonatomic, assign, readwrite) IBInspectable BOOL useScrubbing;
@property(nonatomic, assign, readwrite) BOOL panActive;

#pragma mark - Managed Views
@property (strong, nonatomic) UIScrollView *scrollView;
@property(nonatomic, weak, readwrite) LITHistogramView *fullHistogramView;
@property(nonatomic, weak, readwrite) LITHistogramView *detailHistogramView;
//@property(nonatomic, weak, readwrite) VOXProgressLineView *slider;

#pragma mark - Helpers
@property(assign, nonatomic) CGPoint beganTrackingLocation;
@property(assign, nonatomic) CGFloat realPositionValue;
@property(nonatomic, weak) UITouch *currentTouch;


@property(nonatomic, strong) VOXHistogramRenderer *fullHistogramRenderer;
@property(nonatomic, strong) VOXHistogramAnimator *fullAnimator;

@property(nonatomic, strong) VOXHistogramRenderer *detailHistogramRenderer;
@property(nonatomic, strong) VOXHistogramAnimator *detailAnimator;

@property (strong, nonatomic) NSArray *fullResampledLevels;
@property (strong, nonatomic) NSArray *detailResampledLevels;

@property (strong, nonatomic) LITHandleView *leftHandle;
@property (strong, nonatomic) LITHandleView *rightHandle;

@property (strong, nonatomic) CAShapeLayer *playbackBar;

@property (strong, nonatomic) NSLayoutConstraint *leftHandleConstraint;
@property (strong, nonatomic) NSLayoutConstraint *rightHandleConstraint;

@property (assign, nonatomic, getter=isTrackingLeft)    BOOL trackingLeft;
@property (assign, nonatomic, getter=isTrackingRight)   BOOL trackingRight;

@property (assign, nonatomic) CGPoint lastTrackingPointLeft;
@property (assign, nonatomic) CGPoint lastTrackingPointRight;

@property (assign, nonatomic) NSTimeInterval detailScale;

@property (assign, nonatomic) CGFloat selectionConstraint;

@end

@implementation LITHistogramControlView

#pragma mark - Accessors

- (void)setCompleteColor:(UIColor *)completeColor
{
    _completeColor = completeColor;
    self.fullHistogramView.completeColor = completeColor;
    self.detailHistogramView.completeColor = completeColor;
//    self.slider.completeColor = completeColor;
}

- (void)setNotCompleteColor:(UIColor *)notCompleteColor
{
    _notCompleteColor = notCompleteColor;
//    self.fullHistogramView.notCompleteColor = notCompleteColor;
//    self.detailHistogramView.notCompleteColor = notCompleteColor;
//    self.slider.notCompleteColor = notCompleteColor;
}

- (void)setDownloadedColor:(UIColor *)downloadedColor
{
    _downloadedColor = downloadedColor;
//    self.fullHistogramView.downloadedColor = downloadedColor;
//    self.detailHistogramView.downloadedColor = downloadedColor;
//    self.slider.downloadedColor = downloadedColor;
}

- (void)setLevels:(NSArray *)levels
{
    NSParameterAssert(levels);
    NSAssert(self.assetDuration, @"Must provide an asset duration prior calling this method");
    NSAssert([levels count] > 0, @"Levels count cannot be 0");
    _levels = [levels copy];
    self.detailScale = self.assetDuration / kLITDetailSeconds;
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    [self _calculateResampledLevelsWithCompletion:^(NSArray *levelsResampled)  {
        self.fullResampledLevels = levelsResampled;
        _fullMaximumSamplingRate = [self.fullResampledLevels count];
        self.fullHistogramView.scale = self.detailScale;
        dispatch_group_leave(group);
    } forHistogramViewType:LITHistogramViewTypeFull];
    
    dispatch_group_enter(group);
    [self _calculateResampledLevelsWithCompletion:^(NSArray *levelsResampled)  {
        self.detailResampledLevels = levelsResampled;
        _detailMaximumSamplingRate = [self.detailResampledLevels count];
        dispatch_group_leave(group);
    } forHistogramViewType:LITHistogramViewTypeDetail];
    
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        _levels = nil;
        [self _renderHistograms];
    });
}

- (void)setPlaybackProgress:(CGFloat)playbackProgress
{
    if (_playbackProgress == playbackProgress || self.isTracking)
        return;
    
    _playbackProgress = [self _normalizedValue:playbackProgress];
    
    CGFloat xCoord = CGRectGetMidX(self.leftHandle.frame) + (_playbackProgress - _playbackStart) * self.scrollView.contentSize.width;
    UIBezierPath *linePath=[UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(xCoord,
                                      CGRectGetMinY(self.leftHandle.frame) + CGRectGetHeight(self.leftHandle.frame) * 0.2)];
    [linePath addLineToPoint:CGPointMake(xCoord,
                                        CGRectGetMinY(self.leftHandle.frame) + CGRectGetHeight(self.leftHandle.frame) * 0.8)];
    linePath.lineWidth = 4.0f;
    self.playbackBar.path=linePath.CGPath;
}

- (void)setPlaybackStart:(CGFloat)playbackStart
{
    _playbackStart = playbackStart;
    [self.detailHistogramView setPlaybackStart:playbackStart];
    [self.fullHistogramView setPlaybackStart:playbackStart];
}

- (void)setPlaybackEnd:(CGFloat)playbackEnd
{
    _playbackEnd = playbackEnd;
    [self.detailHistogramView setPlaybackEnd:playbackEnd];
    [self.fullHistogramView setPlaybackEnd:playbackEnd];
}

- (void)setDownloadProgress:(CGFloat)downloadProgress
{
    if (_downloadProgress == downloadProgress)
        return;
    
    _downloadProgress = [self _normalizedDownloadProgressValue:downloadProgress];
}

- (BOOL)histogramPresented
{
    return self.detailAnimator.histogramPresented;
}

- (BOOL)animating
{
    return self.detailAnimator.animating;
}

- (VOXHistogramRenderer *)fullHistogramRenderer
{
    if (!_fullHistogramRenderer) {
    
        /* Creating rendering configuration */
        VOXHistogramRenderingConfiguration *renderingConfiguration;
        renderingConfiguration = [VOXHistogramRenderingConfiguration new];
        renderingConfiguration.outputImageSize = CGSizeMake(CGRectGetWidth(self.fullHistogramView.bounds), CGRectGetHeight(self.fullHistogramView.bounds));
        renderingConfiguration.renderingMode = UIImageRenderingModeAlwaysTemplate;
        renderingConfiguration.peaksColor = [UIColor whiteColor];
        //        renderingConfiguration.peakWidth = self.peakWidth;
        //        renderingConfiguration.marginWidth = self.marginWidth;
                renderingConfiguration.peakWidth = LITHistogramControlViewDefaultPeakWidthFull;
                renderingConfiguration.marginWidth = LITHistogramControlViewDefaultMarginWidthFull;
        renderingConfiguration.produceFlipped = YES;
        
        /* Creating histogram renderer */
        _fullHistogramRenderer = [VOXHistogramRenderer rendererWithRenderingConfiguration:renderingConfiguration];
        
    }
    return _fullHistogramRenderer;
}

- (VOXHistogramRenderer *)detailHistogramRenderer
{
    if (!_detailHistogramRenderer) {

        /* Creating rendering configuration */
        VOXHistogramRenderingConfiguration *renderingConfiguration;
        renderingConfiguration = [VOXHistogramRenderingConfiguration new];
        renderingConfiguration.outputImageSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds) * self.detailScale, CGRectGetHeight(self.scrollView.bounds));
        renderingConfiguration.renderingMode = UIImageRenderingModeAlwaysTemplate;
        renderingConfiguration.peaksColor = [UIColor whiteColor];
//        renderingConfiguration.peakWidth = self.peakWidth;
//        renderingConfiguration.marginWidth = self.marginWidth;
        renderingConfiguration.peakWidth = LITHistogramControlViewDefaultPeakWidthDetail;
        renderingConfiguration.marginWidth = LITHistogramControlViewDefaultMarginWidthDetail;
        renderingConfiguration.produceFlipped = YES;
        
        /* Creating histogram renderer */
        _detailHistogramRenderer = [VOXHistogramRenderer rendererWithRenderingConfiguration:renderingConfiguration];

    }
    return _detailHistogramRenderer;
}

- (CAShapeLayer *)playbackBar
{
    if (!_playbackBar) {
        CAShapeLayer *line = [CAShapeLayer layer];
        line.fillColor = nil;
        line.opacity = 1.0;
        line.strokeColor = [UIColor redColor].CGColor;
        line.lineWidth = 2.0f;
        _playbackBar = line;
    }
    return _playbackBar;
}

#pragma mark - Init

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupFullHistogramView];
        [self setupDetailHistogramView];
        [self setupDefaults];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupFullHistogramView];
        [self setupDetailHistogramView];
        [self setupDefaults];
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
    
    // we should set color to slider here because designable
    // properties are set between initWithCoder and awakeFromNib
//    self.slider.completeColor = self.completeColor;
//    self.slider.downloadedColor = self.downloadedColor;
//    self.slider.notCompleteColor = self.notCompleteColor;
}

#pragma mark - Setup

- (void)setupDefaults
{
    /* Histogram params */
//    self.peakWidth = LITHistogramControlViewDefaultPeakWidth;
//    self.marginWidth = LITHistogramControlViewDefaultMarginWidth;
    
    /* Colors */
    self.completeColor = [UIColor lit_lightGreyColor];
    
    /* Shared flags */
    self.panActive = NO;
}

- (void)setup
{
    /* Setup managed views */
    [self setupViewsConstraints];
    
    /* Gesture recognizer setup */
    [self setupGestureRecognizers];
}

- (void)setupFullHistogramView
{
    LITHistogramView *fullHistogramView = [LITHistogramView autolayoutView];
    [fullHistogramView setDelegate:self];
    [fullHistogramView setBackgroundColor:[UIColor clearColor]];
    fullHistogramView.showRectangleView = YES;
    [self addSubview:fullHistogramView];
    self.fullHistogramView = fullHistogramView;
}
- (void)setupDetailHistogramView
{
    LITHistogramView *detailHistogramView = [LITHistogramView autolayoutView];
    UIScrollView *scrollView = [UIScrollView autolayoutView];
    [scrollView addSubview:detailHistogramView];
    [scrollView setDelegate:self];
    [detailHistogramView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    self.detailHistogramView = detailHistogramView;
    [self.layer addSublayer: self.playbackBar];
    [self setupHandles];
}

- (void)setupHandles
{
    LITHandleView *leftHandle = [LITHandleView autolayoutView];
    LITHandleView *rightHandle = [LITHandleView autolayoutView];
    [self addSubview:leftHandle];
    [self addSubview:rightHandle];
    _leftHandle = leftHandle;
    _rightHandle = rightHandle;
}

- (void)setupViewsConstraints
{
    UIScrollView *scrollView = self.scrollView;
    LITHistogramView *detailHistogramView = self.detailHistogramView;
    LITHistogramView *fullHistogramView = self.fullHistogramView;
    LITHandleView *leftHandle = self.leftHandle;
    LITHandleView *rightHandle = self.rightHandle;
    
    NSDictionary *viewsBinding = NSDictionaryOfVariableBindings(scrollView, detailHistogramView, fullHistogramView, leftHandle, rightHandle);

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsBinding]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[fullHistogramView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsBinding]];
    
//    NSString *detailFormat = self.detailHistogramHeight == 0 ? @"V:|-50-[scrollView]|" : [NSString stringWithFormat:@"V-50-:[scrollView(%f)]|", self.detailHistogramHeight];
    
//    [self.fullHistogramView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[fullHistogramView(50)]|"
//                                                                                  options:0
//                                                                                  metrics:nil
//                                                                                    views:viewsBinding]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[fullHistogramView(50)]-10-[scrollView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsBinding]];
    
    self.selectionConstraint = (1 - (kLITSelectionSeconds /kLITDetailSeconds )) / 2;
    
    NSLog(@"Scroll view frame is %@", NSStringFromCGRect(scrollView.frame));
    
    [scrollView setContentInset:UIEdgeInsetsMake(0, self.selectionConstraint, 0, self.selectionConstraint)];
    
    self.leftHandleConstraint = [NSLayoutConstraint constraintWithItem:leftHandle attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeRight multiplier:self.selectionConstraint constant:0];
    self.rightHandleConstraint = [NSLayoutConstraint constraintWithItem:rightHandle attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeRight multiplier:1- self.selectionConstraint constant:0];
    
    NSLayoutConstraint *centerLeftHandle = [NSLayoutConstraint constraintWithItem:leftHandle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    NSLayoutConstraint *centerRightHandle = [NSLayoutConstraint constraintWithItem:rightHandle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    
    NSLayoutConstraint *leftHandleHeight = [NSLayoutConstraint constraintWithItem:leftHandle attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:1.0];
    NSLayoutConstraint *rightHandleHeight = [NSLayoutConstraint constraintWithItem:rightHandle attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:1.0];
    
    NSLayoutConstraint *leftHandleWidth = [NSLayoutConstraint constraintWithItem:leftHandle attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:57.0f];
    NSLayoutConstraint *rightHandleWidth = [NSLayoutConstraint constraintWithItem:rightHandle attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:57.0f];
    
    
    [self addConstraints:@[self.leftHandleConstraint, self.rightHandleConstraint,
                          centerLeftHandle, centerRightHandle,
                          leftHandleHeight, rightHandleHeight,
                           leftHandleWidth, rightHandleWidth]];

//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:detailFormat
//                                                                     options:0
//                                                                     metrics:nil
//                                                                       views:viewsBinding]];
    
    

    
//    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[detailHistogramView]|" options:0 metrics: 0 views:viewsBinding]];
//    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[detailHistogramView]|" options:0 metrics: 0 views:viewsBinding]];
    
//    if (self.slider) {
//        VOXProgressLineView *slider = self.slider;
//        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[slider]|"
//                                                                     options:0
//                                                                     metrics:nil
//                                                                       views:NSDictionaryOfVariableBindings(slider)]];
//        NSString *format = [NSString stringWithFormat:@"V:[histogramView(%f)][slider(%f)]|", self.histogramHeight, self.sliderHeight];
//        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
//                                                                     options:0
//                                                                     metrics:nil
//                                                                       views:NSDictionaryOfVariableBindings(histogramView, slider)]];
//    }
//    else {
//        NSString *format = self.histogramHeight == 0 ? @"V:|[histogramView]|" : [NSString stringWithFormat:@"V:[histogramView(%f)]|",
//                                                                                 

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    NSLog(@"Scroll view frame is %@", NSStringFromCGRect(self.scrollView.frame));
    CGFloat sideInset = self.selectionConstraint * CGRectGetWidth(self.scrollView.frame);
    [self.scrollView setContentInset:UIEdgeInsetsMake(0, sideInset, 0, sideInset)];
    
}

- (void)setupGestureRecognizers
{
//    UILongPressGestureRecognizer *longPressGestureRecognizer;
//    longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
//                                                                               action:@selector(tapOccured:)];
//    longPressGestureRecognizer.delegate = self;
//    CGFloat pressDuration = self.trackingMode == VOXHistogramControlViewTrackingModeLongTap ? 0.3f : 0.001f;
//    longPressGestureRecognizer.minimumPressDuration = pressDuration;
//    [self addGestureRecognizer:longPressGestureRecognizer];
    UIPanGestureRecognizer *leftPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureForLeftHandle:)];
//    leftPanRecognizer.delegate = self;
    [self.leftHandle addGestureRecognizer:leftPanRecognizer];
    
    UIPanGestureRecognizer *rightPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureForRightHandle:)];
    [leftPanRecognizer requireGestureRecognizerToFail:rightPanRecognizer];
//    [rightPanRecognizer requireGestureRecognizerToFail:leftPanRecognizer];
//    rightPanRecognizer.delegate = self;
    [self.rightHandle addGestureRecognizer:rightPanRecognizer];
}

#pragma mark - Public

- (void)showHistogramViewAnimated:(BOOL)animated
{
    [self.detailAnimator showHistogramViewAnimated:animated];
}

- (void)hideHistogramViewAnimated:(BOOL)animated
{
    [self.detailAnimator hideHistogramViewAnimated:animated];
}

- (void)stopHistogramRendering
{
    [self.detailHistogramRenderer cancelCurrentRendering];
    self.detailHistogramRenderer = nil;
}

#pragma mark - Gestures

- (void)handlePanGestureForLeftHandle:(UIPanGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.scrollView];
    if (location.x < 0) {
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Touches began at %@", NSStringFromCGPoint(location));
        self.trackingLeft = YES;
        self.lastTrackingPointLeft = location;
        [self.playbackBar setHidden:YES];
        if (self.delegate && [self.delegate respondsToSelector:@selector(histogramControlViewWillMoveLeftHandle:)]) {
            [self.delegate histogramControlViewWillMoveLeftHandle:self];
        }
    } else if (recognizer.state == UIGestureRecognizerStateChanged && self.isTrackingLeft) {
        NSLog(@"Touches changed at %@", NSStringFromCGPoint(location));
        //Don't move if the two handles are too close
        CGFloat xOffset = self.lastTrackingPointLeft.x - location.x;
        if (CGRectGetMidX(self.rightHandle.frame) - (CGRectGetMidX(self.leftHandle.frame) - xOffset) > CGRectGetWidth(self.scrollView.frame) * (kLITMinSelectionSeconds / kLITDetailSeconds) &&
            CGRectGetMidX(self.leftHandle.frame) - xOffset >= 0 &&
            CGRectGetMidX(self.rightHandle.frame) - CGRectGetMidX(self.leftHandle.frame) + xOffset < CGRectGetWidth(self.scrollView.frame) * (kLITSelectionSeconds / kLITDetailSeconds)) {
            self.leftHandleConstraint.constant -= xOffset;
            self.lastTrackingPointLeft = location;
            [self layoutIfNeeded];
        }
    } else if (recognizer.state == UIGestureRecognizerStateEnded ||
               recognizer.state == UIGestureRecognizerStateCancelled ||
               recognizer.state == UIGestureRecognizerStateFailed) {
        NSLog(@"Touches ended at %@", NSStringFromCGPoint(location));
        [self.playbackBar setHidden:NO];
        if (self.delegate && [self.delegate respondsToSelector:@selector(histogramControlView:didMoveLeftHandleToProgress:)]) {
            [self.delegate histogramControlView:self
                        didMoveLeftHandleToProgress:(self.scrollView.contentOffset.x + CGRectGetMidX(self.leftHandle.frame)) / self.scrollView.contentSize.width];
        }
        self.trackingLeft = NO;
        self.lastTrackingPointLeft = CGPointZero;
    }
}

- (void)handlePanGestureForRightHandle:(UIPanGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.scrollView];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Touches began at %@", NSStringFromCGPoint(location));
        self.trackingRight = YES;
        self.lastTrackingPointRight = location;
        [self.playbackBar setHidden:YES];
        if (self.delegate && [self.delegate respondsToSelector:@selector(histogramControlViewWillMoveRightHandle:)]) {
            [self.delegate histogramControlViewWillMoveRightHandle:self];
        }
    } else if (recognizer.state == UIGestureRecognizerStateChanged && self.isTrackingRight) {
        NSLog(@"Touches changed at %@", NSStringFromCGPoint(location));
        //Don't move if the two handles are too close
        CGFloat xOffset = self.lastTrackingPointRight.x - location.x;
        if ((CGRectGetMidX(self.rightHandle.frame) - xOffset - CGRectGetMidX(self.leftHandle.frame)) > CGRectGetWidth(self.scrollView.frame) * (kLITMinSelectionSeconds / kLITDetailSeconds) &&
            CGRectGetMidX(self.rightHandle.frame) - xOffset <= CGRectGetWidth(self.scrollView.bounds) &&
            CGRectGetMidX(self.rightHandle.frame) - CGRectGetMidX(self.leftHandle.frame) - xOffset < CGRectGetWidth(self.scrollView.frame) * (kLITSelectionSeconds / kLITDetailSeconds)) {
            self.rightHandleConstraint.constant -= xOffset;
            self.lastTrackingPointRight = location;
            [self layoutIfNeeded];
        }
    } else if (recognizer.state == UIGestureRecognizerStateEnded ||
               recognizer.state == UIGestureRecognizerStateCancelled ||
               recognizer.state == UIGestureRecognizerStateFailed) {
        [self.playbackBar setHidden:NO];
        if (self.delegate && [self.delegate respondsToSelector:@selector(histogramControlView:didMoveRightHandleToProgress:)]) {
            [self.delegate histogramControlView:self
                       didMoveRightHandleToProgress:(self.scrollView.contentOffset.x + CGRectGetMidX(self.rightHandle.frame)) / self.scrollView.contentSize.width];
        }
        self.trackingRight = NO;
        self.lastTrackingPointRight = CGPointZero;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    //ensure that the end of scroll is fired.
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:0.3];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.tracking = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(histogramControlViewWillScrollDetailView:)]) {
        [self.delegate histogramControlViewWillScrollDetailView:self];
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.tracking = NO;
    if (!self.scrollView || self.scrollView.contentSize.width == 0) {
        return;
    }
    if(!self.panActive){
        [self.fullHistogramView moveRectangleViewToLocation:(self.scrollView.contentOffset.x + CGRectGetWidth(self.scrollView.frame) / 2.0f) / self.scrollView.contentSize.width];
    }
    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(histogramControlView:didScrollToProgress:)] &&
        [self.delegate respondsToSelector:@selector(histogramControlView:didMoveLeftHandleToProgress:)]) {
        [self.delegate histogramControlView:self didScrollToProgress:self.scrollView.contentOffset.x / self.scrollView.contentSize.width];
        CGFloat leftProgress = (self.scrollView.contentOffset.x / self.scrollView.contentSize.width) + (CGRectGetMidX(self.leftHandle.frame) / self.scrollView.contentSize.width);
        CGFloat rightProgress =((CGRectGetMidX(self.rightHandle.frame) - CGRectGetMidX(self.leftHandle.frame)) / self.scrollView.contentSize.width) + leftProgress;
        [self.delegate histogramControlView:self didMoveLeftHandleToProgress:leftProgress];
        [self.delegate histogramControlView:self didMoveRightHandleToProgress:rightProgress];
    }
}

- (void)setScrubFinished
{
    self.panActive = NO;
}

#pragma mark - VOXHistogramViewDelegate
- (void)histogramView:(LITHistogramView *)histogramView didRecognizeTapAtLocation:(CGFloat)location withPanRecognizerActive:(BOOL)isPanRecognizerActive
{
    self.panActive = isPanRecognizerActive;
    
    CGSize contentSize = self.scrollView.contentSize;
    CGPoint scrollToCenter = CGPointMake(contentSize.width * location, contentSize.height / 2.0f);
    CGSize rectangleSize = CGSizeMake(CGRectGetWidth(self.detailHistogramView.bounds) / self.detailScale, CGRectGetHeight(self.scrollView.bounds));
    self.tracking = YES;
    [self.scrollView scrollRectToVisible:CGRectMake(scrollToCenter.x - rectangleSize.width / 2.0, 0, rectangleSize.width, contentSize.height / 2.0) animated:YES];
}

#pragma mark - Helpers

- (void)_renderHistograms
{
    /* Notify delegate */
    [self _notifyDelegateWillStartRendering];
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    
    [self.fullHistogramRenderer renderHistogramWithLevels:self.fullResampledLevels completion:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.fullHistogramView.image = image;
            dispatch_group_leave(group);
        });
    }];
    
    dispatch_group_enter(group);
    [self.detailHistogramRenderer renderHistogramWithLevels:self.detailResampledLevels completion:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.scrollView setContentSize:CGSizeMake(image.size.width, image.size.height)];
            self.detailHistogramView.image = image;
            dispatch_group_leave(group);
        });
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self _notifyDelegateDidFinishRendering];
    });
    
    
}

- (void)_calculateResampledLevelsWithCompletion:(void(^)(NSArray *))completion
                           forHistogramViewType:(LITHistogramViewType)histogramType
{
    NSParameterAssert(completion);
    
    if (histogramType == LITHistogramViewTypeFull && self.fullResampledLevels) {
        completion(self.detailResampledLevels);
        return;
    }
    
    if (histogramType == LITHistogramViewTypeDetail && self.detailResampledLevels) {
        completion(self.detailResampledLevels);
        return;
    }
    
    /* Setup levels converter */
    VOXHistogramLevelsConverter *converter = [VOXHistogramLevelsConverter new];
    [converter updateLevels:self.levels];
    
    NSUInteger samplingRate;
    if (histogramType == LITHistogramViewTypeFull) {
        samplingRate = [self _samplingRateForHistogramWidth:CGRectGetWidth(self.fullHistogramView.bounds)
                                                  peakWidth:LITHistogramControlViewDefaultPeakWidthFull
                                                marginWidth:LITHistogramControlViewDefaultMarginWidthFull];
    } else if (histogramType == LITHistogramViewTypeDetail) {
        samplingRate = [self _samplingRateForHistogramWidth:CGRectGetWidth(self.scrollView.bounds) * self.detailScale
                                     peakWidth:LITHistogramControlViewDefaultPeakWidthDetail
                                   marginWidth:LITHistogramControlViewDefaultMarginWidthDetail];
    }
    
    NSAssert(samplingRate, @"Sampling rate cannot be 0 at this point");
    /* Calculate number of levels that histogram can display in current bounds */
    
    
    [converter calculateLevelsForSamplingRate:samplingRate completion:^(NSArray *resampledLevels) {
        completion(resampledLevels);
    }];
}


- (void)cancelScrollInDetailView {
    [self.detailHistogramView setUserInteractionEnabled:NO];
}
- (void)activateScrollInDetailView {
    [self.detailHistogramView setUserInteractionEnabled:YES];
}
- (void)cancelScrollInFullView {
    [self.fullHistogramView setUserInteractionEnabled:NO];
}
- (void)activateScrollInFullView {
    [self.fullHistogramView setUserInteractionEnabled:YES];
}


//- (void)_updateValueForCurrentTouch
//{
//    /* Get touch params */
//    CGPoint previousLocation = [self.currentTouch previousLocationInView:self];
//    CGPoint currentLocation = [self.currentTouch locationInView:self];
//    
//    CGFloat trackingOffset = currentLocation.x - previousLocation.x;
//    CGFloat controlViewWidth = CGRectGetWidth(self.bounds);
//    
//    self.realPositionValue = self.realPositionValue + (trackingOffset / controlViewWidth);
//    
//    CGFloat valueAdjustment = self.scrubbingSpeed * (trackingOffset / controlViewWidth);
//    
//    CGFloat thumbAdjustment = 0.0f;
//    
//    /* Vertical progress adjustment - when user moves finger down closer to histogram we should also adjust progress */
//    if (((self.beganTrackingLocation.y < currentLocation.y) && (currentLocation.y < previousLocation.y)) ||
//        ((self.beganTrackingLocation.y > currentLocation.y) && (currentLocation.y > previousLocation.y))) {
//        // We are getting closer to the slider, go closer to the real location
//        thumbAdjustment = (self.realPositionValue - self.playbackProgress) / (1 + fabs(currentLocation.y - self.beganTrackingLocation.y));
//    }
//    
//    if ((trackingOffset == 0 && (currentLocation.y - previousLocation.y) == 0) || ! self.useScrubbing) {
//        _playbackProgress = currentLocation.x / controlViewWidth;
//    }
//    else {
//        _playbackProgress += valueAdjustment + thumbAdjustment; // should not call setter here
//    }
//    
////    [self.slider updatePlaybackProgress:self.playbackProgress];
//    [self.detailHistogramView updatePlaybackProgress:self.playbackProgress];
//    
//    [self _notifyDelegateDidChangePlaybackProgress:self.playbackProgress];
//}

//- (void)_updateScrubbingSpeed
//{
//    CGPoint touchLocation = [self.currentTouch locationInView:self];
//    CGFloat verticalOffset = ABS(touchLocation.y - self.beganTrackingLocation.y);
//    NSUInteger scrubbingSpeedChangePosIndex = [self _indexOfLowerScrubbingSpeed:self.scrubbingSpeedChangePositions
//                                                                      forOffset:verticalOffset];
//    if (scrubbingSpeedChangePosIndex == NSNotFound) {
//        scrubbingSpeedChangePosIndex = [self.scrubbingSpeeds count];
//    }
//    
//    CGFloat scrubbingSpeed = [self.scrubbingSpeeds[scrubbingSpeedChangePosIndex - 1] floatValue];
//    
//    if (scrubbingSpeed != self.scrubbingSpeed) {
//        self.scrubbingSpeed = scrubbingSpeed;
//        [self _notifyDelegateDidChangeScrubbingSpeed:scrubbingSpeed];
//    }
//}

//- (NSArray *)_defaultScrubbingSpeeds
//{
//    return @[ @1.0f, @0.5f, @0.25f, @0.1f ];
//}
//
//- (NSArray *)_defaultScrubbingSpeedChangePositions
//{
//    return @[ @0.0f, @50.0f, @100.0f, @150.0f ];
//}

// Return the lowest index in the array of numbers passed in scrubbingSpeedPositions
// whose value is smaller than verticalOffset.
//- (NSUInteger)_indexOfLowerScrubbingSpeed:(NSArray *)scrubbingSpeedPositions
//                                forOffset:(CGFloat)verticalOffset
//{
//    for (NSUInteger i = 0; i < [scrubbingSpeedPositions count]; i ++) {
//        NSNumber *scrubbingSpeedOffset = scrubbingSpeedPositions[i];
//        if (verticalOffset < [scrubbingSpeedOffset floatValue]) {
//            return i;
//        }
//    }
//    return NSNotFound;
//}

- (NSUInteger)_samplingRateForHistogramWidth:(CGFloat)histogramWidth
                                   peakWidth:(CGFloat)peakWidth
                                 marginWidth:(CGFloat)marginWidth
{
    CGFloat scale = [UIScreen mainScreen].scale;
    return (NSUInteger) ceilf((histogramWidth / (peakWidth + marginWidth)) * scale);
}

- (CGFloat)_normalizedValue:(CGFloat)value
{
    return MAX(MIN(value, 1), 0);
}

- (CGFloat)_normalizedDownloadProgressValue:(CGFloat)downloadProgressValue
{
    return MAX(MIN(downloadProgressValue, 1), self.playbackProgress);
}

#pragma mark - Delegate Notifications

- (void)_notifyDelegateWillStartRendering
{
    if ([self.delegate respondsToSelector:@selector(histogramControlViewWillStartRendering:)]) {
        [self.delegate histogramControlViewWillStartRendering:self];
    }
}

- (void)_notifyDelegateDidFinishRendering
{
    if ([self.delegate respondsToSelector:@selector(histogramControlViewDidFinishRendering:)]) {
        [self.delegate histogramControlViewDidFinishRendering:self];
    }
}

- (void)_notifyDelegateDidChangePlaybackProgress:(CGFloat)playbackProgress
{
    if ([self.delegate respondsToSelector:@selector(histogramControlView:didChangeProgress:)]) {
        [self.delegate histogramControlView:self
                          didChangeProgress:playbackProgress];
    }
}



@end
