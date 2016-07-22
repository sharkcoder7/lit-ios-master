//
//  LITBaseSoundTableViewCell.m
//  
//
//  Created by ioshero on 19/08/2015.
//
//

#import "LITBaseSoundbiteTableViewCell.h"
#import "LITTheme.h"
#import "AVUtils.h"
#import <VOXHistogramView/VOXHistogramControlView.h>
#import <VOXHistogramView/VOXHistogramRenderingConfiguration.h>
#import <EZAudio/EZAudioFile.h>
#import <Parse/PFFile.h>

@interface LITBaseSoundbiteTableViewCell () <VOXHistogramControlViewDelegate> {
        BOOL _didSetupHistogram;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet VOXHistogramControlView *histogramControlView;
@property (weak, nonatomic) IBOutlet UIButton *optionsButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) NSURL *cachedFileURL;

@property (strong, nonatomic) EZAudioFile *ezAudioFile;

@end


@implementation LITBaseSoundbiteTableViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleLabel.text = @"";
    [self.titleLabel setTextColor:[UIColor lit_darkGreyColor]];
    
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.histogramControlView setDelegate:self];
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.histogramControlView setDelegate:self];

    
}

- (void)initHistogramViewWithFileURL:(NSURL *)cachedFileURL
{
    self.ezAudioFile = [[EZAudioFile alloc] initWithURL:cachedFileURL];
    __weak typeof(self) weakSelf = self;
    NSParameterAssert(cachedFileURL);
    NSParameterAssert(self.ezAudioFile);
    [self.ezAudioFile getWaveformDataWithCompletionBlock:^(float **waveformData, int length) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
//        NSCAssert(waveformData, @"Waveform data cannot be NULL");
        if (!waveformData) {
            NSLog(@"Waveform data is NULL. Returning");
            return;
        }
        float *buffer1 = waveformData[0];
        float *buffer2 = waveformData[1];
        NSMutableArray *numbersArray = [NSMutableArray arrayWithCapacity:length];
        float max = 0;
        for (NSInteger i = 0; i < length; i++) {
            //Mean of the two channels (for stereo)
            float avg = (buffer1[i] + buffer2[i]) / 2;
            max = avg > max ? avg : max;
            [numbersArray addObject:[NSNumber numberWithFloat:avg]];
        }
        NSMutableArray *normalizedValues = [NSMutableArray arrayWithCapacity:numbersArray.count];
        for (NSNumber *floatNumber in numbersArray) {
            [normalizedValues addObject:[NSNumber numberWithFloat:(floatNumber.floatValue / max)]];
        }
        [strongSelf.histogramControlView setDelegate:strongSelf];
        
        [strongSelf.histogramControlView setNotCompleteColor:[UIColor lit_histogramGreyColor]];
        [strongSelf.histogramControlView setCompleteColor:[UIColor lit_fadedOrangeLightColor]];
        
        [strongSelf.histogramControlView setLevels:[NSArray arrayWithArray:normalizedValues]];
        [strongSelf.histogramControlView setBackgroundColor:[UIColor clearColor]];
        [strongSelf.histogramControlView setUserInteractionEnabled:NO];
        _didSetupHistogram = YES;
    }];
}


#pragma mark - VOXHistogramControlViewDelegate
- (void)histogramControlViewWillStartRendering:(VOXHistogramControlView *)controlView
{
    [self.activityIndicator startAnimating];
}
- (void)histogramControlViewDidFinishRendering:(VOXHistogramControlView *)controlView
{
    [self.activityIndicator stopAnimating];
}

@end
