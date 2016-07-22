//
//  KeyboardBar.m
//  KeyboardInputView
//
//  Created by Brian Mancini on 10/4/14.
//  Copyright (c) 2014 iOSExamples. All rights reserved.
//

#import "LITKeyboardBar.h"
#import "LITTheme.h"

@interface LITKeyboardBar () <UITextFieldDelegate>

//@property (strong, nonatomic) UITextField *textfield;
@property (strong, nonatomic) UIButton *actionButton;

@end


@implementation LITKeyboardBar

- (id)initWithDelegate:(id<LITKeyboardBarDelegate>)delegate {
    self = [self init];
    self.delegate = delegate;
    return self;
}

- (id)init {
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectMake(0,0, CGRectGetWidth(screen), 60);
    if (self = [self initWithFrame:frame]) {
        self.backgroundColor = [UIColor lit_darkOrangishColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if(self) {
        
        self.backgroundColor = [UIColor colorWithWhite:0.75f alpha:1.0f];
        
        self.textfield = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, frame.size.width - 10, frame.size.height - 10)];
        self.textfield.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f];
        [self addSubview:self.textfield];
        [self.textfield setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f]];
        [self.textfield setTextColor:[UIColor whiteColor]];
        [self.textfield setBackgroundColor:[UIColor clearColor]];
        [self.textfield setPlaceholder:@"Add a name..."];
        [self.textfield setValue:[UIColor lit_placeholderOrange] forKeyPath:@"_placeholderLabel.textColor"];
        
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 0)];
        [self.textfield setLeftView:paddingView];
        [self.textfield setLeftViewMode:UITextFieldViewModeAlways];
        [self.textfield setTintColor:[UIColor lit_placeholderOrange]];
        
        [self.textfield setKeyboardType:UIKeyboardTypeDefault];
        [self.textfield setReturnKeyType:UIReturnKeyGo];
        [self.textfield setDelegate:self];
//        self.actionButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width - 60, 5, 55, frame.size.height - 10)];
//        self.actionButton.backgroundColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
//        self.actionButton.layer.cornerRadius = 2.0;
//        self.actionButton.layer.borderWidth = 1.0;
//        self.actionButton.layer.borderColor = [[UIColor colorWithWhite:0.45 alpha:1.0f] CGColor];
//        [self.actionButton setTitle:@"" forState:UIControlStateNormal];
//        [self.actionButton addTarget:self action:@selector(didTouchAction) forControlEvents:UIControlEventTouchUpInside];
//        
//        [self addSubview:self.actionButton];
        
    }
    return self;
}

- (void) didTouchAction
{
    [self.delegate keyboardBar:self sendText:self.textfield.text];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(keyboardBar:sendText:)]) {
        [self.delegate keyboardBar:self sendText:self.textfield.text];
    }
    return NO;
}

@end
