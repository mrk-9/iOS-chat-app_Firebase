//
//  WifiViewController.m
//  Layovr
//
//  Created by Daniel Drescher on 06/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "WifiViewController.h"
#import "WifiCellBody.h"
#import "WifiCellHeader.h"
#import "SetDepartureViewController.h"
#import "PeerListViewController.h"

@interface WifiViewController() <UITableViewDelegate, UITableViewDataSource>{
    
}
@property (weak, nonatomic) IBOutlet UITableView *wifiListTableView;

@end

@implementation WifiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_wifiListTableView setBackgroundView:[UIView new]];
    [[_wifiListTableView backgroundView] setBackgroundColor:[UIColor clearColor]];
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

- (IBAction)checkInTouchUp:(UIButton *)sender {
    if ([self isValidDepartTime]) {
        [self showPeerListView];
    }else {
        [self showDepartureView];
    }
}

#pragma mark - UITableView DataSource and Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WifiCellBody *cell = [tableView dequeueReusableCellWithIdentifier:@"WifiCellBody"];
    cell.label.text = @"ATT64748330";
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    WifiCellHeader *cell = [tableView dequeueReusableCellWithIdentifier:@"WifiCellHeader"];
    [cell.label setText:@"Starbucks"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (UIApplicationOpenSettingsURLString != NULL) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];//@"prefs:root=WIFI"
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    [view setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - Custom Method

- (BOOL)isValidDepartTime {
    NSString *departTime = [[[UserInfo sharedInstance] userData] objectForKey:DEPART_TIME];
    if (departTime == nil) {
        return NO;
    }
    NSTimeInterval originInterval = [departTime doubleValue];
    NSTimeInterval currentInterval = [[NSDate date] timeIntervalSince1970];
    if (currentInterval >= originInterval) {
        return NO;
    }
    
    return YES;
}

- (void)showDepartureView {
    SetDepartureViewController *departureVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SetDepartureViewController"];
    [self presentViewController:departureVC animated:YES completion:nil];
}

- (void)showPeerListView {
    PeerListViewController *peerListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PeerListViewController"];
    [self.navigationController pushViewController:peerListVC animated:YES];
}

@end
