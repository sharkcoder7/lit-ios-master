//
//  LITKBEmojiCollectionViewCell.h
//  lit-ios
//
//  Created by Admin on 3/20/16.
//  Copyright © 2016 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LITKBBaseCollectionViewCell.h"

extern NSString *const kLITKBEmojiCollectionViewCellIdentifier;

@interface LITKBEmojiCollectionViewCell : LITKBBaseCollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *emojiImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
