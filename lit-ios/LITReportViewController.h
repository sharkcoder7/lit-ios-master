//
//  LITReportViewController.h
//  lit-ios
//
//  Created by Antonio Losada on 28/8/15.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kLITKBSoundbiteCollectionViewCell;
extern NSString *const kLITKBDubCollectionViewCell;
extern NSString *const kLITKBLyricCollectionViewCell;

@class PFObject;
@interface LITReportViewController : UIViewController

-(void)assignObject:(PFObject *)object;

@end
