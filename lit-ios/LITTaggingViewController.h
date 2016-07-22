//
//  LITTaggingViewController.h
//  lit-ios
//
//  Created by Antonio Losada on 16/11/15.
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/PFObject.h>

extern NSString *const kLITPresentTagsForSoundbiteSegueIdentifier;
extern NSString *const kLITPresentTagsForDubSegueIdentifier;

@protocol LITTaggableContent;
@interface LITTaggingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) PFObject<LITTaggableContent> *content;

@end
