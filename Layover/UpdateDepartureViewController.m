//
//  UpdateDepartureViewController.m
//  Layovr
//
//  Created by Daniel Muller on 22/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "UpdateDepartureViewController.h"

@interface UpdateDepartureViewController() {
    
}

@end

@implementation UpdateDepartureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.datePicker setBackgroundColor:[UIColor whiteColor]];
    
    [self setFontSizeForControls];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.departTimeLabel setAttributedText:[self departureTimeForPeerWith:[[[UserInfo sharedInstance] userData] objectForKey:DEPART_TIME]]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Custom Event

- (IBAction)updateTouchUp:(UIButton *)sender {
    if (![self isValidDepartureTime]) {
        [self showPopupAlertWithString:@"Please choose the valid Departure Time!" isError:YES textAlign:NSTextAlignmentCenter];
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:DEPARTED_FLAG];
    
    //Update Departure Time;
    NSTimeInterval interval = [self.datePicker.date timeIntervalSince1970];
    NSString *departureTime = [NSString stringWithFormat:@"%f", interval];
    
    [[[UserInfo sharedInstance] userData] setObject:departureTime forKey:DEPART_TIME];
    [[[[[[FIRDatabase database] reference] child:USERS_REF] child:[FIRAuth auth].currentUser.uid] child:DEPART_TIME] setValue:departureTime];
    
    //
    [self showPopupAlertWithString:@"Your departure was updated successfully!" isError:NO textAlign:NSTextAlignmentCenter];
    
    [self.departTimeLabel setAttributedText:[self departureTimeForPeerWith:[[[UserInfo sharedInstance] userData] objectForKey:DEPART_TIME]]];
}

- (IBAction)checkOutTouchUp:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:DEPARTED_FLAG];
    
    NSTimeInterval nowInterval = [[NSDate date] timeIntervalSinceReferenceDate];
    NSString *departureTime = [NSString stringWithFormat:@"%f", nowInterval];
    
    [[[UserInfo sharedInstance] userData] setObject:departureTime forKey:DEPART_TIME];
    [[[[[[FIRDatabase database] reference] child:USERS_REF] child:[FIRAuth auth].currentUser.uid] child:DEPART_TIME] setValue:departureTime];
    
    [self.departTimeLabel setAttributedText:[self departureTimeForPeerWith:[[[UserInfo sharedInstance] userData] objectForKey:DEPART_TIME]]];
}

- (IBAction)peersTouchUp:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Custom Method

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
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:DEPARTED_FLAG];
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
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:DEPARTED_FLAG];
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

- (void)setFontSizeForControls {
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    CGFloat size1 = h * 17 / 667;
    //    CGFloat size2 = h * 20 / 667;
    
    [self.peersButton.titleLabel setFont:[UIFont systemFontOfSize:size1]];
}

- (BOOL)isValidDepartureTime {
    NSTimeInterval timeInterVal = [self.datePicker.date timeIntervalSinceNow];
    if (timeInterVal < 0) {
        return NO;
    }
    return YES;
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
