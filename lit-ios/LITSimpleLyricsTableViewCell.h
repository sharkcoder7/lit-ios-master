//
//  LITSimpleLyricsTableViewCell.h
//  lit-ios
//
//  Created by ioshero on 25/08/2015.
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kLITSimpleLyricsTableViewCellIdentifier;

@interface LITSimpleLyricsTableViewCell : UITableViewCell

@property (weak, nonatomic, readonly) UILabel *lyricsLabel;
@property (weak, nonatomic, readonly) UIButton *optionsButton;

@end
