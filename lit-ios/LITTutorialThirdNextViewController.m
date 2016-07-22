//
//  LITTutorialThirdNextViewController.m
//  lit-ios
//
//  Created by Antonio Losada on 29/10/15.
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import "LITTutorialThirdNextViewController.h"

@interface LITTutorialThirdNextViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@end

@implementation LITTutorialThirdNextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    // If the user has not gone to Settings, we show an alert
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"installationCompleted"]){
     
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"installationCompleted"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"JUST KNOW"
                                                        message:@"You can't use the keyboard without updating the settings."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        [self.textField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.textField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
