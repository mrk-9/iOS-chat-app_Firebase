//
//  PeerProfileViewController.m
//  Layovr
//
//  Created by Daniel Drescher on 07/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "PeerProfileViewController.h"
#import "ChatViewController.h"
#import "ChatParentViewController.h"

@interface PeerProfileViewController() {
    NSMutableDictionary *peerDic;
    NSString *peerUID;
    
    NSString *backString;
    
    BOOL isExistedPhoto;
}

@end

@implementation PeerProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setFontSizeForControls];
    
    [self.peerProfileImageV.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.peerProfileImageV.layer setBorderWidth:2];
    [self.peerProfileImageV.layer setCornerRadius:10];
    [self.peerProfileImageV setClipsToBounds:YES];
    [self.peerProfileImageV setImage:[UIImage imageNamed:@"user.png"]];
    
    [self.peerNameLabel setText:@""];
    [self.peerJobLabel setText:@""];
    [self.peerLocationLabel setText:@""];
    
    [self.peerDepartTimeLabel setText:@""];
    
    [self.messageButton.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [self.messageButton.layer setBorderWidth:1];
    [self.messageButton.layer setCornerRadius:5];
    
    [self.contactButton setTitle:backString forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setBlurForImageView];
    
    [self displayPeerInfo];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
//    [self.contactButton.titleLabel setText:backString];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIButton Touch Up

- (IBAction)contactTouchUp:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)messageTouchUp:(UIButton *)sender {
    if (peerUID == nil) {
        NSLog(@"There is no peer uid in PeerProfileViewController");
    }
    
    // Check my avatar image
    if ([FIRAuth auth].currentUser.photoURL == nil || [[FIRAuth auth].currentUser.photoURL.absoluteString isEqualToString:EMPTY_STRING]) {
        [self showPopupAlertWithString:@"Please set your avatar image in Profile page! You will not able to message(or be messaged!) until you add one." isError:NO textAlign:NSTextAlignmentCenter];
        return;
    }
    
    // Check my depart time
    if ([self isValidDepartTimeForMe] == NO) {
        [self showPopupAlertWithString:@"Please update your depart time!" isError:NO textAlign:NSTextAlignmentCenter];
        return;
    }
    
    // Check the peer's avatar image
    if (isExistedPhoto == NO) {
        [self showPopupAlertWithString:@"There is no the profile image of the specific peer. Please try with another one!" isError:NO textAlign:NSTextAlignmentCenter];
        return;
    }
    
    // Check the peer's depart time
    if ([self isValidDepartTimeForPeer] == NO) {
        [self showPopupAlertWithString:@"Currently, this peer was departed. Please try again later!" isError:NO textAlign:NSTextAlignmentCenter];
        return;
    }
    
    [self addPeerToContactList];
    
    // Show the chat view Controller
//    ChatViewController *chatVC = [ChatViewController messagesViewController];
//    chatVC.hidesBottomBarWhenPushed = YES;
////    chatVC.secondUser = roomsMutDict.allValues[indexPath.row][@"secondUser"];
//    [chatVC setOtherInfoWithUID:peerUID andDictionary:peerDic andImage:self.peerProfileImageV.image];
    
    ChatParentViewController *chatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatParentViewController"];
    [chatVC setOtherInfoWithUID:peerUID andDictionary:peerDic andImage:self.peerProfileImageV.image];
    [chatVC setBackButtonLabelWithText:@"< Peer Profile"];
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (IBAction)blockTouchUp:(UIButton *)sender {
    [self showPopupAlertWithString];// Check the Block Or Report
}

#pragma mark - Custom Method

- (void)setTextForBackButton: (NSString *)text {
    backString = text;
}

- (void)addPeerToContactList {
    NSMutableDictionary *contactList = [[UserInfo sharedInstance] userContactList];
    if (![contactList isEqual:[NSNull null]]) {
        BOOL isExisted = NO;
        for (id key in contactList) {
            NSMutableDictionary *itemDic = [contactList objectForKey:key];
            if ([[itemDic objectForKey:USERID] isEqualToString:peerUID]) {
                isExisted = YES;
            }
        }
        
        if (!isExisted) {
            // Add to contact list
            NSDictionary *dict = @{USERID : peerUID//[PFUser currentUser].objectId,
                                   };
            [[[[[[FIRDatabase database] reference] child:CONTACTS_REF] child:[FIRAuth auth].currentUser.uid] childByAutoId] setValue:dict];
        }
    }
}

- (void)setFontSizeForControls {
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    CGFloat size1 = h * 17 / 667;
    CGFloat size2 = h * 20 / 667;
    
    [self.contactButton.titleLabel setFont:[UIFont systemFontOfSize:size1]];
    
    [self.peerNameLabel setFont:[UIFont systemFontOfSize:size1]];
    [self.peerJobLabel setFont:[UIFont systemFontOfSize:size1]];
    [self.peerLocationLabel setFont:[UIFont systemFontOfSize:size1]];
    
    [self.peerDepartTimeLabel setFont:[UIFont systemFontOfSize:size1]];
    [self.messageButton.titleLabel setFont:[UIFont systemFontOfSize:size1]];
    
    [self.otherInfoTextView setFont:[UIFont systemFontOfSize:size2]];
}

- (void)setPeerInfo: (NSMutableDictionary *)sender withUID: (NSString *)uid {
    if (!peerDic) {
        peerDic = [NSMutableDictionary new];
    }
    peerDic = [sender mutableCopy];
    peerUID = uid;
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
        departText = @"Departed";
        timeColor = [UIColor clearColor];
        timeText = @"";
    }else{
        departColor = [UIColor whiteColor];
        departText = @"Departing in ";
        
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

- (void)displayPeerInfo {
    
    [ProgressHUD show:@"Loading..." Interaction:NO];
    
    [self.peerNameLabel setText:peerDic[USERNAME]];
    [self.peerJobLabel setText:peerDic[OCCUPATION]];
    [self.peerLocationLabel setText:peerDic[CURRENT_CITY]];
    
    [self setMatchedMeetOption];
    
    NSNumber *peerNet = peerDic[NETWORK_OPTION];
    if ([peerNet integerValue] == 1) {
//        [self.netYesImageV setHidden:NO];
        [self.netYesImageV setImage:[UIImage imageNamed:@"network_yes.png"]];
    }else{
//        [self.netNoImageV setHidden:YES];
        [self.netYesImageV setImage:[UIImage imageNamed:@"network_no.png"]];
    }
    
    // Depart Time
    [self.peerDepartTimeLabel setAttributedText:[self departureTimeForPeerWith:[peerDic objectForKey:DEPART_TIME]]];
    
    // Other Info
    NSString *infoStr = @"\n";
    
//    if (peerDic[CURRENT_CITY] && ![EMPTY_STRING isEqualToString:peerDic[CURRENT_CITY]]) {
//        infoStr = [NSString stringWithFormat:@"%@Location: %@\n", infoStr, peerDic[CURRENT_CITY]];
//    }
//    
    if (peerDic[FIRST_CITY] && ![EMPTY_STRING isEqualToString:peerDic[FIRST_CITY]]) {
        infoStr = [NSString stringWithFormat:@"%@1st City: %@\n", infoStr, peerDic[FIRST_CITY]];
    }
    
    if (peerDic[SECOND_CITY] && ![EMPTY_STRING isEqualToString:peerDic[SECOND_CITY]]) {
        infoStr = [NSString stringWithFormat:@"%@2nd City: %@\n", infoStr, peerDic[SECOND_CITY]];
    }
    
    if (peerDic[THIRD_CITY] && ![EMPTY_STRING isEqualToString:peerDic[THIRD_CITY]]) {
        infoStr = [NSString stringWithFormat:@"%@3rd City: %@\n", infoStr, peerDic[THIRD_CITY]];
    }
    
    infoStr = [NSString stringWithFormat:@"%@\n", infoStr];
    
    if (peerDic[HOME_CITY] && ![EMPTY_STRING isEqualToString:peerDic[HOME_CITY]]) {
        infoStr = [NSString stringWithFormat:@"%@Home Town: %@\n", infoStr, peerDic[HOME_CITY]];
    }
    
//    if (peerDic[OCCUPATION] && ![EMPTY_STRING isEqualToString:peerDic[OCCUPATION]]) {
//        infoStr = [NSString stringWithFormat:@"%@Job: %@\n", infoStr, peerDic[OCCUPATION]];
//    }
//    
    if (peerDic[COLLEGE] && ![EMPTY_STRING isEqualToString:peerDic[COLLEGE]]) {
        infoStr = [NSString stringWithFormat:@"%@College: %@\n", infoStr, peerDic[COLLEGE]];
    }
    
    infoStr = [NSString stringWithFormat:@"%@\n", infoStr];
    
    if (peerDic[FIRST_INTEREST] && ![EMPTY_STRING isEqualToString:peerDic[FIRST_INTEREST]]) {
        infoStr = [NSString stringWithFormat:@"%@1st Interest: %@\n", infoStr, peerDic[FIRST_INTEREST]];
    }
    
    if (peerDic[SECOND_INTEREST] && ![EMPTY_STRING isEqualToString:peerDic[SECOND_INTEREST]]) {
        infoStr = [NSString stringWithFormat:@"%@2nd Interest: %@\n", infoStr, peerDic[SECOND_INTEREST]];
    }
    
    if (peerDic[THIRD_INTEREST] && ![EMPTY_STRING isEqualToString:peerDic[THIRD_INTEREST]]) {
        infoStr = [NSString stringWithFormat:@"%@3rd Interest: %@\n", infoStr, peerDic[THIRD_INTEREST]];
    }
    
    infoStr = [NSString stringWithFormat:@"%@\n", infoStr];
    
    if (peerDic[BAND] && ![EMPTY_STRING isEqualToString:peerDic[BAND]]) {
        infoStr = [NSString stringWithFormat:@"%@Band: %@\n", infoStr, peerDic[BAND]];
    }
    
    if (peerDic[BOOK] && ![EMPTY_STRING isEqualToString:peerDic[BOOK]]) {
        infoStr = [NSString stringWithFormat:@"%@Book: %@\n", infoStr, peerDic[BOOK]];
    }
    
    if (peerDic[MOVIE] && ![EMPTY_STRING isEqualToString:peerDic[MOVIE]]) {
        infoStr = [NSString stringWithFormat:@"%@Movie: %@\n", infoStr, peerDic[MOVIE]];
    }
    
    if (peerDic[PLACE] && ![EMPTY_STRING isEqualToString:peerDic[PLACE]]) {
        infoStr = [NSString stringWithFormat:@"%@Place: %@\n", infoStr, peerDic[PLACE]];
    }
    
    [self.otherInfoTextView setText:infoStr];
    [self.otherInfoTextView scrollRangeToVisible:NSMakeRange(0, 0)];
    
    // Show Avatar Image
    
    if (peerDic[PHOTO] == nil || [peerDic[PHOTO] isEqualToString:EMPTY_STRING]) {
        
        isExistedPhoto = NO;
        
        [self.peerProfileImageV setImage:[UIImage imageNamed:@"user.png"]];
        [ProgressHUD dismiss];
        return;
    }
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.png", DocumentDirectory, peerUID];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [self.peerProfileImageV setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]]];
        isExistedPhoto = YES;
        [ProgressHUD dismiss];
    }else{
        FIRStorageReference *httpRef = [[FIRStorage storage] referenceForURL:peerDic[PHOTO]];
        [httpRef dataWithMaxSize:1 * 1024 * 1024 completion:^(NSData * _Nullable data, NSError * _Nullable error) {
            
            UIImage *image;
            if (error) {
                isExistedPhoto = NO;
                image = [UIImage imageNamed:@"user.png"];
            }else {
                isExistedPhoto = YES;
                image = [UIImage imageWithData:data];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.peerProfileImageV setImage:image];
            });
            
            [ProgressHUD dismiss];
        }];
    }
    
}

- (void)setMatchedMeetOption {
    // Compare the find option (Meet or Network)
    NSInteger myMeet = [[[[UserInfo sharedInstance] userData] objectForKey:MEET_OPTION] integerValue];
    NSInteger peerMeet = [peerDic[MEET_OPTION] integerValue];
    
    BOOL isMatched = NO;
    
    if (peerMeet != 0) {
        switch (myMeet) {
            case 0:
                isMatched = NO;
                break;
            case 1:
                if (peerMeet == 9 || peerMeet == 11 || peerMeet == 12 || peerMeet == 14) {
                    isMatched = YES;
                }
                break;
            case 2:
                if (peerMeet == 2 || peerMeet == 4 || peerMeet == 5 || peerMeet == 7) {
                    isMatched = YES;
                }
                break;
            case 3:
                if (peerMeet == 16 || peerMeet == 18 || peerMeet == 19 || peerMeet == 21) {
                    isMatched = YES;
                }
                break;
            case 4:
                if (peerMeet == 2 || peerMeet == 4 || peerMeet == 5 || peerMeet == 7 || peerMeet == 9 || peerMeet == 11 || peerMeet == 12 || peerMeet == 14) {
                    isMatched = YES;
                }
                break;
            case 5:
                if (peerMeet == 2 || peerMeet == 4 || peerMeet == 5 || peerMeet == 7 || peerMeet == 16 || peerMeet == 18 || peerMeet == 19 || peerMeet == 21) {
                    isMatched = YES;
                }
                break;
            case 6:
                if (peerMeet == 16 || peerMeet == 18 || peerMeet == 19 || peerMeet == 21 || peerMeet == 9 || peerMeet == 11 || peerMeet == 12 || peerMeet == 14) {
                    isMatched = YES;
                }
                break;
            case 7:
                if (peerMeet == 2 || peerMeet == 4 || peerMeet == 5 || peerMeet == 7 || peerMeet == 9 || peerMeet == 11 || peerMeet == 12 || peerMeet == 14 || peerMeet == 16 || peerMeet == 18 || peerMeet == 19 || peerMeet == 21) {
                    isMatched = YES;
                }
                break;
            case 8:
                if (peerMeet == 8 || peerMeet == 11 || peerMeet == 13 || peerMeet == 14) {
                    isMatched = YES;
                }
                break;
            case 9:
                if (peerMeet == 1 || peerMeet == 4 || peerMeet == 6 || peerMeet == 7) {
                    isMatched = YES;
                }
                break;
            case 10:
                if (peerMeet == 15 || peerMeet == 18 || peerMeet == 20 || peerMeet == 21) {
                    isMatched = YES;
                }
                break;
            case 11:
                if (peerMeet == 1 || peerMeet == 4 || peerMeet == 6 || peerMeet == 7 || peerMeet == 8 || peerMeet == 11 || peerMeet == 13 || peerMeet == 14) {
                    isMatched = YES;
                }
                break;
            case 12:
                if (peerMeet == 1 || peerMeet == 4 || peerMeet == 6 || peerMeet == 7 || peerMeet == 15 || peerMeet == 18 || peerMeet == 20 || peerMeet == 21) {
                    isMatched = YES;
                }
                break;
            case 13:
                if (peerMeet == 15 || peerMeet == 18 || peerMeet == 20 || peerMeet == 21 || peerMeet == 8 || peerMeet == 11 || peerMeet == 13 || peerMeet == 14) {
                    isMatched = YES;
                }
                break;
            case 14:
                if (peerMeet == 1 || peerMeet == 4 || peerMeet == 6 || peerMeet == 7 || peerMeet == 8 || peerMeet == 11 || peerMeet == 13 || peerMeet == 14 || peerMeet == 15 || peerMeet == 18 || peerMeet == 20 || peerMeet == 21) {
                    isMatched = YES;
                }
                break;
            case 15:
                if (peerMeet == 10 || peerMeet == 12 || peerMeet == 13 || peerMeet == 14) {
                    isMatched = YES;
                }
                break;
            case 16:
                if (peerMeet == 3 || peerMeet == 5 || peerMeet == 6 || peerMeet == 7) {
                    isMatched = YES;
                }
                break;
            case 17:
                if (peerMeet == 17 || peerMeet == 19 || peerMeet == 20 || peerMeet == 21) {
                    isMatched = YES;
                }
                break;
            case 18:
                if (peerMeet == 3 || peerMeet == 5 || peerMeet == 6 || peerMeet == 7 || peerMeet == 10 || peerMeet == 12 || peerMeet == 13 || peerMeet == 14) {
                    isMatched = YES;
                }
                break;
            case 19:
                if (peerMeet == 3 || peerMeet == 5 || peerMeet == 6 || peerMeet == 7 || peerMeet == 17 || peerMeet == 19 || peerMeet == 20 || peerMeet == 21) {
                    isMatched = YES;
                }
                break;
            case 20:
                if (peerMeet == 17 || peerMeet == 19 || peerMeet == 20 || peerMeet == 21 || peerMeet == 10 || peerMeet == 12 || peerMeet == 13 || peerMeet == 14) {
                    isMatched = YES;
                }
                break;
            case 21:
                if (peerMeet == 3 || peerMeet == 5 || peerMeet == 6 || peerMeet == 7 || peerMeet == 10 || peerMeet == 12 || peerMeet == 13 || peerMeet == 14 || peerMeet == 17 || peerMeet == 19 || peerMeet == 20 || peerMeet == 21) {
                    isMatched = YES;
                }
                break;
                
            default:
                break;
        }
    }
    
    BOOL isAgeRange = NO;// Check the age range.
    
    NSInteger ageMin = [[[[UserInfo sharedInstance] userData] objectForKey:AGE_MIN] integerValue];
    NSInteger ageMax = [[[[UserInfo sharedInstance] userData] objectForKey:AGE_MAX] integerValue];
    NSInteger peerAge = [[peerDic objectForKey:AGE] integerValue];
    
    if (ageMax == 61) {
        if (peerAge >= ageMin) {
            isAgeRange = YES;
        }
    }else{
        if (peerAge >= ageMin && peerAge <= ageMax) {
            isAgeRange = YES;
        }
    }
    
    if (isMatched && isAgeRange) {
        [self.meetYesImageV setImage:[UIImage imageNamed:@"meet_yes.png"]];
    }else {
        [self.meetYesImageV setImage:[UIImage imageNamed:@"meet_no.png"]];
    }
}

//- Show blur image in front of avatar image
- (void)setBlurForImageView {
    
    NSMutableDictionary *contactList = [[UserInfo sharedInstance] userContactList];
    NSInteger blurL = 0;
    BOOL isExisted = NO;
    for (id key in contactList) {
        NSMutableDictionary *itemDic = [contactList objectForKey:key];
        if ([[itemDic objectForKey:USERID] isEqualToString:peerUID]) {
            if ([itemDic objectForKey:STATUS]) {// Although he is in your contact list, 
                blurL = [[itemDic objectForKey:STATUS] integerValue];
            }else{
                blurL = BlurLevel5;
            }
            isExisted = YES;
            break;
        }
    }
    
    if (isExisted == NO) {
        blurL = BlurLevel5;
    }
    
    if (blurL == 0) {
        return;
    }
    
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    
    FXBlurView *blurV = [[FXBlurView alloc] initWithFrame:CGRectMake(0, 0, h * 204 / 667, h * 204 / 667)];
    [blurV setBackgroundColor:[UIColor clearColor]];
    [blurV setBlurRadius:blurL * 5];
    
    for (UIView *subV in self.peerProfileImageV.subviews) {
        [subV removeFromSuperview];
    }
    
//    UIView *blurV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, h * 204 / 667, h * 204 / 667)];
//    [blurV setBackgroundColor:[UIColor whiteColor]];
//    [blurV setAlpha:(1 - 1 / blurL)];
//    [blurV setOpaque:NO];
    
    [self.peerProfileImageV addSubview:blurV];
}

- (void)blockOptionTouchUp: (UIButton *)sender {
    [self dismissButtonPressed:sender];
    
    [self addPeerToBlockList];
}

- (void)reportOptionTouchUp: (UIButton *)sender {
    [self dismissButtonPressed:sender];
    
    [self addPeerToBlockList];
}

- (void)addPeerToBlockList {
    NSMutableDictionary *blockList = [[UserInfo sharedInstance] userBlockList];
    
    BOOL isExisted = NO;
    if (![blockList isEqual:[NSNull null]]) {
        for (id key in blockList) {
            NSMutableDictionary *itemDic = [blockList objectForKey:key];
            if ([[itemDic objectForKey:USERID] isEqualToString:peerUID]) {
                isExisted = YES;
            }
        }
    }
    
    if (!isExisted) {
        // Add to block list
        NSDictionary *dict = @{USERID : peerUID//[PFUser currentUser].objectId,
                               };
        [[[[[[FIRDatabase database] reference] child:BLOCKLIST_REF] child:[FIRAuth auth].currentUser.uid] childByAutoId] setValue:dict];
    }
    
    // Remove peer from contact list
    NSMutableDictionary *contactList = [[UserInfo sharedInstance] userContactList];
    for (id key in contactList) {
        NSMutableDictionary *itemDic = [contactList objectForKey:key];
        if ([[itemDic objectForKey:USERID] isEqualToString:peerUID]) {
            [[[[[[FIRDatabase database] reference] child:CONTACTS_REF] child:[FIRAuth auth].currentUser.uid] child:key] removeValue];
        }
    }
    
    //--
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)isValidDepartTimeForMe {
    NSString *myDepartTime = [[[UserInfo sharedInstance] userData] objectForKey:DEPART_TIME];
    if (myDepartTime == nil || [myDepartTime isEqualToString:EMPTY_STRING]) {
        return NO;
    }
    
//    if ([myDepartTime rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound) {
        NSTimeInterval myTime = [myDepartTime doubleValue];
        NSTimeInterval nowInterval = [[NSDate date] timeIntervalSince1970];
        if (myTime > nowInterval) {
            return YES;
        }else {
            return NO;
        }
//    }else {
//        return NO;
//    }
    return YES;
}

- (BOOL)isValidDepartTimeForPeer {
    NSString *peerDepartTime = [peerDic objectForKey:DEPART_TIME];
    if (peerDepartTime == nil || [peerDepartTime isEqualToString:EMPTY_STRING]) {
        return NO;
    }
    
//    if ([peerDepartTime rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound) {
        NSTimeInterval peerTime = [peerDepartTime doubleValue];
        NSTimeInterval nowInterval = [[NSDate date] timeIntervalSince1970];
        if (peerTime > nowInterval) {
            return YES;
        }else {
            return NO;
        }
//    }else {
//        return NO;
//    }
    return YES;
}

- (void)showPopupAlertWithString{
    
    [self.view endEditing:YES];
    
    CGFloat w = [[UIScreen mainScreen] bounds].size.width * 2 / 3;
    CGFloat h = w / 5;
    
    UIButton *block = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, w / 2, h)];
    [block setTitle:@"Block" forState:UIControlStateNormal];
    [block addTarget:self action:@selector(blockOptionTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [block setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [block.titleLabel setFont:[UIFont systemFontOfSize:w / 15]];
    [block setShowsTouchWhenHighlighted:YES];
    
    UIButton *report = [[UIButton alloc] initWithFrame:CGRectMake(w / 2, 0, w / 2, h)];
    [report setTitle:@"Report" forState:UIControlStateNormal];
    [report addTarget:self action:@selector(reportOptionTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [report setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [report.titleLabel setFont:[UIFont systemFontOfSize:w / 15]];
    [report setShowsTouchWhenHighlighted:YES];
    
    UIView *seperateV = [[UIView alloc] initWithFrame:CGRectMake(w / 2 - 1, h / 6, 2, h * 2 / 3)];
    [seperateV setBackgroundColor:[UIColor lightGrayColor]];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    [contentView addSubview:block];
    [contentView addSubview:report];
    [contentView addSubview:seperateV];
    
    [contentView setBackgroundColor:[UIColor whiteColor]];
    [contentView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [contentView.layer setBorderWidth:1];
    [contentView.layer setCornerRadius: w / 20];
    
    // Show in popup
    KLCPopupLayout layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter,
                                               KLCPopupVerticalLayoutCenter);
    
    KLCPopup* popup = [KLCPopup popupWithContentView:contentView
                                            showType:KLCPopupShowTypeShrinkIn
                                         dismissType:KLCPopupDismissTypeShrinkOut
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

@end
