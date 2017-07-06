//
//  Screen3ViewController.m
//  Layovr
//
//  Created by Daniel Drescher on 03/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "Screen3ViewController.h"
#import "Screen4ViewController.h"

@interface Screen3ViewController() <UITextFieldDelegate>{
    
}

@end

@implementation Screen3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.cityTF setReturnKeyType:UIReturnKeyDone];
    
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

- (IBAction)continueTouchUp:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.cityTF.text forKey:CURRENT_CITY];
    
    [[[UserInfo sharedInstance] userData] setValue:self.cityTF.text forKey:CURRENT_CITY];
    
    [self showScreen4];
}

- (IBAction)skipTouchUp:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:CURRENT_CITY];
    
    [[[UserInfo sharedInstance] userData] setValue:EMPTY_STRING forKey:CURRENT_CITY];
    
    [self showScreen4];
}

- (IBAction)backTouchUp:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.cityTF) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - View Tap Gesture

- (IBAction)viewTapGesture:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

#pragma mark - Custom Method

- (void)setFontSizeForControls {
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    CGFloat size1 = h * 18 / 667;
    CGFloat size2 = h * 17 / 667;
    CGFloat size3 = h * 20 / 667;
    
    [self.questionLabel setFont:[UIFont systemFontOfSize:size1]];
    [self.cityTF setFont:[UIFont systemFontOfSize:size2]];
    [self.backButton.titleLabel setFont:[UIFont systemFontOfSize:size3]];
    [self.nextButton.titleLabel setFont:[UIFont systemFontOfSize:size3]];
    [self.skipButton.titleLabel setFont:[UIFont systemFontOfSize:size3]];
}

- (void)showScreen4 {
    Screen4ViewController *screen4VC = [self.storyboard instantiateViewControllerWithIdentifier:@"Screen4ViewController"];
    [self.navigationController pushViewController:screen4VC animated:YES];
}
@end
