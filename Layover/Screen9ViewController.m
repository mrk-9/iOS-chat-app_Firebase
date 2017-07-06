//
//  Screen9ViewController.m
//  Layovr
//
//  Created by Daniel Drescher on 04/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "Screen9ViewController.h"
#import "RootViewController.h"
#import "AppDelegate.h"

@interface Screen9ViewController() <UITextFieldDelegate>{
    
}

@end

@implementation Screen9ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.bandTF setReturnKeyType:UIReturnKeyNext];
    [self.bookTF setReturnKeyType:UIReturnKeyNext];
    [self.movieTF setReturnKeyType:UIReturnKeyNext];
    [self.placeTF setReturnKeyType:UIReturnKeyDone];
    
    [self setFontSizeForControls];
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

#pragma mark - UIButton Touch Up

- (IBAction)doneTouchUp:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.bandTF.text forKey:BAND];
    [[NSUserDefaults standardUserDefaults] setObject:self.bookTF.text forKey:BOOK];
    [[NSUserDefaults standardUserDefaults] setObject:self.movieTF.text forKey:MOVIE];
    [[NSUserDefaults standardUserDefaults] setObject:self.placeTF.text forKey:PLACE];
    
    [[[UserInfo sharedInstance] userData] setValue:self.bandTF.text forKey:BAND];
    [[[UserInfo sharedInstance] userData] setValue:self.bookTF.text forKey:BOOK];
    [[[UserInfo sharedInstance] userData] setValue:self.movieTF.text forKey:MOVIE];
    [[[UserInfo sharedInstance] userData] setValue:self.placeTF.text forKey:PLACE];
    
    
    [ProgressHUD show:@"Saving..." Interaction:YES];
    
//    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:USERID];//[self userData]
    NSLog(@"%@", [[UserInfo sharedInstance] userData]);
    
    if ([[UserInfo sharedInstance] userData]) {
        [[[[[FIRDatabase database] reference] child:USERS_REF] child:[FIRAuth auth].currentUser.uid] setValue:[[UserInfo sharedInstance] userData]];
//        RootViewController *rootVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RootViewController"];
//        [self.navigationController pushViewController:rootVC animated:YES];
        AppDelegate *myDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [myDelegate setRootViewController];
        
    }else {
        [self showPopupAlertWithString:@"There are some error. Please try again later!" isError:YES textalign:NSTextAlignmentCenter];
    }
    
    [ProgressHUD dismiss];
}

- (IBAction)backTouchUp:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.bandTF) {
        [textField resignFirstResponder];
        [self.bookTF becomeFirstResponder];
    }else if (textField == self.bookTF) {
        [textField resignFirstResponder];
        [self.movieTF becomeFirstResponder];
    }else if (textField == self.movieTF) {
        [textField resignFirstResponder];
        [self.placeTF becomeFirstResponder];
    }else if (textField == self.placeTF) {
        [textField resignFirstResponder];
        [self.topViewTopContraint setConstant:0];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.placeTF) {
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.topViewTopContraint setConstant:-100];
            [self.topView layoutIfNeeded];
            [self.centerViewCenterX setConstant:-100];
            [self.centerView layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.placeTF) {
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.topViewTopContraint setConstant:0];
            [self.topView layoutIfNeeded];
            [self.centerViewCenterX setConstant:0];
            [self.centerView layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark - View Tap Gesture

- (IBAction)tapGestureForView:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}


#pragma mark - Custom Method

- (void)setFontSizeForControls {
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    CGFloat size1 = h * 20 / 667;
    
    [self.pickLabel setFont:[UIFont systemFontOfSize:size1]];
    [self.bandTF setFont:[UIFont systemFontOfSize:size1]];
    [self.bookTF setFont:[UIFont systemFontOfSize:size1]];
    [self.movieTF setFont:[UIFont systemFontOfSize:size1]];
    [self.placeTF setFont:[UIFont systemFontOfSize:size1]];
    
    [self.backButton.titleLabel setFont:[UIFont systemFontOfSize:size1]];
    [self.doneButton.titleLabel setFont:[UIFont systemFontOfSize:size1]];
}

- (NSDictionary *)userData {
    NSDictionary *userData = @{USERNAME: [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME]
                               , EMAIL: [[NSUserDefaults standardUserDefaults] objectForKey:EMAIL]
                               , GENDER: [[NSUserDefaults standardUserDefaults] objectForKey:GENDER]
                               , MEET_OPTION: [[NSUserDefaults standardUserDefaults] objectForKey:MEET_OPTION]
                               , NETWORK_OPTION: [[NSUserDefaults standardUserDefaults] objectForKey:NETWORK_OPTION]
                               , CURRENT_CITY: [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_CITY]
                               , HOME_CITY: [[NSUserDefaults standardUserDefaults] objectForKey:HOME_CITY]
                               , OCCUPATION: [[NSUserDefaults standardUserDefaults] objectForKey:OCCUPATION]
                               , COLLEGE: [[NSUserDefaults standardUserDefaults] objectForKey:COLLEGE]
                               , FIRST_CITY: [[NSUserDefaults standardUserDefaults] objectForKey:FIRST_CITY]
                               , SECOND_CITY: [[NSUserDefaults standardUserDefaults] objectForKey:SECOND_CITY]
                               , THIRD_CITY: [[NSUserDefaults standardUserDefaults] objectForKey:THIRD_CITY]
                               , FIRST_INTEREST: [[NSUserDefaults standardUserDefaults] objectForKey:FIRST_INTEREST]
                               , SECOND_INTEREST: [[NSUserDefaults standardUserDefaults] objectForKey:SECOND_INTEREST]
                               , THIRD_INTEREST: [[NSUserDefaults standardUserDefaults] objectForKey:THIRD_INTEREST]
                               , BAND: [[NSUserDefaults standardUserDefaults] objectForKey:BAND]
                               , BOOK: [[NSUserDefaults standardUserDefaults] objectForKey:BOOK]
                               , MOVIE: [[NSUserDefaults standardUserDefaults] objectForKey:MOVIE]
                               , PLACE: [[NSUserDefaults standardUserDefaults] objectForKey:PLACE]
                               };
    
    return userData;
}

- (void)showPopupAlertWithString: (NSString *)msg isError: (BOOL)isError textalign: (NSTextAlignment)align{
    
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

@end
