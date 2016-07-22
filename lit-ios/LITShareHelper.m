//
//  LITShareHelper.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITShareHelper.h"
#import "LITKeyboard.h"
#import "LITCongratsKeyboardViewController.h"
#import <Parse/Parse.h>
#import <ParseTwitterUtils/PFTwitterUtils.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "LITShareHelper.h"
#import "LITProgressHud.h"
#import <Social/Social.h>

@implementation LITShareHelper


+ (BOOL)checkTwitterLinked {
    
    if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (BOOL)checkFacebookLinked {
    
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){
        return YES;
    }
    else {
        return NO;
    }
}

+ (BFTask *)linkTwitterAccount {

    return [[PFTwitterUtils linkUserInBackground:[PFUser currentUser]]continueWithBlock:^id(BFTask *task) {
        
        if(task.result){
            return [BFTask taskWithResult:@(LITSharingLinkOkTwitter)];
        }
        else{
            return [BFTask taskWithResult:@(LITSharingLinkErrorTwitter)];
        }
    }];
}

+ (BFTask *)linkFacebookAccount {
    
    return [[PFFacebookUtils linkUserInBackground:[PFUser currentUser] withPublishPermissions:@[ @"publish_actions"]] continueWithBlock:^id(BFTask *task) {
        
        if(task.result){
            return [BFTask taskWithResult:@(LITSharingLinkOkFacebook)];
        }
        else{
            return [BFTask taskWithResult:@(LITSharingLinkErrorFacebook)];
        }
    }];
}

+ (void)shareMessage:(NSString *)message {
    
    // Check Twitter enabled and publish the message
    if([self checkTwitterLinked]){
        
        NSString *url = @"https://api.twitter.com/1.1/statuses/update.json";
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
        [params setObject:message forKey:@"status"];
        
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            if(granted)
            {
                NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
                if ([accountsArray count] > 0)
                {
                    ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                    
                    SLRequest *postRequest = [SLRequest  requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:url] parameters:params ];
                    
                    [postRequest setAccount:twitterAccount];
                    
                    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                     {
                         //                         NSString *output = [NSString stringWithFormat:@"HTTP response status: %i", [urlResponse statusCode]];
                         //                         NSLog(@"output = %@",output);
                         dispatch_async( dispatch_get_main_queue(), ^{
                             if (error){NSLog(@"POST error from Twitter: %@",[error description]);}
                         });
                     }];
                }
                else
                {
                    NSLog(@"No Account in Settings");
                }
            }
        }];
        
    }
    
    // Check Facebook enabled and publish the message
    if([self checkFacebookLinked]){
        
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        __block ACAccount *facebookAccount = nil;
        
        ACAccountType *facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        
        NSDictionary *accessOptions = @{
                                        ACFacebookAppIdKey: @"1610324759219302",
                                        ACFacebookPermissionsKey: @[@"email"],
                                        ACFacebookAudienceKey: ACFacebookAudienceEveryone
                                        };
        
        // Request access to the user's account
        [accountStore requestAccessToAccountsWithType:facebookAccountType options:accessOptions completion:^(BOOL granted, NSError *e)
         {
             if (granted) {
                 
                 NSDictionary *writingOptions = @{
                                                  ACFacebookAppIdKey: @"1610324759219302",
                                                  ACFacebookPermissionsKey: @[@"publish_actions"],
                                                  ACFacebookAudienceKey: ACFacebookAudienceFriends
                                                  };
                 
                 // Request access to publish from the user's account
                 [accountStore requestAccessToAccountsWithType:facebookAccountType options:writingOptions completion:^(BOOL granted, NSError *error) {
                     if (granted) {
                         
                         NSArray *accounts = [accountStore accountsWithAccountType:facebookAccountType];
                         facebookAccount = [accounts lastObject];
                         
                         NSDictionary *parameters = @{@"message": message};
                         
                         NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me/feed"];
                         
                         SLRequest *feedRequest = [SLRequest
                                                   requestForServiceType:SLServiceTypeFacebook
                                                   requestMethod:SLRequestMethodPOST
                                                   URL:feedURL
                                                   parameters:parameters];
                         
                         [feedRequest setAccount:facebookAccount];
                         
                         [feedRequest performRequestWithHandler:^(NSData *responseData,
                                                                  NSHTTPURLResponse *urlResponse, NSError *error)
                          {
                              // Handle response if needed
                              //                              NSLog(@"%@%@", error,urlResponse);
                              //                              NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
                              //                              NSLog(@"Facebook Response : %@",response);
                          }];
                     }
                     else {
                         NSLog(@"Writing Access Denied: %@", [error description]);
                     }
                 }];
             } else {
                 NSLog(@"Account Access Denied: %@", [e description]);
             }
         }];
    }
}

+ (void)shareMessage:(NSString *)message inView:(id)view {
    
    JGProgressHUD *hud = [LITProgressHud createHudWithMessage:@""];
    
    // Check Twitter enabled and publish the message
    if([self checkTwitterLinked]){
        
        NSString *url = @"https://api.twitter.com/1.1/statuses/update.json";
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
        [params setObject:message forKey:@"status"];
        
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            if(granted)
            {
                NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
                if ([accountsArray count] > 0)
                {
                    ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                    
                    SLRequest *postRequest = [SLRequest  requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:url] parameters:params ];
                    
                    [postRequest setAccount:twitterAccount];
                    
                    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                     {
                         dispatch_async( dispatch_get_main_queue(), ^{
                             if (error){NSLog(@"POST error from Twitter: %@",[error description]);
                                 
                                 [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError withMessage:@"Error sharing"];
                                 [hud showInView:view animated:YES];
                                 [hud dismissAfterDelay:1.5f];
                             }
                             else{
                                 [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:@"Shared"];
                                 [hud showInView:view animated:YES];
                                 [hud dismissAfterDelay:1.5f];
                             }
                             
                         });
                     }];
                }
                else
                {
                    [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError withMessage:@"Error sharing"];
                    [hud showInView:view animated:YES];
                    [hud dismissAfterDelay:1.5f];
                }
            }
        }];
        
    }
    
    // Check Facebook enabled and publish the message
    if([self checkFacebookLinked]){
        
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        __block ACAccount *facebookAccount = nil;
        
        ACAccountType *facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        
        NSDictionary *accessOptions = @{
                                        ACFacebookAppIdKey: @"1610324759219302",
                                        ACFacebookPermissionsKey: @[@"email"],
                                        ACFacebookAudienceKey: ACFacebookAudienceEveryone
                                        };
        
        // Request access to the user's account
        [accountStore requestAccessToAccountsWithType:facebookAccountType options:accessOptions completion:^(BOOL granted, NSError *e)
         {
             if (granted) {
                 
                 NSDictionary *writingOptions = @{
                                                  ACFacebookAppIdKey: @"1610324759219302",
                                                  ACFacebookPermissionsKey: @[@"publish_actions"],
                                                  ACFacebookAudienceKey: ACFacebookAudienceFriends
                                                  };
                 
                 // Request access to publish from the user's account
                 [accountStore requestAccessToAccountsWithType:facebookAccountType options:writingOptions completion:^(BOOL granted, NSError *error) {
                     if (granted) {
                         
                         NSArray *accounts = [accountStore accountsWithAccountType:facebookAccountType];
                         facebookAccount = [accounts lastObject];
                         
                         NSDictionary *parameters = @{@"message": message};
                         
                         NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me/feed"];
                         
                         SLRequest *feedRequest = [SLRequest
                                                   requestForServiceType:SLServiceTypeFacebook
                                                   requestMethod:SLRequestMethodPOST
                                                   URL:feedURL
                                                   parameters:parameters];
                         
                         [feedRequest setAccount:facebookAccount];
                         
                         [feedRequest performRequestWithHandler:^(NSData *responseData,
                                                                  NSHTTPURLResponse *urlResponse, NSError *error)
                          {
                              if(error){
                                  [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError withMessage:@"Error sharing"];
                                  [hud showInView:view animated:YES];
                                  [hud dismissAfterDelay:1.5f];
                              }
                              else {
                                  [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateDone withMessage:@"Shared"];
                                  [hud showInView:view animated:YES];
                                  [hud dismissAfterDelay:1.5f];
                              }
                          }];
                     }
                     else {
                         [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError withMessage:@"Error sharing"];
                         [hud showInView:view animated:YES];
                         [hud dismissAfterDelay:1.5f];
                     }
                 }];
             } else {
                 [LITProgressHud changeStateOfHUD:hud to:kLITHUDStateError withMessage:@"Error sharing"];
                 [hud showInView:view animated:YES];
                 [hud dismissAfterDelay:1.5f];
             }
         }];
    }
}

@end
