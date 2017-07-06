//
//  ChatParentViewController.m
//  Layovr
//
//  Created by Daniel Muller on 27/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "ChatParentViewController.h"
#import "ChatViewController.h"
#import "PeerProfileViewController.h"

@interface ChatParentViewController() {
    UIImage *peerAvatarImage;
    NSMutableDictionary *peerDic;
    NSString *peerUID;
    
    UIImageView *peerImageV;// Peer Avatar Image View
    FXBlurView *blurOverlayView;// For Peer Avatar Image View
    UILabel *peerLabel;
    
    UIButton *backButton;
    
    NSTimer *departTimer;// Monitoring the peer's depart time;(with me)
    NSInteger blurRadius;
    
    BOOL isDeparted;
    
    NSString *backString;
}

@end

@implementation ChatParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    blurRadius = 20;
    
    // Set backButton
    [self setBackButton];
    
    // Display the peer avatar image and other data in center-top of the View
    [self displayPeerInfo];
    isDeparted = NO;
    
    NSString *roomname = [Utils generateChatRoom:[FIRAuth auth].currentUser.uid second:peerUID];
    
    [[[[[FIRDatabase database] reference] child:MESSAGES_REF] child:roomname] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        JSQMessage *msg = [[JSQMessage alloc] initWithSenderId:snapshot.value[@"user1"]
                                             senderDisplayName:snapshot.value[@"user2"]
                                                          date:[Utils dateFromString:snapshot.value[@"date"] format:@"yyyy-MM-dd HH:mm:ss" timezone:@"UTC"]
                                                          text:snapshot.value[@"message"]];
        
        if (![[FIRAuth auth].currentUser.uid isEqualToString:msg.senderId] ) {
            blurRadius -= 5;
            if (blurRadius < 0) {
                blurRadius = 0;
            }
            
            [self setBlurTagWithIndex:(blurRadius / 5)];// Set Blur Level
            
            if (blurOverlayView) {
                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [blurOverlayView setBlurRadius:blurRadius];
                } completion:^(BOOL finished) {
                    if (blurRadius == 0) {
                        [blurOverlayView removeFromSuperview];
                    }
                }];
            }
        }
    }];
    
    [backButton setTitle:backString forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    departTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkDepartTime) userInfo:nil repeats:YES];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:ISSHOWED_CHATVIEWCONTROLLER];
    [[NSUserDefaults standardUserDefaults] setObject:peerUID forKey:CHAT_PEERUID];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:ISSHOWED_CHATVIEWCONTROLLER];
    [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:CHAT_PEERUID];
}

- (void)becomeActive: (NSNotification *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:ISSHOWED_CHATVIEWCONTROLLER];
    [[NSUserDefaults standardUserDefaults] setObject:peerUID forKey:CHAT_PEERUID];
}

- (void)willResignActive: (NSNotification *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:ISSHOWED_CHATVIEWCONTROLLER];
    [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:CHAT_PEERUID];
}

#pragma mark - UIButton Touch Up

- (void)backTouchUp: (UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Custom Method

- (void)setOtherInfoWithUID: (NSString *)uid andDictionary: (NSDictionary *)otherDic andImage: (UIImage *)image {
    peerAvatarImage = image;
    peerUID = uid;
    peerDic = [otherDic mutableCopy];
}

- (void)setBlurTagWithIndex: (NSInteger)ind {
    BlurTag blurTag;
    
    switch (ind) {
        case 0:
            blurTag = BlurLevel1;
            break;
        case 1:
            blurTag = BlurLevel2;
            break;
        case 2:
            blurTag = BlurLevel3;
            break;
        case 3:
            blurTag = BlurLevel4;
            break;
        case 4:
            blurTag = BlurLevel5;
            break;
            
        default:
            blurTag = BlurLevel5;
            break;
    }
    
    if ([self getPeerKeyInContactList]) {
        [[[[[[[FIRDatabase database] reference] child:CONTACTS_REF] child:[FIRAuth auth].currentUser.uid] child:[self getPeerKeyInContactList]] child:STATUS] setValue:[NSNumber numberWithInteger:blurTag]];
    }
}

- (NSString *)getPeerKeyInContactList {
    NSString *peerKey;
    for (id key in [[UserInfo sharedInstance] userContactList]) {
        NSMutableDictionary *itemDic = [[[UserInfo sharedInstance] userContactList] objectForKey:key];
        if ([[itemDic objectForKey:USERID] isEqualToString:peerUID]) {
            peerKey = key;
            break;
        }
    }
    
    return peerKey;
}

- (void)checkDepartTime {
    [peerLabel setAttributedText:[self departureTimeForPeerWith:peerDic[DEPART_TIME]]];
    
    if (isDeparted) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setBackButton {
    CGFloat w = [[UIScreen mainScreen] bounds].size.width;
    
    backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 8, w / 4, w / 8)];
    [backButton addTarget:self action:@selector(backTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:w / 25]];
    
    [self.view addSubview:backButton];
}

- (void)setBackButtonLabelWithText: (NSString *)text {
    backString = text;
}

- (void)displayPeerInfo {
    CGFloat w = [[UIScreen mainScreen] bounds].size.width;
//    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    
    // Avatar Image View
    peerImageV = [[UIImageView alloc] initWithFrame:CGRectMake(w * 3 / 8, 20, w / 4, w / 4)];
    [peerImageV.layer setBorderColor:[UIColor whiteColor].CGColor];
    [peerImageV.layer setBorderWidth:2];
    [peerImageV.layer setCornerRadius:10];
    [peerImageV setClipsToBounds:YES];
    [peerImageV setImage:peerAvatarImage];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAvatarImage:)];
    [peerImageV addGestureRecognizer:tapGesture];
    [peerImageV setUserInteractionEnabled:YES];
    
    // Set Blur Overlay View
    blurOverlayView = [[FXBlurView alloc] initWithFrame:CGRectMake(0, 0, w, w)];
    [blurOverlayView setBackgroundColor:[UIColor whiteColor]];
    [blurOverlayView setBlurRadius:blurRadius];
    
    [peerImageV addSubview:blurOverlayView];
    
    // Username and Departing Time
    peerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20 + w / 4, w, w / 6)];
    [peerLabel setTextAlignment:NSTextAlignmentCenter];
    [peerLabel setFont:[UIFont systemFontOfSize:w / 20]];
    [peerLabel setNumberOfLines:2];
    
    [peerLabel setAttributedText:[self departureTimeForPeerWith:peerDic[DEPART_TIME]]];
    
    [self.view addSubview:peerImageV];
    [self.view addSubview:peerLabel];
    
    // Show chat view controller
    [self showChatView];
}

- (void)showChatView {
    CGFloat topPadding = peerLabel.frame.origin.y + peerLabel.frame.size.height;
    NSNumber *rootTopHeight = [[NSUserDefaults standardUserDefaults] objectForKey:TOPBAR_HEIGHT];
    
    ChatViewController *chatVC = [ChatViewController messagesViewController];
    chatVC.hidesBottomBarWhenPushed = YES;
    //    chatVC.secondUser = roomsMutDict.allValues[indexPath.row][@"secondUser"];
    [chatVC setOtherInfoWithUID:peerUID andDictionary:peerDic andImage:peerAvatarImage];
    [chatVC.view setFrame:CGRectMake(0, topPadding, [[UIScreen mainScreen] bounds].size.width, self.view.frame.size.height - (topPadding + [rootTopHeight floatValue] + 30))];
    [chatVC.view setBackgroundColor:[UIColor clearColor]];
    [self addChildViewController:chatVC];
    [chatVC didMoveToParentViewController:self];
    [self.view addSubview:chatVC.view];
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
    
    //--
    departText = [NSString stringWithFormat:@"%@\n", peerDic[USERNAME]];
    
    UIColor *departColor;
    UIColor *timeColor;
    if (interval <= 0) {
        departColor = [UIColor redColor];
        departText = [NSString stringWithFormat:@"%@Departed", departText];
        timeColor = [UIColor clearColor];
        timeText = @"";
        isDeparted = YES;
    }else{
        departColor = [UIColor whiteColor];
        departText = [NSString stringWithFormat:@"%@Departing in ", departText];
        
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

// Tap the avatar Image

- (void)tapAvatarImage: (UITapGestureRecognizer *)sender {
    if ([backButton.titleLabel.text isEqualToString:@"< Peer Profile"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        PeerProfileViewController *peerProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PeerProfileViewController"];
        
        [peerProfileVC setPeerInfo:peerDic withUID:peerUID];
        
        [peerProfileVC setTextForBackButton:@"< back"];
        
        [self.navigationController pushViewController:peerProfileVC animated:YES];
    }
}

@end
