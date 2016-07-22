//
//  LITImageUtils.h
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface LITImageUtils : NSObject

+ (UIImage *)resizeImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (void)updateUserParsePicture:(UIImage *)picture;

@end