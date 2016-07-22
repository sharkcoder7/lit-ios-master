//
//  APIGlobals.h
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifndef lit_ios_ParseGlobals_h
#define lit_ios_ParseGlobals_h


static NSString *const kParseKeyboardsPath                  = @"keyboards";
static NSString *const kParseLyricsPath                     = @"lyrics";
static NSString *const kParseSoundbitesPath                 = @"soundbites";
static NSString *const kParseDubsPath                       = @"dubs";
static NSString *const kParseTagsPath                       = @"tags";
static NSString *const kParseSongPath                       = @"song";
static NSString *const kParseUsersPath                      = @"_User";

static NSString *const kLyricClassName                      = @"lyric";
//static NSString *const kLyricSearchDataKey                  = @"searchData";
//static NSString *const kLyricSearchTextKey                  = @"text";
//static NSString *const kLyricUserKey                        = @"user";
//static NSString *const kLyricLikeCountKey                   = @"likeCount";
//static NSString *const kLyricLikesKey                       = @"likes";
//static NSString *const kLyricPriorityKey                    = @"priority";
//static NSString *const kLyricSongKey                        = @"song";
//static NSString *const kLyricTagsKey                        = @"tags";
//static NSString *const kLyricUsesKey                        = @"uses";

static NSString *const kSoundBiteClassName                  = @"soundbite";
//static NSString *const kSoundBiteAudioKey                   = @"audio";
//static NSString *const kSoundBiteImageKey                   = @"image";
//static NSString *const kSoundBiteLikeCountKey               = @"likeCount";
//static NSString *const kSoundBiteLikesKey                   = @"likes";
//static NSString *const kSoundBitePriorityKey                = @"priority";
//static NSString *const kSoundBiteSearchDataKey              = @"searchData";
//static NSString *const kSoundBiteSongKey                    = @"song";
//static NSString *const kSoundBiteTagsKey                    = @"tags";
//static NSString *const kSoundBiteVideoKey                   = @"video";
//static NSString *const kSoundBiteUsesKey                    = @"uses";
//static NSString *const kSoundBiteUserKey                    = @"user";

static NSString *const kDubClassName                        = @"dub";
//static NSString *const kDubCaptionKey                       = @"caption";
//static NSString *const kDubLikeCountKey                     = @"likeCount";
//static NSString *const kDubLikesKey                         = @"likes";
//static NSString *const kDubPriorityKey                      = @"priority";
//static NSString *const kDubSearchDataKey                    = @"searchData";
//static NSString *const kDubSnapShotKey                      = @"snapshot";
//static NSString *const kDubSoundBiteKey                     = @"soundbite";
//static NSString *const kDubTagsKey                          = @"tags";
//static NSString *const kDubVideoKey                         = @"video";
//static NSString *const kDubUsesKey                          = @"uses";
//static NSString *const kDubUserKey                          = @"user";

static NSString *const kKeyboardInstallationsClassName      = @"keyboardInstallations";
static NSString *const kKeyboardInstallationsUserKey        = @"user";
static NSString *const kKeyboardInstallationsKeyboardsKey   = @"keyboards";

static NSString *const kKeyboardDownloadsClassName          = @"keyboardDownload";
static NSString *const kKeyboardDownloadsUserKey            = @"user";
static NSString *const kKeyboardDownloadsKeyboardKey        = @"keyboard";

static NSString *const kKeyboardLikesClassName              = @"keyboardLikes";
static NSString *const kKeyboardLikesUserKey                = @"user";
static NSString *const kKeyboardLikesKeyboardKey            = @"keyboard";

static NSString *const kSoundbiteDownloadClassName          = @"soundbiteDownload";
static NSString *const kSoundbiteDownloadSoundbiteKey       = @"soundbite";
static NSString *const kSoundbiteDownloadUserKey            = @"user";

static NSString *const kSoundbiteLikeClassName              = @"soundbiteLike";
static NSString *const kSoundbiteLikeSoundbiteKey           = @"soundbite";
static NSString *const kSoundbiteLikeUserKey                = @"user";

static NSString *const kDubDownloadClassName                = @"dubDownload";
static NSString *const kDubDownloadDubKey                   = @"dub";
static NSString *const kDubDownloadUserKey                  = @"user";

static NSString *const kDubLikeClassName                    = @"dubLike";
static NSString *const kDubLikeDubKey                       = @"dub";
static NSString *const kDubLikeUserKey                      = @"user";

static NSString *const kLyricDownloadClassName              = @"lyricDownload";
static NSString *const kLyricDownloadLyricKey               = @"lyric";
static NSString *const kLyricDownloadUserKey                = @"user";

static NSString *const kLyricLikeClassName                  = @"lyricLike";
static NSString *const kLyricLikeLyricKey                   = @"lyric";
static NSString *const kLyricLikeUserKey                    = @"user";

static NSString *const kSoundbiteUseClassName               = @"soundbiteUse";
static NSString *const kSoundbiteUseSoundbiteKey            = @"soundbite";
static NSString *const kSoundbiteUseUserKey                 = @"user";

static NSString *const kDubUseClassName                     = @"dubUse";
static NSString *const kDubUseDubKey                        = @"dub";
static NSString *const kDubUseUserKey                       = @"user";

static NSString *const kLyricUseClassName                   = @"lyricUse";
static NSString *const kLyricUseLyricKey                    = @"lyric";
static NSString *const kLyricUseUserKey                     = @"user";

static NSString *const kEmojiClassName                      = @"emoji";
static NSString *const kEmojiEmojiKey                       = @"emoji";
static NSString *const kEmojiCaptionKey                     = @"caption";
static NSString *const kEmojiEmojiPreviewKey                = @"emojiPreview";

static NSString *const kKeyboardUseClassName                = @"keyboardUse";
static NSString *const kKeyboardUseKeyboardKey              = @"keyboard";
static NSString *const kKeyboardUseUserKey                  = @"user";

static NSString *const kLITKeyboardUserKey                  = @"user";
static NSString *const kLITKeyboardDisplayNameKey           = @"displayName";
static NSString *const kLITKeyboardContentsKey              = @"contents";

static NSString *const kMainFeedClassName                   = @"mainFeed";
static NSString *const kMainFeedReferenceKey                = @"referenceId";
static NSString *const kMainFeedSearchDataKey               = @"searchData";
static NSString *const kMainFeedClassKey                    = @"class";

static NSString *const kSoundbiteCaptionKey                 = @"caption";
static NSString *const kDubCaptionKey                       = @"caption";
static NSString *const kLyricTextKey                        = @"text";

static NSString *const kFavKeyboardClassName                = @"favKeyboard";
static NSString *const kFavKeyboardContentsKey              = @"contents";
static NSString *const kUserPictureKey                      = @"picture";
static NSString *const kUserFavKeyboardKey                  = @"favKeyboard";

static NSString *const kUserCreatedContentClassName         = @"userCreatedContent";
static NSString *const kUserCreatedContentUserKey           = @"user";
static NSString *const kUserCreatedContentClassKey          = @"class";
static NSString *const kUserCreatedContentReferenceKey      = @"referenceId";

static NSString *const kTagClassName                        = @"tag";
static NSString *const kTagTextKey                          = @"text";

static NSString *const kLITKeyboardLikesKey                 = @"likeCount";
static NSString *const kLITKeyboardSearchDataKey            = @"searchData";
static NSString *const kLITKeyboardPriorityKey              = @"priority";
static NSString *const kLITKeyboardFeaturedKey              = @"featured";
static NSString *const kLITKeyboardCreatedAtKey             = @"createdAt";
static NSString *const kLITObjectLikesKey                   = @"likeCount";
static NSString *const kLITObjectHiddenKey                  = @"hidden";
static NSString *const kLITObjectPriorityKey                = @"priority";
static NSString *const kLITObjectCreatedAtKey               = @"createdAt";
static NSString *const kLITObjectUsesKey                    = @"uses";

static NSString *const kLITSongArtist                       = @"artist";
static NSString *const kLITSongTitle                        = @"title";
static NSString *const kLITSongTimesUsed                    = @"timesUsed";

static NSString *const kLITUserId                           = @"G1CJRmGnIH";
static NSString *const kLITKeyboardObjectId                 = @"eeB7ogUU5q";
static NSString *const kLITFavKeyboardObjectId              = @"U4rnVRdGg0";
static NSUInteger const kLITMaxKeyboardsNumber              = 10;

static NSUInteger const kLITObjectsPerPage                  = 12;

static NSUInteger const kLITNumShareApps                    = 8;

static NSInteger const kLITIndexShareMessages               = 0;
static NSInteger const kLITIndexShareFacebook               = 1;
static NSInteger const kLITIndexShareFacebookMessenger      = 2;
static NSInteger const kLITIndexShareTwitter                = 3;
static NSInteger const kLITIndexShareWhatsapp               = 4;
static NSInteger const kLITIndexShareSlack                  = 5;
static NSInteger const kLITIndexShareInstagram              = 6;
static NSInteger const kLITIndexShareTumblr                 = 7;

static NSString *const kParseTwitterConsumerKey             = @"ACuh1wCpQDkcBqBPXWWOI1ICn";
static NSString *const kParseTwitterConsumerSecret          = @"L1YbmXL80ZtYqSfaoP3Wuku85O3oaYP6Wkf5CZqkerzCaLOU9P";

static NSString *const kLITAppGroupSharingIdentifier        = @"group.it.itsl.lit-ios";

static NSString *const kLITApplicationIdentifier            = @"qglI1zVSI90yMtTg4qZjJgOkjsoyw2aY0VKPbrQv";
static NSString *const kLITApplicationClientKey             = @"jEaL89gpWKnJd9KFLEvMAS5WEumn6Op5yO7EiHU0";

#endif