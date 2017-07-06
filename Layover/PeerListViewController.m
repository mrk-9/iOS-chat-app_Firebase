//
//  PeerListViewController.m
//  Layovr
//
//  Created by Daniel Muller on 22/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "PeerListViewController.h"
#import "MessageDepartCell.h"
#import "PeerProfileViewController.h"
#import "UpdateDepartureViewController.h"


@interface PeerListViewController() <UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate> {
    NSMutableDictionary *peersDic;
    
    BOOL loading_1;// Check for loading
    BOOL loading_2;
    
    NSTimer *departTimer;
    
    FIRDatabaseHandle findPeersHandle;
}

@end

@implementation PeerListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setFontSizeForControls];
    peersDic = [NSMutableDictionary new];

    if (departTimer == nil) {
        departTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkingDepart) userInfo:nil repeats:YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)becomeActive: (NSNotification *)sender {
    if (departTimer != nil) {
        [departTimer invalidate];
        departTimer = nil;
    }
    departTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkingDepart) userInfo:nil repeats:YES];
}

- (void)willResignActive: (NSNotification *)sender {
    if (departTimer != nil) {
        [departTimer invalidate];
        departTimer = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self isDeparted] == NO) {
        [self findPeers];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:ISFIRSTLAUNCHED]) {
        [self showPopupAlertWithString:@"Users are veiled until you start chatting. Each time you message someone you reveal a little more of your photo.\nSimilarly the person you message won't become clearer until they respond." isError:NO textAlign:NSTextAlignmentCenter];
        
        [[NSUserDefaults standardUserDefaults] setObject:ISFIRSTLAUNCHED forKey:ISFIRSTLAUNCHED];
    }
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Custom Event

- (IBAction)networkTouchUp:(UIButton *)sender {// Refresh
//    if (UIApplicationOpenSettingsURLString != NULL) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];//@"prefs:root=WIFI"
//    }
    [self findPeers];
}

- (IBAction)departTouchUp:(UIButton *)sender {
    UpdateDepartureViewController *updateDepartureVC = [self.storyboard instantiateViewControllerWithIdentifier:@"UpdateDepartureViewController"];
    [self.navigationController pushViewController:updateDepartureVC animated:YES];
}

#pragma mark - UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [peersDic allKeys].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableDictionary *peerDic = [peersDic objectForKey:[[peersDic allKeys] objectAtIndex:indexPath.row]];
    
    MessageDepartCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageDepartCell" forIndexPath:indexPath];
    [cell.nameLabel setText:[peerDic objectForKey:USERNAME]];
    [cell.jobLabel setText:[peerDic objectForKey:OCCUPATION]];
    [cell.messageLabel setText:[NSString stringWithFormat:@"%@", [peerDic objectForKey:CURRENT_CITY]]];
//    NSLog(@"Current City: %@", [peerDic objectForKey:CURRENT_CITY]);
    
    [cell.departStatusLabel setAttributedText:[self departureTimeForPeerWith:[peerDic objectForKey:DEPART_TIME]]];
    
    // Set Blur Level
    [cell setBlurLevelWithUID:[[peersDic allKeys] objectAtIndex:indexPath.row] withFlag:YES];

    if ([peerDic objectForKey:PHOTO]) {// If the photo of the peer is existed
        NSString *filePath = [NSString stringWithFormat:@"%@/%@.png", DocumentDirectory, [[peersDic allKeys] objectAtIndex:indexPath.row]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [cell.avatarImageV setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]]];
            [cell.avatarImageV setTag:1];
        }else{
        
            [[[FIRStorage storage] referenceForURL:[peerDic objectForKey:PHOTO]] writeToFile:[NSURL URLWithString:[NSString stringWithFormat:@"file:%@", filePath]] completion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
        //            [self.peerListTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [cell.avatarImageV setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]]];
                [cell.avatarImageV setTag:1];
            }];
        }
    }
    
    //Add Block Button
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor clearColor] icon:[UIImage imageNamed:@"delete_user_cell.png"]];
    cell.leftUtilityButtons = leftUtilityButtons;
    cell.delegate = self;
    
    // Set background color
    if (indexPath.row % 2 == 0) {
        [cell.contentView setBackgroundColor:[UIColor colorWithRed:28 / 255.0f green:14 / 255.0f blue:158 / 255.0f alpha:1]];
    }else{
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PeerProfileViewController *peerProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PeerProfileViewController"];
    
    [peerProfileVC setPeerInfo:[peersDic objectForKey:[[peersDic allKeys] objectAtIndex:indexPath.row]] withUID:[[peersDic allKeys] objectAtIndex:indexPath.row]];
    
    [peerProfileVC setTextForBackButton:@"< Peers"];
    
    [self.navigationController pushViewController:peerProfileVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor clearColor]];
    
//    NSString *filePath = [NSString stringWithFormat:@"%@/%@.png", DocumentDirectory, [[peersDic allKeys] objectAtIndex:indexPath.row]];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
//        MessageDepartCell *peerCell = (MessageDepartCell *)cell;
//        [peerCell.avatarImageV setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]]];
//        [peerCell.avatarImageV setTag:1];
//    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    [view setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - SWTableViewCell Delegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:// Delete Peer
            NSLog(@"SWTableViewCell: Click the Delete Button...");
            NSInteger ind = [self.peerListTableView indexPathForCell:cell].row;
            [self addPeerToBlockList:ind];
            [self.peerListTableView reloadData];
            break;
            
        default:
            break;
    }
}

#pragma mark - Custom Method

- (void)checkingDepart {
    if ([self isDeparted]) {
        [[[[FIRDatabase database] reference] child:USERS_REF] removeObserverWithHandle:findPeersHandle];
        peersDic = [NSMutableDictionary new];
        [self.peerListTableView reloadData];
    }else{
//        [self findPeers];
    }
}

- (void)addPeerToBlockList: (NSInteger)ind {
    NSMutableDictionary *blockList = [[UserInfo sharedInstance] userBlockList];
    NSString *peerUID = [[peersDic allKeys] objectAtIndex:ind];
    
    BOOL isExisted = NO;
    if (![blockList isEqual:[NSNull null]]) {
        for (id key in blockList) {
            NSMutableDictionary *itemDic = [blockList objectForKey:key];
            if ([[itemDic objectForKey:USERID] isEqualToString:peerUID]) {
                isExisted = YES;
            }
        }
    }
    
    if (!isExisted) {// not existed
        // Add to contact list
        NSDictionary *dict = @{USERID : peerUID//[PFUser currentUser].objectId,
                               };
        [[[[[[FIRDatabase database] reference] child:BLOCKLIST_REF] child:[FIRAuth auth].currentUser.uid] childByAutoId] setValue:dict];
    }
    
    [peersDic removeObjectForKey:peerUID];
    
    // Remove peer from contact list
    NSMutableDictionary *contactList = [[UserInfo sharedInstance] userContactList];
    for (id key in contactList) {
        NSMutableDictionary *itemDic = [contactList objectForKey:key];
        if ([[itemDic objectForKey:USERID] isEqualToString:peerUID]) {
            [[[[[[FIRDatabase database] reference] child:CONTACTS_REF] child:[FIRAuth auth].currentUser.uid] child:key] removeValue];
        }
    }
    
    //--
}

- (BOOL)image: (UIImage *)image1 isEqualTo: (UIImage *)image2 {
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    
    return [data1 isEqual:data2];
}

- (void)showPopupAlertWithString: (NSString *)msg isError: (BOOL)isError textAlign: (NSTextAlignment)align{
    
    [self.view endEditing:YES];
    
    UIView *labelV = [MyAlert alertLabel:msg isError:isError textAlign:align];
    UIButton *ok = [MyAlert alertButton:labelV];
    [ok addTarget:self action:@selector(dismissButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIView *contentView = [MyAlert alertView:labelV withButton:ok];
    
    // Show in popup
    KLCPopupLayout layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,
                                               KLCPopupVerticalLayoutCenter);
    
    KLCPopup* popup = [KLCPopup popupWithContentView:contentView
                                            showType:KLCPopupShowTypeSlideInFromTop
                                         dismissType:KLCPopupDismissTypeSlideOutToBottom
                                            maskType:KLCPopupMaskTypeDimmed
                            dismissOnBackgroundTouch:YES
                               dismissOnContentTouch:NO];
    
    //    if (_shouldDismissAfterDelay) {
    //        [popup showWithLayout:layout duration:2.0];
    //    } else {
    [popup showWithLayout:layout];
    //    }
}

- (void)dismissButtonPressed:(id)sender {
    if ([sender isKindOfClass:[UIView class]]) {
        [(UIView*)sender dismissPresentingPopup];
    }
}

- (NSMutableAttributedString *)departureTimeForPeerWith: (NSString *)intervalTime {
    // Get Time interval since 1970
    NSTimeInterval peerTime;
    if (intervalTime == nil || [intervalTime isEqualToString:EMPTY_STRING]) {
        peerTime = 0;
    }else{
        peerTime = [intervalTime doubleValue];
    }
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    NSInteger interval = (NSInteger)peerTime - (NSInteger)now;
    
    NSString *departText;
    NSString *timeText;
    
    UIColor *departColor;
    UIColor *timeColor;
    if (interval <= 0) {
        departColor = [UIColor redColor];
        departText = @"Departed\n";
        timeColor = [UIColor clearColor];
        timeText = @"";
    }else{
        departColor = [UIColor whiteColor];
        departText = @"Departing in\n";
        
        interval = interval / 60; // Get the time with Miniute
        if (interval < 15) { // less than 15 mins
            
            timeColor = [UIColor redColor];
            timeText = [NSString stringWithFormat:@"%ld miuntes", (long)interval];
        }else if (interval <= 60) {// less than 1 hr
            
            timeColor = [UIColor yellowColor];
            if (interval == 60) {
                timeText = [NSString stringWithFormat:@"1 hour"];
            }else {
                if (interval == 1) {
                    timeText = [NSString stringWithFormat:@"%ld miunte", (long)interval];
                }else {
                    timeText = [NSString stringWithFormat:@"%ld miuntes", (long)interval];
                }
            }
        }else {// Greater than 1 hr
            
            timeColor = [UIColor greenColor];
            NSInteger m = interval % 60;
            NSInteger h = interval / 60;
            if (h == 1) {
                timeText = [NSString stringWithFormat:@"%ld hour", (long)h];
            }else {
                timeText = [NSString stringWithFormat:@"%ld hours", (long)h];
            }
            if (m == 1) {
                timeText = [NSString stringWithFormat:@"%@ %ld minute", timeText, (long)m];
            }else if (m != 0) {
                timeText = [NSString stringWithFormat:@"%@ %ld minutes", timeText, (long)m];
            }
        }
            
    }
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] init];
    NSDictionary *attDepart = @{NSForegroundColorAttributeName : departColor};
    NSDictionary *attTime = @{NSForegroundColorAttributeName : timeColor};
    NSAttributedString *departStr = [[NSAttributedString alloc] initWithString:departText attributes:attDepart];
    NSAttributedString *timeStr = [[NSAttributedString alloc] initWithString:timeText attributes:attTime];
    [attStr appendAttributedString:departStr];
    [attStr appendAttributedString:timeStr];
    
    return attStr;
}

- (void)findPeers {
    
    FIRDatabaseReference *usersRef = [[[FIRDatabase database] reference] child:USERS_REF];
    
    [ProgressHUD show:@"Loading..." Interaction:NO];
    
    findPeersHandle = [usersRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSMutableDictionary *results = snapshot.value;
        
        if (![results isEqual:[NSNull null]]) {
            [peersDic addEntriesFromDictionary:results];
    
            if ([FIRAuth auth].currentUser) {
                [peersDic removeObjectForKey:[FIRAuth auth].currentUser.uid];
            }else{
                [usersRef removeObserverWithHandle:findPeersHandle];
            }
            
            // Remove the block peers from Current Users
            [self removeBlockedPeers];
            
            // Filter the peers with distance (meter)
            [self filterPeersWithDistance:1000.0];
            
            [self.peerListTableView reloadData];
        }
        loading_1 = YES;
        loading_2 = YES;
        [ProgressHUD dismiss];
    }];
    
}

- (void)setFontSizeForControls {
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    CGFloat size1 = h * 17 / 667;
//    CGFloat size2 = h * 20 / 667;
    
    [self.networkButton.titleLabel setFont:[UIFont systemFontOfSize:size1]];
    [self.departureButton.titleLabel setFont:[UIFont systemFontOfSize:size1]];
}

- (void)removeBlockedPeers {
    for (id key in [[UserInfo sharedInstance] userBlockList]) {
        [peersDic removeObjectForKey:[[[[UserInfo sharedInstance] userBlockList] objectForKey:key] objectForKey:USERID]];
    }
}

- (void)filterPeersWithDistance: (double)filterDistance {
    double myLong;
    double myLati;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:LONGITUDE]) {
        myLong = [[[NSUserDefaults standardUserDefaults] objectForKey:LONGITUDE] doubleValue];
    }else{
        myLong = 0;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:LATITUDE]) {
        myLati = [[[NSUserDefaults standardUserDefaults] objectForKey:LATITUDE] doubleValue];
    }else{
        myLati = 0;
    }
    
    double peerLong = 0;
    double peerLati = 0;
    
    for (id key in [peersDic allKeys]) {
        NSMutableDictionary *peerDic = [peersDic objectForKey:key];
        if ([peerDic objectForKey:LONGITUDE]) {
            peerLong = [[peerDic objectForKey:LONGITUDE] doubleValue];
        }else{
            peerLong = 0;
        }
        
        if ([peerDic objectForKey:LATITUDE]) {
            peerLati = [[peerDic objectForKey:LATITUDE] doubleValue];
        }else{
            peerLati = 0;
        }
        
        // Calculate the distance between me and peer
        if (filterDistance < [self getDistanceFromLatitude1:myLati longitude1:myLong latitude2:peerLati longitude2:peerLong]) {
            [peersDic removeObjectForKey:key];
        }
    }
}

- (double)getDistanceFromLatitude1: (double)lat1 longitude1: (double)lon1 latitude2: (double)lat2 longitude2: (double)lon2 {
    double d;
    double R = 6371000.0;// Earth Radius
    double dLat = (lat1 - lat2) * M_PI / 180.0;
    double dLon = (lon1 - lon2) * M_PI / 180.0;
    double a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1 * M_PI / 180.0) * cos(lat2 * M_PI / 180.0) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    d = R * c;
    return d;
 }

- (BOOL)isDeparted {
    NSString *myDepart = [[[UserInfo sharedInstance] userData] objectForKey:DEPART_TIME];
    NSTimeInterval myTime;
    if (myDepart == nil || [myDepart isEqualToString:EMPTY_STRING]) {
        myTime = 0;
    }else{
        myTime = [myDepart doubleValue];
    }
    
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    
    NSInteger interval = (NSInteger)myTime - (NSInteger)nowTime;
    
    if (interval <= 0) {
        return YES;
    }
    
    return NO;
}

@end
