//
//  LITKeyboardInstallerHelper.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITKeyboardInstallerHelper.h"
#import "LITAddToKeyboardViewController.h"
#import "LITKeyboard.h"
#import "ParseGlobals.h"
#import "LITSharedFileCache.h"
#import "LITKeyboard.h"
#import "LITDub.h"
#import "LITSoundbite.h"
#import <Bolts/Bolts.h>
#import <Parse/PFQuery.h>
#import <Parse/PFFile.h>

NSString *const kLITKeyboardWasInstalledNotificationName = @"kLITKeyboardWasInstalledNotification";
NSString *const kLITKeyboardWasRemovedNotificationName = @"kLITKeyboardWasRemovedNotification";

@implementation LITKeyboardInstallerHelper

+ (BFTask *)installKeyboard:(LITKeyboard *)targetKeyboard fromViewController:(UIViewController *)viewController
{
    return [self installKeyboard:targetKeyboard
              fromViewController:viewController
               withProgressBlock:nil
            andCancellationToken:nil];
}

+ (BFTask *)installKeyboard:(LITKeyboard *)targetKeyboard
         fromViewController:(UIViewController *)viewController
          withProgressBlock:(LITKeyboardInstallationProgressBlock)block
       andCancellationToken:(BFCancellationToken *)cancelToken
{
    __block NSMutableArray *installedKeyboards;
    return [[self downloadKeyboardContentsToSharedCache:targetKeyboard withProgressBlock:block]
            continueWithSuccessBlock:^id(BFTask *task) {
                if (cancelToken.isCancellationRequested) {
                    return [BFTask cancelledTask];
                }
                else if(task.error){
                    NSLog(@"1: %@",task.error);
                }
                NSLog(@"All contents in keyboard were downloaded to shared cache");
                return [[[[[[PFQuery queryWithClassName:kKeyboardInstallationsClassName]
                            whereKey:kKeyboardInstallationsUserKey equalTo:[PFUser currentUser]] fromLocalDatastore]
                          getFirstObjectInBackground] continueWithSuccessBlock:^id(BFTask *task) {
                    if (cancelToken.isCancellationRequested) {
                        return [BFTask cancelledTask];
                    }
                    else if(task.error){
                        NSLog(@"2: %@",task.error);
                    }
                    PFObject *keyboardInstallationsObject = task.result;
                    installedKeyboards = [NSMutableArray arrayWithArray:[keyboardInstallationsObject objectForKey:kKeyboardInstallationsKeyboardsKey]];
                    if ([installedKeyboards count] <= kLITMaxKeyboardsNumber) {
                        if(![installedKeyboards containsObject:targetKeyboard]){
                            [installedKeyboards addObject:targetKeyboard];
                        }
                        [keyboardInstallationsObject setObject:installedKeyboards forKey:kKeyboardInstallationsKeyboardsKey];
                        return [keyboardInstallationsObject saveEventually];
                    } else
                        return [BFTask taskWithError:[NSError errorWithDomain:@"it.itsl" code:20 userInfo:@{NSLocalizedDescriptionKey : @"Keyboards list is full"}]];
                    
                }] continueWithSuccessBlock:^id(BFTask *task) {
                    if (cancelToken.isCancellationRequested) {
                        return [BFTask cancelledTask];
                    }
                    else if(task.error){
                        NSLog(@"3: %@",task.error);
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kLITKeyboardWasInstalledNotificationName object:[NSArray arrayWithArray:installedKeyboards]];
                    });
                    if([viewController class] != [LITAddToKeyboardViewController class]){
                        PFObject *keyboardDownloadsObject = [PFObject objectWithClassName:kKeyboardDownloadsClassName];
                        [keyboardDownloadsObject setObject:[PFUser currentUser] forKey:kKeyboardDownloadsUserKey];
                        [keyboardDownloadsObject setObject:targetKeyboard forKey:kKeyboardDownloadsKeyboardKey];
                        [keyboardDownloadsObject saveInBackground];
                    }
                    return nil;
                }];
            }];
}

+ (BFTask *)downloadKeyboardContentsToSharedCache:(LITKeyboard *)targetKeyboard
                                withProgressBlock:(LITKeyboardInstallationProgressBlock)block
{
    return [[targetKeyboard fetchInBackground] continueWithSuccessBlock:^id(BFTask *task) {
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(.05);
            });
        }
        return [[task.result pinInBackground] continueWithSuccessBlock:^id(BFTask *task) {
            if (block) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(.10);
                });
            }
            NSLog(@"Installed keyboard was pinned");
            NSMutableArray *tasks = [NSMutableArray array];
            CGFloat percentIncrement = (.9f / [targetKeyboard.contents count]);
            __block CGFloat totalProgress = .10;
            for (id object in targetKeyboard.contents) {
                BFTask *pinContentTask = [[[object fetchIfNeededInBackground]
                                           continueWithSuccessBlock:^id(BFTask *task) {
                                               return [object pinInBackground];
                                           }] continueWithBlock:^id(BFTask *task) {
                                               if (task.error) {
                                                   NSLog(@"Error pinning object: %@", task.error.localizedDescription);
                                                   return [BFTask taskWithError:task.error];
                                               } else {
                                                   NSLog(@"Object was pinned %@", object);
                                                   totalProgress+=percentIncrement;
                                                   if (block) {
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           block(totalProgress);
                                                       });
                                                   }
                                                   return nil;
                                               }
                                           }];
                [tasks addObject:pinContentTask];
                if ([object isKindOfClass:[LITDub class]] ||
                    [object isKindOfClass:[LITSoundbite class]]) {
                    [tasks addObject:[object addToSharedCache]];
                }
            }
            return [BFTask taskForCompletionOfAllTasks:tasks];
        }];
    }];
}

+ (BFTask *)downloadKeyboardContentsToSharedCache:(LITKeyboard *)targetKeyboard
{
    return [self downloadKeyboardContentsToSharedCache:targetKeyboard
                                     withProgressBlock:nil];
}

+ (BFTask *)removeKeyboard:(LITKeyboard *)targetKeyboard
{
    return [[targetKeyboard unpinInBackground] continueWithSuccessBlock:^id(BFTask *task) {
        return [[[[[PFQuery queryWithClassName:kKeyboardInstallationsClassName]
                   whereKey:kKeyboardInstallationsUserKey equalTo:[PFUser currentUser]] fromLocalDatastore]
                  getFirstObjectInBackground] continueWithSuccessBlock:^id(BFTask *task) {
            PFObject *keyboardInstallationsObject = task.result;
            NSMutableArray *installedKeyboards = [NSMutableArray arrayWithArray:[keyboardInstallationsObject objectForKey:kKeyboardInstallationsKeyboardsKey]];
            [installedKeyboards removeObject:targetKeyboard];
            NSLog(@"Successfully deleted keyboard contents");
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kLITKeyboardWasRemovedNotificationName object:installedKeyboards];
            });
            [keyboardInstallationsObject setObject:installedKeyboards forKey:kKeyboardInstallationsKeyboardsKey];
            return [keyboardInstallationsObject saveEventually];
        }];
    }];
}

+ (BFTask *)checkKeyboardStatus:(LITKeyboard *)keyboard
{
    return [[[[[PFQuery
                queryWithClassName:kKeyboardInstallationsClassName]
               whereKey:kKeyboardInstallationsUserKey equalTo:[PFUser currentUser]]
              whereKey:kKeyboardInstallationsKeyboardsKey containsAllObjectsInArray:@[keyboard]] findObjectsInBackground] continueWithSuccessBlock:^id(BFTask *task) {
        if ([task.result count] > 0) {
            return [BFTask taskWithResult:@(LITKeyboardStatusInstalled)];
        } else return [[[[[PFQuery queryWithClassName:kKeyboardDownloadsClassName]
                          whereKey:kKeyboardDownloadsUserKey equalTo:[PFUser currentUser]]
                         whereKey:kKeyboardDownloadsKeyboardKey equalTo:keyboard] getFirstObjectInBackground]
                       continueWithBlock:^id(BFTask *task) {
                           if (task.result) {
                               return [BFTask taskWithResult:@(LITKeyboardStatusUninstalled)];
                           } else return [BFTask taskWithResult:@(LITKeyboardStatusNonInstalled)];
                       }];
    }];
}

@end
