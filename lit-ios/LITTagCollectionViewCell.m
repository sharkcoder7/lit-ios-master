//
//  LITTagCollectionViewCell.m
//  lit-ios
//
//  Created by ioshero on 20/07/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITTagCollectionViewCell.h"

NSString *const kLITTagCollectionViewCellidentifier = @"LITTagCollectionViewCell";

@interface LITTagCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *emojiLabel;
@property (weak, nonatomic) IBOutlet UIView *selectionOverlayView;
@property (strong, nonatomic) CALayer *selectionLayer;

@end


@implementation LITTagCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        [self _setupLabel];
//        [self _setupViewConstraints];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
//        [self _setupLabel];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    float marginSize = 9.0f;
    float cellSize = (screenWidth-marginSize*5)/4; // 4 cells per row, 5 spaces per row
    
    CGRect cellFrame = CGRectMake(self.selectionOverlayView.frame.origin.x, self.selectionOverlayView.frame.origin.y, cellSize, cellSize);
    
    self.selectionOverlayView.frame = cellFrame;
    
    self.contentView.frame = cellFrame;
    
    self.emojiLabel.adjustsFontSizeToFitWidth = YES;
    self.emojiLabel.font = [UIFont systemFontOfSize:90.0f];
    self.layer.borderWidth=1.0f;
    self.layer.borderColor=[UIColor whiteColor].CGColor;
//    [self _setupViewConstraints];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self.selectionOverlayView setHidden:!selected];
}

@end
