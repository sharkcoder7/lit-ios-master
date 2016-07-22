//
//  LITTheme.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITTheme.h"
#ifndef LIT_EXTENSION
#import "LITGradientNavigationBar.h"
#endif



@implementation UIColor (LITColors)

+ (UIColor *)lit_fadedOrangeLightColor {
    //return [UIColor colorWithRed:244.0f / 255.0f green:153.0f / 255.0f blue:91.0f / 255.0f alpha:1.0f];
    return [UIColor colorWithRed:247.0f / 255.0f green:152.0f / 255.0f blue:101.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_fadedOrangeDarkColor {
    //return [UIColor colorWithRed:244.0f / 255.0f green:132.0f / 255.0f blue:102.0f / 255.0f alpha:1.0f];
    return [UIColor colorWithRed:242.0f / 255.0f green:128.0f / 255.0f blue:105.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_lyricCellOrangeDarkColor {
    //return [UIColor colorWithRed:244.0f / 255.0f green:132.0f / 255.0f blue:102.0f / 255.0f alpha:1.0f];
    return [UIColor colorWithRed:244.0f/255.0f green:132.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
}

+ (UIColor *)lit_lyricCellOrangeLightColor {
    //return [UIColor colorWithRed:244.0f / 255.0f green:132.0f / 255.0f blue:102.0f / 255.0f alpha:1.0f];
    return [UIColor colorWithRed:251.0f/255.0f green:146.0f/255.0f blue:76.0f/255.0f alpha:1.0f];
}


+ (UIColor *)lit_histogramGreyColor {
    return [UIColor colorWithWhite:236.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_whiteColor {
    return [UIColor colorWithWhite:255.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_pinkishGreyColor {
    return [UIColor colorWithWhite:205.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_coolGreyColor {
    return [UIColor colorWithRed:140.0f / 255.0f green:145.0f / 255.0f blue:148.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_darkOrangishColor {
    return [UIColor colorWithRed:248.0f / 255.0f green:123.0f / 255.0f blue:81.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_placeholderOrange {
    return [UIColor colorWithRed:255.0f / 255.0f green:207.0f / 255.0f blue:186.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_greyColor {
    return [UIColor colorWithWhite:216.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_darkGreyColor {
    return [UIColor colorWithRed:57.0f / 255.0f green:59.0f / 255.0f blue:59.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_lightGreyColor {
    return [UIColor colorWithWhite:242.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_lighterGreyColor {
    return [UIColor colorWithWhite:246.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_salmonColor {
    return [UIColor colorWithRed:249.0f / 255.0f green:111.0f / 255.0f blue:111.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_lightOrangishColor {
    return [UIColor colorWithRed:251.0f / 255.0f green:137.0f / 255.0f blue:76.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_facebookColor {
    return [UIColor colorWithRed:63.0f / 255.0f green:93.0f / 255.0f blue:152.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_twitterColor {
    return [UIColor colorWithRed:89.0f / 255.0f green:173.0f / 236.0f blue:236.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_keyboardTitleColor {
    return [UIColor colorWithRed:230.0f / 255.0f green:230.0f / 236.0f blue:230.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)searchBar_Color1 {
    return [UIColor colorWithRed:135.0f / 255.0f green:28.0f / 255.0f blue:26.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)searchBar_Color2 {
    return [UIColor colorWithRed:149.0f / 255.0f green:35.0f / 255.0f blue:27.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)tag_cellColor {
    return [UIColor colorWithRed:11.0f / 255.0f green:131.0f / 255.0f blue:254.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_kbFadeRedDark {
    return [UIColor colorWithRed:98.0f / 255.0f green:32.0f / 255.0f blue:44.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_kbFadeRedLight {
    return [UIColor colorWithRed:226.0f / 255.0f green:40.0f / 255.0f blue:40.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_kbOrangeDark {
    return [UIColor colorWithRed:142.0/255.0 green:14.0/255.0 blue:3.0/255.0f alpha:1.0];
}

+ (UIColor *)lit_kbOrangeLight {
    return [UIColor colorWithRed:243.0/255.0 green:116.0/255.0 blue:29.0/255.0 alpha:1.0];
}

+ (UIColor *)lit_kbFadeOrangeDark {
    return [UIColor colorWithRed:134.0f / 255.0f green:33.0f / 255.0f blue:32.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_kbFadeOrangeLight {
    return [UIColor colorWithRed:248.0f / 255.0f green:112.0f / 255.0f blue:28.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_kbFadeOrangeDarkFeed {
    return [UIColor colorWithRed:125.0f / 255.0f green:10.0f / 255.0f blue:25.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_kbFadeOrangeMediumFeed {
    return [UIColor colorWithRed:174.0f / 255.0f green:30.0f / 255.0f blue:7.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_kbFadeOrangeLightFeed {
    return [UIColor colorWithRed:249.0f / 255.0f green:83.0f / 255.0f blue:10.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_kbFadePurpleDark {
    return [UIColor colorWithRed:55.0f / 255.0f green:48.0f / 255.0f blue:106.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_kbFadePurpleLight {
    return [UIColor colorWithRed:194.0f / 255.0f green:107.0f / 255.0f blue:212.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_kbFadeGreenDark {
    return [UIColor colorWithRed:32.0f / 255.0f green:84.0f / 255.0f blue:43.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_kbFadeGreenLight {
    return [UIColor colorWithRed:14.0f / 255.0f green:175.0f / 255.0f blue:3.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_kbFadeBlueDark {
    return [UIColor colorWithRed:32.0f / 255.0f green:84.0f / 255.0f blue:134.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_kbFadeBlueLight {
    return [UIColor colorWithRed:29.0f / 255.0f green:203.0f / 255.0f blue:249.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_kbFadeFavoritesDark {
    return [UIColor colorWithRed:102.0f / 255.0f green:39.0f / 255.0f blue:51.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_kbFadeFavoritesLight {
    return [UIColor colorWithRed:227.0f / 255.0f green:40.0f / 255.0f blue:40.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_kbNoAccessBackgroundDark {
    return [UIColor colorWithRed:50.0f / 255.0f green:0.0f / 255.0f blue:0.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_kbNoAccessBackgroundLight {
    return [UIColor colorWithRed:216.0f / 255.0f green:78.0f / 255.0f blue:37.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_kbNoAccessTitleBarDark {
    return [UIColor colorWithRed:227.0f / 255.0f green:105.0f / 255.0f blue:60.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)lit_kbNoAccessTitleBarLight {
    return [UIColor colorWithRed:252.0f / 255.0f green:130.0f / 255.0f blue:78.0f / 255.0f alpha:1.0f];
}






@end

#ifndef LIT_EXTENSION
@implementation UIViewController (Theming)

- (void)setTitleLogo
{
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
}

@end

@implementation LITTheme

+ (void)applyTheme {
    [self applyThemeToNavigationBar];
    [self applyThemeToUIAlertControllers];
}

+ (void)applyThemeToNavigationBar
{
    NSArray *colors = @[[UIColor lit_fadedOrangeLightColor], [UIColor lit_fadedOrangeDarkColor]];
    [[LITGradientNavigationBar appearance] setBarTintGradientColors:colors];
    [[LITGradientNavigationBar appearance] setGradientAngle:0.0f];
    [[LITGradientNavigationBar appearance] setOpacity:1.0];
    [[LITGradientNavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[LITGradientNavigationBar appearance] setTranslucent:NO];
    
    [[LITGradientNavigationBar appearance]
     setTitleTextAttributes:@{   NSForegroundColorAttributeName:[UIColor whiteColor],
                                 NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Medium" size:15.0f]}];
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil]
     setDefaultTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Regular" size:12]}];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                              NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Bold" size:10]}
     forState:UIControlStateNormal];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
     setTitle:@"CANCEL"];
    
    [[UISearchBar appearance] setBarTintColor:[UIColor lit_lightGreyColor]];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];

}

+ (void)applyThemeToUIAlertControllers
{    
    [[UILabel appearanceWhenContainedIn:UIAlertController.class, nil] setAppearanceFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:13]];
    [[UILabel appearanceWhenContainedIn:UIAlertController.class, nil] setAppearanceTextColor:[UIColor colorWithRed:140.0f / 255.0f green:145.0f / 255.0f blue:148.0f / 255.0f alpha:1.0f]];
}

@end

#endif
