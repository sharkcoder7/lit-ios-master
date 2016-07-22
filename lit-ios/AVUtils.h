//
//  AudioUtils.h
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define kSoundbiteMaxLengthInSeconds  6

typedef void(^LITAudioVideoCompletionBlock)(NSURL *assetURL, NSError *error);

static inline CMTimeValue ConvertTimeValueFromScaleToScale(CMTimeValue value1, CMTimeScale scale1, CMTimeScale scale2)
{
    return value1 * scale2 / scale1;
}

static NSTimeInterval const kSoundbiteMaxLength     = 6.0;
static NSTimeInterval const kSoundbiteTriggerLength = 2.0;

@class EZAudioFile, MPMediaItem, PFFile, SCVideoConfiguration;
@interface AVUtils : NSObject

+ (NSArray *)applicationDocuments;
+ (NSString *)applicationDocumentsDirectory;
+ (NSURL *)soundbiteRecordingTempFilePathURL;
+ (NSURL *)dubRecordingTempFilePathURL;
+ (NSURL *)cacheSoundbiteTempFilePathURL;
+ (NSURL *)PFFileCacheURLForContentName:(NSString *)name;

#ifndef LIT_EXTENSION
+ (NSString *)getTmpDirPath:(NSString*)filename;
+ (void)createVideoFromImage:(UIImage *)image andAudioFileURL:(NSURL *)audioFileURL withCompletionBlock:(LITAudioVideoCompletionBlock)block;

+ (void)cropAudioAsset:(AVAsset*)asset
    audioStartTime:(NSTimeInterval)audioStartTime
           duration:(NSTimeInterval)duration
          outputURL:(NSURL*)outputURL
         completion:(LITAudioVideoCompletionBlock)block;

+ (void)openMediaItem:(MPMediaItem *)item
           completion:(void(^)(EZAudioFile *audioFile, NSError *error))completion;
+ (void)generateThumbnailForVideoAtURL:(NSURL *)videoURL withCompletionBlock:(void(^)(PFFile *image, NSError *error))block;
+ (void)fillSCVideoConfigurationWithPresets:(SCVideoConfiguration **)videoConfiguration;
#endif

@end
