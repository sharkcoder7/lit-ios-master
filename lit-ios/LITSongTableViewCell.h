//
//  LITSongTableViewCell.h
//  lit-ios
//
//  Created by ioshero on 25/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kLITSongTableViewCellIdentifier;

@interface LITSongTableViewCell : UITableViewCell

@property (nonatomic, weak, readonly) UILabel *artistLabel;
@property (nonatomic, weak, readonly) UILabel *songTitleLabel;

@end
