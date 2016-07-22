//
//  AppDelegate.m
//  slit-ios
//
//  Copyright (c) 2015 Slit Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "LITLyric.h"
#import "LITSoundbite.h"
#import "LITDub.h"
#import "LITKeyboard.h"
#import "LITKeyboardInstallerHelper.h"
#import "ParseGlobals.h"
#import "LITTheme.h"
#import "LITSharedFileCache.h"
#import "LITNoInternetConnectionViewController.h"

#import <Parse/Parse.h>
#import <Bolts/Bolts.h>
#import <ParseTwitterUtils/PFTwitterUtils.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Reachability/Reachability.h>
#import <GBVersionTracking/GBVersionTracking.h>
#import <Mixpanel/Mixpanel.h>
#import "MixpanelGlobals.h"

@interface AppDelegate ()

@property (assign, nonatomic) BOOL appStarted;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // In case there is no Push Notification detected, everything stays the same
    
    [Mixpanel sharedInstanceWithToken:kMixpanelToken];
    
    self.appStarted = NO;
    [GBVersionTracking track];
    
    // Initialize Reachability
    Reachability *reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    reachability.reachableOnWWAN = YES;
    [reachability startNotifier];
    
    // Add Reachability observer preventing duplicates
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kReachabilityChangedNotification object:nil];
    
    [Parse enableLocalDatastore];
    
    //Setup app sharing
    [Parse enableDataSharingWithApplicationGroupIdentifier:kLITAppGroupSharingIdentifier];
    
    // Initialize Parse.
    [Parse setApplicationId:kLITApplicationIdentifier
                  clientKey:kLITApplicationClientKey];
    
    //    [FBSDKSettings enableLoggingBehavior:FBSDKLoggingBehaviorNetworkRequests];
    
    
    
    
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    [LITTheme applyTheme];
    
    
    NSLog(@"Created cache shared folder at %@", [[LITSharedFileCache sharedFileCacheURL] absoluteString]);
    
    
    
    //    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [PFTwitterUtils initializeWithConsumerKey:kParseTwitterConsumerKey
                               consumerSecret:kParseTwitterConsumerSecret];
    
    // Check if the app is launched via Push Notification
    
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if(notificationPayload){
        NSLog(@"App launched using remote notification for user %@", [PFUser currentUser]);
        
    }
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:[[UIStoryboard
                                         storyboardWithName:@"Main"
                                         bundle:nil]
                                        instantiateInitialViewController]];
    [self.window makeKeyAndVisible];
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (void)reachabilityDidChange:(NSNotification *)notification {
    Reachability *reachability = (Reachability *)[notification object];
    
    // Back to the Initial VC
    if ([reachability isReachable]) {
        if(self.appStarted == YES){
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            [[[UIApplication sharedApplication].windows objectAtIndex:0] setRootViewController:[mainStoryboard instantiateInitialViewController]];
            self.appStarted = NO;
        }
    }
    // Show No Connection Controller
    else {
        self.appStarted = YES;
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"noConnectionVC"];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}



- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}



- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog(@"Received remote notification %@", userInfo);
//    NSString *keyboardId = [userInfo valueForKey:@"keyboardId"];
    
//    [[self updateInstalledKeyboardWithId:keyboardId] continueWithBlock:^id(BFTask *task) {
//        if(!task.error){
//            NSLog(@"Keyboards updated successfully via Push Notification");
//        }
//        return nil;
//    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSString *keyboardId = [userInfo valueForKey:@"keyboardId"];
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        [[self updateInstalledKeyboardWithId:keyboardId] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
            if(!task.error){
                NSLog(@"Keyboards updated successfully via Push Notification");
                completionHandler(UIBackgroundFetchResultNewData);
            }
            else {
                NSLog(@"Keyboards failed updating via Push Notification");
                completionHandler(UIBackgroundFetchResultFailed);
            }
            return nil;
        }];
    } else {
        [self updateInstalledKeyboardWithIdSync:keyboardId];
        completionHandler(UIBackgroundFetchResultNewData);
    }
}

- (void)updateInstalledKeyboardWithIdSync:(NSString *)keyboardId
{
    PFObject *keyboardInstallationsObject = [[[[PFQuery queryWithClassName:kKeyboardInstallationsClassName] includeKey:kKeyboardInstallationsKeyboardsKey] whereKey:kKeyboardInstallationsUserKey equalTo:[PFUser currentUser]] getFirstObject];
    
    NSArray *installedKeyboards = [keyboardInstallationsObject objectForKey:kKeyboardInstallationsKeyboardsKey];
    for (LITKeyboard *installedKeyboard in installedKeyboards) {
        if ([installedKeyboard.objectId isEqualToString:keyboardId]) {
            LITKeyboard *targetKeyboard = [installedKeyboard fetch];
            for (id object in targetKeyboard.contents) {
                [[object fetchIfNeeded] pin:nil];
                if ([object isKindOfClass:[LITDub class]] ||
                    [object isKindOfClass:[LITSoundbite class]]) {
                    [object addToSharedCacheSync];
                }
            }

        }
    }
}


- (BFTask *)updateInstalledKeyboardWithId:(NSString *)keyboardId
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
                      if([installedKeyboard.objectId isEqualToString:keyboardId])
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
