//
//  UIViewController+LITKeyboardCellConfigurator.m
//  lit-ios
//
//  Created by ioshero on 17/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "UIViewController+LITKeyboardCellConfigurator.h"
#import "LITKBDubCollectionViewCell.h"
#import "LITKBLyricCollectionViewCell.h"
#import "LITKBSoundbiteCollectionViewCell.h"
#import "LITDub.h"
#import "LITLyric.h"
#import "LITSoundbite.h"
#import "LITKeyboard.h"
#import "LITSharedFileCache.h"
#import "LITCollectionViewDecorationLayout.h"
#import "DataKeeper.h"
#import "LITGlobals.h"
#import "LITKeyboardViewController.h"
#import "LITEmoji.h"
#import <objc/runtime.h>
#import <Reachability/Reachability.h>

CGFloat kLITKeyboardCellHeight;
CGFloat kLITKeyboardCellWidth;
CGFloat kLITKeyboardCellItemPortraitDimension;
CGFloat kLITKeyboardCellItemLandscapeDimension;
CGFloat kLITKeyboardCellItemSpacing = 1.5;

CGSize  kLITKeyboardHeaderReferenceSize;
CGSize  kLITKeyboardFooterReferenceSize;

NSString *const kTouchDetectorIndexPathKey          = @"TouchDetectorIndexPathKey";
NSString *const kTouchDetectorCollectionViewKey     = @"TouchDetectorCollectionViewKey";
NSString *const kTouchDetectorGesturecognizerKey    = @"TouchDetectorGestureRecognizerKey";

NSString *const kLITOptionsTableViewCellIdentifier  = @"LITOptionsTableViewCellIdentifier";

static void* kCellConfiguratorRecognizerCollectionViewPropertyKey;


@implementation UIViewController (LITKeyboardCellConfigurator)

+ (void)load
{
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    kLITKeyboardCellItemPortraitDimension = (screenWidth - kLITKeyboardCellItemSpacing * 2) / 3;
    
    kLITKeyboardCellHeight = 54.0f + kLITKeyboardCellItemPortraitDimension * 2 + 38.0f + kLITKeyboardCellItemSpacing * 2 + 15.0f;
    kLITKeyboardCellWidth = screenWidth;
    
    kLITKeyboardCellItemLandscapeDimension = (CGRectGetHeight([UIScreen mainScreen].bounds) - kLITKeyboardCellItemSpacing * 5) / 6;
    
    kLITKeyboardHeaderReferenceSize = CGSizeMake(screenWidth, 54.0);
    kLITKeyboardFooterReferenceSize = CGSizeMake(screenWidth, 53.0);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath usingKeyboard:(LITKeyboard *)keyboard
{
    UICollectionViewCell *cell;

    Reachability *reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    reachability.reachableOnWWAN = YES;
    if (![reachability isReachable]) {
        LITKBEmptyCollectionViewCell *emptyCell = [collectionView dequeueReusableCellWithReuseIdentifier:kLITKBEmptyCollectionViewCellIdentifier forIndexPath:indexPath];
        [emptyCell.plusImageView setHidden:YES];
        [emptyCell.noInternetConnection setHidden:NO];
        return emptyCell;
    }
    
    if (indexPath.row >= [keyboard.contents count]) {
        LITKBEmptyCollectionViewCell *emptyCell = [collectionView dequeueReusableCellWithReuseIdentifier:kLITKBEmptyCollectionViewCellIdentifier forIndexPath:indexPath];
        if (indexPath.row == [keyboard.contents count] &&
            [keyboard class] != [LITFavoritesKeyboard class]){
            if(keyboard.user == [PFUser currentUser]){
                [emptyCell.plusImageView setHidden:NO];
                cell = emptyCell;
            }
            else {
                [emptyCell.plusImageView setHidden:YES];
                return emptyCell;
            }
        } else {
            [emptyCell.plusImageView setHidden:YES];
            return emptyCell;
        }
    } else if ([keyboard.contents[indexPath.row] isKindOfClass:[LITSoundbite class]]) {
        LITSoundbite *soundbite = keyboard.contents[indexPath.row];
        LITKBSoundbiteCollectionViewCell *soundCell = [collectionView dequeueReusableCellWithReuseIdentifier:kLITKBSoundbiteCollectionViewCellIdentifier forIndexPath:indexPath];
        [soundCell.cellIcon setHidden:YES];
        
#ifdef LIT_EXTENSION
        [LITSoundbite updateCollectionCell:soundCell withObject:soundbite tryLocalCache:NO];
#else
        [LITSoundbite updateCollectionCell:soundCell withObject:soundbite];
#endif
        
        cell = soundCell;
    } else if ([keyboard.contents[indexPath.row] isKindOfClass:[LITDub class]]) {
        LITDub *dub = keyboard.contents[indexPath.row];
        LITKBDubCollectionViewCell *dubCell = [collectionView dequeueReusableCellWithReuseIdentifier:kLITKBDubCollectionViewCellIdentifier forIndexPath:indexPath];
        [dubCell.cellIcon setHidden:YES];
#ifdef LIT_EXTENSION
        [LITDub updateCollectionCell:dubCell withObject:dub tryLocalCache:NO];
#else
        [LITDub updateCollectionCell:dubCell withObject:dub];
#endif
        cell = dubCell;
    } else if ([keyboard.contents[indexPath.row] isKindOfClass:[LITLyric class]]) {
        LITLyric *lyric = keyboard.contents[indexPath.row];
        LITKBLyricCollectionViewCell *lyricCell = [collectionView dequeueReusableCellWithReuseIdentifier:kLITKBLyricCollectionViewCellIdentifier forIndexPath:indexPath];
        cell = lyricCell;
#ifdef LIT_EXTENSION
        [LITLyric updateCollectionCell:lyricCell withObject:lyric tryLocalCache:NO];
#else
        [LITLyric updateCollectionCell:lyricCell withObject:lyric];
#endif
    }
    else if ([keyboard.contents[indexPath.row] isKindOfClass:[LITEmoji class]]) {
        LITEmoji *emoji = keyboard.contents[indexPath.row];
        LITKBEmojiCollectionViewCell *emojiCell = [collectionView dequeueReusableCellWithReuseIdentifier:kLITKBEmojiCollectionViewCellIdentifier forIndexPath:indexPath];
#ifdef LIT_EXTENSION
        [LITEmoji updateCollectionCell:emojiCell withObject:emoji tryLocalCache:NO];
#else
        [LITEmoji updateCollectionCell:emojiCell withObject:emoji];
#endif
        cell = emojiCell;
    } else if ([keyboard.contents[indexPath.row] isKindOfClass:[LITFavoritesKeyboard class]]) {
        LITKBEmptyCollectionViewCell *emptyCell = [collectionView dequeueReusableCellWithReuseIdentifier:kLITKBEmptyCollectionViewCellIdentifier forIndexPath:indexPath];
        [emptyCell.plusImageView setHidden:YES];
        return emptyCell;
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"Unrecognized class in keyboard contents"];
    }
    
    // Configure the cell
    
#ifdef LIT_EXTENSION
    // Animation Long press over the cell
    UILongPressGestureRecognizer *animationLongPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleAnimationLongPress:)];
    animationLongPressRecognizer.minimumPressDuration = .001;
    animationLongPressRecognizer.cancelsTouchesInView = NO;
    animationLongPressRecognizer.delegate = self;
    [cell addGestureRecognizer:animationLongPressRecognizer];
#endif
    
    // Single tap over the cell
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
#ifdef LIT_EXTENSION
    tapRecognizer.delegate = self;
#endif
    
    __weak UICollectionView *weakCollectionView = collectionView;
    
    if (![cell isKindOfClass:[LITKBEmptyCollectionViewCell class]]) {
        // Long press over the cell
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        longPressRecognizer.minimumPressDuration = .6;
#ifdef LIT_EXTENSION
        longPressRecognizer.delegate = self;
#endif
        [cell addGestureRecognizer:longPressRecognizer];
        [tapRecognizer requireGestureRecognizerToFail:longPressRecognizer];
        objc_setAssociatedObject(longPressRecognizer,
                                 kCellConfiguratorRecognizerCollectionViewPropertyKey,
                                 weakCollectionView,
                                 OBJC_ASSOCIATION_ASSIGN);
    }

//    // Double tap over the cell
//    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
//    doubleTapRecognizer.numberOfTapsRequired = 2;
//    doubleTapRecognizer.numberOfTouchesRequired = 1;
//#ifdef LIT_EXTENSION
//    doubleTapRecognizer.delegate = self;
//#endif    
//    [cell addGestureRecognizer:doubleTapRecognizer];
    

//    [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];

    [cell addGestureRecognizer:tapRecognizer];

//    objc_setAssociatedObject(doubleTapRecognizer,
//                             kCellConfiguratorRecognizerCollectionViewPropertyKey,
//                             weakCollectionView,
//                             OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(tapRecognizer,
                             kCellConfiguratorRecognizerCollectionViewPropertyKey,
                             weakCollectionView,
                             OBJC_ASSOCIATION_ASSIGN);
#ifdef LIT_EXTENSION
    objc_setAssociatedObject(animationLongPressRecognizer,
                             kCellConfiguratorRecognizerCollectionViewPropertyKey,
                             weakCollectionView,
                             OBJC_ASSOCIATION_ASSIGN);
#endif

    [[cell valueForKey:@"removeButton"] setHidden:YES];
    
    return cell;
}

- (void)configureCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([LITKBSoundbiteCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:kLITKBSoundbiteCollectionViewCellIdentifier];
    
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([LITKBDubCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:kLITKBDubCollectionViewCellIdentifier];
    
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([LITKBLyricCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:kLITKBLyricCollectionViewCellIdentifier];
    
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([LITKBEmojiCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:kLITKBEmojiCollectionViewCellIdentifier];
    
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([LITKBEmptyCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:kLITKBEmptyCollectionViewCellIdentifier];
    
#ifndef LIT_EXTENSION
    [collectionView registerNib:[UINib nibWithNibName:@"LITKeyboardHeaderView"
                                               bundle:nil]
     forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
            withReuseIdentifier:@"LITKeyboardHeaderView"];
    
    [collectionView registerNib:[UINib nibWithNibName:@"LITKeyboardFooterView"
                                               bundle:nil]
     forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
            withReuseIdentifier:@"LITKeyboardFooterView"];
    LITCollectionViewDecorationLayout *layout = [[LITCollectionViewDecorationLayout alloc] init];
    layout.minimumInteritemSpacing = kLITKeyboardCellItemSpacing;
    layout.minimumLineSpacing = kLITKeyboardCellItemSpacing;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [layout setItemSize:CGSizeMake(kLITKeyboardCellItemPortraitDimension, kLITKeyboardCellItemPortraitDimension)];
    [collectionView setCollectionViewLayout:layout];
    
#else
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = kLITKeyboardCellItemSpacing;
    layout.minimumLineSpacing = kLITKeyboardCellItemSpacing;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [layout setItemSize:CGSizeMake(kLITKeyboardCellItemPortraitDimension, kLITKeyboardCellItemPortraitDimension)];
    [collectionView setCollectionViewLayout:layout];
    
#endif
    
    [collectionView setAllowsSelection:NO];
}


#pragma mark - Recognizer Actions

-(void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    NSDictionary *params = [self getParamsFromGestureRecognizer:gestureRecognizer];
    
    NSIndexPath *indexPath = [params objectForKey:kTouchDetectorIndexPathKey];
    UICollectionView *collectionView = [params objectForKey:kTouchDetectorCollectionViewKey];
    
    LITKBBaseCollectionViewCell *contentCell = (LITKBBaseCollectionViewCell *)[collectionView
                                                                               cellForItemAtIndexPath:indexPath];
    if (![contentCell.removeButton isHidden]) {
        CGPoint location = [gestureRecognizer locationInView:contentCell];
        if (CGRectContainsPoint(contentCell.removeButton.frame, location)) {
            [self performSelector:@selector(deleteActionDetectedOnCellAtIndexPathForCollectionView:) withObject:params];
            return;
        }
    }
    [self performSelector:@selector(singleTapDetectedOnCellAtIndexPathForCollectionView:) withObject:params];
}

-(void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    NSDictionary *params = [self getParamsFromGestureRecognizer:gestureRecognizer];
    [self performSelector:@selector(doubleTapDetectedOnCellAtIndexPathForCollectionView:) withObject:params];
}

-(void)handleAnimationLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        NSDictionary *params = [self getParamsFromGestureRecognizer:gestureRecognizer];
        [self performSelector:@selector(animationLongPressDetectedOnCellAtIndexPathForCollectionView:) withObject:params];
    }
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    NSDictionary *params = [self getParamsFromGestureRecognizer:gestureRecognizer];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self performSelector:@selector(longPressDetectedOnCellAtIndexPathForCollectionView:) withObject:params];
    }
    else{
        return;
    }
}

- (NSDictionary *)getParamsFromGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    __weak UICollectionView *collectionView = objc_getAssociatedObject(gestureRecognizer, kCellConfiguratorRecognizerCollectionViewPropertyKey);
    NSAssert([gestureRecognizer.view
              isKindOfClass:[UICollectionViewCell class]],
             @"Recognizer view must be of class UICollectionViewCell");
    NSParameterAssert(collectionView);
    NSIndexPath *indexPath = [collectionView
                              indexPathForCell:(UICollectionViewCell *)gestureRecognizer.view];
    
    NSDictionary *params = @{kTouchDetectorIndexPathKey : indexPath,
                             kTouchDetectorCollectionViewKey: collectionView,
                             kTouchDetectorGesturecognizerKey: gestureRecognizer};
    return params;
}


@end
