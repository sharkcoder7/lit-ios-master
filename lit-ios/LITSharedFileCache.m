//
//  LITSharedFileCache.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITSharedFileCache.h"
#import "ParseGlobals.h"
#import "AVUtils.h"
#import <Parse/PFObject+Synchronous.h>
#import <Parse/PFFile+Synchronous.h>
#import <Bolts/Bolts.h>

NSString *const kLITSharedFileCachePathComponent = @"LITSharedCache";

@implementation  PFFile (LITSharedCache)
- (BFTask *)saveAtSharedCache
{
    NSURL *fileCacheURL = [LITSharedFileCache sharedFileCacheFileURLForPFFile:self];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileCacheURL.path]) {
        return [BFTask taskWithResult:@(YES)];
    }
    
    return [[self getDataInBackground] continueWithSuccessBlock:^id(BFTask *task) {
        if (task.result) {
            NSData *fileData = task.result;
            NSError *error;
            BOOL saveResult = [fileData writeToURL:[LITSharedFileCache sharedFileCacheFileURLForPFFile:self]
                                           options:0
                                             error:&error];
            NSLog(@"Correctly saved file at shared cache: %@", [LITSharedFileCache sharedFileCacheFileURLForPFFile:self].path);
            if (!saveResult) {
                return [BFTask taskWithError:error];
            } else return [BFTask taskWithResult:@(YES)];
        }
        return nil;
    }];
}

- (BOOL)saveAtSharedCacheSync
{
    NSURL *fileCacheURL = [LITSharedFileCache sharedFileCacheFileURLForPFFile:self];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileCacheURL.path]) {
        return YES;
    }
    NSData *fileData = [self getData];
    return [fileData writeToURL:[LITSharedFileCache sharedFileCacheFileURLForPFFile:self]
                        options:0
                          error:nil];
}

- (BFTask *)retrieveFromSharedCache
{
    NSURL *fileCacheURL = [LITSharedFileCache sharedFileCacheFileURLForPFFile:self];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileCacheURL.path]) {
        NSLog(@"File doesn't exist at path %@", fileCacheURL.path);
    }
    return [BFTask taskWithResult:fileCacheURL];
}

- (BOOL)deleteSharedCacheEntryWithError:(NSError **)error;
{
    NSURL *fileCacheURL = [LITSharedFileCache sharedFileCacheFileURLForPFFile:self];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileCacheURL.path]) {
        NSLog(@"Tried to delete unexistent file at path %@", fileCacheURL.path);
        return YES;
    } else {
        [[NSFileManager defaultManager] removeItemAtURL:fileCacheURL error:error];
        if (*error) {
            NSLog(@"Error deleting item at path %@", fileCacheURL.path);
            return NO;
        } else return YES;
    }
}

@end

@implementation PFObject (LITSharedCache)

- (BFTask *)saveColumnNameAtSharedCache:(NSString *)columnName;
{
    NSParameterAssert(columnName);
    if (!self.isDataAvailable) {
        return [[self fetchInBackground] continueWithSuccessBlock:^id(BFTask *task) {
            PFFile *file = [self valueForKey:columnName];
            NSParameterAssert(file);
            return [file saveAtSharedCache];
        }];
    } else {
        PFFile *file = [self valueForKey:columnName];
        NSParameterAssert(file);
        return [file saveAtSharedCache];
    }
}

- (BOOL)saveColumnNameAtSharedCacheSync:(NSString *)columnName
{
    NSParameterAssert(columnName);
    if (!self.isDataAvailable) {
        return [[[self fetch] valueForKey:columnName] saveAtSharedCacheSync];
    } else return [[self valueForKey:columnName] saveAtSharedCacheSync];
}

- (BFTask *)retrieveColumnNameFromSharedCache:(NSString *)columnName
{
    NSParameterAssert(columnName);
    if (!self.isDataAvailable) {
        return [[self fetchFromLocalDatastoreInBackground] continueWithSuccessBlock:^id(BFTask *task) {
            PFFile *file = [self valueForKey:columnName];
            NSParameterAssert(file);
            return [file retrieveFromSharedCache];
        }];
    } else {
        PFFile *file = [self valueForKey:columnName];
        NSParameterAssert(file);
        return [file retrieveFromSharedCache];
    }
}

- (BOOL)deleteColumnNameFromSharedCache:(NSString *)columnName withError:(NSError **)error;
{
    NSParameterAssert(columnName);
    PFFile *file = [self valueForKey:columnName];
    NSParameterAssert(file);
    return [file deleteSharedCacheEntryWithError:error];
}

@end

@implementation LITSharedFileCache

+ (NSURL *)sharedFileCacheURL
{
    NSURL *containerURL = [[[NSFileManager defaultManager]
                            containerURLForSecurityApplicationGroupIdentifier:kLITAppGroupSharingIdentifier]
                           URLByAppendingPathComponent:kLITSharedFileCachePathComponent
                           isDirectory:YES];
    if (![[NSFileManager defaultManager]
         fileExistsAtPath:[containerURL path]
         isDirectory:NULL]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtURL:containerURL
                                 withIntermediateDirectories:NO
                                                  attributes:nil
                                                       error:&error];
        if (error) {
            NSLog(@"Error: Couldn't create shared cache directory at %@", containerURL.path);
        }
    }
    return containerURL;
}

+ (NSURL *)sharedFileCacheFileURLForPFFile:(PFFile *)file
{
    return [[LITSharedFileCache sharedFileCacheURL] URLByAppendingPathComponent:file.name];
}


@end
