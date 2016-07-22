//
//  LITLyric.h
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITTaggableContent.h"
#import "LITSong.h"
#import "LITLyricsTableViewCell.h"
#import <Parse/PFSubclassing.h>
#import <Parse/PFObject.h>

extern NSString *const kFirebaseLyricDataKey;
extern NSString *const kFirebaseLyricArtistKey;
extern NSString *const kFirebaseLyricAlbumKey;
extern NSString *const kFirebaseLyricTitleKey;

@class LITKBLyricCollectionViewCell, LITSimpleLyricsTableViewCell;
@interface LITLyric : PFObject <LITTaggableContent, PFSubclassing>

@property (strong, nonatomic) LITSong *song;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) PFUser *user;

+ (void)updateCell:(LITLyricsTableViewCell *)tableCell withObject:(LITLyric *)lyric;
+ (void)updateSimpleCell:(LITSimpleLyricsTableViewCell *)tableCell withObject:(LITLyric *)lyric;
+ (void)updateCollectionCell:(LITKBLyricCollectionViewCell *)collectionCell
                  withObject:(LITLyric *)lyric;
+ (void)updateCollectionCell:(LITKBLyricCollectionViewCell *)collectionCell
                  withObject:(LITLyric *)lyric tryLocalCache:(BOOL)tryLocalCache;

@end
