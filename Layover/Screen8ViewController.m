//
//  Screen8ViewController.m
//  Layovr
//
//  Created by Daniel Drescher on 04/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "Screen8ViewController.h"
#import "Screen9ViewController.h"

@interface Screen8ViewController() <UITextFieldDelegate>{
    
}

@end

@implementation Screen8ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.firstInterestTF setReturnKeyType:UIReturnKeyNext];
    [self.secondInterestTF setReturnKeyType:UIReturnKeyNext];
    [self.thirdInterestTF setReturnKeyType:UIReturnKeyDone];
    
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

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.firstInterestTF) {
        [textField resignFirstResponder];
        [self.secondInterestTF becomeFirstResponder];
        return NO;
    }else if (textField == self.secondInterestTF) {
        [textField resignFirstResponder];
        [self.thirdInterestTF becomeFirstResponder];
    }else if (textField == self.thirdInterestTF) {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - UIButton Touch Up

- (IBAction)backTouchUp:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)continueTouchUp:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.firstInterestTF.text forKey:FIRST_INTEREST];
    [[NSUserDefaults standardUserDefaults] setObject:self.secondInterestTF.text forKey:SECOND_INTEREST];
    [[NSUserDefaults standardUserDefaults] setObject:self.thirdInterestTF.text forKey:THIRD_INTEREST];
    
    [[[UserInfo sharedInstance] userData] setValue:self.firstInterestTF.text forKey:FIRST_INTEREST];
    [[[UserInfo sharedInstance] userData] setValue:self.secondInterestTF.text forKey:SECOND_INTEREST];
    [[[UserInfo sharedInstance] userData] setValue:self.thirdInterestTF.text forKey:THIRD_INTEREST];
    
    [self showScreen9];
}

- (IBAction)skipTouchUp:(UIButton *)sender {
    
    [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:FIRST_INTEREST];
    [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:SECOND_INTEREST];
    [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:THIRD_INTEREST];
    
    [[[UserInfo sharedInstance] userData] setValue:EMPTY_STRING forKey:FIRST_INTEREST];
    [[[UserInfo sharedInstance] userData] setValue:EMPTY_STRING forKey:SECOND_INTEREST];
    [[[UserInfo sharedInstance] userData] setValue:EMPTY_STRING forKey:THIRD_INTEREST];
    
    [self showScreen9];
}

#pragma mark - View Tap Gesture

- (IBAction)viewTapGesture:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

#pragma mark - Custom Method

- (void)showScreen9 {
    Screen9ViewController *screen9VC = [self.storyboard instantiateViewControllerWithIdentifier:@"Screen9ViewController"];
    [self.navigationController pushViewController:screen9VC animated:YES];
}

- (void)setFontSizeForControls {
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    CGFloat size1 = h * 18 / 667;
    CGFloat size2 = h * 17 / 667;
    CGFloat size3 = h * 20 / 667;
    CGFloat size4 = h * 25 / 667;
    
    [self.descriptionLabel setFont:[UIFont systemFontOfSize:size1]];
    [self.firstInterestTF setFont:[UIFont systemFontOfSize:size2]];
    [self.secondInterestTF setFont:[UIFont systemFontOfSize:size2]];
    [self.thirdInterestTF setFont:[UIFont systemFontOfSize:size2]];
    
    [self.almostLabel setFont:[UIFont systemFontOfSize:size4]];
    
    [self.backButton.titleLabel setFont:[UIFont systemFontOfSize:size3]];
    [self.nextButton.titleLabel setFont:[UIFont systemFontOfSize:size3]];
    [self.skipButton.titleLabel setFont:[UIFont systemFontOfSize:size3]];
}

@end
