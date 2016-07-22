//
//  LITKeyboardTableViewCell.m
//  slit-ios
//
//  Created by ioshero on 09/07/2015.
//  Copyright (c) 2015 Slit Inc. All rights reserved.
//

#import "LITKeyboardTableViewCell.h"
#import "LITKBDubCollectionViewCell.h"
#import "LITKBLyricCollectionViewCell.h"
#import "LITKBSoundbiteCollectionViewCell.h"
#import "UIView+GradientBackground.h"
#import "LITTheme.h"
#import "UIView+BlurEffect.h"
#import <ParseUI/PFImageView.h>
#import <DownloadButton/PKDownloadButton.h>

NSString *const kLITKeyboardTableViewCellIdentifier = @"LITKeyboardTableViewCell";

@interface LITIndexedCollectionView ()

@end


@implementation LITIndexedCollectionView

@end


@interface LITKeyboardTableViewCell () {
    BOOL _blurSet;
}

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIButton *optionsButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewRightConstraint;
@property (weak, nonatomic) IBOutlet PKDownloadButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@end

@implementation LITKeyboardTableViewCell



- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self.likesLabel setTextColor:[UIColor lit_coolGreyColor]];
    
    self.userImageView.layer.cornerRadius = CGRectGetWidth(self.userImageView.frame)  / 2.0f;
    self.userImageView.layer.masksToBounds = YES;
    self.userImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.removeButton setHidden:YES];
    [self.removeButton.layer setBorderWidth:1.0f];
    [self.removeButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.removeButton.layer setCornerRadius:2.0f];
    [self.editButton setHidden:YES];
    [self.editButton.layer setBorderWidth:1.0f];
    [self.editButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.editButton.layer setCornerRadius:2.0f];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
        
    [self.contentView setupFeedKeyboardGradientBackground];
    
    [self.titleView setFrame:CGRectMake(self.titleView.frame.origin.x, self.titleView.frame.origin.y, [[UIScreen mainScreen] bounds].size.width, self.titleView.frame.size.height)];
    
    [self.titleView setupFeedKeyboardTitleBarGradientBackground];
}


- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath
{
    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;
    self.collectionView.indexPath = indexPath;

    [self.collectionView reloadData];
}


@end
