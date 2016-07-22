//
//  LITTaggingCollectionViewController.h
//  lit-ios
//
//  Created by ioshero on 20/07/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/PFObject.h>
#import <ParseUI/PFQueryCollectionViewController.h>

/*
extern NSString *const kLITPresentTagsForLyricSegueIdentifier;
extern NSString *const kLITPresentTagsForSoundbiteSegueIdentifier;
extern NSString *const kLITPresentTagsForDubSegueIdentifier;
*/
 
@protocol LITTaggableContent;
@interface LITTaggingCollectionViewController : UICollectionViewController

@property (strong, nonatomic) PFObject<LITTaggableContent> *content;

@end
