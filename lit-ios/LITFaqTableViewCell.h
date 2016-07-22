//
//  LITFaqTableViewCell.h
//  lit-ios
//
//  Created by Antonio Losada on 8/10/15.
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LITFaqTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerLabel;

@end
