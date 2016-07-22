//
//  LITEmojiSearchCollectionViewController.h
//  lit-ios
//
//  Created by Antonio Losada on 22/9/15.
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LITEmojiSearchDelegate;

@interface LITEmojiSearchCollectionViewController : UICollectionViewController

@property (strong, nonatomic) NSString *emojiString;
@property (weak, nonatomic) id<LITEmojiSearchDelegate> delegate;

@end

@protocol LITEmojiSearchDelegate <NSObject>

- (void) didTapCloseButton:(LITEmojiSearchCollectionViewController *) emojiCV;

@end
