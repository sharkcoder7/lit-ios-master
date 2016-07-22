//
//  KeyboardViewController.m
//  iOSKeyboardTemplate
//
//  Copyright (c) 2014 BJH Studios. All rights reserved.
//  questions or comments contact jeff@bjhstudios.com

#import "KeyboardViewController.h"
#import "LITKeyboardsBaseViewController.h"
#import "Header.h"
#import "SearchViewController.h"
#import "AKTagCell.h"
#import "UIView+GradientBackground.h"
#import "LITTheme.h"


@interface KeyboardViewController () {
    int _shiftStatus; //0 = off, 1 = on, 2 = caps lock
    int _subShiftStatus;
    NSMutableArray* upperKeyList;
    NSMutableArray* lowerKeyList;
    NSMutableArray* numKeyList;
    NSMutableArray* symbolKeyList;
}

//keyboard rows
@property (nonatomic, weak) IBOutlet UIView *numbersRow1View;
@property (nonatomic, weak) IBOutlet UIView *numbersRow2View;
@property (nonatomic, weak) IBOutlet UIView *symbolsRow1View;
@property (nonatomic, weak) IBOutlet UIView *symbolsRow2View;
@property (nonatomic, weak) IBOutlet UIView *numbersSymbolsRow3View;

@property (nonatomic, weak) IBOutlet UIView *lettersRow1View;
@property (nonatomic, weak) IBOutlet UIView *lettersRow2View;
@property (nonatomic, weak) IBOutlet UIView *lettersRow3View;

@property (weak, nonatomic) IBOutlet UIView *numberSymbolView;
@property (weak, nonatomic) IBOutlet UIView *letterView;

//keys
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *letterButtonsArray;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *symbolButtonsArray;
@property (nonatomic, weak) IBOutlet UIButton *switchModeRow3Button;
@property (nonatomic, weak) IBOutlet UIButton *switchModeRow4Button;
@property (nonatomic, weak) IBOutlet UIButton *shiftButton;
@property (nonatomic, weak) IBOutlet UIButton *spaceButton;

@end

@implementation KeyboardViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self initializeKeyboard];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TextInput methods

- (void)textWillChange:(id<UITextInput>)textInput {
}

- (void)textDidChange:(id<UITextInput>)textInput {
}

#pragma mark - initialization method

- (void) initializeKeyboard {
    
    //start with shift on
    _shiftStatus = 1;
    _subShiftStatus = 0;
    
    //initialize space key double tap
    UITapGestureRecognizer *spaceDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(spaceKeyDoubleTapped:)];
    
    spaceDoubleTap.numberOfTapsRequired = 2;
    [spaceDoubleTap setDelaysTouchesEnded:NO];
    
    [self.spaceButton addGestureRecognizer:spaceDoubleTap];
    
    //initialize shift key double and triple tap
    UITapGestureRecognizer *shiftDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shiftKeyDoubleTapped:)];
    UITapGestureRecognizer *shiftTripleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shiftKeyPressed:)];
    
    shiftDoubleTap.numberOfTapsRequired = 2;
    shiftTripleTap.numberOfTapsRequired = 3;
    
    [shiftDoubleTap setDelaysTouchesEnded:NO];
    [shiftTripleTap setDelaysTouchesEnded:NO];
    
    [self.shiftButton addGestureRecognizer:shiftDoubleTap];
    [self.shiftButton addGestureRecognizer:shiftTripleTap];
    
}

#pragma mark - key methods

- (IBAction) globeKeyPressed:(id)sender {
    
    //required functionality, switches to user's next keyboard
    [self advanceToNextInputMode];
    
}

- (IBAction) keyPressed:(UIButton*)sender {
    
    // Letters - Row 1
    if (sender.tag == Q) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"q"];
        } else {
            [self.textDocumentProxy insertText:@"Q"];
        }
    } else if (sender.tag == W) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"w"];
        } else {
            [self.textDocumentProxy insertText:@"W"];
        }
    } else if (sender.tag == E) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"e"];
        } else {
            [self.textDocumentProxy insertText:@"E"];
        }
    } else if (sender.tag == R) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"r"];
        } else {
            [self.textDocumentProxy insertText:@"R"];
        }
    } else if (sender.tag == T) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"t"];
        } else {
            [self.textDocumentProxy insertText:@"T"];
        }
    } else if (sender.tag == Y) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"y"];
        } else {
            [self.textDocumentProxy insertText:@"Y"];
        }
    } else if (sender.tag == U) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"u"];
        } else {
            [self.textDocumentProxy insertText:@"U"];
        }
    } else if (sender.tag == _I) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"i"];
        } else {
            [self.textDocumentProxy insertText:@"I"];
        }
    } else if (sender.tag == O) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"o"];
        } else {
            [self.textDocumentProxy insertText:@"O"];
        }
    } else if (sender.tag == P) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"p"];
        } else {
            [self.textDocumentProxy insertText:@"P"];
        }
        
    //Letters - Row 2
    } else if (sender.tag == A) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"a"];
        } else {
            [self.textDocumentProxy insertText:@"A"];
        }
    } else if (sender.tag == S) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"s"];
        } else {
            [self.textDocumentProxy insertText:@"S"];
        }
    } else if (sender.tag == D) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"d"];
        } else {
            [self.textDocumentProxy insertText:@"D"];
        }
    } else if (sender.tag == F) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"f"];
        } else {
            [self.textDocumentProxy insertText:@"F"];
        }
    } else if (sender.tag == G) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"g"];
        } else {
            [self.textDocumentProxy insertText:@"G"];
        }
    } else if (sender.tag == H) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"h"];
        } else {
            [self.textDocumentProxy insertText:@"H"];
        }
    } else if (sender.tag == J) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"j"];
        } else {
            [self.textDocumentProxy insertText:@"J"];
        }
    } else if (sender.tag == K) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"k"];
        } else {
            [self.textDocumentProxy insertText:@"K"];
        }
    } else if (sender.tag == L) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"l"];
        } else {
            [self.textDocumentProxy insertText:@"L"];
        }
        
    //Letters - Row 3
    } else if (sender.tag == shift) {
        NSLog(@"shitfPressed");
    } else if (sender.tag == Z) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"z"];
        } else {
            [self.textDocumentProxy insertText:@"Z"];
        }
    } else if (sender.tag == X) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"x"];
        } else {
            [self.textDocumentProxy insertText:@"X"];
        }
    } else if (sender.tag == C) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"c"];
        } else {
            [self.textDocumentProxy insertText:@"C"];
        }
    } else if (sender.tag == V) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"v"];
        } else {
            [self.textDocumentProxy insertText:@"V"];
        }
    } else if (sender.tag == B) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"b"];
        } else {
            [self.textDocumentProxy insertText:@"B"];
        }
    } else if (sender.tag == N) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"n"];
        } else {
            [self.textDocumentProxy insertText:@"N"];
        }
    } else if (sender.tag == M) {
        if (_shiftStatus == 0) {
            [self.textDocumentProxy insertText:@"m"];
        } else {
            [self.textDocumentProxy insertText:@"M"];
        }
        
    //123 - Rows 1
    }else if (sender.tag == num_0) {
        if(_subShiftStatus) [self.textDocumentProxy insertText:@"="];
        else [self.textDocumentProxy insertText:@"0"];
    } else if (sender.tag == num_1) {
        if(_subShiftStatus) [self.textDocumentProxy insertText:@"["];
        else [self.textDocumentProxy insertText:@"1"];
    } else if (sender.tag == num_2) {
        if(_subShiftStatus) [self.textDocumentProxy insertText:@"]"];
        else [self.textDocumentProxy insertText:@"2"];
    } else if (sender.tag == num_3) {
        if(_subShiftStatus) [self.textDocumentProxy insertText:@"{"];
        else [self.textDocumentProxy insertText:@"3"];
    } else if (sender.tag == num_4) {
        if(_subShiftStatus) [self.textDocumentProxy insertText:@"}"];
        else [self.textDocumentProxy insertText:@"4"];
    } else if (sender.tag == num_5) {
        if(_subShiftStatus) [self.textDocumentProxy insertText:@"#"];
        else [self.textDocumentProxy insertText:@"5"];
    } else if (sender.tag == num_6) {
        if(_subShiftStatus) [self.textDocumentProxy insertText:@"%"];
        else [self.textDocumentProxy insertText:@"6"];
    } else if (sender.tag == num_7) {
        if(_subShiftStatus) [self.textDocumentProxy insertText:@"^"];
        else [self.textDocumentProxy insertText:@"7"];
    } else if (sender.tag == num_8) {
        if(_subShiftStatus) [self.textDocumentProxy insertText:@"*"];
        else [self.textDocumentProxy insertText:@"8"];
    } else if (sender.tag == num_9) {
        if(_subShiftStatus) [self.textDocumentProxy insertText:@"+"];
        else [self.textDocumentProxy insertText:@"9"];
        
    //123 - Row 2
        /*
         sym_1_0    -
         sym_1_1    /
         sym_1_2    :
         sym_1_3    ;
         sym_1_4    (
         sym_1_5    )
         sym_1_6    $
         sym_1_7    &
         sym_1_8    @
         sym_1_9    "
         */
    } else if (sender.tag == sym_1_0) {
        if(_subShiftStatus) [self.textDocumentProxy insertText:@"_"];
        else [self.textDocumentProxy insertText:@"-"];
    } else if (sender.tag == sym_1_1) {
        if(_subShiftStatus) [self.textDocumentProxy insertText:@"\\"];
        else [self.textDocumentProxy insertText:@"/"];
    } else if (sender.tag == sym_1_2) {
        if(_subShiftStatus) [self.textDocumentProxy insertText:@"|"];
        else [self.textDocumentProxy insertText:@":"];
    } else if (sender.tag == sym_1_3) {
        if(_subShiftStatus) [self.textDocumentProxy insertText:@"~"];
        else [self.textDocumentProxy insertText:@";"];
    } else if (sender.tag == sym_1_4) {
        if(_subShiftStatus) [self.textDocumentProxy insertText:@"<"];
        else [self.textDocumentProxy insertText:@"("];
    } else if (sender.tag == sym_1_5) {
        if(_subShiftStatus) [self.textDocumentProxy insertText:@">"];
        else [self.textDocumentProxy insertText:@")"];
    } else if (sender.tag == sym_1_6) {
        if(_subShiftStatus) [self.textDocumentProxy insertText:@"€"];
        else [self.textDocumentProxy insertText:@"$"];
    } else if (sender.tag == sym_1_7) {
        if(_subShiftStatus) [self.textDocumentProxy insertText:@"£"];
        else [self.textDocumentProxy insertText:@"&"];
    } else if (sender.tag == sym_1_8) {
        if(_subShiftStatus) [self.textDocumentProxy insertText:@"¥"];
        else [self.textDocumentProxy insertText:@"@"];
    } else if (sender.tag == sym_1_9) {
        if(_subShiftStatus) [self.textDocumentProxy insertText:@"•"];
        else [self.textDocumentProxy insertText:@"\""];
    } else if (sender.tag == sym_4_1) {
        [self.textDocumentProxy insertText:@"."];
    } else if (sender.tag == sym_4_2) {
        [self.textDocumentProxy insertText:@","];
    } else if (sender.tag == sym_4_5) {
        [self.textDocumentProxy insertText:@"'"];
    } else if (sender.tag == sym_4_3) {
        [self.textDocumentProxy insertText:@"?"];
    } else if (sender.tag == sym_4_4) {
        [self.textDocumentProxy insertText:@"!"];
    }
    
    
    //if shiftStatus is 1, reset it to 0 by pre  ssing the shift key
    if (_shiftStatus == 1) {
        [self shiftKeyPressed:self.shiftButton];
    }
}

-(IBAction) backspaceKeyPressed: (UIButton*) sender {
    [self.textDocumentProxy deleteBackward];
}

-(IBAction) spaceKeyPressed: (UIButton*) sender {
    [self.textDocumentProxy insertText:@" "];
}

-(void) spaceKeyDoubleTapped: (UIButton*) sender {
    //double tapping the space key automatically inserts a period and a space
    //if necessary, activate the shift button
    [self.textDocumentProxy deleteBackward];
    [self.textDocumentProxy insertText:@". "];
    if (_shiftStatus == 0) {
        [self shiftKeyPressed:self.shiftButton];
    }
}

-(IBAction)returnKeyPressed: (UIButton*) sender {
    if ([self.delegate respondsToSelector:@selector(returnKeyPressed:)])
        [self.delegate returnKeyPressed:self];
}

-(IBAction) shiftKeyPressed: (UIButton*) sender {
    //if shift is on or in caps lock mode, turn it off. Otherwise, turn it on
    _shiftStatus = _shiftStatus > 0 ? 0 : 1;
    [self shiftKeys];
}

- (IBAction)switchToSymNum:(UIButton *)sender {
    _subShiftStatus = _subShiftStatus > 0 ? 0 : 1;
    
    if(_subShiftStatus)
    {
        symbolKeyList = [[NSMutableArray alloc] init];
        symbolKeyList = [NSMutableArray arrayWithObjects:@"[", @"]", @"{", @"}", @"#", @"%", @"^", @"*", @"+", @"=", @"_", @"\\", @"|", @"~", @"<", @">", @"€", @"£", @"¥", @"•", nil];
            
        int ii = 0;
        for (UIButton* symbolButton in self.symbolButtonsArray) {
            
            [symbolButton setTitle:@"" forState:UIControlStateNormal];
            [symbolButton setTitle:symbolKeyList[ii] forState:UIControlStateNormal];
            ii ++;
            if(ii == 20) break;
        }
            
        [sender setTitle:@"123" forState:UIControlStateNormal];
    }
    else{
        numKeyList = [[NSMutableArray alloc] init];
        numKeyList = [NSMutableArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0", @"-", @"/", @":", @";", @"(", @")", @"$", @"&", @"@", @"\"", nil];
        
        int ii = 0;
        for (UIButton* symbolButton in self.symbolButtonsArray) {
            
            [symbolButton setTitle:@"" forState:UIControlStateNormal];
            [symbolButton setTitle:numKeyList[ii] forState:UIControlStateNormal];
            ii ++;
            if(ii == 20) break;
        }
        
        [sender setTitle:@"#+=" forState:UIControlStateNormal];
    }
}

-(void) shiftKeyDoubleTapped: (UIButton*) sender {
    //set shift to caps lock and set all letters to uppercase
    _shiftStatus = 2;
    [self shiftKeys];
}

- (IBAction)switchToLetterBoard:(UIButton *)sender {
    self.letterView.hidden = !self.letterView.hidden;
    self.numberSymbolView.hidden = !self.numberSymbolView.hidden;
}

- (void) shiftKeys {
    upperKeyList = [[NSMutableArray alloc] init];
    lowerKeyList = [[NSMutableArray alloc] init];
    upperKeyList = [NSMutableArray arrayWithObjects:@"Q",@"W", @"E", @"R", @"T", @"Y", @"U", @"I", @"O", @"P", @"A", @"S", @"D", @"F", @"G", @"H", @"J", @"K", @"L", @"Z", @"X", @"C", @"V", @"B", @"N", @"M", nil];
    lowerKeyList = [NSMutableArray arrayWithObjects:@"q",@"w", @"e", @"r", @"t", @"y", @"u", @"i", @"o", @"p", @"a", @"s", @"d", @"f", @"g", @"h", @"j", @"k", @"l", @"z", @"x", @"c", @"v", @"b", @"n", @"m", nil];
    int ii = 0;
    int jj = 0;
    if (_shiftStatus == 0) {
        for (UIButton* letterButton in self.letterButtonsArray) {
            
            [letterButton setTitle:@"" forState:UIControlStateNormal];
            [letterButton setTitle:lowerKeyList[ii] forState:UIControlStateNormal];
            ii ++;
            if(ii == 26) break;
        }
    } else {
        for (UIButton* letterButton in self.letterButtonsArray) {
            
            [letterButton setTitle:@"" forState:UIControlStateNormal];
            [letterButton setTitle:upperKeyList[jj] forState:UIControlStateNormal];
            jj++;
            if(jj == 26) break;
        }
    }
}

- (IBAction) switchKeyboardMode:(UIButton*)sender {
    self.letterView.hidden = !self.letterView.hidden;
    self.numberSymbolView.hidden = !self.numberSymbolView.hidden;
    
    numKeyList = [[NSMutableArray alloc] init];
    numKeyList = [NSMutableArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0", @"-", @"/", @":", @";", @"(", @")", @"$", @"&", @"@", @"\"", nil];
    
    int ii = 0;
    for (UIButton* symbolButton in self.symbolButtonsArray) {
        
        [symbolButton setTitle:@"" forState:UIControlStateNormal];
        [symbolButton setTitle:numKeyList[ii] forState:UIControlStateNormal];
        ii ++;
        if(ii == 20) break;
    }
}

@end
