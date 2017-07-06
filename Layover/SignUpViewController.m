//
//  SignUpViewController.m
//  Layovr
//
//  Created by Daniel Drescher on 03/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "SignUpViewController.h"
#import "Screen1ViewController.h"

@interface SignUpViewController () <UITextFieldDelegate>{
    DVSwitch *genderSwitch;
}

@end

@implementation SignUpViewController

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

#pragma mark - init view
- (void)initUIControlsInView {
    CGFloat w = [[UIScreen mainScreen] bounds].size.width;
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    CGFloat size1 = h * 25 / 667;
    CGFloat size2 = h * 18 / 667;
    CGFloat size3 = h * 20 / 667;
    
    [self.signUpLabel setFont:[UIFont systemFontOfSize:size1]];
    
    [self.emailTextF setFont:[UIFont systemFontOfSize:size2]];
    [self.passwordTextF setFont:[UIFont systemFontOfSize:size2]];
    [self.retypeTextF setFont:[UIFont systemFontOfSize:size2]];
    
    [self.usernameTextF setFont:[UIFont systemFontOfSize:size1]];
    [self.ageTextF setFont:[UIFont systemFontOfSize:size1]];
    
    [self.ageTextF setKeyboardType:UIKeyboardTypeNumberPad];
    
    [self.continueBt.titleLabel setFont:[UIFont systemFontOfSize:size3]];
    [self.signInBt.titleLabel setFont:[UIFont systemFontOfSize:size3]];
    
    [self.emailTextF setReturnKeyType:UIReturnKeyNext];
    [self.passwordTextF setReturnKeyType:UIReturnKeyNext];
    [self.retypeTextF setReturnKeyType:UIReturnKeyNext];
    [self.usernameTextF setReturnKeyType:UIReturnKeyNext];
    [self.ageTextF setReturnKeyType:UIReturnKeyDone];
    
    // Gender Switch
    
    genderSwitch = [DVSwitch switchWithStringsArray:@[@"Female", @"Male", @"Trans"]];
    genderSwitch.frame = CGRectMake(w / 6, h * 3 / 4, w * 2 / 3, h / 14);
    genderSwitch.font = [UIFont systemFontOfSize:h / 30 weight:UIFontWeightMedium];
    genderSwitch.backgroundColor = [UIColor whiteColor];
    genderSwitch.sliderColor = [UIColor colorWithRed:51/255.0 green:102/255.0 blue:255/255.0 alpha:1.0];
    [genderSwitch setSelectedIndex:1];
    [self.view addSubview:genderSwitch];
    
    //UILabel "I am :"
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, h * 2 / 3, w, h / 12)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont systemFontOfSize:25 weight:UIFontWeightMedium]];
    [label setText:@"I am :"];
    [self.view addSubview:label];
    
    
}

#pragma mark - Custom Event

- (IBAction)continueButtonTouchUp:(UIButton *)sender {
    
    if (![[self.emailTextF text] isValidString]) {
//        [self showErrorAlertWithString:@"Invalid Email Address!" textField:self.emailTextF];
        [self showPopupAlertWithString:@"Invalid Email Address!" isError:YES textAlign:NSTextAlignmentCenter];
        [self.emailTextF setText:@""];
        return;
    }
    if ([self.passwordTextF.text isEqualToString:@""]) {
//        [self showErrorAlertWithString:@"Please set your password!" textField:self.passwordTextF];
        [self showPopupAlertWithString:@"Please set your password!" isError:YES textAlign:NSTextAlignmentCenter];
        return;
    }
    if ([self.retypeTextF.text isEqualToString:@""]) {
//        [self showErrorAlertWithString:@"Please confirm your password!" textField:self.retypeTextF];
        [self showPopupAlertWithString:@"Please confirm your password!" isError:YES textAlign:NSTextAlignmentCenter];
        return;
    }
    if (![[self.usernameTextF text] isValidString]) {
//        [self showErrorAlertWithString:@"Please set the valid name" textField:self.usernameTextF];
        [self showPopupAlertWithString:@"Please set the valid name!" isError:YES textAlign:NSTextAlignmentCenter];
        [self.usernameTextF setText:@""];
        return;
    }
    if (![self.passwordTextF.text isEqualToString:self.retypeTextF.text]) {
//        [self showErrorAlertWithString:@"Please confirm password again!" textField:self.retypeTextF];
        [self showPopupAlertWithString:@"Please confirm password again!" isError:YES textAlign:NSTextAlignmentCenter];
        [self.retypeTextF setText:@""];
        return;
    }    
    
    // Update user info and Continue to set other features
    [ProgressHUD show:@"Registering..." Interaction:NO];
    
    [[FIRAuth auth] createUserWithEmail:self.emailTextF.text password:self.passwordTextF.text completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showPopupAlertWithString:error.localizedDescription isError:YES textAlign:NSTextAlignmentCenter];
                [ProgressHUD dismiss];
            });
        }else {
            [[NSUserDefaults standardUserDefaults] setObject:self.emailTextF.text forKey:EMAIL];
            [[NSUserDefaults standardUserDefaults] setObject:self.passwordTextF.text forKey:PASSWORD];
            [[NSUserDefaults standardUserDefaults] setObject:self.usernameTextF.text forKey:USERNAME];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:[self.ageTextF.text integerValue]] forKey:AGE];
            [[NSUserDefaults standardUserDefaults] setObject:user.uid forKey:USERID];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:genderSwitch.selectedIndex] forKey:GENDER];

            [[[UserInfo sharedInstance] userData] setValue:self.emailTextF.text forKey:EMAIL];
//            [[[UserInfo sharedInstance] userData] setValue:self.passwordTextF.text forKey:PASSWORD];
            [[[UserInfo sharedInstance] userData] setValue:self.usernameTextF.text forKey:USERNAME];
//            [[[UserInfo sharedInstance] userData] setValue:[result objectForKey:USERID] forKey:USERID];
            [[[UserInfo sharedInstance] userData] setValue:[NSNumber numberWithInteger:genderSwitch.selectedIndex] forKey:GENDER];
            [[[UserInfo sharedInstance] userData] setValue:[NSNumber numberWithInteger:[self.ageTextF.text integerValue]] forKey:AGE];
            
            FIRUserProfileChangeRequest *changeRequest = [user profileChangeRequest];
            [changeRequest setDisplayName:self.usernameTextF.text];
            [changeRequest commitChangesWithCompletion:^(NSError * _Nullable error) {
                
            }];

            Screen1ViewController *screen1VC = [self.storyboard instantiateViewControllerWithIdentifier:@"Screen1ViewController"];
            [self.navigationController pushViewController:screen1VC animated:YES];
            
            [ProgressHUD dismiss];
        }
    }];
}

- (IBAction)signInTouchUp:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)viewTapGesture:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextF) {
        [textField resignFirstResponder];
        [self.passwordTextF becomeFirstResponder];
    }else if (textField == self.passwordTextF) {
        [textField resignFirstResponder];
        [self.retypeTextF becomeFirstResponder];
    }else if (textField == self.retypeTextF) {
        [textField resignFirstResponder];
        [self.usernameTextF becomeFirstResponder];
    }else if (textField == self.usernameTextF) {
        [textField resignFirstResponder];
        [self.ageTextF becomeFirstResponder];
    }else {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - Custom Method

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

@end
