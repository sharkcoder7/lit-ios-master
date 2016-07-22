//
//  LITProgressHud.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITProgressHud.h"

@implementation LITProgressHud

NSString *const kLITHUDStateError = @"kLITHUDStateError";
NSString *const kLITHUDStateSuccess = @"kLITHUDStateSuccess";
NSString *const kLITHUDStateDone = @"kLITHUDStateDone";
NSString *const kLITHUDStatePaste = @"kLITHUDStatePaste";

int const donePasteImageSize = 60;


+ (JGProgressHUD *)createHudWithMessage:(NSString*)msg {
    
    JGProgressHUD *hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleLight];
    
    [hud.textLabel setText:msg];
    [hud.textLabel setTextColor:[UIColor colorWithWhite:0 alpha:1]];
    
    hud.opaque = NO;
    //hud.alpha = .9;
    
    hud.interactionType = JGProgressHUDInteractionTypeBlockAllTouches;
    
    //hud.square = YES;
    
    hud.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    hud.textLabel.textColor = [UIColor colorWithWhite:0.0f alpha:1];
    
    hud.HUDView.layer.shadowColor = [UIColor blackColor].CGColor;
    hud.HUDView.layer.shadowOffset = CGSizeZero;
    hud.HUDView.layer.shadowOpacity = 0.1f;
    hud.HUDView.layer.shadowRadius = 2.0f;
    
    return hud;
}

+ (JGProgressHUD *)createKeyboardHudWithMessage:(NSString*)msg {
    
    JGProgressHUD *hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleLight];
    
    [hud.textLabel setText:msg];
    
    hud.indicatorView = nil;
    hud.interactionType = JGProgressHUDInteractionTypeBlockAllTouches;
    
    //hud.square = YES;
    
    hud.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    
    hud.HUDView.layer.shadowColor = [UIColor blackColor].CGColor;
    hud.HUDView.layer.shadowOffset = CGSizeZero;
    hud.HUDView.layer.shadowOpacity = 0.0f;
    hud.HUDView.layer.shadowRadius = 2.0f;
    
    return hud;
}

+ (JGProgressHUD *)createCopyPasteHudWithMessage:(NSString*)msg {
    
    JGProgressHUD *hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleLight];
    hud.interactionType = JGProgressHUDInteractionTypeBlockAllTouches;
    
    
    [hud.textLabel setText:msg];
    [hud.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:30]];
    
    
    UIGraphicsBeginImageContext(CGSizeMake(donePasteImageSize, donePasteImageSize));
    CGContextAddRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, donePasteImageSize, donePasteImageSize));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    hud.indicatorView = [[JGProgressHUDImageIndicatorView alloc] initWithImage:image];
    
    
    
    UIView *indicatorExtraView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, donePasteImageSize, donePasteImageSize)];
    UIImage *indicatorImage = [UIImage imageNamed:@"hudDoneIconBlack.png"];
    UIImageView *indicatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, donePasteImageSize, donePasteImageSize)];
    
    [indicatorImageView setImage:indicatorImage];
    [indicatorExtraView addSubview:indicatorImageView];
    [indicatorExtraView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [hud.indicatorView addSubview:indicatorExtraView];
    
    
    
    hud.interactionType = JGProgressHUDInteractionTypeBlockAllTouches;
    hud.square = YES;
    hud.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    
    hud.HUDView.layer.shadowColor = [UIColor blackColor].CGColor;
    hud.HUDView.layer.shadowOffset = CGSizeZero;
    hud.HUDView.layer.shadowOpacity = 0.0f;
    hud.HUDView.layer.shadowRadius = 0.0f;
    
    return hud;
}

+ (void)changeStateOfHUD:(JGProgressHUD*)hud to:(NSString*)newState withMessage:(NSString *)msg{
    
    if(newState == kLITHUDStateError){
        hud.indicatorView = [[JGProgressHUDErrorIndicatorView alloc] init];
    }
    
    else if(newState == kLITHUDStateSuccess){
        hud.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
    }
    
    else if(newState == kLITHUDStateDone){
        hud.square = YES;
        
        // Real view with the tick to unveil progressively
        hud.indicatorView = [[JGProgressHUDImageIndicatorView alloc] initWithImage:[UIImage imageNamed:@"hudDoneIconBlack.png"]];
        
        // Dummy view to keep the square proportion
        UIView *dummyView = [[UIView alloc] init];
        dummyView.frame = CGRectMake(hud.indicatorView.frame.origin.x, hud.indicatorView.frame.origin.y, hud.indicatorView.frame.size.width, hud.indicatorView.frame.size.height);
        [hud addSubview:dummyView];
        
        int hudWidth = hud.indicatorView.frame.size.width;
        
        hud.indicatorView.clipsToBounds = YES;
        hud.indicatorView.frame = CGRectMake(hud.indicatorView.frame.origin.x, hud.indicatorView.frame.origin.y, 0, hud.indicatorView.frame.size.height);
        
        [UIView animateWithDuration:.2 delay:0.1 options: UIViewAnimationOptionCurveLinear animations:^{
            
            hud.indicatorView.frame = CGRectMake(hud.indicatorView.frame.origin.x, hud.indicatorView.frame.origin.y, hudWidth, hud.indicatorView.frame.size.height);
        }
        completion:^(BOOL finished){
                             
        }];
    }
    
    else if(newState == kLITHUDStatePaste){
        
        // Move the Done icon to the left, while pushing the Paste icon
        
        [UIView animateWithDuration:.1 delay:0.0 options: UIViewAnimationOptionCurveLinear animations:^{
            
            CGRect newPositionFrame = CGRectMake(-donePasteImageSize-20, 0, donePasteImageSize, donePasteImageSize);
            
            for(int i=0; i<[[hud.indicatorView subviews] count]; i++){
                
                if([[[hud.indicatorView subviews]objectAtIndex:i] isKindOfClass:[UIView class]]){
                    [[[hud.indicatorView subviews] objectAtIndex:i] setFrame:newPositionFrame];
                }
            }
        }
                         completion:^(BOOL finished){
                             
                             UIView *indicatorExtraView = [[UIView alloc]initWithFrame:CGRectMake(donePasteImageSize, 0, donePasteImageSize, donePasteImageSize)];
                             
                             UIImage *indicatorImage = [UIImage imageNamed:@"hudPasteIconBlack.png"];
                             
                             UIImageView *indicatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, donePasteImageSize, donePasteImageSize)];
                             [indicatorImageView setImage:indicatorImage];
                             [indicatorExtraView addSubview:indicatorImageView];
                             [indicatorExtraView setTranslatesAutoresizingMaskIntoConstraints:NO];
                             
                             [[hud.indicatorView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
                             
                             [hud.indicatorView addSubview:indicatorExtraView];
                             
                             
                             [UIView animateWithDuration:.1 delay:0.0 options: UIViewAnimationOptionCurveLinear animations:^{
                                 
                                 CGRect newPositionFrame = CGRectMake(0, 0, donePasteImageSize, donePasteImageSize);
                                 
                                 for(int i=0; i<[[hud.indicatorView subviews] count]; i++){
                                     
                                     if([[[hud.indicatorView subviews]objectAtIndex:i] isKindOfClass:[UIView class]]){
                                         [[[hud.indicatorView subviews] objectAtIndex:i] setFrame:newPositionFrame];
                                     }
                                 }
                             }
                                              completion:^(BOOL finished){
                                                  
                                              }];
                             
                         }];
    }
    
    [hud.textLabel setText:msg];
}

@end
