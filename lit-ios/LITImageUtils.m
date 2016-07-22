//
//  LITImageUtils.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITImageUtils.h"

#import <Parse/PFFile.h>
#import <Parse/PFUser.h>

@implementation LITImageUtils

+ (UIImage *)resizeImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void)updateUserParsePicture:(UIImage *)picture {
    
    NSData* data = UIImageJPEGRepresentation([self resizeImage:picture scaledToSize:CGSizeMake(90,90)],.6f);
    PFFile *imageFile = [PFFile fileWithName:@"pic.jpeg" data:data];
    
    // Update the user in Parse, changing its picture. First we upload the image
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            // And now we associate it with the current user's profile pic
            [[PFUser currentUser] setObject:imageFile forKey:@"picture"];
            
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"User picture updated");
                }
                else{
                    // Error
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
    }];
}


@end
