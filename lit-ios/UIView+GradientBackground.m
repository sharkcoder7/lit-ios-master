//
//  UIView+GradientBackground.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITTheme.h"
#import "UIView+GradientBackground.h"

@implementation UIView (GradientBackground)

- (void)setupGradientBackground
{
    [self setupGradientBackgroundWithColors:@[(id)[UIColor lit_fadedOrangeDarkColor].CGColor,
                                              (id)[UIColor lit_fadedOrangeLightColor].CGColor]];
}

- (void)setupGradientBackgroundWithColors:(NSArray *)colors
{
    if (self.gradientLayer) {
        return;
    }
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    [gradientLayer setStartPoint:CGPointMake(0, 1)];
    [gradientLayer setEndPoint:CGPointMake(0, 0)];
    gradientLayer.colors = @[(id)[UIColor lit_fadedOrangeDarkColor].CGColor,
                              (id)[UIColor lit_fadedOrangeLightColor].CGColor];
    [gradientLayer setFrame:self.bounds];
    [gradientLayer setStartPoint:CGPointMake(0.5, 0.3)];
    
    [self.layer insertSublayer:gradientLayer atIndex:0];
}

- (void)setupGradientBackgroundFromPoint:(CGPoint)startingPoint andStartingColor:(UIColor*)startingColor toPoint:(CGPoint)finalPoint andFinalColor:(UIColor*)finalColor{
    
    if (self.gradientLayer) {
        return;
    }
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    [gradientLayer setStartPoint:CGPointMake(startingPoint.x, startingPoint.y)];
    [gradientLayer setEndPoint:CGPointMake(finalPoint.x, finalPoint.y)];
    gradientLayer.colors = @[(id)startingColor.CGColor,
                             (id)finalColor.CGColor];
    [gradientLayer setFrame:self.bounds];
    [self.layer insertSublayer:gradientLayer atIndex:0];
}

- (void)setupFeedKeyboardGradientBackground{

    if (self.gradientLayer) {
        return;
    }
    
    //Create gradient layer
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(id)[UIColor lit_kbFadeOrangeDarkFeed].CGColor,
                              (id)[UIColor lit_kbFadeOrangeMediumFeed].CGColor,
                              (id)[UIColor lit_kbFadeOrangeLightFeed].CGColor];
    [gradientLayer setFrame:self.bounds];
    
    NSArray *endinglocations = @[@0.15,@0.5,@.9];
    
    gradientLayer.locations = endinglocations;
    gradientLayer.startPoint = CGPointMake(0.0f, 0.15f);
    gradientLayer.endPoint = CGPointMake(0.0f, 1.0f);
    
    [self.layer insertSublayer:gradientLayer atIndex:0];
}

- (void)setupFeedKeyboardTitleBarGradientBackground{
    
    if (self.gradientLayer) {
        return;
    }
    
    //Create gradient layer
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(id)[UIColor colorWithRed:237.0/255.0f green:104.0f/255.0f blue:57.0f/255.0f alpha:1.0f].CGColor,
                             (id)[UIColor colorWithRed:237.0/255.0f green:104.0f/255.0f blue:57.0f/255.0f alpha:1.0f].CGColor,
                             (id)[UIColor colorWithRed:240.0/255.0f green:135.0f/255.0f blue:105.0f/255.0f alpha:1.0f].CGColor];
    [gradientLayer setFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - 15.0f)];
    
    NSArray *endinglocations = @[@0.1,@0.7,@1];
    
    gradientLayer.locations = endinglocations;
    gradientLayer.startPoint = CGPointMake(0.0f, 0.0f);
    gradientLayer.endPoint = CGPointMake(0.0f, 1.0f);
    
    [self.layer insertSublayer:gradientLayer atIndex:0];
}

- (CAGradientLayer *)gradientLayer
{
    CAGradientLayer *gradientLayer = (CAGradientLayer *)[[self.layer sublayers] objectAtIndex:0];
    if ([gradientLayer isKindOfClass:[CAGradientLayer class]]) {
        return gradientLayer;
    } else return nil;
}



@end
