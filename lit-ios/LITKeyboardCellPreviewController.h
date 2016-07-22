//
//  LITKeyboardCellPreviewController.h
//  lit-ios
//
//  Created by Antonio Losada on 7/9/15.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

@import Foundation;
#import "AVUtils.h"

typedef void(^LITKeyboardCellDataCompletionBlock)(NSError *error);

@class AVPlayer, LITSoundbite, LITDub;
@protocol LITKeyboardCellPreviewController<NSObject>

- (void)playSoundbite:(LITSoundbite *)soundbite
          atIndexPath:(NSIndexPath *)indexPath
   withCollectionView:(UICollectionView *)collectionView;
- (void)getDataForSoundbite:(LITSoundbite *)soundbite
                atIndexPath:(NSIndexPath *)indexPath
        withCompletionBlock:(LITKeyboardCellDataCompletionBlock)completionBlock;

- (void)getDataForSoundbite:(LITSoundbite *)soundbite
                atIndexPath:(NSIndexPath *)indexPath
        withCompletionBlock:(LITKeyboardCellDataCompletionBlock)completionBlock
             trySharedCache:(BOOL)trySharedCache;

- (void)getDataForDub:(LITDub *)dub
                atIndexPath:(NSIndexPath *)indexPath
                withCompletionBlock:(LITKeyboardCellDataCompletionBlock)completionBlock;

@end