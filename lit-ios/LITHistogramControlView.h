//
//  LITHistogramControlView.h
//  lit-ios
//
//  Created by ioshero on 29/07/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

@import UIKit;

@class LITHistogramControlView;
@class LITHistogramView;

@protocol LITHistogramControlViewDelegate <NSObject>


@optional

- (void)histogramControlViewWillShowHistogram:(LITHistogramControlView *)controlView;

- (void)histogramControlViewDidShowHistogram:(LITHistogramControlView *)controlView;

- (void)histogramControlViewWillHideHistogram:(LITHistogramControlView *)controlView;

- (void)histogramControlViewDidHideHistogram:(LITHistogramControlView *)controlView;

- (void)histogramControlViewWillMoveLeftHandle:(LITHistogramControlView *)controlView;
- (void)histogramControlViewWillMoveRightHandle:(LITHistogramControlView *)controlView;

- (void)histogramControlViewWillScrollDetailView:(LITHistogramControlView *)controlView;
- (void)histogramControlView:(LITHistogramControlView *)controlView didScrollToProgress:(CGFloat)progress;

- (void)histogramControlView:(LITHistogramControlView *)controlView didMoveLeftHandleToProgress:(CGFloat)progress;
- (void)histogramControlView:(LITHistogramControlView *)controlView didMoveRightHandleToProgress:(CGFloat)progress;


- (void)histogramControlView:(LITHistogramControlView *)controlView
           didChangeProgress:(CGFloat)progress;


- (void)histogramControlViewWillStartRendering:(LITHistogramControlView *)controlView;

- (void)histogramControlViewDidFinishRendering:(LITHistogramControlView *)controlView;


@end

@interface LITHistogramControlView : UIView

#pragma mark - Delegate
@property(nonatomic, weak) id <LITHistogramControlViewDelegate> delegate;


#pragma mark - Managed Views
@property(nonatomic, weak, readonly) LITHistogramView *fullHistogramView;
@property(nonatomic, weak, readonly) LITHistogramView *detailHistogramView;
//@property(nonatomic, weak, readonly) VOXProgressLineView *slider;


#pragma mark - Inspectable Properties


@property(nonatomic, strong) IBInspectable UIColor *completeColor;

@property(nonatomic, strong) IBInspectable UIColor *notCompleteColor;

@property(nonatomic, strong) IBInspectable UIColor *downloadedColor;

//@property(nonatomic, assign) IBInspectable NSUInteger peakWidth;
//@property(nonatomic, assign) IBInspectable NSUInteger marginWidth;

//@property(nonatomic, assign) IBInspectable CGFloat detailHistogramHeight;

@property(nonatomic, assign) IBInspectable CGFloat sliderHeight;



#pragma mark - Setup

/**
 *   Current tracking mode
 *
 *   VOXHistogramControlViewTrackingModeNone - tracking will be off
 *   VOXHistogramControlViewTrackingModeTap  - tracking will start from tap
 *   VOXHistogramControlViewTrackingModeLongTap - tracking will start from long tap
 *
 *   @default VOXHistogramControlViewTrackingModeTap
 */
//@property(nonatomic, assign) VOXHistogramControlViewTrackingMode trackingMode;


#pragma mark - State

@property(nonatomic, copy) NSArray *levels;

@property(nonatomic, assign) CGFloat playbackProgress;

@property(nonatomic, assign) CGFloat downloadProgress;

@property (assign, nonatomic) CGFloat playbackStart;
@property (assign, nonatomic) CGFloat playbackEnd;

@property(nonatomic, assign, readonly, getter=isTracking) BOOL tracking;

@property(nonatomic, assign, readonly) BOOL histogramPresented;

@property(nonatomic, assign, readonly) BOOL animating;

@property(nonatomic, assign, readonly) NSUInteger fullMaximumSamplingRate;
@property(nonatomic, assign, readonly) NSUInteger detailMaximumSamplingRate;

@property (nonatomic, assign) NSTimeInterval assetDuration;

#pragma mark - Public

/**
 *   Show or hide histogram view.
 */
- (void)showHistogramViewAnimated:(BOOL)animated;
- (void)hideHistogramViewAnimated:(BOOL)animated;

/**
 *   Will stop current histogram rendering if any.
 */
- (void)stopHistogramRendering;




@end
