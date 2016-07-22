//
//  LITFavoritesKeyboard.h
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <Parse/PFObject.h>
#import <Parse/PFSubclassing.h>
#import <Parse/PFObject+Subclass.h>

@protocol LITKeyboard <NSObject>

@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSArray *contents;

@end


@interface LITFavoritesKeyboard : PFObject <PFSubclassing, LITKeyboard>

@end
