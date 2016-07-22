//
//  LITBaseSoundTableViewCell.h
//  
//
//  Created by ioshero on 19/08/2015.
//
//

#import <UIKit/UIKit.h>

@class VOXHistogramControlView, PFFile;
@interface LITBaseSoundbiteTableViewCell : UITableViewCell

@property (readonly, weak, nonatomic) UILabel *titleLabel;
@property (readonly, weak, nonatomic) UIButton *playButton;
@property (readonly, weak, nonatomic) VOXHistogramControlView *histogramControlView;
@property (readonly, weak, nonatomic) UIButton *optionsButton;
@property (readonly, weak, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSString *soundbiteId;
@property (strong, nonatomic) PFFile *audioFile;

- (void)initHistogramViewWithFileURL:(NSURL *)cachedFileURL;

@end
