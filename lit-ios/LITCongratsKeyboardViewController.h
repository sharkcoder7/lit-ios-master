//
//  LITCongratsKeyboardViewController.h
//  lit-ios
//
//  Created by Antonio Losada on 21/8/15.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareDialog.h>

@interface LITCongratsKeyboardViewController : UIViewController <FBSDKSharingDelegate>

-(void)assignKeyboard:(LITKeyboard *)kb;
-(void)prepareControls;

@end
