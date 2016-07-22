//
//  LITTaggableContent.h
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <Parse/PFRelation.h>
#import <Foundation/Foundation.h>


static NSString *const kParseTagsKey = @"tags";

@protocol LITTaggableContent

@property (strong, nonatomic) NSString *tags;

@end
