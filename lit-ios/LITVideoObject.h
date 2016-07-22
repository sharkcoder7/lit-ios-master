//
//  LITVideoObject.h
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/PFFile.h>

@protocol LITVideoObject <NSObject>

@property (strong, nonatomic) PFFile *video;

@end
