//
//  RootViewController.m
//  Layovr
//
//  Created by Daniel Drescher on 06/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "RootViewController.h"
#import <CoreLocation/CoreLocation.h>

#define TOPVIEW_TAG 1
#define BGIMAGE_TAG 2
#define SEPERATE_TAG 3

#define MESSAGE_NEW_TAG 100
#define MESSAGE_INACTIVE_TAG 101

@interface RootViewController() <CLLocationManagerDelegate>{
    UINavigationController *naviNetVC;
    UINavigationController *naviProfileVC;
    UINavigationController *naviMessageVC;
    
    NSTimer *myTimer; // Monitering whether the data is downloaded or not
    
    CLLocationManager *locationManager;
    
    BOOL isMessageClicked;
}

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [locationManager requestAlwaysAuthorization];
        }
        
        locationManager.distanceFilter = 1;
        
        [locationManager startUpdatingLocation];
    }else{
        NSLog(@"Location services are not enabled!");
    }
    
    self.topViewTopConstraint.constant = [[UIApplication sharedApplication] statusBarFrame].size.height;
    [self.seperateV layoutIfNeeded];
    // Set the specific tag for Original SubViews
    [self.topV setTag:TOPVIEW_TAG];
    [self.seperateV setTag:SEPERATE_TAG];
    [self.bgImageV setTag:BGIMAGE_TAG];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:ISDOWNLOADED_USERDATA] == [NSNumber numberWithBool:YES]) {
        if (_isFromCameraView) {
            [self.netImageV setImage:[UIImage imageNamed:@"network_inactive.png"]];
            [self.profileImageV setImage:[UIImage imageNamed:@"profile_clicked.png"]];
            [self.messageImageV setImage:[UIImage imageNamed:@"mess_inactive.png"]];
            
            [self showProfileView];
        }else{
            [self.netImageV setImage:[UIImage imageNamed:@"network_clicked.png"]];
            [self.profileImageV setImage:[UIImage imageNamed:@"profile_inactive.png"]];
            [self.messageImageV setImage:[UIImage imageNamed:@"mess_inactive.png"]];
            
            [self showNetView];
        }
    }else {
        myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkDownloadStatus) userInfo:nil repeats:YES];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[FIRMessaging messaging] subscribeToTopic:@"/topics/news"];
    
//    [self setBadgeNumberInMessage];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([myTimer isValid]) {
        [myTimer invalidate];
    }
    myTimer = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSNumber *isDownloaded = [[NSUserDefaults standardUserDefaults] objectForKey:ISDOWNLOADED_USERDATA];
    
    if ([isDownloaded isEqualToNumber:[NSNumber numberWithBool:NO]]) {
        [ProgressHUD show:@"Downloading..." Interaction:NO];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.topV.frame.size.height] forKey:TOPBAR_HEIGHT];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
//    self.topViewTopConstraint.constant = 50;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIButton Touch Up

- (IBAction)netButtonTouchUp:(UIButton *)sender {
    
    // --
    if (![[NSUserDefaults standardUserDefaults] objectForKey:MESSAGE_ID]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:1] forKey:MESSAGE_ID];
    }
    NSInteger messageID = [[[NSUserDefaults standardUserDefaults] objectForKey:MESSAGE_ID] integerValue];
    
    [[FIRMessaging messaging] sendMessage:@{@"key1":@"Eezy",@"key2": @"Tutorials"}
                                    to:[NSString stringWithFormat:@"%@@gcm.googleapis.com", SENDER_ID]
                         withMessageID:[NSString stringWithFormat:@"%ld", (long)messageID]
                            timeToLive:30];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:(messageID + 1)] forKey:MESSAGE_ID];
    // --
    
    [self.netImageV setImage:[UIImage imageNamed:@"network_clicked.png"]];
    [self.profileImageV setImage:[UIImage imageNamed:@"profile_inactive.png"]];
    
    if (self.messageImageV.tag != MESSAGE_NEW_TAG) {
        [self.messageImageV setImage:[UIImage imageNamed:@"mess_inactive.png"]];
        [self.messageImageV setTag:MESSAGE_INACTIVE_TAG];
    }
    
    [self showNetView];
}

- (IBAction)profileButtonTouchUp:(UIButton *)sender {
    [self.netImageV setImage:[UIImage imageNamed:@"network_inactive.png"]];
    [self.profileImageV setImage:[UIImage imageNamed:@"profile_clicked.png"]];
    
    if (self.messageImageV.tag != MESSAGE_NEW_TAG) {
        [self.messageImageV setImage:[UIImage imageNamed:@"mess_inactive.png"]];
        [self.messageImageV setTag:MESSAGE_INACTIVE_TAG];
    }
    
    [self showProfileView];
}

- (IBAction)messageButtonTouchUp:(UIButton *)sender {
    [self.netImageV setImage:[UIImage imageNamed:@"network_inactive.png"]];
    [self.profileImageV setImage:[UIImage imageNamed:@"profile_inactive.png"]];
    
    if (self.messageImageV.tag != MESSAGE_NEW_TAG) {
        [self.messageImageV setImage:[UIImage imageNamed:@"mess_clicked.png"]];
        [self.messageImageV setTag:MESSAGE_INACTIVE_TAG];
    }
    
    [self showMessageView];
}

#pragma mark - Navigate Wifi, Profile, Message Views

- (void)removeSubViews {
    for (UIView *subV in self.view.subviews) {
        if (subV.tag != TOPVIEW_TAG && subV.tag != SEPERATE_TAG && subV.tag != BGIMAGE_TAG) {
            [subV removeFromSuperview];
        }
    }
}

- (void)showNetView {
    isMessageClicked = NO;
    
    [self removeSubViews];
    
    if (naviNetVC == nil) {
        CGFloat top = self.seperateV.frame.origin.y + self.seperateV.frame.size.height;
        
        naviNetVC = [self.storyboard instantiateViewControllerWithIdentifier:@"naviPeerListViewController"];//NaviNetViewController
        [naviNetVC.view setFrame:CGRectMake(0, top, self.view.frame.size.width, self.view.frame.size.height - top)];
        [self addChildViewController:naviNetVC];
        [naviNetVC didMoveToParentViewController:self];
    }
    [self.view addSubview:naviNetVC.view];
}

- (void)showProfileView {
    isMessageClicked = NO;
    
    [self removeSubViews];
    
    if (naviProfileVC == nil) {
        CGFloat top = self.seperateV.frame.origin.y + self.seperateV.frame.size.height;
        
        naviProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NaviProfileViewController"];
        [naviProfileVC.view setFrame:CGRectMake(0, top, self.view.frame.size.width, self.view.frame.size.height - top)];
        [self addChildViewController:naviProfileVC];
        [naviProfileVC didMoveToParentViewController:self];
    }
    [self.view addSubview:naviProfileVC.view];
}

- (void)showMessageView {
    isMessageClicked = YES;
    
    [self removeSubViews];
    
    if (naviMessageVC == nil) {
        CGFloat top = self.seperateV.frame.origin.y + self.seperateV.frame.size.height;
        
        naviMessageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NaviMessageViewController"];
        [naviMessageVC.view setFrame:CGRectMake(0, top, self.view.frame.size.width, self.view.frame.size.height - top)];
        [self addChildViewController:naviMessageVC];
        [naviMessageVC didMoveToParentViewController:self];
    }
    [self.view addSubview:naviMessageVC.view];
}

#pragma mark - Custom Method

- (void)checkDownloadStatus {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:ISDOWNLOADED_USERDATA] == [NSNumber numberWithBool:YES]) {
        
        [self.netImageV setImage:[UIImage imageNamed:@"network_clicked.png"]];
        [self.profileImageV setImage:[UIImage imageNamed:@"profile_inactive.png"]];
        if (self.messageImageV.tag != MESSAGE_NEW_TAG) {
            [self.messageImageV setImage:[UIImage imageNamed:@"mess_inactive.png"]];
            [self.messageImageV setTag:MESSAGE_INACTIVE_TAG];
        }
        
        [self showNetView];
        
        if ([myTimer isValid]) {
            [myTimer invalidate];
        }
        myTimer = nil;
    }
}

- (void)setBadgeNumberInMessage: (NSInteger)count {
    if (count > 0) {
        NSString *badgeString = [NSString stringWithFormat:@"%ld", (long)count];
        
        [self.messageButton setBadgeString:badgeString];
        [self.messageButton setBadgeEdgeInsets:UIEdgeInsetsMake(18, 5, 0, 8)];
        [self.messageButton setBadgeTextColor:[UIColor redColor]];
        [self.messageButton setBadgeBackgroundColor:[UIColor whiteColor]];
        
        [self.messageImageV setImage:[UIImage imageNamed:@"mess_new.png"]];
        [self.messageImageV setTag:MESSAGE_NEW_TAG];
    }else{
        [self.messageButton setBadgeString:nil];
        
        if (isMessageClicked) {
            [self.messageImageV setImage:[UIImage imageNamed:@"mess_clicked.png"]];
        }else{
            [self.messageImageV setImage:[UIImage imageNamed:@"mess_inactive.png"]];
        }
        [self.messageImageV setTag:MESSAGE_INACTIVE_TAG];
    }
}

#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Failed to Get the Current Location!");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    NSLog(@"Location updated...");
    
    CLLocation *location = [locations lastObject];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:LATITUDE];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:LONGITUDE];
    
    [[[UserInfo sharedInstance] userData] setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:LATITUDE];
    [[[UserInfo sharedInstance] userData] setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:LONGITUDE];
    
    [[[[[[FIRDatabase database] reference] child:USERS_REF] child:[FIRAuth auth].currentUser.uid] child:LATITUDE] setValue:[NSNumber numberWithDouble:location.coordinate.latitude]];    
    [[[[[[FIRDatabase database] reference] child:USERS_REF] child:[FIRAuth auth].currentUser.uid] child:LONGITUDE] setValue:[NSNumber numberWithDouble:location.coordinate.longitude]];
}

@end
