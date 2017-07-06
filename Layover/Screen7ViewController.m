//
//  Screen7ViewController.m
//  Layovr
//
//  Created by Daniel Drescher on 03/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "Screen7ViewController.h"
#import "Screen8ViewController.h"

@interface Screen7ViewController() <UITextFieldDelegate>{
    
}

@end

@implementation Screen7ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collegeTF setReturnKeyType:UIReturnKeyDone];
    
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
    [[NSUserDefaults standardUserDefaults] setObject:self.collegeTF.text forKey:COLLEGE];
    
    [[[UserInfo sharedInstance] userData] setValue:self.collegeTF.text forKey:COLLEGE];
    
    [self showScreen8];
}

- (IBAction)skipTouchUp:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:COLLEGE];
    
    [[[UserInfo sharedInstance] userData] setValue:EMPTY_STRING forKey:COLLEGE];
    
    [self showScreen8];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.collegeTF) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - Custom Method

- (void)showScreen8 {
    Screen8ViewController *screen8VC = [self.storyboard instantiateViewControllerWithIdentifier:@"Screen8ViewController"];
    [self.navigationController pushViewController:screen8VC animated:YES];
}

- (void)setFontSizeForControls {
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    CGFloat size1 = h * 18 / 667;
    CGFloat size2 = h * 17 / 667;
    CGFloat size3 = h * 20 / 667;
    
    [self.questionLabel setFont:[UIFont systemFontOfSize:size1]];
    [self.collegeTF setFont:[UIFont systemFontOfSize:size2]];
    [self.backButton.titleLabel setFont:[UIFont systemFontOfSize:size3]];
    [self.nextButton.titleLabel setFont:[UIFont systemFontOfSize:size3]];
    [self.skipButton.titleLabel setFont:[UIFont systemFontOfSize:size3]];
    
}

#pragma mark - View Tap Gesture

- (IBAction)viewTapGesture:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

@end
