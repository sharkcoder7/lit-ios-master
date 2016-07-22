//
//  LITKeyboard.h
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITFavoritesKeyboard.h"

#define kLITKeyboardMaxItemCount   6

@interface LITKeyboard : PFObject <PFSubclassing, LITKeyboard>

@property (strong, nonatomic) PFUser *user;
@property (assign, nonatomic, getter=isFeatured) BOOL featured;


@end
