//
//  Screen4ViewController.m
//  Layovr
//
//  Created by Daniel Drescher on 03/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "Screen4ViewController.h"
#import "Screen5ViewController.h"

@interface Screen4ViewController() <UITextFieldDelegate>{
    
}

@end

@implementation Screen4ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.firstCityTF setReturnKeyType:UIReturnKeyNext];
    [self.secondCityTF setReturnKeyType:UIReturnKeyNext];
    [self.thirdCityTF setReturnKeyType:UIReturnKeyDone];
    
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

#pragma mark - UIButton Event

- (IBAction)backTouchUp:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)nextTouchUp:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.firstCityTF.text forKey:FIRST_CITY];
    [[NSUserDefaults standardUserDefaults] setObject:self.secondCityTF.text forKey:SECOND_CITY];
    [[NSUserDefaults standardUserDefaults] setObject:self.thirdCityTF.text forKey:THIRD_CITY];
    
    [[[UserInfo sharedInstance] userData] setValue:self.firstCityTF.text forKey:FIRST_CITY];
    [[[UserInfo sharedInstance] userData] setValue:self.secondCityTF.text forKey:SECOND_CITY];
    [[[UserInfo sharedInstance] userData] setValue:self.thirdCityTF.text forKey:THIRD_CITY];
    
    [self showScreen5];
}
- (IBAction)skipTouchUp:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:FIRST_CITY];
    [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:SECOND_CITY];
    [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:THIRD_CITY];
    
    [[[UserInfo sharedInstance] userData] setValue:EMPTY_STRING forKey:FIRST_CITY];
    [[[UserInfo sharedInstance] userData] setValue:EMPTY_STRING forKey:SECOND_CITY];
    [[[UserInfo sharedInstance] userData] setValue:EMPTY_STRING forKey:THIRD_CITY];
    
    [self showScreen5];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.firstCityTF) {
        [textField resignFirstResponder];
        [self.secondCityTF becomeFirstResponder];
        return NO;
    }else if (textField == self.secondCityTF) {
        [textField resignFirstResponder];
        [self.thirdCityTF becomeFirstResponder];
        return NO;
    }else if (textField == self.thirdCityTF) {
        [textField resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - Custom Method

- (void)showScreen5 {
    Screen5ViewController *screen5VC = [self.storyboard instantiateViewControllerWithIdentifier:@"Screen5ViewController"];
    [self.navigationController pushViewController:screen5VC animated:YES];
}

- (void)setFontSizeForControls {
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    CGFloat size1 = h * 18 / 667;
    CGFloat size2 = h * 17 / 667;
    CGFloat size3 = h * 20 / 667;
    
    [self.questionLabel setFont:[UIFont systemFontOfSize:size1]];
    [self.firstCityTF setFont:[UIFont systemFontOfSize:size2]];
    [self.secondCityTF setFont:[UIFont systemFontOfSize:size2]];
    [self.thirdCityTF setFont:[UIFont systemFontOfSize:size2]];
    
    [self.backButton.titleLabel setFont:[UIFont systemFontOfSize:size3]];
    [self.nextButton.titleLabel setFont:[UIFont systemFontOfSize:size3]];
    [self.skipButton.titleLabel setFont:[UIFont systemFontOfSize:size3]];
}

#pragma mark - View Tap Gesture

- (IBAction)viewTapGesture:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

@end
