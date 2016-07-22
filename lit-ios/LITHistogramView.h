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

@import Foundation;
@import UIKit;
@import CoreGraphics;


@protocol LITHistogramViewDelegate;
@interface LITHistogramView : UIView

/**
*   Colors setup
*/
@property(nonatomic, strong) IBInspectable UIColor *completeColor;
@property(nonatomic, strong) IBInspectable UIColor *playbackColor;
//@property(nonatomic, strong) IBInspectable UIColor *downloadedColor;

@property (assign, nonatomic) BOOL showRectangleView;

@property (assign, nonatomic) CGFloat playbackStart;
@property (assign, nonatomic) CGFloat playbackEnd;

@property(nonatomic, assign) CGFloat playbackProgress;
@property(nonatomic, assign) CGFloat downloadProgress;

/**
*   Histogram image
*/
@property(nonatomic, strong) UIImage *image;

@property (nonatomic, assign) NSTimeInterval scale;

/**
 *  Delegate
 */
@property (assign, nonatomic) id<LITHistogramViewDelegate>delegate;


- (void)moveRectangleViewToLocation:(CGFloat)location;

@end

@protocol LITHistogramViewDelegate <NSObject>

@optional
- (void)histogramView:(LITHistogramView *)histogramView didRecognizeTapAtLocation:(CGFloat)location withPanRecognizerActive:(BOOL)isPanRecognizerActive;
- (void)setScrubFinished;
- (void)cancelScrollInDetailView;
- (void)activateScrollInDetailView;
- (void)cancelScrollInFullView;
- (void)activateScrollInFullView;

@end