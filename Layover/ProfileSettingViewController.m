//
//  ProfileSettingViewController.m
//  Layovr
//
//  Created by Daniel Drescher on 07/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "ProfileSettingViewController.h"
#import "AppDelegate.h"

@interface ProfileSettingViewController() <TTRangeSliderDelegate>{
    BOOL isMeet;
    BOOL isMen;
    BOOL isTrans;
    
    BOOL isWomen;
    BOOL isNetwork;
    
    BOOL isSignOutClicked;
    
    UIButton *profileBt;
    UIButton *signoutBt;
    
    UIButton *meetBt;
    UIButton *networkBt;
    UIButton *menBt;
    UIButton *womenBt;
    UIButton *transBt;
    
    UILabel *meetLabel;
    UILabel *networkLabel;
    UILabel *menLabel;
    UILabel *womenLabel;
    UILabel *transLabel;
    
    UILabel *emailLabel;
    
    UIView *topView;
    UIView *bottomView;
    
    UILabel *lookingToL;
    UILabel *interestedInL;
    UILabel *accountL;

    UILabel *ageLabel;
    TTRangeSlider *ageSlider;
}

@end

@implementation ProfileSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [meetBt setTag:0];
    [networkBt setTag:2];
    [menBt setTag:4];
    [womenBt setTag:6];
    [transBt setTag:8];
    
    [self initUIControls];
    
    [self setUserInfoInControls];// Showing User Data
    
    [self setFontSizeForControls];
    
    isSignOutClicked = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - UIButton Touch Up

- (IBAction)signOutTouchUp:(UIButton *)sender {
    isSignOutClicked = YES;
    [self showPopupAlertWithString:@"Really?" isError:NO textAlign:NSTextAlignmentCenter];
}

- (IBAction)profileTouchUp:(UIButton *)sender {
    [self saveFindOption];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)meetTouchUp:(UIButton *)sender {
    if (sender.tag == 0) {
        isMeet = YES;
        
        [self selectMeet];
        
        [self showBottomView];
    }else {
        isMeet = NO;
        
        [self unSeletMeet];
        
        [self hideBottomView];
    }
    
    isMen = NO;
    isWomen = NO;
    isTrans = NO;
}

- (void)networkTouchUp:(UIButton *)sender {
    if (sender.tag == 2) {
        isNetwork = YES;
        [self selectNetwork];
        
//        [self hideBottomView];
    }else {
        isNetwork = NO;
        
        [self unSelectNetwork];
    }
}

- (void)menTouchUp:(UIButton *)sender {
    if (sender.tag == 4) {
        isMen = YES;
        
        [sender setTag:5];
        [sender setBackgroundImage:[UIImage imageNamed:@"men_yes.png"] forState:UIControlStateNormal];
    }else {
        isMen = NO;
        
        [sender setTag:4];
        [sender setBackgroundImage:[UIImage imageNamed:@"men_no.png"] forState:UIControlStateNormal];
        
//        if (isWomen == NO) {
//            [self womenTouchUp:self.womenBt];
//        }
    }
}

- (void)womenTouchUp:(UIButton *)sender {
    if (sender.tag == 6) {
        isWomen = YES;
        
        [sender setTag:7];
        [sender setBackgroundImage:[UIImage imageNamed:@"women_yes.png"] forState:UIControlStateNormal];
    }else {
        isWomen = NO;
        
        [sender setTag:6];
        [sender setBackgroundImage:[UIImage imageNamed:@"women_no.png"] forState:UIControlStateNormal];
        
//        if (isMen == NO) {
//            [self menTouchUp:self.menBt];
//        }
    }
}

- (void)transTouchUp:(UIButton *)sender {
    if (sender.tag == 8) {
        isTrans = YES;
        
        [sender setTag:9];
        [sender setBackgroundImage:[UIImage imageNamed:@"trans_yes.png"] forState:UIControlStateNormal];
    }else {
        isTrans = NO;
        
        [sender setTag:8];
        [sender setBackgroundImage:[UIImage imageNamed:@"trans_no.png"] forState:UIControlStateNormal];
        
//        if (isMen == NO) {
//            [self menTouchUp:self.menBt];
//        }
    }
}

#pragma mark - TTRangeSliderViewDelegate
-(void)rangeSlider:(TTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum{
    
}

#pragma mark - Custom Method

- (void)initUIControls {
    CGFloat w = [[UIScreen mainScreen] bounds].size.width;
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    
    CGFloat th = h * 220 / 667;// Top View height
    CGFloat bh = h * 180 / 667;// Bottom View height
    
    CGFloat font1 = h * 17 / 667;
    CGFloat font2 = h * 20 / 667;
    
    // Top View
    topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, th)];
    
    lookingToL  = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, w - 60, th * 32 / 220)];
    [lookingToL setFont:[UIFont systemFontOfSize:font1 weight:UIFontWeightMedium]];
    [lookingToL setTextColor:[UIColor whiteColor]];
    [lookingToL setTextAlignment:NSTextAlignmentCenter];
    [lookingToL setText:@"Looking to:"];
    
    [topView addSubview:lookingToL];
    
    CGFloat mw = (th * 188 / 220) * 3 / 4;
    meetLabel = [[UILabel alloc] initWithFrame:CGRectMake(w / 2 - mw, th * 32 / 220, mw, th * 188 / 220 - mw)];
    [meetLabel setText:@"Meet"];
    [meetLabel setTextColor:[UIColor whiteColor]];
    [meetLabel setFont:[UIFont systemFontOfSize:font2 weight:UIFontWeightSemibold]];
    [meetLabel setTextAlignment:NSTextAlignmentCenter];
    
    [topView addSubview:meetLabel];
    
    networkLabel = [[UILabel alloc] initWithFrame:CGRectMake(w / 2, th * 32 / 220, mw, th * 188 / 220 - mw)];
    [networkLabel setText:@"Network"];
    [networkLabel setFont:[UIFont systemFontOfSize:font2 weight:UIFontWeightSemibold]];
    [networkLabel setTextColor:[UIColor whiteColor]];
    [networkLabel setTextAlignment:NSTextAlignmentCenter];
    
    [topView addSubview:networkLabel];
    
    meetBt = [[UIButton alloc] initWithFrame:CGRectMake(w / 2 - mw, th - mw, mw, mw)];
    [meetBt setBackgroundImage:[UIImage imageNamed:@"meet_no.png"] forState:UIControlStateNormal];
    [meetBt addTarget:self action:@selector(meetTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:meetBt];
    
    networkBt = [[UIButton alloc] initWithFrame:CGRectMake(w / 2, th - mw, mw, mw)];
    [networkBt setBackgroundImage:[UIImage imageNamed:@"network_no.png"] forState:UIControlStateNormal];
    [networkBt addTarget:self action:@selector(networkTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:networkBt];
    
    // Bottom View
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, h * 220 / 667, w, bh)];
    interestedInL  = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, w - 60, bh * 32 / 180)];
    [interestedInL setFont:[UIFont systemFontOfSize:font1 weight:UIFontWeightMedium]];
    [interestedInL setTextColor:[UIColor whiteColor]];
    [interestedInL setText:@"Interested in:"];
    [interestedInL setTextAlignment:NSTextAlignmentCenter];
    [bottomView addSubview:interestedInL];
    
    menLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, bh * 32 / 180, w / 3, bh * 48 / 180)];
    [menLabel setTextAlignment:NSTextAlignmentCenter];
    [menLabel setText:@"Men"];
    [menLabel setTextColor:[UIColor whiteColor]];
    [menLabel setFont:[UIFont systemFontOfSize:font2 weight:UIFontWeightSemibold]];
    [bottomView addSubview:menLabel];
    
    womenLabel = [[UILabel alloc] initWithFrame:CGRectMake(w * 2 / 3, bh * 32 / 180, w / 3, bh * 48 / 180)];
    [womenLabel setTextAlignment:NSTextAlignmentCenter];
    [womenLabel setText:@"Women"];
    [womenLabel setTextColor:[UIColor whiteColor]];
    [womenLabel setFont:[UIFont systemFontOfSize:font2 weight:UIFontWeightSemibold]];
    [bottomView addSubview:womenLabel];
    
    transLabel = [[UILabel alloc] initWithFrame:CGRectMake(w / 3, bh * 32 / 180, w / 3, bh * 48 / 180)];
    [transLabel setTextAlignment:NSTextAlignmentCenter];
    [transLabel setText:@"Trans"];
    [transLabel setTextColor:[UIColor whiteColor]];
    [transLabel setFont:[UIFont systemFontOfSize:font2 weight:UIFontWeightSemibold]];
    [bottomView addSubview:transLabel];
    
    CGFloat ow = w / 3;// Option button width
    if (ow > (bh * 5 / 9)) {
        ow = bh * 5 / 9;
    }
    
    menBt = [[UIButton alloc] initWithFrame:CGRectMake(w / 6 - ow / 2, bh * 4 / 9, ow, ow)];
    [menBt setBackgroundImage:[UIImage imageNamed:@"men_no.png"] forState:UIControlStateNormal];
    [menBt addTarget:self action:@selector(menTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:menBt];
    
    transBt = [[UIButton alloc] initWithFrame:CGRectMake(w / 3 + w / 6 - ow / 2, bh * 4 / 9, ow, ow)];
    [transBt setBackgroundImage:[UIImage imageNamed:@"trans_no.png"] forState:UIControlStateNormal];
    [transBt addTarget:self action:@selector(transTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:transBt];
    
    womenBt = [[UIButton alloc] initWithFrame:CGRectMake(w * 2 / 3 + w / 6 - ow / 2, bh * 4 / 9, ow, ow)];
    [womenBt setBackgroundImage:[UIImage imageNamed:@"women_no.png"] forState:UIControlStateNormal];
    [womenBt addTarget:self action:@selector(womenTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:womenBt];
    
    [self.settingView addSubview:topView];
    [self.settingView addSubview:bottomView];
    
    // Adding Age Slider
    ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, th + bh, w, h * 32 / 667)];
    [ageLabel setText:@"Age"];
    [ageLabel setFont:[UIFont systemFontOfSize:font1 weight:UIFontWeightMedium]];
    [ageLabel setTextAlignment:NSTextAlignmentCenter];
    [ageLabel setTextColor:[UIColor whiteColor]];
    [self.settingView addSubview:ageLabel];
    
    ageSlider = [[TTRangeSlider alloc] initWithFrame:CGRectMake(w / 10, th + bh + h * 32 / 667, w * 4 / 5, h / 12)];
    [ageSlider setDelegate:self];
    [ageSlider setMinValue:18];
    [ageSlider setMaxValue:61];
    [ageSlider setSelectedMinimum:18];
    [ageSlider setSelectedMaximum:61];
    [ageSlider setMinLabelText:[NSString stringWithFormat:@"%f", ageSlider.selectedMinimum]];
    [ageSlider setMaxLabelText:@"60+"];
    [ageSlider setTintColor:[UIColor whiteColor]];
    [ageSlider setTintColorBetweenHandles:[UIColor whiteColor]];
    [self.settingView addSubview:ageSlider];
    
    accountL = [[UILabel alloc] initWithFrame:CGRectMake(0, ageSlider.frame.size.height + ageSlider.frame.origin.y, w, h * 32 / 667)];
    [accountL setText:@"Account"];
    [accountL setFont:[UIFont systemFontOfSize:font1 weight:UIFontWeightMedium]];
    [accountL setTextAlignment:NSTextAlignmentCenter];
    [accountL setTextColor:[UIColor whiteColor]];
    [self.settingView addSubview:accountL];
    
    emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, accountL.frame.size.height + accountL.frame.origin.y, w, h * 32 / 667)];
//    [emailLabel setText:@"Account"];
    [emailLabel setFont:[UIFont systemFontOfSize:font1 weight:UIFontWeightMedium]];
    [emailLabel setTextAlignment:NSTextAlignmentCenter];
    [emailLabel setTextColor:[UIColor whiteColor]];
    [self.settingView addSubview:emailLabel];
    
    
    [self.settingView setFrame:CGRectMake(0, 0, w, emailLabel.frame.size.height + emailLabel.frame.origin.y)];
}

- (void)setFontSizeForControls {
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    CGFloat size1 = h * 17 / 667;
    CGFloat size2 = h * 20 / 667;
    
    [profileBt.titleLabel setFont:[UIFont systemFontOfSize:size1]];
    [signoutBt.titleLabel setFont:[UIFont systemFontOfSize:size1]];
    
    [lookingToL setFont:[UIFont systemFontOfSize:size1]];
    [interestedInL setFont:[UIFont systemFontOfSize:size1]];
    [accountL setFont:[UIFont systemFontOfSize:size1]];
    
    [meetLabel setFont:[UIFont systemFontOfSize:size2]];
    [networkLabel setFont:[UIFont systemFontOfSize:size2]];
    [menLabel setFont:[UIFont systemFontOfSize:size2]];
    [womenLabel setFont:[UIFont systemFontOfSize:size2]];
    [transLabel setFont:[UIFont systemFontOfSize:size2]];
}

- (void)saveFindOption {
    NSInteger gender = [[[[UserInfo sharedInstance] userData] objectForKey:GENDER] integerValue];
    NSInteger meet = 0;
    NSInteger network = 0;
    
    if (isMeet) {
        if (gender == 1) { // Male
            if (isWomen && !isMen && !isTrans) {
                meet = 1;
            }else if (!isWomen && isMen && !isTrans) {
                meet = 2;
            }else if (!isWomen && !isMen && isTrans) {
                meet = 3;
            }else if (isWomen && isMen && !isTrans) {
                meet = 4;
            }else if (!isWomen && isMen && isTrans) {
                meet = 5;
            }else if (isWomen && !isMen && isTrans) {
                meet = 6;
            }else if (isWomen && isMen && isTrans) {
                meet = 7;
            }
        }else if (gender == 0) { // Female
            if (isWomen && !isMen && !isTrans) {
                meet = 8;
            }else if (!isWomen && isMen && !isTrans) {
                meet = 9;
            }else if (!isWomen && !isMen && isTrans) {
                meet = 10;
            }else if (isWomen && isMen && !isTrans) {
                meet = 11;
            }else if (!isWomen && isMen && isTrans) {
                meet = 12;
            }else if (isWomen && !isMen && isTrans) {
                meet = 13;
            }else if (isWomen && isMen && isTrans) {
                meet = 14;
            }
        }else { // Trans
            if (isWomen && !isMen && !isTrans) {
                meet = 15;
            }else if (!isWomen && isMen && !isTrans) {
                meet = 16;
            }else if (!isWomen && !isMen && isTrans) {
                meet = 17;
            }else if (isWomen && isMen && !isTrans) {
                meet = 18;
            }else if (!isWomen && isMen && isTrans) {
                meet = 19;
            }else if (isWomen && !isMen && isTrans) {
                meet = 20;
            }else if (isWomen && isMen && isTrans) {
                meet = 21;
            }
        }
    }else if (isMeet == NO || (!isWomen && !isMen && !isTrans)) {
        meet = 0;
    }
    
    if (isNetwork) {
        network = 1;
    }else {
        network = 0;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:meet] forKey:MEET_OPTION];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:network] forKey:NETWORK_OPTION];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:(NSInteger)ageSlider.selectedMinimum] forKey:AGE_MIN];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:(NSInteger)ageSlider.selectedMaximum] forKey:AGE_MAX];
    
    [[[UserInfo sharedInstance] userData] setValue:[NSNumber numberWithInteger:meet] forKey:MEET_OPTION];
    [[[UserInfo sharedInstance] userData] setValue:[NSNumber numberWithInteger:network] forKey:NETWORK_OPTION];
    [[[UserInfo sharedInstance] userData] setValue:[NSNumber numberWithInteger:(NSInteger)ageSlider.selectedMinimum] forKey:AGE_MIN];
    [[[UserInfo sharedInstance] userData] setValue:[NSNumber numberWithInteger:(NSInteger)ageSlider.selectedMaximum] forKey:AGE_MAX];
    
//    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:USERID];
//    if (uid == nil) {
//        return;
//    }
    
    [[[[[[FIRDatabase database] reference] child:USERS_REF] child:[FIRAuth auth].currentUser.uid] child:MEET_OPTION] setValue:[NSNumber numberWithInteger:meet]];
    [[[[[[FIRDatabase database] reference] child:USERS_REF] child:[FIRAuth auth].currentUser.uid] child:NETWORK_OPTION] setValue:[NSNumber numberWithInteger:network]];
    [[[[[[FIRDatabase database] reference] child:USERS_REF] child:[FIRAuth auth].currentUser.uid] child:AGE_MIN] setValue:[NSNumber numberWithInteger:(NSInteger)ageSlider.selectedMinimum]];
    [[[[[[FIRDatabase database] reference] child:USERS_REF] child:[FIRAuth auth].currentUser.uid] child:AGE_MAX] setValue:[NSNumber numberWithInteger:(NSInteger)ageSlider.selectedMaximum]];
//    [[DataService user_ref:uid] setValue:[[UserInfo sharedInstance] userData]];
}

- (void)setUserInfoInControls {
    NSString *email;
    if ([[[UserInfo sharedInstance] userData] objectForKey:EMAIL]) {
        email = [[[UserInfo sharedInstance] userData] objectForKey:EMAIL];
    }else{
        email = @"email@email.com";
    }
    
    NSMutableAttributedString *emailStr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"Email address: %@", email]];
    [emailStr setAttributes:@{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]} range:NSMakeRange(14, emailStr.length - 14)];
    [emailLabel setAttributedText:emailStr];
    
    NSInteger ageMin = [[[[UserInfo sharedInstance] userData] objectForKey:AGE_MIN] integerValue];
    NSInteger ageMax = [[[[UserInfo sharedInstance] userData] objectForKey:AGE_MAX] integerValue];
    if (ageMin == 0) {
        ageMin = 18;
    }
    if (ageMax == 0) {
        ageMax = 61;
    }
    
    [ageSlider setSelectedMinimum:(float)ageMin];
    [ageSlider setSelectedMaximum:(float)ageMax];
    
    NSInteger meetOption = [[[[UserInfo sharedInstance] userData] objectForKey:MEET_OPTION] integerValue];
    NSInteger networkOption = [[[[UserInfo sharedInstance] userData] objectForKey:NETWORK_OPTION] integerValue];
    
    isMeet = YES;
    if (meetOption == 1 || meetOption == 8 || meetOption == 15) {
        isWomen = YES;
        isMen = NO;
        isTrans = NO;
    }else if (meetOption == 2 || meetOption == 9 || meetOption == 16) {
        isWomen = NO;
        isMen = YES;
        isTrans = NO;
    }else if (meetOption == 3 || meetOption == 10 || meetOption == 17) {
        isWomen = NO;
        isMen = NO;
        isTrans = YES;
    }else if (meetOption == 4 || meetOption == 11 || meetOption == 18) {
        isWomen = YES;
        isMen = YES;
        isTrans = NO;
    }else if (meetOption == 5 || meetOption == 12 || meetOption == 19) {
        isWomen = NO;
        isMen = YES;
        isTrans = YES;
    }else if (meetOption == 6 || meetOption == 13 || meetOption == 20) {
        isWomen = YES;
        isMen = NO;
        isTrans = YES;
    }else if (meetOption == 7 || meetOption == 14 || meetOption == 21) {
        isWomen = YES;
        isMen = YES;
        isTrans = YES;
    }else {
        isMeet = NO;
        isWomen = NO;
        isMen = NO;
        isTrans = NO;
    }
    switch (networkOption) {
        case 0:
            isNetwork = NO;
            break;
        case 1:
            isNetwork = YES;
            break;
            
        default:
            break;
    }
    
    if (isMeet) {
        [meetBt setTag:1];
        [meetBt setBackgroundImage:[UIImage imageNamed:@"meet_yes.png"] forState:UIControlStateNormal];
    }else{
        [meetBt setTag:0];
        [meetBt setBackgroundImage:[UIImage imageNamed:@"meet_no.png"] forState:UIControlStateNormal];
        [self hideBottomView];
    }
    
    if (isNetwork) {
        [networkBt setTag:3];
        [networkBt setBackgroundImage:[UIImage imageNamed:@"network_yes.png"] forState:UIControlStateNormal];
    }else{
        [networkBt setTag:2];
        [networkBt setBackgroundImage:[UIImage imageNamed:@"network_no.png"] forState:UIControlStateNormal];
    }
    
    if (isMen) {
        [menBt setTag:5];
        [menBt setBackgroundImage:[UIImage imageNamed:@"men_yes.png"] forState:UIControlStateNormal];
    }else {
        [menBt setTag:4];
        [menBt setBackgroundImage:[UIImage imageNamed:@"men_no.png"] forState:UIControlStateNormal];
    }
    
    if (isWomen) {
        [womenBt setTag:7];
        [womenBt setBackgroundImage:[UIImage imageNamed:@"women_yes.png"] forState:UIControlStateNormal];
    }else{
        [womenBt setTag:6];
        [womenBt setBackgroundImage:[UIImage imageNamed:@"women_no.png"] forState:UIControlStateNormal];
    }
    
    if (isTrans) {
        [transBt setTag:9];
        [transBt setBackgroundImage:[UIImage imageNamed:@"trans_yes.png"] forState:UIControlStateNormal];
    }else{
        [transBt setTag:8];
        [transBt setBackgroundImage:[UIImage imageNamed:@"trans_no.png"] forState:UIControlStateNormal];
    }
        
}

- (void)hideBottomView {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [bottomView setAlpha:0];
    } completion:^(BOOL finished) {
        [bottomView setHidden:YES];
    }];
}

- (void)showBottomView {
    [bottomView setHidden:NO];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [bottomView setAlpha:1];
    } completion:^(BOOL finished) {
    }];
}

- (void)selectMeet {
    [meetBt setTag:1];
    [meetBt setBackgroundImage:[UIImage imageNamed:@"meet_yes.png"] forState:UIControlStateNormal];
    
//    [self.networkBt setTag:2];
//    [self.networkBt setBackgroundImage:[UIImage imageNamed:@"network_no.png"] forState:UIControlStateNormal];
    
    [menBt setTag:4];
    [menBt setBackgroundImage:[UIImage imageNamed:@"men_no.png"] forState:UIControlStateNormal];
    
    [womenBt setTag:6];
    [womenBt setBackgroundImage:[UIImage imageNamed:@"women_no.png"] forState:UIControlStateNormal];
    
    [transBt setTag:8];
    [transBt setBackgroundImage:[UIImage imageNamed:@"trans_no.png"] forState:UIControlStateNormal];
    
    [menBt setEnabled:YES];
    [womenBt setEnabled:YES];
    [transBt setEnabled:YES];
}

- (void)unSeletMeet {
    [meetBt setTag:0];
    [meetBt setBackgroundImage:[UIImage imageNamed:@"meet_no.png"] forState:UIControlStateNormal];
    
    [menBt setTag:5];
    [menBt setBackgroundImage:[UIImage imageNamed:@"men_yes.png"] forState:UIControlStateNormal];
    
    [womenBt setTag:7];
    [womenBt setBackgroundImage:[UIImage imageNamed:@"women_yes.png"] forState:UIControlStateNormal];
    
    [transBt setTag:9];
    [transBt setBackgroundImage:[UIImage imageNamed:@"trans_yes.png"] forState:UIControlStateNormal];
    
    [menBt setEnabled:NO];
    [womenBt setEnabled:NO];
    [transBt setEnabled:NO];
}

- (void)selectNetwork {
    
    [networkBt setTag:3];
    [networkBt setBackgroundImage:[UIImage imageNamed:@"network_yes.png"] forState:UIControlStateNormal];
}

- (void)unSelectNetwork {
    
    [networkBt setTag:2];
    [networkBt setBackgroundImage:[UIImage imageNamed:@"network_no.png"] forState:UIControlStateNormal];
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
        
        if (isSignOutClicked) {
            [self firebaseSignOut];
        }
    }
}

- (void)firebaseSignOut {
    [ProgressHUD show:@"Sign out..." Interaction:NO];
    // Start Sign Out
    NSError *signOutError;
    
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    
    if (!status) {
        isSignOutClicked = NO;
        NSString *errorStr;
        if (signOutError) {
            errorStr = signOutError.localizedDescription;
        }else{
            errorStr = @"SignOut Failed!";
        }
        [self showPopupAlertWithString:errorStr isError:YES textAlign:NSTextAlignmentCenter];
    }else{// Change root view controller to Main View Controller
        AppDelegate *myDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [myDelegate setRootViewController];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:ISDOWNLOADED_USERDATA];
        
        [[UserInfo sharedInstance] initUserInfo];
    }
    
    [ProgressHUD dismiss];
}

@end
