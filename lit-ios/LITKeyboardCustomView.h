//
//  CustomView.h
//  KeyboardInput
//
//  Created by Brian Mancini on 10/4/14.
//  Copyright (c) 2014 iOSExamples. All rights reserved.
//

@import UIKit;
#import "LITKeyboardBar.h"

@interface LITKeyboardCustomView : UIView

@property (weak, nonatomic) id<LITKeyboardBarDelegate> keyboardBarDelegate;

@end
