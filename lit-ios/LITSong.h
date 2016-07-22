//
//  LITSong.h
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <Parse/PFObject.h>
#import <Parse/PFSubclassing.h>

#define kLyricsMaxLenght 140

extern NSString *const kSongArtistKey;
extern NSString *const kSongAlbumKey;
extern NSString *const kSongTitleKey;
extern NSString *const kSongTimesUsedKey;

@class LITSongTableViewCell;

@interface LITSong : PFObject <PFSubclassing>

@property (strong, nonatomic) NSString *albumName;
@property (strong, nonatomic) NSString *artist;
@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) NSNumber *timesUsed;

@property (strong, nonatomic) NSDictionary *songMetadata;

+ (void)updateCell:(LITSongTableViewCell *)tableCell withSoundbite:(LITSong *)song;

@end
