//
//  Screen2ViewController.m
//  Layovr
//
//  Created by Daniel Drescher on 03/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "Screen2ViewController.h"
#import "Screen3ViewController.h"

@interface Screen2ViewController() {
    
}

@end

@implementation Screen2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [self initUIControlsInView];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Init UIControls

- (void)initUIControlsInView {
    CGFloat w = [[UIScreen mainScreen] bounds].size.width;
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    
    [self.titleLabel setFrame:CGRectMake((w - h * 280 / 667) / 2, h * 54 / 667, h * 280 / 667, h * 64 / 667)];
//    NSLog(@"%f, %f, %f, %f", self.titleLabel.frame.size.width, self.titleLabel.frame.size.height, self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y);
//    NSLog(@"%f, %f", w, h);
}

#pragma mark - Continue Button Touch Up

- (IBAction)continueTouchUp:(UIButton *)sender {
    Screen3ViewController *screen3VC = [self.storyboard instantiateViewControllerWithIdentifier:@"Screen3ViewController"];
    [self.navigationController pushViewController:screen3VC animated:YES];
}

#pragma mark - Custom Method

- (void)setFontSizeForControls {
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    CGFloat size1 = h * 18 / 667;
    CGFloat size2 = h * 20 / 667;
    
    [self.titleLabel setFont:[UIFont systemFontOfSize:size1]];
    [self.descriptionLabel setFont:[UIFont systemFontOfSize:size1]];
    [self.continueButton.titleLabel setFont:[UIFont systemFontOfSize:size2]];
}

@end
