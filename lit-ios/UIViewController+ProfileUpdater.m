//
//  UIViewController+UserNameUpdater.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "UIViewController+ProfileUpdater.h"
#import "ParseGlobals.h"
#import "LITKeyboard.h"
#import "LITKeyboardInstallerHelper.h"

#import <Parse/PFUser+Synchronous.h>
#import <Parse/PFQuery+Synchronous.h>
#import <Parse/PFObject+Synchronous.h>
#import <Parse/PFFile.h>
#import <Parse/PFQuery.h>
#import <Bolts/Bolts.h>
#import <ParseTwitterUtils/ParseTwitterUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>


NSString *const kProfileDataUsernameKey     = @"name";
NSString *const kProfileDataEmailKey        = @"email";
NSString *const kProfileDataPictureURLKey   = @"picture";

@implementation UIViewController (ProfileUpdater)

- (BFTask *)updateProfileDataWithAuthData:(NSDictionary *)authData
{
    return [[[[self getProfileData:authData] continueWithSuccessBlock:^id(BFTask *task) {
        NSDictionary *accountData = task.result;
        
        if (accountData[kProfileDataUsernameKey] &&
            [accountData[kProfileDataUsernameKey] length] > 0 &&
            ![[PFUser currentUser].username isEqualToString:accountData[kProfileDataUsernameKey]]) {
            [[PFUser currentUser] setUsername:accountData[kProfileDataUsernameKey]];
        }
        
        if (accountData[kProfileDataEmailKey] &&
            [accountData[kProfileDataEmailKey] length] > 0 &&
            ![[PFUser currentUser].email isEqualToString:accountData[kProfileDataEmailKey]]) {
            [[PFUser currentUser] setEmail:accountData[kProfileDataEmailKey]];
        }
        
        if (![[PFUser currentUser] objectForKey:@"picture"]) {
            NSData *picData = [NSData dataWithContentsOfURL:[NSURL URLWithString:accountData[kProfileDataPictureURLKey]]];
            if (picData) {
                PFFile *picture = [PFFile fileWithData:picData];
                [[PFUser currentUser] setObject:picture forKey:@"picture"];
            }
        }
        return [[PFUser currentUser] saveInBackground];
    }] continueWithSuccessBlock:^id(BFTask *task) {
        return [self fetchFavsKeyboardIfNeeded];
    }] continueWithSuccessBlock:^id(BFTask *task) {
        return [self updateInstalledKeyboards];
    }];
}

- (BFTask *)getProfileData:(NSDictionary *)authData
{
    NSParameterAssert(authData);
    NSAssert([[authData allKeys] count] >= 1, @"Auth data dictionary cannot be empty");
    for (NSString *authDataKey in [authData allKeys]) {
        if ([authDataKey isEqualToString:@"facebook"]) {
            NSLog(@"User is linked to Facebook");
            return [self getFacebookProfileData];
        } else if ([authDataKey isEqualToString:@"twitter"]) {
            NSLog(@"User is linked to Twitter");
            return [self getTwitterProfileData];
        }
    }
    return [BFTask taskWithError:[NSError errorWithDomain:@"it.itsl" code:001 userInfo:@{NSLocalizedDescriptionKey : @"User is not authenticated"}]];
}


- (BFTask *)setProfilePictureAtURL:(NSURL *)picURL
{
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    if (picURL) {
        NSData *picData = [NSData dataWithContentsOfURL:picURL];
        if (picData) {
            PFFile *userPicture = [[PFUser currentUser] objectForKey:@"picture"];
            if (!userPicture) {
                [[PFUser currentUser] setObject:[PFFile fileWithData:picData] forKey:@"picture"];
                NSLog(@"Saved picture");
            }
            [[PFUser currentUser] save];
        }
    }
    return taskSource.task;
}

- (BFTask *)getFacebookProfileData
{
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"name,picture,email"}];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSString *facebookUsername = [result objectForKey:@"name"];
                NSString *email = [result objectForKey:@"email"];
                NSString *picURLString = result[@"picture"][@"data"][@"url"];
                
                if (facebookUsername && email && picURLString) {
                    NSDictionary *dictionary = @{kProfileDataUsernameKey    : facebookUsername,
                                                 kProfileDataEmailKey       : email,
                                                 kProfileDataPictureURLKey  : picURLString};
                    
                    [taskSource setResult:dictionary];
                } else {
                    [taskSource
                     setResult:[NSError errorWithDomain:@"it.itsl" code:1066 userInfo:@{NSLocalizedDescriptionKey: @"Cannot retrieve youf fb profile information"}]];
                }
            }
            else {
                NSLog(@"Error retrieving user");
                [taskSource setError:error];
            }
        }];
    });

    return taskSource.task;
}

- (BFTask *)getTwitterProfileData
{
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    NSString *screenName = [[PFTwitterUtils twitter] screenName];
    NSString *requestString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?screen_name=%@", screenName];
    NSURL *requestURL = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [[PFTwitterUtils twitter] signRequest:request];
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (!error && data) {
        NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSString *name = [result objectForKey:@"name"];
        NSString *pictureURLString = [result objectForKey:@"profile_image_url_https"];
        
        NSDictionary *dictionary = @{kProfileDataUsernameKey    : name,
                                     kProfileDataPictureURLKey  : pictureURLString};
        [taskSource setResult:dictionary];
    } else {
        [taskSource setError:error];
    }
    return taskSource.task;
}

- (BFTask *)fetchFavsKeyboardIfNeeded
{
    __block PFObject *favKeyboard;
    return [[[PFUser currentUser] fetchInBackground] continueWithBlock:^id(BFTask *task) {
        PFUser *theUser = task.result;
        NSString *favKeyboardID = [[theUser objectForKey:kUserFavKeyboardKey] objectId];
        PFQuery *favKBQuery = [PFQuery queryWithClassName:kFavKeyboardClassName];
        [favKBQuery fromLocalDatastore];
        return [[[favKBQuery getObjectInBackgroundWithId:favKeyboardID] continueWithBlock:^id(BFTask *task) {
            if (task.result && !task.error) {
                //Keyboard is pinned. Continue
                return [BFTask taskWithResult:task.result];
            } else {
                //Keyboard is not pinned. Download and pin.
                favKeyboard = [[PFQuery queryWithClassName:kFavKeyboardClassName]
                                         getObjectWithId:favKeyboardID];
                if (favKeyboard) {
                    return [favKeyboard pinInBackground];
                } else {
                    return [BFTask taskWithError:[NSError errorWithDomain:@"it.itsl" code:010 userInfo:@{NSLocalizedDescriptionKey : @"Favorites keyboard couldn't be fetched"}]];
                }
            }
        }] continueWithSuccessBlock:^id(BFTask *task) {
            [LITKeyboardInstallerHelper downloadKeyboardContentsToSharedCache:(LITKeyboard *)favKeyboard];
            return nil;
        }];
    }];
}

//- (BFTask *)updateLITKeyboardCache
//{
//    __block LITKeyboard *litKeyboard;
//    return [[[[[PFQuery queryWithClassName:[LITKeyboard parseClassName]]
//                      getObjectInBackgroundWithId:kLITKeyboardObjectId] continueWithSuccessBlock:^id(BFTask *task) {
//         litKeyboard = task.result;
//        return [litKeyboard pinInBackground];
//    }] continueWithSuccessBlock:^id(BFTask *task) {
//        return [LITKeyboardInstallerHelper downloadKeyboardContentsToSharedCache:litKeyboard];
//    }] continueWithBlock:^id(BFTask *task) {
//        if (!task.error) {
//            NSLog(@"Successfully downloaded LIT Keyboard contents");
//            return [BFTask taskWithError:task.error];
//        } else {
//            NSLog(@"Error downloading LIT Keyboard contents");
//            return nil;
//        }
//    }];
//}

- (BFTask *)updateInstalledKeyboards
{
    __block NSArray *installedKeyboards;
    return [[[[[[[[PFQuery queryWithClassName:kKeyboardInstallationsClassName]
         includeKey:kKeyboardInstallationsKeyboardsKey]
        whereKey:kKeyboardInstallationsUserKey
        equalTo:[PFUser currentUser]] includeKey:kKeyboardInstallationsKeyboardsKey] getFirstObjectInBackground]
    continueWithSuccessBlock:^id(BFTask *task) {
        PFObject *keyboardInstallationsObject = task.result;
        installedKeyboards = [keyboardInstallationsObject objectForKey:kKeyboardInstallationsKeyboardsKey];
        return [keyboardInstallationsObject pinInBackground];
    }] continueWithSuccessBlock:^id(BFTask *task) {
        NSMutableArray *tasks = [NSMutableArray array];
        for (LITKeyboard *installedKeyboard in installedKeyboards) {
            [tasks addObject:[LITKeyboardInstallerHelper downloadKeyboardContentsToSharedCache:installedKeyboard]];
        }
        return [BFTask taskForCompletionOfAllTasks:tasks];
    }] continueWithBlock:^id(BFTask *task) {
        if (!task.error) {
            NSLog(@"Successfully downloaded installed Keyboards contents");
            return [BFTask taskWithError:task.error];
        } else {
            NSLog(@"Error downloading installed keyboards contents");
            return nil;
        }
    }];
}

@end
