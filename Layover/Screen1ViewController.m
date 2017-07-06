//
//  Screen1ViewController.m
//  Layovr
//
//  Created by Daniel Drescher on 03/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "Screen1ViewController.h"
#import "Screen2ViewController.h"

@interface Screen1ViewController () <TTRangeSliderDelegate> {
    UIView *firstView;
    UIView *secondView;
    
    UIButton *meetBt;
    UIButton *netBt;
    UIButton *menBt;
    UIButton *womenBt;
    UIButton *transBt;
    
    TTRangeSlider *ageSlider;
    
    UIButton *continueBt;
    
    BOOL isMeet;
    BOOL isMen;
    BOOL isWomen;
    BOOL isTrans;
    
    BOOL isNetwork;
}

@end

@implementation Screen1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUIControlsInView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Init View

- (void)initUIControlsInView {
    CGFloat w = [[UIScreen mainScreen] bounds].size.width;
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    
    firstView = [[UIView alloc] initWithFrame:CGRectMake(0, h / 6, w, h / 2)];
    UILabel *welcomeL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w, h / 8)];
    [welcomeL setText:[NSString stringWithFormat:@"Hi %@. Welcome!", [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME]]];
    [welcomeL setTextAlignment:NSTextAlignmentCenter];
    [welcomeL setTextColor:[UIColor whiteColor]];
    [welcomeL setFont:[UIFont systemFontOfSize:h / 22 weight:UIFontWeightMedium]];
    [welcomeL setNumberOfLines:1];
    [welcomeL setMinimumScaleFactor:10];
    [welcomeL setAdjustsFontSizeToFitWidth:YES];
    [firstView addSubview:welcomeL];
    
    UILabel *questionL = [[UILabel alloc] initWithFrame:CGRectMake(0, h / 8, w, h / 8)];
    [questionL setText:@"What are you looking to do?"];
    [questionL setTextAlignment:NSTextAlignmentCenter];
    [questionL setTextColor:[UIColor whiteColor]];
    [questionL setFont:[UIFont systemFontOfSize:h / 25 weight:UIFontWeightMedium]];
    [questionL setNumberOfLines:1];
    [questionL setMinimumScaleFactor:10];
    [questionL setAdjustsFontSizeToFitWidth:YES];
    [firstView addSubview:questionL];
    
    CGFloat mw = h / 5;
    CGFloat mg = h / 6;
    UIView *meetV = [[UIView alloc] initWithFrame:CGRectMake(w / 2 - mw, h / 4 + h / 20, mw, mw)];
    
    UILabel *meetL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, mw, mw * 2 / 5)];
    [meetL setText:@"Meet"];
    [meetL setTextColor:[UIColor whiteColor]];
    [meetL setTextAlignment:NSTextAlignmentCenter];
    [meetL setFont:[UIFont systemFontOfSize:h / 25 weight:UIFontWeightMedium]];
    
    [meetV addSubview:meetL];
    //meet
    meetBt = [[UIButton alloc] initWithFrame:CGRectMake(mw / 5, mw * 2 / 5, mw * 3 / 5, mw * 3 / 5)];
    [meetBt setBackgroundImage:[UIImage imageNamed:@"meet_no.png"] forState:UIControlStateNormal];
    [meetBt addTarget:self action:@selector(meetIconTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [meetBt setTag:0];
    
    [meetV addSubview:meetBt];
    
    UIView *netV = [[UIView alloc] initWithFrame:CGRectMake(w / 2, h / 4 + h / 20, mw, mw)];
    UILabel *netL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, mw, mw * 2 / 5)];
    [netL setText:@"Network"];
    [netL setTextColor:[UIColor whiteColor]];
    [netL setFont:[UIFont systemFontOfSize:h / 25 weight:UIFontWeightMedium]];
    [netL setTextAlignment:NSTextAlignmentCenter];
    
    [netV addSubview:netL];
    //internet
    netBt = [[UIButton alloc] initWithFrame:CGRectMake(mw / 5, mw * 2 / 5, mw * 3 / 5, mw * 3 / 5)];
    [netBt setBackgroundImage:[UIImage imageNamed:@"network_no.png"] forState:UIControlStateNormal];
    [netBt addTarget:self action:@selector(netIconTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [netBt setTag:2];
    
    [netV addSubview:netBt];
    
//    [meetV setBackgroundColor:[UIColor whiteColor]];
//    [netV setBackgroundColor:[UIColor whiteColor]];
    [firstView addSubview:meetV];
    [firstView addSubview:netV];
    
    secondView = [[UIView alloc] initWithFrame:CGRectMake(0, h * 2 / 3, w, h / 2)];
    
    UILabel *interestL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w, h / 7)];
    [interestL setTextAlignment:NSTextAlignmentCenter];
    [interestL setText:@"Interested In :"];
    [interestL setFont:[UIFont systemFontOfSize:h / 25 weight:UIFontWeightMedium]];
    [interestL setTextColor:[UIColor whiteColor]];
    
    [secondView addSubview:interestL];
    
    UIView *menV = [[UIView alloc] initWithFrame:CGRectMake(w / 2 - mg * 3 / 2, h / 7, mg, mg)];
    
    UILabel *menL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, mg, mg * 2 / 5)];
    [menL setText:@"Men"];
    [menL setTextColor:[UIColor whiteColor]];
    [menL setTextAlignment:NSTextAlignmentCenter];
    [menL setFont:[UIFont systemFontOfSize:h / 25 weight:UIFontWeightMedium]];
    
    [menV addSubview:menL];
    //Men
    menBt = [[UIButton alloc] initWithFrame:CGRectMake(mg / 5, mg * 2 / 5, mg * 3 / 5, mg * 3 / 5)];
    [menBt setBackgroundImage:[UIImage imageNamed:@"men_no.png"] forState:UIControlStateNormal];
    [menBt addTarget:self action:@selector(menIconTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [menBt setTag:4];
    
    [menV addSubview:menBt];
    
    UIView *womenV = [[UIView alloc] initWithFrame:CGRectMake(w / 2 + mg / 2, h / 7, mg, mg)];
    UILabel *womenL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, mg, mg * 2 / 5)];
    [womenL setText:@"Women"];
    [womenL setTextColor:[UIColor whiteColor]];
    [womenL setFont:[UIFont systemFontOfSize:h / 25 weight:UIFontWeightMedium]];
    [womenL setTextAlignment:NSTextAlignmentCenter];
    
    [womenV addSubview:womenL];
    //Women
    womenBt = [[UIButton alloc] initWithFrame:CGRectMake(mg / 5, mg * 2 / 5, mg * 3 / 5, mg * 3 / 5)];
    [womenBt setBackgroundImage:[UIImage imageNamed:@"women_no.png"] forState:UIControlStateNormal];
    [womenBt addTarget:self action:@selector(womenIconTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [womenBt setTag:6];
    
    [womenV addSubview:womenBt];
    
    UIView *transV = [[UIView alloc] initWithFrame:CGRectMake(w / 2 - mg / 2, h / 7, mg, mg)];
    UILabel *transL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, mg, mg * 2 / 5)];
    [transL setText:@"Trans"];
    [transL setTextColor:[UIColor whiteColor]];
    [transL setFont:[UIFont systemFontOfSize:h / 25 weight:UIFontWeightMedium]];
    [transL setTextAlignment:NSTextAlignmentCenter];
    
    [transV addSubview:transL];
    //Women
    transBt = [[UIButton alloc] initWithFrame:CGRectMake(mg / 5, mg * 2 / 5, mg * 3 / 5, mg * 3 / 5)];
    [transBt setBackgroundImage:[UIImage imageNamed:@"trans_no.png"] forState:UIControlStateNormal];
    [transBt addTarget:self action:@selector(transIconTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [transBt setTag:8];
    
    [transV addSubview:transBt];
    
    //    [meetV setBackgroundColor:[UIColor whiteColor]];
    //    [netV setBackgroundColor:[UIColor whiteColor]];
    [secondView addSubview:menV];
    [secondView addSubview:womenV];
    [secondView addSubview:transV];
    
    UILabel *ageTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2 * mg, w, mg / 2)];
    [ageTitleLabel setText:@"Age"];
    [ageTitleLabel setFont:[UIFont systemFontOfSize:h / 25 weight:UIFontWeightMedium]];
    [ageTitleLabel setTextColor:[UIColor whiteColor]];
    [ageTitleLabel setTextAlignment:NSTextAlignmentCenter];
    
    ageSlider = [[TTRangeSlider alloc] initWithFrame:CGRectMake(w / 10, 5.0f / 2.0f * mg, w * 4 / 5, mg / 2)];
    [ageSlider setDelegate:self];
    [ageSlider setMinValue:18];
    [ageSlider setMaxValue:61];
    [ageSlider setSelectedMinimum:18];
    [ageSlider setSelectedMaximum:61];
    [ageSlider setMinLabelText:[NSString stringWithFormat:@"%f", ageSlider.selectedMinimum]];
    [ageSlider setMaxLabelText:@"60+"];
    [ageSlider setTintColor:[UIColor whiteColor]];
    [ageSlider setTintColorBetweenHandles:[UIColor whiteColor]];
    [ageSlider setMinLabelFont:[UIFont systemFontOfSize:h / 30]];
    [ageSlider setMaxLabelFont:[UIFont systemFontOfSize:h / 30]];
    
    [secondView addSubview:ageTitleLabel];
    [secondView addSubview:ageSlider];
    
    [secondView setHidden:YES];
    [secondView setAlpha:0];
    
    [self.view addSubview:firstView];
    [self.view addSubview:secondView];
    
    CGFloat ch = h * 40 / 667;
    CGFloat cw = ch * 5 / 2;
    
    continueBt = [[UIButton alloc] initWithFrame:CGRectMake((w - cw) / 2, h - ch - 20, cw, ch)];
    [continueBt setFrame:CGRectMake((w - cw) / 2, h - ch - 20, cw, ch)];
    [continueBt setTitle:@"continue" forState:UIControlStateNormal];
    [continueBt.titleLabel setFont:[UIFont systemFontOfSize:ch / 2 weight:UIFontWeightMedium]];
//    [continueBt.titleLabel setTextColor:[UIColor whiteColor]];
    [continueBt setAlpha:0];
    [continueBt setFrame:CGRectMake(continueBt.frame.origin.x, h, continueBt.frame.size.width, continueBt.frame.size.height)];
    [continueBt setContentMode:UIViewContentModeRedraw];
    
    [continueBt addTarget:self action:@selector(continueTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [continueBt addTarget:self action:@selector(continueTouchDown:) forControlEvents:UIControlEventTouchDown];
    [continueBt addTarget:self action:@selector(continueTouchUpOut:) forControlEvents:UIControlEventTouchUpOutside];
    
    [self.view addSubview:continueBt];
}

#pragma mark - TTRangeSliderViewDelegate
-(void)rangeSlider:(TTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum{
 
}

#pragma mark - ICONs Touch Up

- (void)meetIconTouchUp: (UIButton *)sender {
    if (sender.tag == 0) {
        isMeet = YES;
        
        [sender setBackgroundImage:[UIImage imageNamed:@"meet_yes.png"] forState:UIControlStateNormal];
        [sender setTag:1];
        
        if (secondView.alpha == 0) {
            [self showSeconView];//show second view for choosing men or women
        }
        
        [menBt setEnabled:YES];
        [womenBt setEnabled:YES];
        [transBt setEnabled:YES];
        
        [menBt setBackgroundImage:[UIImage imageNamed:@"men_no.png"] forState:UIControlStateNormal];
        [menBt setTag:4];
        
        [womenBt setBackgroundImage:[UIImage imageNamed:@"women_no.png"] forState:UIControlStateNormal];
        [womenBt setTag:6];
        
        [transBt setBackgroundImage:[UIImage imageNamed:@"trans_no.png"] forState:UIControlStateNormal];
        [transBt setTag:8];
        
        isMen = NO;
        isWomen = NO;
        isTrans = NO;

    }else{
        isMeet = NO;
        [sender setTag:0];
        [sender setBackgroundImage:[UIImage imageNamed:@"meet_no.png"] forState:UIControlStateNormal];
        if (secondView.alpha == 1) {
            [self hideSecondView];//show second view for choosing men or women
        }
    }
}

- (void)netIconTouchUp: (UIButton *)sender {
    if (sender.tag == 2) {
        isNetwork = YES;
        
        [sender setBackgroundImage:[UIImage imageNamed:@"network_yes.png"] forState:UIControlStateNormal];
        [sender setTag:3];
        
        if (continueBt.alpha == 0) {
            [self showContinueButton];
        }
    
    }else{
        isNetwork = NO;
        
        [sender setBackgroundImage:[UIImage imageNamed:@"network_no.png"] forState:UIControlStateNormal];
        [sender setTag:2];
    }
}

- (void)menIconTouchUp: (UIButton *)sender {
    if (sender.tag == 4) {
        isMen = YES;
        
        [sender setBackgroundImage:[UIImage imageNamed:@"men_yes.png"] forState:UIControlStateNormal];
        [sender setTag:5];
        
        if (continueBt.alpha == 0) {
            [self showContinueButton];
        }
    }else{
        isMen = NO;
        
        [sender setBackgroundImage:[UIImage imageNamed:@"men_no.png"] forState:UIControlStateNormal];
        [sender setTag:4];
        
//        [womenBt setBackgroundImage:[UIImage imageNamed:@"women_yes.png"] forState:UIControlStateNormal];
//        [womenBt setTag:7];
    }
}

- (void)womenIconTouchUp: (UIButton *)sender {
    if (sender.tag == 6) {
        isWomen = YES;
        
        [sender setBackgroundImage:[UIImage imageNamed:@"women_yes.png"] forState:UIControlStateNormal];
        [sender setTag:7];
        
        if (continueBt.alpha == 0) {
            [self showContinueButton];
        }
    }else{
        isWomen = NO;
        
        [sender setBackgroundImage:[UIImage imageNamed:@"women_no.png"] forState:UIControlStateNormal];
        [sender setTag:6];
        
//        [menBt setBackgroundImage:[UIImage imageNamed:@"men_yes.png"] forState:UIControlStateNormal];
//        [menBt setTag:5];
    }
}

- (void)transIconTouchUp: (UIButton *)sender {
    if (sender.tag == 8) {
        isTrans = YES;
        
        [sender setBackgroundImage:[UIImage imageNamed:@"trans_yes.png"] forState:UIControlStateNormal];
        [sender setTag:9];
        
        if (continueBt.alpha == 0) {
            [self showContinueButton];
        }
    }else{
        isTrans = NO;
        
        [sender setBackgroundImage:[UIImage imageNamed:@"trans_no.png"] forState:UIControlStateNormal];
        [sender setTag:8];
        
//        [menBt setBackgroundImage:[UIImage imageNamed:@"men_yes.png"] forState:UIControlStateNormal];
//        [menBt setTag:5];
    }
}

- (void)continueTouchUp: (UIButton *)sender {
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // Check your options
    if (!isMen && !isWomen && !isTrans && isMeet) {
//        [self showErrorAlertWithString:@"Please set your interested option!" textField:nil];
        [self showPopupAlertWithString:@"Please set your interested option!" isError:YES textAlign:NSTextAlignmentCenter];
        return;
    }
    
    [self saveInterestedOption];
    
    Screen2ViewController *screen2VC = [self.storyboard instantiateViewControllerWithIdentifier:@"Screen2ViewController"];
    [self.navigationController pushViewController:screen2VC animated:YES];
}

- (void)continueTouchDown: (UIButton *)sender {
    [sender setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}

- (void)continueTouchUpOut: (UIButton *)sender {
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

#pragma mark - Custom Event

- (void)showSeconView {
    [secondView setHidden:NO];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [firstView setFrame:CGRectMake(0, 0, firstView.frame.size.width, firstView.frame.size.height)];
        [secondView setFrame:CGRectMake(0, secondView.frame.size.height, secondView.frame.size.width, secondView.frame.size.height)];
        [secondView setAlpha:1];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideSecondView {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [secondView setAlpha:0];
    } completion:^(BOOL finished) {
        [secondView setHidden:YES];
    }];
}

- (void)showContinueButton {
    [continueBt setHidden:NO];
    
    CGFloat w = [[UIScreen mainScreen] bounds].size.width;
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [continueBt setFrame:CGRectMake(continueBt.frame.origin.x, [[UIScreen mainScreen] bounds].size.height - continueBt.frame.size.height - 20, continueBt.frame.size.width, continueBt.frame.size.height)];
        [continueBt setAlpha:1];
        [firstView setFrame:CGRectMake(0, - h / 8, w, h / 2)];
        [secondView setFrame:CGRectMake(0, h * 3 / 8, w, h / 2)];
    } completion:^(BOOL finished) {
        
    }];
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

- (void)showErrorAlertWithString: (NSString *)msg textField: (UITextField *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    NSMutableAttributedString *errorStr = [[NSMutableAttributedString alloc] initWithString:msg];
    [errorStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, errorStr.length)];
    [alert setValue:errorStr forKey:@"attributedMessage"];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
        
        if (sender) {
            [sender becomeFirstResponder];
        }
    }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)saveInterestedOption {
    NSInteger gender = [[[NSUserDefaults standardUserDefaults] objectForKey:GENDER] integerValue];
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
    }else {
        meet = 0;
    }
    
    if (isNetwork){
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
}

@end
