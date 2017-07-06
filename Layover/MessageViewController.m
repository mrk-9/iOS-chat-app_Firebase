//
//  MessageViewController.m
//  Layovr
//
//  Created by Daniel Drescher on 07/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//  28, 14, 158

#import "MessageViewController.h"
#import "MessageDepartCell.h"
#import "PeerProfileViewController.h"
#import "ChatParentViewController.h"

@interface MessageViewController() <UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate>{
    NSMutableDictionary *contactDic;
    
    BOOL loading_1;// Check for loading
    BOOL loading_2;
}
@property (weak, nonatomic) IBOutlet UITableView *departureListTableView;

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_departureListTableView setBackgroundView:[UIView new]];
    [[_departureListTableView backgroundView] setBackgroundColor:[UIColor clearColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CurrentViewController" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, @"lastViewController", nil]];
    
    [self findPeers];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:ISSHOWED_MESSAGEVIEWCONTROLLER];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:ISSHOWED_MESSAGEVIEWCONTROLLER];
}

- (void)becomeActive: (NSNotification *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:ISSHOWED_MESSAGEVIEWCONTROLLER];
}

- (void)willResignActive: (NSNotification *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:ISSHOWED_MESSAGEVIEWCONTROLLER];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIButton Touch Event

- (void)avatarImageTouchUp:(UIButton *)sender {
    NSInteger ind = sender.tag;
    
    PeerProfileViewController *peerProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PeerProfileViewController"];
    
    [peerProfileVC setPeerInfo:[contactDic objectForKey:[[contactDic allKeys] objectAtIndex:ind]] withUID:[[contactDic allKeys] objectAtIndex:ind]];
    
    [self.navigationController pushViewController:peerProfileVC animated:YES];
}

#pragma mark - UITableView DataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [contactDic allKeys].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableDictionary *peerDic = [contactDic objectForKey:[[contactDic allKeys] objectAtIndex:indexPath.row]];
    
    MessageDepartCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageDepartCell"];
    [cell.nameLabel setText:[peerDic objectForKey:USERNAME]];
    [cell.jobLabel setText:[peerDic objectForKey:OCCUPATION]];
    [cell.avatarImageButton setTag:indexPath.row];
    
//    [cell.avatarImageButton addTarget:self action:@selector(avatarImageTouchUp:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.messageLabel setText:[peerDic objectForKey:LAST_MESSAGE]];
//    [cell.messageLabel setText:[NSString stringWithFormat:@"%@", [peerDic objectForKey:CURRENT_CITY]]];
    
    [cell.departStatusLabel setAttributedText:[self departureTimeForPeerWith:[peerDic objectForKey:DEPART_TIME]]];
//    [cell.avatarImageV setImage:[UIImage imageNamed:@"user.png"]];
    
    // Set Blur Level
    [cell setBlurLevelWithUID:[[contactDic allKeys] objectAtIndex:indexPath.row] withFlag:NO];
    
    if ([self hasNewMessagesInPeer:[[contactDic allKeys] objectAtIndex:indexPath.row]]) {
        [cell.contentView.layer setBorderWidth:2];
        [cell.contentView.layer setBorderColor:[UIColor redColor].CGColor];
    }else{
        [cell.contentView.layer setBorderColor:[UIColor clearColor].CGColor];
    }
    
    if ([peerDic objectForKey:PHOTO]) {// If the photo of the peer is existed
        NSString *filePath = [NSString stringWithFormat:@"%@/%@.png", DocumentDirectory, [[contactDic allKeys] objectAtIndex:indexPath.row]];
        
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self isDeparted:[[contactDic objectForKey:[[contactDic allKeys] objectAtIndex:indexPath.row]] objectForKey:DEPART_TIME]]) {
        [self showPopupAlertWithString:@"This peer was departed. Please try again later!" isError:NO textAlign:NSTextAlignmentCenter];
        return;
    }
    
    // Check Notifications, so if it has new messages, the specific notification will be deleted
    [self checkNotificationsWithIndex:indexPath.row];
    
    MessageDepartCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    ChatParentViewController *chatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatParentViewController"];
    [chatVC setOtherInfoWithUID:[[contactDic allKeys] objectAtIndex:indexPath.row] andDictionary:[contactDic objectForKey:[[contactDic allKeys] objectAtIndex:indexPath.row]] andImage:selectedCell.avatarImageV.image];
    [chatVC setBackButtonLabelWithText:@"< Messages"];
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    [view setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - SWTableViewCell Delegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:// Delete Peer
            NSLog(@"SWTableViewCell: Click the Delete Button...");
            NSInteger ind = [self.departureListTableView indexPathForCell:cell].row;
            [self addPeerToBlockList:ind];
            [self.departureListTableView reloadData];
            break;
            
        default:
            break;
    }
}

#pragma mark - Custom Method

//- (void)addObserverForContacts {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView:) name:UPDATEDCONTACTLIST_NOTIFICATION object:nil];
//}
//
//- (void)addObserverForNotifications {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView:) name:UPDATEDCONTACTLIST_NOTIFICATION object:nil];
//}

- (BOOL)isDeparted: (NSString *)intervalTime {
    // Get Time interval since 1970
    NSTimeInterval peerTime;
    if (intervalTime == nil || [intervalTime isEqualToString:EMPTY_STRING]) {
        peerTime = 0;
    }else{
        peerTime = [intervalTime doubleValue];
    }
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    NSInteger interval = (NSInteger)peerTime - (NSInteger)now;
    //--
    
    if (interval <= 0) {
        return YES;
    }
    
    return NO;
}

- (BOOL)hasNewMessagesInPeer: (NSString *)selectedUID {
    NSMutableDictionary *notifications = [[UserInfo sharedInstance] userNotifications];
    
    if (![notifications isEqual:[NSNull null]]) {
        for (id key in notifications) {
            if ([selectedUID isEqualToString:key]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)reloadTableView {
    [self.departureListTableView reloadData];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATEDNOTIFICATIONS_NOTIFICATION object:nil];
}

- (void)refreshTableView {
    [self findPeers];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATEDCONTACTLIST_NOTIFICATION object:nil];
}

- (void)checkNotificationsWithIndex: (NSInteger)ind {
    NSMutableDictionary *notifications = [[UserInfo sharedInstance] userNotifications];
    if (![notifications isEqual:[NSNull null]]) {
        for (id key in notifications) {
            if ([[[contactDic allKeys] objectAtIndex:ind] isEqualToString:key]) {
                [[[[[[FIRDatabase database] reference] child:NOTIFICATIONS_REF] child:[FIRAuth auth].currentUser.uid] child:key] removeValue];
                break;
            }
        }
    }
}

- (void)addPeerToBlockList: (NSInteger)ind {
    NSMutableDictionary *blockList = [[UserInfo sharedInstance] userBlockList];
    NSString *peerUID = [[contactDic allKeys] objectAtIndex:ind];
    
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
    
    [contactDic removeObjectForKey:peerUID];
    
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
    
    contactDic = [NSMutableDictionary new];
    
//    FIRDatabaseReference *contactRef = [[[[FIRDatabase database] reference] child:CONTACTS_REF] child:[FIRAuth auth].currentUser.uid];
    
    [ProgressHUD show:@"Loading..." Interaction:NO];
    
    __block NSInteger contactsNum = 0;
    
//    [contactRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSMutableDictionary *results = [[UserInfo sharedInstance] userContactList];
        
        if (![results isEqual:[NSNull null]]) {
            NSMutableDictionary *contactsList = [NSMutableDictionary new];
            [contactsList addEntriesFromDictionary:results];
            
            for (id key in contactsList) {
                NSMutableDictionary *peerDic = [contactsList objectForKey:key];
                if (![peerDic objectForKey:USERID]) {
                    continue;
                }
                [[[[[FIRDatabase database] reference] child:USERS_REF] child:[peerDic objectForKey:USERID]] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                    if (snapshot.value) {
                        NSDictionary *dic = snapshot.value;
                        [contactDic setObject:dic forKey:[peerDic objectForKey:USERID]];
                    }
                    contactsNum++;
                    if (contactsNum >= contactsList.allKeys.count) {
                        
                        [self.departureListTableView reloadData];
                        [ProgressHUD dismiss];
                    }
                }];
            }
            if ([contactsList allKeys].count == 0) {
                [ProgressHUD dismiss];
            }
        }else {
            
            [ProgressHUD dismiss];
        }
//    }];
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
                            dismissOnBackgroundTouch:NO
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


@end
