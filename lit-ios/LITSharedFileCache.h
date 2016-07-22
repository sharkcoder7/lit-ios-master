//
//  LITSharedFileCache.h
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/PFFile.h>
#import <Parse/PFObject.h>

typedef void(^LITSharedCacheRetrieveBlock)(NSURL *fileCacheURL, NSError *error);
typedef void(^LITSharedCacheSaveBlock)(BOOL success, NSError *error);

@interface PFObject (LITSharedCache)
- (BFTask *)saveColumnNameAtSharedCache:(NSString *)columnName;
- (BOOL)saveColumnNameAtSharedCacheSync:(NSString *)columnName;
- (BFTask *)retrieveColumnNameFromSharedCache:(NSString *)columnName;
- (BOOL)deleteColumnNameFromSharedCache:(NSString *)columnName withError:(NSError **)error;
@end

@interface PFFile (LITSharedCache)
- (BFTask *)saveAtSharedCache;
- (BFTask *)retrieveFromSharedCache;
- (BOOL)deleteSharedCacheEntryWithError:(NSError **)error;
@end

@class PFFile;
@interface LITSharedFileCache : NSObject

+ (NSURL *)sharedFileCacheURL;
+ (NSURL *)sharedFileCacheFileURLForPFFile:(PFFile *)file;

@end
