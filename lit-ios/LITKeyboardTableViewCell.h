//
//  LITKeyboardTableViewCell.h
//  slit-ios
//
//  Created by ioshero on 09/07/2015.
//  Copyright (c) 2015 Slit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat kLITKeyboardCellHeight;
extern NSString *const kLITKeyboardTableViewCellIdentifier;

@interface LITIndexedCollectionView : UICollectionView

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@class PFImageView, PKDownloadButton;
@interface LITKeyboardTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet LITIndexedCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic, readonly) UIButton *optionsButton;
@property (weak, nonatomic, readonly) PKDownloadButton *downloadButton;
@property (weak, nonatomic, readonly) UIButton *removeButton;
@property (weak, nonatomic, readonly) UIButton *editButton;
@property (weak, nonatomic, readonly) UIButton *likeButton;

@property (assign, nonatomic) BOOL collectionViewConfigured;

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;

@end
