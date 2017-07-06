//
//  SetDepartureViewController.m
//  Layovr
//
//  Created by Daniel Drescher on 07/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "SetDepartureViewController.h"
#import "CameraViewController.h"

@interface SetDepartureViewController() {
    
}

@end

@implementation SetDepartureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.datePicker setBackgroundColor:[UIColor whiteColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self showPopupAlertWithString:@"You can stay connected to a network for up to 4 hours.\nIf you wish to shorten or extend your stay you may adjust it at any time." isError:NO textAlign:NSTextAlignmentCenter];
}

//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
//}

#pragma mark -

- (IBAction)setDepartureTouchUp:(UIButton *)sender {
    if (![self isValidDepartureTime]) {
        [self showPopupAlertWithString:@"Please choose the valid Departure Time!" isError:YES textAlign:NSTextAlignmentCenter];
        return;
    }
    
    [self saveDepartureTime];// Save the Depart Time in Firebase
    
    CameraViewController *camerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraViewController"];
    [camerVC setIsFromProfileView:NO];
    
    [self presentViewController:camerVC animated:YES completion:nil];
}

#pragma mark - Custom Method

- (BOOL)isValidDepartureTime {
    NSTimeInterval timeInterVal = [self.datePicker.date timeIntervalSinceNow];
    if (timeInterVal < 0) {
        return NO;
    }
    return YES;
}

- (void)saveDepartureTime {
    
    NSString *departTime = [NSString stringWithFormat:@"%f", [self.datePicker.date timeIntervalSince1970]];
    [[[UserInfo sharedInstance] userData] setValue:departTime forKey:DEPART_TIME];
    
    [[[[[[FIRDatabase database] reference] child:USERS_REF] child:[FIRAuth auth].currentUser.uid] child:DEPART_TIME] setValue:departTime];
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
