//
//  AudioUtils.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "AVUtils.h"

#ifndef LIT_EXTENSION
#import <MediaPlayer/MPMediaItem.h>
#import <Parse/PFFile.h>
#import <SCRecorder/SCVideoConfiguration.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <EZAudio/EZAudioFile.h>
#endif

@implementation AVUtils

//------------------------------------------------------------------------------
#pragma mark - Utility
//------------------------------------------------------------------------------

+ (NSArray *)applicationDocuments
{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
}

//------------------------------------------------------------------------------

+ (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

//------------------------------------------------------------------------------

+ (NSURL *)soundbiteRecordingTempFilePathURL
{

//    return [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:
//                                   [AudioUtils generatedFileNameFromCurrentDateUsingPrefix:@"soundbite"] stringByAppendingPathExtension:@"m4a"];
    
    return [NSURL fileURLWithPath:[[NSTemporaryDirectory()
                                    stringByAppendingPathComponent:[AVUtils generatedFileNameFromCurrentDateUsingPrefix:@"soundbite"]] stringByAppendingPathExtension:@"m4a"]];
}

+ (NSURL *)dubRecordingTempFilePathURL
{
    
    //    return [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:
    //                                   [AudioUtils generatedFileNameFromCurrentDateUsingPrefix:@"soundbite"] stringByAppendingPathExtension:@"m4a"];
    
    return [NSURL fileURLWithPath:[[NSTemporaryDirectory()
                                    stringByAppendingPathComponent:[AVUtils generatedFileNameFromCurrentDateUsingPrefix:@"dub"]] stringByAppendingPathExtension:@"mov"]];
}
// TODO: Implement real cache
+ (NSURL *)cacheSoundbiteTempFilePathURL
{
    
    //    return [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:
    //                                   [AudioUtils generatedFileNameFromCurrentDateUsingPrefix:@"soundbite"] stringByAppendingPathExtension:@"m4a"];
    
    return [NSURL fileURLWithPath:[[NSTemporaryDirectory()
                                    stringByAppendingPathComponent:[AVUtils generatedFileNameFromCurrentDateUsingPrefix:@"soundbite"]] stringByAppendingPathExtension:@"mp4"]];
}

+ (NSString *)generatedFileNameFromCurrentDateUsingPrefix:(NSString *)prefix
{
    static NSDateFormatter *formatter;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
    }
    
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    return [NSString stringWithFormat:@"%@-%@", prefix, [formatter stringFromDate:[NSDate date]]];
}

+ (NSURL *)PFFileCacheURLForContentName:(NSString *)name {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0] stringByAppendingFormat:@"/Caches/Parse/PFFileCache/%@", name];
    NSURL *url;
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        url = [NSURL fileURLWithPath:path];
    }
    return url;
}

#ifndef LIT_EXTENSION

+ (NSString *)getTmpDirPath:(NSString*)filename
{
    NSString *tmpDir = NSTemporaryDirectory();
    NSAssert(tmpDir, @"tmpDir");
    NSString *outPath = [tmpDir stringByAppendingPathComponent:filename];
    NSAssert(outPath, @"outPath");
    return outPath;
}

+ (void)createVideoFromImage:(UIImage *)image andAudioFileURL:(NSURL *)audioFileURL withCompletionBlock:(LITAudioVideoCompletionBlock)block;
{
    NSParameterAssert(image);
    NSParameterAssert(audioFileURL);
             
    AVAsset *audioAsset = [AVURLAsset assetWithURL:audioFileURL];
    if (!audioAsset) {
        NSLog(@"Couldn't create audio asset");
        return;
    }
    
    [audioAsset loadValuesAsynchronouslyForKeys:@[@"duration"] completionHandler:^{
        AVAssetTrack *audioTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        NSError *error;
        AVKeyValueStatus durationStatus = [audioAsset statusOfValueForKey:@"duration" error:&error];
        if (durationStatus != AVKeyValueStatusLoaded) {
            block(nil, error);
        }
        NSString *tmpVideoURLString = [[NSTemporaryDirectory()
                                        stringByAppendingPathComponent:@"soundbite-tmpVideo"]
                                       stringByAppendingPathExtension:@"mp4"];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:tmpVideoURLString]) {
            [[NSFileManager defaultManager] removeItemAtPath:tmpVideoURLString error:&error];
            if (error) {
                [NSException raise:NSGenericException format:@"Fatal: Couldn't remove existing video file"];
            }
        }

        
        NSURL *tmpVideoURL = [NSURL fileURLWithPath:tmpVideoURLString];
        
        AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:tmpVideoURL fileType:AVFileTypeMPEG4 error:&error];
        NSAssert(videoWriter, @"Couldn't create video writer");
        
        NSDictionary *videoSettings = @{AVVideoCodecKey : AVVideoCodecH264 ,
                                        AVVideoWidthKey : @(image.size.width),
                                        AVVideoHeightKey: @(image.size.height)};
        AVAssetWriterInput *videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
        AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                         assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
                                                         sourcePixelBufferAttributes:nil];
        
        NSAssert(videoWriterInput, @"Couldn't create video writer input");
        NSAssert([videoWriter canAddInput:videoWriterInput], @"Video writer can't be attached to this input");
        
        [videoWriter addInput:videoWriterInput];
        
        [videoWriter startWriting];
        [videoWriter startSessionAtSourceTime:kCMTimeZero];
        
        CVPixelBufferRef buffer = [AVUtils pixelBufferFromCGImage:[image CGImage]];
        
        [adaptor appendPixelBuffer:buffer withPresentationTime:kCMTimeZero];
        [adaptor appendPixelBuffer:buffer withPresentationTime:audioAsset.duration];
        
        [videoWriterInput markAsFinished];
        [videoWriter endSessionAtSourceTime:audioAsset.duration];
        
        [videoWriter finishWritingWithCompletionHandler:^{
            if (videoWriter.error) {
                NSLog(@"Failed writing video: %@", videoWriter.error.localizedDescription);
            }
            AVMutableComposition *mixComposition = [AVMutableComposition composition];
            NSString *soundbiteVideoPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:[AVUtils generatedFileNameFromCurrentDateUsingPrefix:@"soundbite-video"]] stringByAppendingPathExtension:@"mp4"];
            NSURL *sounbdbiteVideoURL = [NSURL fileURLWithPath:soundbiteVideoPath];
            
            
            //Generated Video
            AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:tmpVideoURL options:nil];
            
            CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
            AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            NSError *compositionError;
            if(![a_compositionVideoTrack
                 insertTimeRange:video_timeRange
                 ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject] atTime:kCMTimeZero error:&compositionError]) {
                block(nil, error);
            }
            
            //Audio
            CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
            AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            if(![b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:audioTrack atTime:kCMTimeZero error:&compositionError]) {
                block(nil, error);
            }
            
            AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
            assetExport.outputFileType = AVFileTypeMPEG4;
            assetExport.shouldOptimizeForNetworkUse = YES;
            assetExport.outputURL = sounbdbiteVideoURL;
            
            [assetExport exportAsynchronouslyWithCompletionHandler:^{
                if (assetExport.status == AVAssetExportSessionStatusCompleted) {
                    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:sounbdbiteVideoURL]) {
                        [library writeVideoAtPathToSavedPhotosAlbum:sounbdbiteVideoURL completionBlock:^(NSURL *assetURL, NSError *error) {
                            if (!error) {
                                NSLog(@"Successfully saved soundbite to camera roll: %@", assetURL.absoluteString);
                            } else {
                                NSLog(@"Couldn't save soundbite to camera roll: %@", error.localizedDescription);
                            }
                            block(sounbdbiteVideoURL, error);
                        }];
                    }

                }
            }];
        }];
    }];
    
}



+ (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image
{
    CGSize frameSize = CGSizeMake(CGImageGetWidth(image),
                                  CGImageGetHeight(image));
    NSDictionary *options =
    [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithBool:YES],
     kCVPixelBufferCGImageCompatibilityKey,
     [NSNumber numberWithBool:YES],
     kCVPixelBufferCGBitmapContextCompatibilityKey,
     nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(
                                          kCFAllocatorDefault, frameSize.width, frameSize.height,
                                          kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef)options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    if (status != kCVReturnSuccess) {
        NSLog(@"Status differs from kCVReturnSuccess");
    }
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(
                                                 pxdata, frameSize.width, frameSize.height,
                                                 8, CVPixelBufferGetBytesPerRow(pxbuffer),
                                                 rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}


+ (void)cropAudioAsset:(AVAsset*)asset
     audioStartTime:(NSTimeInterval)audioStartTime
           duration:(NSTimeInterval)duration
          outputURL:(NSURL*)outputURL
         completion:(LITAudioVideoCompletionBlock)block {
    
    //NSArray* availablePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
    
    AVAssetExportSession* exporter = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetAppleM4A];
    
    if (exporter == nil) {
        if (block != nil) {
            block(nil, [NSError errorWithDomain:@"it.itsl" code:002 userInfo:@{NSLocalizedDescriptionKey : @"Failed creating exporter"}]);
        }
        return;
    }
    
    // Set output file type
    NSLog(@"Supported file types: %@", exporter.supportedFileTypes);
    for (NSString* filetype in exporter.supportedFileTypes) {
        if ([filetype isEqualToString:AVFileTypeAppleM4A]) {
            exporter.outputFileType = AVFileTypeAppleM4A;
            break;
        }
    }
    if (exporter.outputFileType == nil) {
//        NSLog(@"Needed output file type not found? (%@)", AVFileTypeAppleM4A);
        if (block != nil) {
            block(nil, [NSError errorWithDomain:@"it.itsl" code:002 userInfo:@{NSLocalizedDescriptionKey : @"Needed output file type not found"}]);
        }
        return;
    }
    
    exporter.outputURL = outputURL;
    // Specify a time range in case only part of file should be exported
    
    AVAssetTrack *audioTrack = asset.tracks.firstObject;
    
    if (audioTrack == nil) {
        if (block != nil) {
            block(nil, [NSError errorWithDomain:@"it.itsl" code:002 userInfo:@{NSLocalizedDescriptionKey : @"Unable to create audio track"}]);
        }
        return;
    }
    
    AVAudioMix *mix = [AVAudioMix new];
    
    CMTimeRange audioTrackTimeRange = audioTrack.timeRange;
    CMTime startTime = CMTimeMakeWithSeconds(audioStartTime + CMTimeGetSeconds(audioTrackTimeRange.start), 1000);
    CMTime durationTime = CMTimeMakeWithSeconds(duration, 1000);
    
    exporter.timeRange = CMTimeRangeMake(startTime, durationTime);
    exporter.audioMix = mix;
    
    NSLog(@"Starting export! (%@)", exporter.outputURL);
    [exporter exportAsynchronouslyWithCompletionHandler:^(void) {
        // Export ended for some reason. Check in status
        NSString* message;
        switch (exporter.status) {
            case AVAssetExportSessionStatusFailed:
                
                message = [NSString stringWithFormat:@"Export failed. Error: %@", exporter.error.description];
                NSLog(@"%@", message);
                
                if (block != nil) {
                    block(nil,exporter.error);
                }
                
                break;
                
            case AVAssetExportSessionStatusCompleted: {
                
                message = [NSString stringWithFormat:@"Export completed: %@", outputURL.absoluteString];
                NSLog(@"%@", message);
                
                if (block != nil) {
                    block(outputURL, nil);
                }
                
                break;
            }
                
            case AVAssetExportSessionStatusCancelled:
                
                message = [NSString stringWithFormat:@"Export cancelled!"];
                NSLog(@"%@", message);
                
                if (block != nil) {
                    block(nil,exporter.error);
                }
                
                break;
                
            default:
                NSLog(@"Export unhandled status: %ld", (long)exporter.status);
                
                if (block) {
                    block(nil, exporter.error);
                }
                
                break;
        }       
    }];
}

+ (void)openMediaItem:(MPMediaItem *)item
           completion:(void(^)(EZAudioFile *audioFile, NSError *error))completion
{
    if (!item) {
        completion(nil,nil);
    }
    NSString *title = [item valueForProperty:MPMediaItemPropertyTitle];
//    NSString *exportURLPath = [NSTemporaryDirectory() stringByAppendingFormat:@"/%@.m4a", title];
    NSString *exportURLPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a", title]];
    //Check first if it has already been exported before
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportURLPath]) {
        EZAudioFile *audioFile = [[EZAudioFile alloc] initWithURL:[NSURL fileURLWithPath:exportURLPath]];
        completion(audioFile, nil);
        return;
    }
    
    NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    if (url)
    {
        //
        // Create an AVAudioExportSession to export the MPMediaItem to a non-iPod
        // file path url we can actually use for an EZAudioFile
        //
        AVURLAsset *asset = [AVURLAsset assetWithURL:url];
        AVAssetExportSession *exporter = [AVAssetExportSession exportSessionWithAsset:asset
                                                                           presetName:AVAssetExportPresetAppleM4A];
        exporter.outputFileType = @"com.apple.m4a-audio";

        NSURL *exportURL = [NSURL fileURLWithPath:exportURLPath];
        exporter.outputURL = exportURL;
        
        //
        // Delete any existing path in the bundle if one already exists
        //
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:exportURLPath])
        {
            NSError *error;
            [fileManager removeItemAtPath:exportURLPath error:&error];
            if (error)
            {
                NSLog(@"error deleting file: %@", error.localizedDescription);
            }
        }
        
        //
        // Export the audio data using the AVAudioExportSession to the
        // exportURL in the application bundle
        //
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            AVAssetExportSessionStatus status = [exporter status];
            switch (status)
            {
                case AVAssetExportSessionStatusCompleted:
                {
                    EZAudioFile *file = [EZAudioFile audioFileWithURL:exportURL];
                    completion(file ,nil);
                    break;
                }
                case AVAssetExportSessionStatusFailed:
                {
                    completion(nil, exporter.error);
                    break;
                }
                default:
                {
                    NSLog(@"Exporter status not fialed or complete: %ld", (long)status);
                    break;
                }
            }
        }];
    }
    else
    {
        NSError *error = [NSError errorWithDomain:@"it.itsl"
                                             code:-40
                                         userInfo:@{ NSLocalizedDescriptionKey : @"Media item's URL not found" }];
        completion(nil, error);
    }
}


+ (void)generateThumbnailForVideoAtURL:(NSURL *)videoURL withCompletionBlock:(void(^)(PFFile *image, NSError *error))block
{
    NSParameterAssert(block);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVURLAsset *asset = [AVURLAsset assetWithURL:videoURL];
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        NSError *error;
        generator.appliesPreferredTrackTransform = YES;
        generator.maximumSize = CGSizeMake(560.0, 560.f);
        
        CMTime captureTime = CMTimeMake(0, 1000); //0 seconds
        
        CGImageRef imageRef = [generator copyCGImageAtTime:captureTime actualTime:NULL error:&error];
        PFFile *thumbnail = [PFFile fileWithData:UIImagePNGRepresentation([UIImage imageWithCGImage:imageRef]) contentType:@"image/png"];
        CGImageRelease(imageRef);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(thumbnail, error);
        });
    });
}

+ (void)fillSCVideoConfigurationWithPresets:(SCVideoConfiguration **)videoConfiguration
{
    // Whether the video should be enabled or not
    [*videoConfiguration setEnabled:YES];
    // The bitrate of the video video
    //    video.bitrate = 2000000; // 2Mbit/s
    // Size of the video output
    [*videoConfiguration setSize:CGSizeMake(560, 560)];
    // Scaling if the output aspect ratio is different than the output one
    [*videoConfiguration setScalingMode:AVVideoScalingModeResizeAspectFill];
    // The timescale ratio to use. Higher than 1 makes a slow motion, between 0 and 1 makes a timelapse effect
    [*videoConfiguration setTimeScale:1];
    // Whether the output video size should be infered so it creates a square video
    [*videoConfiguration setSizeAsSquare:YES];
}

//+ (void)createSquareVideoFromVideoFileURL:(NSURL *)url usingWaterMarkImage:(UIImage *)watermarkImage andCompletionBlock:(SCRecordSessionCompletionBlock)completionBlock
//{
//    AVAsset *video1Asset = [AVURLAsset assetWithURL:url];
//    if (!video1Asset) {
//        NSLog(@"Couldn't open video asset");
//        NSError *error = [NSError errorWithDomain:@"la.mento.app" code:1 userInfo:nil];
//        completionBlock(nil, error);
//    }
//    
//    AVAssetTrack *assetTrack = [[video1Asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//    CGSize squareVideoSize = CGSizeMake(assetTrack.naturalSize.width * kMentoStampBorderRatio, assetTrack.naturalSize.height);
//    
//    //    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
//    //    videoComposition.renderSize = squareVideoSize;
//    
//    
//    AVMutableComposition *mixComposition = [AVMutableComposition composition];
//    AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//    [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, video1Asset.duration)
//                        ofTrack:assetTrack
//                         atTime:kCMTimeZero error:nil];
//    
//    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
//    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, video1Asset.duration) ofTrack:[[video1Asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
//    
//    AVMutableVideoCompositionLayerInstruction *firstLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
//    
//    CGFloat assetXPosition = (squareVideoSize.width - assetTrack.naturalSize.width) / 2.0f;
//    CGAffineTransform Move = CGAffineTransformMakeTranslation(assetXPosition, 0.0f);
//    [firstLayerInstruction setTransform:Move atTime:kCMTimeZero];
//    
//    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, video1Asset.duration);
//    mainInstruction.layerInstructions = @[firstLayerInstruction];
//    
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGFloat white[] = {1, 1, 1, 1};
//    CGColorRef whiteColor = CGColorCreate(colorSpace, white);
//    mainInstruction.backgroundColor = whiteColor;
//    
//    AVMutableVideoComposition *composition = [AVMutableVideoComposition videoComposition];
//    composition.instructions = @[mainInstruction];
//    composition.frameDuration = CMTimeMake(1, 30);
//    composition.renderSize = squareVideoSize;
//    
//    // Create the export session with the composition and set the preset to the highest quality.
//    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
//    // Set the desired output URL for the file created by the export process.
//    NSString *timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
//    
//    NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *exportVideoPath = [NSString stringWithFormat:@"%@/%@.mp4",documentsDirectoryPath,timestamp];
//    
//    exporter.outputURL = [NSURL fileURLWithPath:exportVideoPath];
//    exporter.videoComposition = composition;
//    //Set the output file type to be a MP4 movie.
//    exporter.outputFileType = AVFileTypeMPEG4;
//    exporter.shouldOptimizeForNetworkUse = YES;
//    
//    //Asynchronously export the composition to a video file and save this file to the camera roll once export completes.
//    [exporter exportAsynchronouslyWithCompletionHandler:^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (exporter.status == AVAssetExportSessionStatusCompleted) {
//                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//                NSURL *exportVideoPathURL = [NSURL URLWithString:exportVideoPath];
//                if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:exportVideoPathURL]) {
//                    [library writeVideoAtPathToSavedPhotosAlbum:exportVideoPathURL completionBlock:^(NSURL *assetURL, NSError *error) {
//                        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
//                        completionBlock(assetURL, error);
//                    }];
//                }
//            }
//        });
//    }];
//}

#endif



@end
