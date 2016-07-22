//
//  LITTermsOfServiceViewController.h
//  lit-ios
//
//  Created by Antonio Losada on 15/10/15.
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kLITPrivacyPolicyURL;
extern NSString *const kLITTOSURL;

typedef NS_ENUM(NSUInteger, LITTermsOfServiceMode) {
    LITTermsOfServiceModeTOS,
    LITTermsOfServiceModePrivacyPolicy
};

@interface LITTermsOfServiceViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webViewTOS;

@property (assign, nonatomic) LITTermsOfServiceMode mode;

@end
