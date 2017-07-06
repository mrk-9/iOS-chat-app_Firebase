//
//  Screen6ViewController.m
//  Layovr
//
//  Created by Daniel Drescher on 03/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "Screen6ViewController.h"
#import "Screen7ViewController.h"

@interface Screen6ViewController() <UITextFieldDelegate>{
    
}
@end

@implementation Screen6ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.occupationTF setReturnKeyType:UIReturnKeyDone];
    
    [self setFontSizeForControls];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIButton Touch Up

- (IBAction)backTouchUp:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)continueTouchUp:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.occupationTF.text forKey:OCCUPATION];
    
    [[[UserInfo sharedInstance] userData] setValue:self.occupationTF.text forKey:OCCUPATION];
    
    [self showScreen7];
}

- (IBAction)skipTouchUp:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:OCCUPATION];
    
    [[[UserInfo sharedInstance] userData] setValue:EMPTY_STRING forKey:OCCUPATION];
    
    [self showScreen7];
}

#pragma mark - Custom Method

- (void)showScreen7 {
    Screen7ViewController *screen7VC = [self.storyboard instantiateViewControllerWithIdentifier:@"Screen7ViewController"];
    
    [self.navigationController pushViewController:screen7VC animated:YES];
}

- (void)setFontSizeForControls {
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    CGFloat size1 = h * 18 / 667;
    CGFloat size2 = h * 17 / 667;
    CGFloat size3 = h * 20 / 667;
    
    [self.questionLabel setFont:[UIFont systemFontOfSize:size1]];
    [self.occupationTF setFont:[UIFont systemFontOfSize:size2]];
    [self.backButton.titleLabel setFont:[UIFont systemFontOfSize:size3]];
    [self.nextButton.titleLabel setFont:[UIFont systemFontOfSize:size3]];
    [self.skipButton.titleLabel setFont:[UIFont systemFontOfSize:size3]];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.occupationTF) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - View Tap Gesture

- (IBAction)viewTapGesture:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

@end
