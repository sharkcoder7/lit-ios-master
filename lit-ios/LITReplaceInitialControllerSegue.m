    //
//  LITReplaceInitialControllerSegue.m
//  slit-ios
//
//  Copyright (c) 2015 Slit Inc. All rights reserved.
//

#import "LITReplaceInitialControllerSegue.h"

@implementation LITReplaceInitialControllerSegue

- (void)perform
{
    UINavigationController *navController = [self.sourceViewController navigationController];
    //NSAssert(navController, @"Navigation controller can't be nil");
    NSArray *controller = @[self.destinationViewController];
    [navController setViewControllers:controller animated:YES];
}

@end
