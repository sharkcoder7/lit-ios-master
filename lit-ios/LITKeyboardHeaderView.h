//
//  LITKeyboardHeaderView.h
//  lit-ios
//
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFImageView, PKDownloadButton;

@interface LITKeyboardHeaderView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet PFImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet PKDownloadButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *fullHeaderButton;

@end
