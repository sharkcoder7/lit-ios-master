//
//  LITCollectionViewDecorationLayout.m
//  lit-ios
//
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import "LITCollectionViewDecorationLayout.h"
#import "LITTheme.h"

static NSString *kDecorationReuseIdentifier = @"section_background";
static NSString *kCellReuseIdentifier = @"view_cell";

@implementation LITCollectionViewDecorationLayout

+ (Class)layoutAttributesClass
{
    return [LITCollectionViewDecorationLayoutAttributes class];
}

- (void)prepareLayout {
    [super prepareLayout];
    
    [self registerClass:[LITCollectionReusableView class] forDecorationViewOfKind:kDecorationReuseIdentifier];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    
    NSMutableArray *allAttributes = [NSMutableArray arrayWithArray:attributes];
    
    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        
        // Look for the first item in a row
        if (attribute.representedElementKind == UICollectionElementCategoryCell
            && attribute.frame.origin.x == self.sectionInset.left) {
            
            // Create decoration attributes
            LITCollectionViewDecorationLayoutAttributes *decorationAttributes =
            [LITCollectionViewDecorationLayoutAttributes layoutAttributesForDecorationViewOfKind:kDecorationReuseIdentifier
                                                                        withIndexPath:attribute.indexPath];
            
            if (attribute.indexPath.row != 0) {
                continue;
            }
            
            // Make the decoration view span the entire row (you can do item by item as well.  I just
            // chose to do it this way)
            decorationAttributes.frame =
            CGRectMake(0,
                       attribute.frame.origin.y-(self.sectionInset.top),
                       self.collectionViewContentSize.width,
                       self.itemSize.height * 2 + (self.minimumLineSpacing+self.sectionInset.top+self.sectionInset.bottom+1));
            
            // Set the zIndex to be behind the item
            decorationAttributes.zIndex = attribute.zIndex-1;
            
            // Add the attribute to the list
            [allAttributes addObject:decorationAttributes];
            
        }
        
    }
    
    return allAttributes;
}
@end

@implementation LITCollectionViewDecorationLayoutAttributes
+ (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind
                                                                withIndexPath:(NSIndexPath *)indexPath {
    
    LITCollectionViewDecorationLayoutAttributes *layoutAttributes = [super layoutAttributesForDecorationViewOfKind:decorationViewKind
                                                                                          withIndexPath:indexPath];
    [layoutAttributes setGradientStartColor:[UIColor lit_kbFadeOrangeDarkFeed]];
    [layoutAttributes setGradientMidColor:[UIColor lit_kbFadeOrangeMediumFeed]];
    [layoutAttributes setGradientEndColor:[UIColor lit_kbFadeOrangeLightFeed]];
    return layoutAttributes;
}

- (id)copyWithZone:(NSZone *)zone {
    LITCollectionViewDecorationLayoutAttributes *newAttributes = [super copyWithZone:zone];
    newAttributes.gradientStartColor = [self.gradientStartColor copyWithZone:zone];
    newAttributes.gradientMidColor = [self.gradientMidColor copyWithZone:zone];
    newAttributes.gradientEndColor = [self.gradientEndColor copyWithZone:zone];
    return newAttributes;
}

@end

@implementation LITCollectionReusableView

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    
    LITCollectionViewDecorationLayoutAttributes *litLayoutAttributes = (LITCollectionViewDecorationLayoutAttributes*)layoutAttributes;
    //    self.backgroundColor = ecLayoutAttributes.color;
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(id)litLayoutAttributes.gradientStartColor.CGColor,
                             (id)litLayoutAttributes.gradientMidColor.CGColor,
                             (id)litLayoutAttributes.gradientEndColor.CGColor];
    [gradientLayer setFrame:self.bounds];
    
    NSArray *endinglocations = @[@0.15,@0.5,@.9];
    
    gradientLayer.locations = endinglocations;
    gradientLayer.startPoint = CGPointMake(0.0f, 0.15f);
    gradientLayer.endPoint = CGPointMake(0.0f, 1.0f);
    
    [self.layer insertSublayer:gradientLayer atIndex:0];
}

@end
