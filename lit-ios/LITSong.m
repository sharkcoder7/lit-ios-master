//
//  LITSong.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITSong.h"
#import "LITSongTableViewCell.h"
#import <Parse/PFObject+Subclass.h>

NSString *const kSongArtistKey      = @"artist";
NSString *const kSongAlbumKey       = @"albumName";
NSString *const kSongTitleKey       = @"title";
NSString *const kSongTimesUsedKey   = @"timesUsed";

@implementation LITSong

@synthesize songMetadata=_songMetadata;

@dynamic    albumName,
            artist,
            title,
            timesUsed;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"song";
}

- (void)setSongMetadata:(NSDictionary *)songMetadata
{
    NSParameterAssert(songMetadata);
    NSAssert([songMetadata count] > 0, @"Metadata dictionary cannot be empty!");
    self.artist = songMetadata[kSongArtistKey];
    self.albumName = songMetadata[kSongAlbumKey];
    self.title = songMetadata[kSongTitleKey];
    self.timesUsed = [NSNumber numberWithInt:1];
}

+ (void)updateCell:(LITSongTableViewCell *)tableCell withSoundbite:(LITSong *)song
{
    NSAssert([song isKindOfClass:[LITSong class]], @"Retrieved object must be of class LITSong");
    NSAssert([NSThread isMainThread], @"This block should only be called on the main thread!");
    [tableCell.songTitleLabel setText:song.title];
    [tableCell.artistLabel setText:song.artist];
}

@end
