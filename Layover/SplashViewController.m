//
//  SplashViewController.m
//  Layovr
//
//  Created by Daniel Muller on 27/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "SplashViewController.h"
#import "AppDelegate.h"

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self performSelector:@selector(setRootViewController) withObject:nil afterDelay:3];
}

- (void)setRootViewController {
    AppDelegate *myDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [myDelegate setRootViewController];
}

@end
