//
//  LITAdjustableLabel.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITAdjustableLabel.h"

@interface LITAdjustableLabel ()
@property(nonatomic) BOOL fontSizeAdjusted;
@end

@implementation LITAdjustableLabel

- (void)setAdjustsFontSizeToFitFrame:(BOOL)adjustsFontSizeToFitFrame
{
    _adjustsFontSizeToFitFrame = adjustsFontSizeToFitFrame;
    
    if (adjustsFontSizeToFitFrame) {
        self.numberOfLines = 0; // because boundingRectWithSize works like this is 0
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.adjustsFontSizeToFitFrame &&
        !self.fontSizeAdjusted &&
        CGRectGetWidth(self.frame) > 0 &&
        CGRectGetHeight(self.frame) > 0)
    {
        self.fontSizeAdjusted = YES; // to avoid recursion, because adjustFontSizeToFrame will trigger this method again
        
        [self adjustFontSizeToFrame];
    }
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    self.fontSizeAdjusted = NO;
    [self setNeedsLayout];
}

// adjustFontSizeToFrame finds one font size `f` that fits (and f+DELTA doesn't fit).
#define DELTA 0.5

/** Based on http://stackoverflow.com/a/3005113
 */
- (void) adjustFontSizeToFrame
{
    UILabel* label = self;
    
    if (label.text.length == 0) return;
    
    // Necessary or single-char texts won't be correctly adjusted
    BOOL checkWidth = label.text.length == 1;
    
    CGSize labelSize = label.frame.size;
    
    // Fit label width-wise
    CGSize constraintSize = CGSizeMake(labelSize.width, MAXFLOAT);
    
    // Try all font sizes from largest to smallest font size
    CGFloat maxFontSize = 17;
    CGFloat minFontSize = 5;
    
    NSString* text = label.text;
    UIFont* font = label.font;
    
    while (true)
    {
        // Binary search between min and max
        CGFloat fontSize = (maxFontSize + minFontSize) / 2;
        
        // Exit if approached minFontSize enough
        if (fontSize - minFontSize < DELTA/2) {
            font = [UIFont fontWithName:font.fontName size:minFontSize];
            break; // Exit because we reached the biggest font size that fits
        } else {
            font = [UIFont fontWithName:font.fontName size:fontSize];
        }
        
        // Find label size for current font size
        CGRect rect = [text boundingRectWithSize:constraintSize
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName : font}
                                         context:nil];
        
        // Now we discard a half
        if( rect.size.height <= labelSize.height && (!checkWidth || rect.size.width <= labelSize.width) ) {
            minFontSize = fontSize; // the best size is in the bigger half
        } else {
            maxFontSize = fontSize; // the best size is in the smaller half
        }
    }
    
    label.font = font;
}

@end
