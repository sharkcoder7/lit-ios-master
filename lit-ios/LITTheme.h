//
//  LITTheme.h
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (LITColors)

+ (UIColor *)lit_fadedOrangeLightColor;
+ (UIColor *)lit_fadedOrangeDarkColor;
+ (UIColor *)lit_histogramGreyColor;
+ (UIColor *)lit_whiteColor;
+ (UIColor *)lit_pinkishGreyColor;
+ (UIColor *)lit_coolGreyColor;
+ (UIColor *)lit_darkOrangishColor;
+ (UIColor *)lit_placeholderOrange;
+ (UIColor *)lit_greyColor;
+ (UIColor *)lit_darkGreyColor;
+ (UIColor *)lit_lightGreyColor;
+ (UIColor *)lit_lighterGreyColor;
+ (UIColor *)lit_salmonColor;
+ (UIColor *)lit_lightOrangishColor;

+ (UIColor *)lit_lyricCellOrangeDarkColor;
+ (UIColor *)lit_lyricCellOrangeLightColor;

+ (UIColor *)lit_facebookColor;
+ (UIColor *)lit_twitterColor;
+ (UIColor *)lit_keyboardTitleColor;

+ (UIColor *)searchBar_Color1;
+ (UIColor *)searchBar_Color2;
+ (UIColor *)tag_cellColor;
+ (UIColor *)lit_kbFadeRedDark;
+ (UIColor *)lit_kbFadeRedLight;
+ (UIColor *)lit_kbFadeOrangeDark;
+ (UIColor *)lit_kbFadeOrangeLight;
+ (UIColor *)lit_kbFadeOrangeDarkFeed;
+ (UIColor *)lit_kbFadeOrangeMediumFeed;
+ (UIColor *)lit_kbFadeOrangeLightFeed;
+ (UIColor *)lit_kbFadePurpleDark;
+ (UIColor *)lit_kbFadePurpleLight;
+ (UIColor *)lit_kbFadeGreenDark;
+ (UIColor *)lit_kbFadeGreenLight;
+ (UIColor *)lit_kbFadeBlueDark;
+ (UIColor *)lit_kbFadeBlueLight;
+ (UIColor *)lit_kbFadeFavoritesDark;
+ (UIColor *)lit_kbFadeFavoritesLight;
+ (UIColor *)lit_kbOrangeDark;
+ (UIColor *)lit_kbOrangeLight;

+ (UIColor *)lit_kbNoAccessBackgroundDark;
+ (UIColor *)lit_kbNoAccessBackgroundLight;
+ (UIColor *)lit_kbNoAccessTitleBarDark;
+ (UIColor *)lit_kbNoAccessTitleBarLight;


@end

#ifndef LIT_EXTENSION

@interface UIViewController (Theming)
- (void)setTitleLogo;
@end

@interface LITTheme : NSObject
+ (void)applyTheme;
@end

@interface UILabel (FontAppearance)
@property (nonatomic, copy) UIFont * appearanceFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) UIColor * appearanceTextColor UI_APPEARANCE_SELECTOR;
@end

@implementation UILabel (FontAppearance)

-(void)setAppearanceFont:(UIFont *)font {
    if (font)
        [self setFont:font];
}

-(UIFont *)appearanceFont {
    return self.font;
}

-(void)setAppearanceTextColor:(UIColor *)textColor {
    if (textColor)
        [self setTextColor:textColor];
}

-(UIColor *)appearanceTextColor {
    return self.textColor;
}

@end

#endif

