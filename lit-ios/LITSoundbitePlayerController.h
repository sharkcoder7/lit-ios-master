//
//  LITSoundbitePlayerController.h
//  lit-ios
//
//  Created by ioshero on 25/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVUtils.h"

typedef void(^LITSoundbiteDataCompletionBlock)(NSURL *fileURL, NSError *error);

@class AVPlayer, LITSoundbite;
@protocol LITSoundbitePlayerController <NSObject>

- (void)playButtonPressed:(UIButton *)sender;
- (void)getDataForSoundbite:(LITSoundbite *)soundbite
                atIndexPath:(NSIndexPath *)indexPath
        withCompletionBlock:(LITSoundbiteDataCompletionBlock)completionBlock;

@end


