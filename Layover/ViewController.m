//
//  ViewController.m
//  Layover
//
//  Created by Daniel Drescher on 31/05/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "ViewController.h"
#import "SignUpViewController.h"
#import "RootViewController.h"
#import "AppDelegate.h"
//#import <ifaddrs.h>
//#import <net/if.h>
//#import <SystemConfiguration/CaptiveNetwork.h>

@interface ViewController () <UITextFieldDelegate> {
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setFontSizeForControls];
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

#pragma mark - custom event

- (IBAction)viewTapGesture:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (IBAction)forgotPasswordTouchUp:(UIButton *)sender {
    
    // Check Email Address Valid or Invalid
    if (![self.emailTextF.text isValidString]) {
//        [self showErrorAlertWithString:@"Invalid Email Address!" textField:self.emailTextF];
        [self showPopupAlertWithString:@"Invalid Email Address!" isError:YES textAlign:NSTextAlignmentCenter];
        return;
    }
    
    [ProgressHUD show:@"Resetting..." Interaction:NO];

    [[FIRAuth auth] sendPasswordResetWithEmail:self.emailTextF.text completion:^(NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showPopupAlertWithString:error.localizedDescription isError:YES textAlign:NSTextAlignmentCenter];
                [self.emailTextF setText:@""];
                [ProgressHUD dismiss];
            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showPopupAlertWithString:@"Your password was just reseted successfully.\nPlease check your email!" isError:NO textAlign:NSTextAlignmentCenter];
            });
        }
    }];
    
//    [[DataService base_ref] resetPasswordForUser:self.emailTextF.text withCompletionBlock:^(NSError *error) {
//        if (error) {
//            NSString *errorStr;
//            if ([error.localizedDescription containsString:@")"]) {
//                NSRange range = [error.localizedDescription rangeOfString:@")"];
//                errorStr = [error.localizedDescription substringFromIndex:range.location + range.length];
//            }else{
//                errorStr = error.localizedDescription;
//            }
//            [self showPopupAlertWithString:errorStr isError:YES textAlign:NSTextAlignmentCenter];
//            [self.emailTextF setText:@""];
//        }else{
//            [self showSuccessAlertWithString:@"Your password was just reseted successfully.\nPlease check your email!"];
//            [self showPopupAlertWithString:@"Your password was just reseted successfully.\nPlease check your email!" isError:NO textAlign:NSTextAlignmentCenter];
//        }
//        
//        [ProgressHUD dismiss];
//    }];
    
//    SignUpViewController *signUpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpViewController"];
//    [self.navigationController pushViewController:signUpVC animated:YES];
}

- (IBAction)continueTouchUp:(UIButton *)sender {
    
    if (![self.emailTextF.text isValidString]) {
//        [self showErrorAlertWithString:@"Invalid Email Address!" textField:self.emailTextF];
        [self showPopupAlertWithString:@"Invalid Email Address!" isError:YES textAlign:NSTextAlignmentCenter];
        [self.emailTextF setText:@""];
        return;
    }
    
    if ([self.passwordTextF.text isEqualToString:@""]) {
//        [self showErrorAlertWithString:@"Please input your password!" textField:self.passwordTextF];
        [self showPopupAlertWithString:@"Please input your password!" isError:YES textAlign:NSTextAlignmentCenter];
        return;
    }
    
    
    [ProgressHUD show:@"Sign in..." Interaction:NO];
    
    [[FIRAuth auth] signInWithEmail:self.emailTextF.text password:self.passwordTextF.text completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        
        if (error) {// login failed
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showPopupAlertWithString:error.localizedDescription isError:YES textAlign:NSTextAlignmentCenter];
                [ProgressHUD dismiss];
            });
        }else {//login successfully
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:ISUSEFROMCAMERA];
            [[NSUserDefaults standardUserDefaults] setObject:user.uid forKey:USERID];
            NSLog(@"ProviderID: %@", user.providerID);
            NSLog(@"uid: %@", user.uid);
            NSLog(@"name: %@", user.displayName);
            NSLog(@"email: %@", user.email);
            NSLog(@"photoURL: %@", user.photoURL);
            
            if (user.photoURL != nil) {// PhotoURL is generated
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:AVATAR_ISEXISTED];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:AVATAR_ISDOWNLOADED];
                
                FIRStorageReference *httpRef = [[FIRStorage storage] referenceForURL:user.photoURL.absoluteString];
                [httpRef dataWithMaxSize:1 * 1024 * 1024 completion:^(NSData * _Nullable data, NSError * _Nullable error) {
                    
                    [[NSUserDefaults standardUserDefaults] setObject:data forKey:AVATARIMAGE];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:AVATAR_ISDOWNLOADED];
                }];
                
            }else {
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:AVATAR_ISEXISTED];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:AVATAR_ISDOWNLOADED];
            }
            
            [ProgressHUD dismiss];
            
            // Get user Data
            AppDelegate *myDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [myDelegate setRootViewController];
            
            //            [[UserInfo sharedInstance] getUserInfo:user.uid];
        }
    
    }];
    
//    [[DataService base_ref] authUser:self.emailTextF.text password:self.passwordTextF.text withCompletionBlock:^(NSError *error, FAuthData *authData) {
//        
//        if (error) {//You can not login
//            if ([error.localizedDescription containsString:ERROR_INVALID_PASSWORD]) {
//                NSRange range = [error.localizedDescription rangeOfString:@")"];
////                [self showErrorAlertWithString:[error.localizedDescription substringFromIndex:range.location + range.length] textField:self.passwordTextF];
//                [self showPopupAlertWithString:[error.localizedDescription substringFromIndex:range.location + range.length] isError:YES textAlign:NSTextAlignmentCenter];
//                [self.passwordTextF setText:@""];
//            }else if ([error.localizedDescription containsString:ERROR_INVALID_EMAIL] || [error.localizedDescription containsString:ERROR_INVALID_USER]) {
//                
//                NSRange range = [error.localizedDescription rangeOfString:@")"];
//                //                [self showErrorAlertWithString:[error.localizedDescription substringFromIndex:range.location + range.length] textField:self.passwordTextF];
//                [self showPopupAlertWithString:[error.localizedDescription substringFromIndex:range.location + range.length] isError:YES textAlign:NSTextAlignmentCenter];
//                [self.emailTextF setText:@""];
//            }else {
////                [self showErrorAlertWithString:@"There are some errors.\nPlease try again later!" textField:nil];
//                [self showPopupAlertWithString:@"There are some errors.\nPlease try again later!" isError:YES textAlign:NSTextAlignmentCenter];
//            }
//        }else{// login successfully
//            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:ISUSEFROMCAMERA];
//            [[NSUserDefaults standardUserDefaults] setObject:authData.uid forKey:USERID];
//            [[NSUserDefaults standardUserDefaults] setObject:[authData.providerData objectForKey:@"profileImageURL"] forKey:PHOTO];
//            
//            [[DataService user_ref:authData.uid] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//                NSLog(@"%@", snapshot);
//                if (snapshot.value) {
//                    NSDictionary *myData = snapshot.value;
//                    
//                    [[UserInfo sharedInstance] setUserInfo:myData];
//                }
//            }];
//            
//            RootViewController *rootVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RootViewController"];
//            [rootVC setIsFromCameraView:NO];
//            [self.navigationController pushViewController:rootVC animated:YES];
//        }
//        
//        [ProgressHUD dismiss];
//    }];
}

- (IBAction)signUpTouchUp:(UIButton *)sender {
    SignUpViewController *signUpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpViewController"];
    [self.navigationController pushViewController:signUpVC animated:YES];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextF) {
        [textField resignFirstResponder];
        [self.passwordTextF becomeFirstResponder];
        
        return NO;
    }else if (textField == self.passwordTextF) {
        [textField resignFirstResponder];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - Custom Method

- (void)setFontSizeForControls {
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    CGFloat size1 = h * 25 / 667;
    CGFloat size2 = h * 18 / 667;
    CGFloat size3 = h * 17 / 667;
    CGFloat size4 = h * 20 / 667;
    
    [self.signInLabel setFont:[UIFont systemFontOfSize:size1]];
    [self.emailTextF setFont:[UIFont systemFontOfSize:size2]];
    [self.passwordTextF setFont:[UIFont systemFontOfSize:size2]];
    [self.forgotPasswordBt.titleLabel setFont:[UIFont systemFontOfSize:size3]];
    [self.continueBt.titleLabel setFont:[UIFont systemFontOfSize:size4]];
    [self.signUpButton.titleLabel setFont:[UIFont systemFontOfSize:size4]];
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

- (void)showSuccessAlertWithString: (NSString *)msg {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    NSMutableAttributedString *errorStr = [[NSMutableAttributedString alloc] initWithString:msg];
    [errorStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, errorStr.length)];
    [alert setValue:errorStr forKey:@"attributedMessage"];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setUserData: (NSDictionary *)myData {
    if ([myData objectForKey:EMAIL]) {
        [[NSUserDefaults standardUserDefaults] setObject:[myData objectForKey:EMAIL] forKey:EMAIL];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:EMAIL];
    }
    
    if ([myData objectForKey:BAND]) {
        [[NSUserDefaults standardUserDefaults] setObject:[myData objectForKey:BAND] forKey:BAND];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:BAND];
    }
    
    if ([myData objectForKey:BOOK]) {
        [[NSUserDefaults standardUserDefaults] setObject:[myData objectForKey:BOOK] forKey:BOOK];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:BOOK];
    }
    
    if ([myData objectForKey:COLLEGE]) {
        [[NSUserDefaults standardUserDefaults] setObject:[myData objectForKey:COLLEGE] forKey:COLLEGE];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:COLLEGE];
    }
    
    if ([myData objectForKey:CURRENT_CITY]) {
        [[NSUserDefaults standardUserDefaults] setObject:[myData objectForKey:CURRENT_CITY] forKey:CURRENT_CITY];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:CURRENT_CITY];
    }
    
    if ([myData objectForKey:MEET_OPTION]) {
        [[NSUserDefaults standardUserDefaults] setObject:[myData objectForKey:MEET_OPTION] forKey:MEET_OPTION];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:MEET_OPTION];
    }
    
    if ([myData objectForKey:NETWORK_OPTION]) {
        [[NSUserDefaults standardUserDefaults] setObject:[myData objectForKey:NETWORK_OPTION] forKey:NETWORK_OPTION];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:NETWORK_OPTION];
    }
    
    if ([myData objectForKey:FIRST_CITY]) {
        [[NSUserDefaults standardUserDefaults] setObject:[myData objectForKey:FIRST_CITY] forKey:FIRST_CITY];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:FIRST_CITY];
    }
    
    if ([myData objectForKey:FIRST_INTEREST]) {
        [[NSUserDefaults standardUserDefaults] setObject:[myData objectForKey:FIRST_INTEREST] forKey:FIRST_INTEREST];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:FIRST_INTEREST];
    }
    
    if ([myData objectForKey:HOME_CITY]) {
        [[NSUserDefaults standardUserDefaults] setObject:[myData objectForKey:HOME_CITY] forKey:HOME_CITY];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:HOME_CITY];
    }
    
    if ([myData objectForKey:MOVIE]) {
        [[NSUserDefaults standardUserDefaults] setObject:[myData objectForKey:MOVIE] forKey:MOVIE];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:MOVIE];
    }
    
    if ([myData objectForKey:OCCUPATION]) {
        [[NSUserDefaults standardUserDefaults] setObject:[myData objectForKey:OCCUPATION] forKey:OCCUPATION];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:OCCUPATION];
    }
    
    if ([myData objectForKey:PLACE]) {
        [[NSUserDefaults standardUserDefaults] setObject:[myData objectForKey:PLACE] forKey:PLACE];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:PLACE];
    }
    
    if ([myData objectForKey:SECOND_CITY]) {
        [[NSUserDefaults standardUserDefaults] setObject:[myData objectForKey:SECOND_CITY] forKey:SECOND_CITY];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:SECOND_CITY];
    }
    
    if ([myData objectForKey:SECOND_INTEREST]) {
        [[NSUserDefaults standardUserDefaults] setObject:[myData objectForKey:SECOND_INTEREST] forKey:SECOND_INTEREST];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:SECOND_INTEREST];
    }
    
    if ([myData objectForKey:THIRD_CITY]) {
        [[NSUserDefaults standardUserDefaults] setObject:[myData objectForKey:THIRD_CITY] forKey:THIRD_CITY];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:THIRD_CITY];
    }
    
    if ([myData objectForKey:THIRD_INTEREST]) {
        [[NSUserDefaults standardUserDefaults] setObject:[myData objectForKey:THIRD_INTEREST] forKey:THIRD_INTEREST];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:THIRD_INTEREST];
    }
    
    if ([myData objectForKey:USERNAME]) {
        [[NSUserDefaults standardUserDefaults] setObject:[myData objectForKey:USERNAME] forKey:USERNAME];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:EMPTY_STRING forKey:USERNAME];
    }
}

@end
