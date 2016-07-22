//
//  LITUploadSoundbiteViewController.m
//  lit-ios
//
//  Created by Alejandro Benito on 17/07/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITUploadSoundbiteViewController.h"
#import "FirebaseGlobals.h"
#import <Firebase/Firebase.h>

NSString *const kSoundbiteUploadSegueIdentifier = @"SoundbiteUploadSegue";

@interface LITUploadSoundbiteViewController ()
@property (strong, nonatomic) Firebase *soundbiteRef;
@property (strong, nonatomic) NSDictionary *dataDict;
@end

@implementation LITUploadSoundbiteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSError *error;
    NSData *soundbiteData     = [NSData dataWithContentsOfFile:self.soundbiteLocalURL.path options:0 error:&error];
    NSString *base64Soundbite = [soundbiteData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    self.soundbiteRef = [[[[Firebase alloc] initWithUrl:kFirebaseURL] childByAppendingPath:kFirebaseSoundbitesPath] childByAutoId];
    
    NSMutableDictionary *soundbiteDataDict = [NSMutableDictionary dictionaryWithDictionary:self.songMetadata];
    [soundbiteDataDict setObject:base64Soundbite forKey:kFirebaseSoundbiteDataKey];
    
    self.dataDict = [NSDictionary dictionaryWithDictionary:soundbiteDataDict];

}

- (void)viewDidAppear:(BOOL)animated
{
    [self.soundbiteRef setValue:self.dataDict];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

@end
