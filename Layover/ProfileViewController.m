//
//  ProfileViewController.m
//  Layovr
//
//  Created by Daniel Drescher on 07/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileSettingViewController.h"
#import "CameraViewController.h"

@interface ProfileViewController() <UITextFieldDelegate>{
    FIRDatabaseHandle getUserDataHandle;
}

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *profileTitle;
//    if ([[[NSUserDefaults standardUserDefaults] objectForKey:USERNAME] isEqualToString:EMPTY_STRING] || ![[NSUserDefaults standardUserDefaults] objectForKey:USERNAME]) {
//        profileTitle = @"My Profile";
//    }else{
//        profileTitle = [NSString stringWithFormat:@"%@'s Profile", [[NSUserDefaults standardUserDefaults] objectForKey: USERNAME]];
//    }
    
    if ([[FIRAuth auth].currentUser.displayName isEqualToString:EMPTY_STRING]) {
        profileTitle = @"My Profile";
    }else {
        profileTitle = [NSString stringWithFormat:@"%@'s Profile", [FIRAuth auth].currentUser.displayName];
    }
    
    [self.nameLabel setText:profileTitle];
    
    [self.cityTF setReturnKeyType:UIReturnKeyNext];
    [self.jobTF setReturnKeyType:UIReturnKeyNext];
    [self.collegeTF setReturnKeyType:UIReturnKeyNext];
    [self.homeTownTF setReturnKeyType:UIReturnKeyNext];
    [self.intoTF setReturnKeyType:UIReturnKeyNext];
    [self.bandTF setReturnKeyType:UIReturnKeyNext];
    [self.bookTF setReturnKeyType:UIReturnKeyNext];
    [self.movieTF setReturnKeyType:UIReturnKeyNext];
    [self.placeTF setReturnKeyType:UIReturnKeyDone];
    
    [self disableContentEditing];
    
    [self setFontSizeForLabels];
    
    [self.avatarImageV.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.avatarImageV.layer setBorderWidth:2];
    [self.avatarImageV.layer setCornerRadius:10];
    [self.avatarImageV setClipsToBounds:YES];
    
    [self setUserDataInTextFields];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self displayAvatarImage];
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:AVATARIMAGE]) {//[[NSUserDefaults standardUserDefaults] objectForKey:ISUSEFROMCAMERA] == [NSNumber numberWithBool:YES] && 
//        [self.avatarImageV setImage:[UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:AVATARIMAGE]]];
//        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:ISUSEFROMCAMERA];
//    }else{
//        [self.avatarImageV setImage:[UIImage imageNamed:@"user.png"]];
//    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIButton Touch Up

- (IBAction)editTouchUp:(UIButton *)sender {
    if ([self.editBt.titleLabel.text isEqualToString:@"Edit"]) {
        [self enableContentEditing];
        [self hideAvatarImage];
        [self moveContentViewToTop];
        
        [self showEditButtons];
    }else{// "cancel"
        [self disableContentEditing];
        [self showAvatarImage];
        [self moveContentViewToBottom];
        
        [self hideEditButtons];
        
        [self setUserDataInTextFields];
    }
}

- (IBAction)settingsTouchUp:(UIButton *)sender {
    if ([self.settingsBt.titleLabel.text isEqualToString:@"Settings"]) {
        ProfileSettingViewController *profileSettingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileSettingViewController"];
        [self.navigationController pushViewController:profileSettingVC animated:YES];
    }else{// "save"
        [self saveUserdata];// Save the user data to firebase DB
        
        getUserDataHandle = [[[[[FIRDatabase database] reference] child:USERS_REF] child:[FIRAuth auth].currentUser.uid] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            NSDictionary *myDic = snapshot.value;
            if (![myDic isEqual:[NSNull null]]) {
                [[UserInfo sharedInstance] setUserInfo:snapshot.value];
                [self setUserDataInTextFields];
            }
            
            [[[[[FIRDatabase database] reference] child:USERS_REF] child:[FIRAuth auth].currentUser.uid] removeObserverWithHandle:getUserDataHandle];
        }];
    }
}

- (IBAction)avatarTouchUp:(UIButton *)sender {
    CameraViewController *camerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraViewController"];
    [camerVC setIsFromProfileView:YES];
    [self presentViewController:camerVC animated:YES completion:nil];
}

#pragma mark - Custom Method

- (void)displayAvatarImage {
    NSNumber *isExisted = [[NSUserDefaults standardUserDefaults] objectForKey:AVATAR_ISEXISTED];
    NSNumber *isDownloaded = [[NSUserDefaults standardUserDefaults] objectForKey:AVATAR_ISDOWNLOADED];
    if ([isExisted isEqual:[NSNumber numberWithBool:YES]]) {
        if ([isDownloaded isEqual:[NSNumber numberWithBool:YES]]) {
            [self.avatarImageV setImage:[UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:AVATARIMAGE]]];
        }else {
            FIRStorageReference *httpRef = [[FIRStorage storage] referenceForURL:[FIRAuth auth].currentUser.photoURL.absoluteString];
            [httpRef dataWithMaxSize:1 * 1024 * 1024 completion:^(NSData * _Nullable data, NSError * _Nullable error) {
                
                if (error) {
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:AVATAR_ISDOWNLOADED];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.avatarImageV setImage:[UIImage imageNamed:@"user.png"]];
                    });
                }else {
                    [[NSUserDefaults standardUserDefaults] setObject:data forKey:AVATARIMAGE];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:AVATAR_ISDOWNLOADED];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.avatarImageV setImage:[UIImage imageWithData:data]];
                    });
                }
            }];
        }
    }else {
        [self.avatarImageV setImage:[UIImage imageNamed:@"user.png"]];
    }
}

- (void)saveUserdata {
    NSMutableDictionary *dic = [[[UserInfo sharedInstance] userData] mutableCopy];
    [dic setValue:self.cityTF.text forKey:CURRENT_CITY];
    [dic setValue:self.jobTF.text forKey:OCCUPATION];
    [dic setValue:self.collegeTF.text forKey:COLLEGE];
    [dic setValue:self.homeTownTF.text forKey:HOME_CITY];
    [dic setValue:self.bandTF.text forKey:BAND];
    [dic setValue:self.bookTF.text forKey:BOOK];
    [dic setValue:self.movieTF.text forKey:MOVIE];
    [dic setValue:self.placeTF.text forKey:PLACE];
    
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:AVATARIMAGE]) {
//        [dic setValue:[[NSUserDefaults standardUserDefaults] objectForKey:AVATARIMAGE] forKey:AVATARIMAGE];
//    }
    
    [[UserInfo sharedInstance] setUserInfo:dic];
    
//    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:USERID];
    
    [ProgressHUD show:@"Saving..." Interaction:NO];
    
    [[[[[FIRDatabase database] reference] child:USERS_REF] child:[FIRAuth auth].currentUser.uid] setValue:dic];
    
    [self disableContentEditing];
    [self showAvatarImage];
    [self moveContentViewToBottom];

    [self hideEditButtons];
    
    [ProgressHUD dismiss];
}

- (void)showPopupAlertWithString: (NSString *)msg isError: (BOOL)isError textAlign: (NSTextAlignment)align{
    
    [self.view endEditing:YES];
    
    UIView *labelV = [MyAlert alertLabel:msg isError:isError textAlign: align];
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

- (void)setFontSizeForLabels {
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    CGFloat labelFS = h * 18 / 667;
    CGFloat textFS = h * 20 / 667;
    CGFloat buttonFS = h * 17 / 667;
    
    [self.cityLabel setFont:[UIFont systemFontOfSize:labelFS]];
    [self.jobLabel setFont:[UIFont systemFontOfSize:labelFS]];
    [self.collegeLabel setFont:[UIFont systemFontOfSize:labelFS]];
    [self.homeTownLabel setFont:[UIFont systemFontOfSize:labelFS]];
    [self.intoLabel setFont:[UIFont systemFontOfSize:labelFS]];
    [self.bandLabel setFont:[UIFont systemFontOfSize:labelFS]];
    [self.bookLabel setFont:[UIFont systemFontOfSize:labelFS]];
    [self.movieLabel setFont:[UIFont systemFontOfSize:labelFS]];
    [self.placeLabel setFont:[UIFont systemFontOfSize:labelFS]];
    
    [self.cityTF setFont:[UIFont systemFontOfSize:textFS]];
    [self.jobTF setFont:[UIFont systemFontOfSize:textFS]];
    [self.collegeTF setFont:[UIFont systemFontOfSize:textFS]];
    [self.homeTownTF setFont:[UIFont systemFontOfSize:textFS]];
    [self.intoTF setFont:[UIFont systemFontOfSize:textFS]];
    [self.bandTF setFont:[UIFont systemFontOfSize:textFS]];
    [self.bookTF setFont:[UIFont systemFontOfSize:textFS]];
    [self.movieTF setFont:[UIFont systemFontOfSize:textFS]];
    [self.placeTF setFont:[UIFont systemFontOfSize:textFS]];
    
    [self.editBt.titleLabel setFont:[UIFont systemFontOfSize:buttonFS]];
    [self.settingsBt.titleLabel setFont:[UIFont systemFontOfSize:buttonFS]];
    [self.nameLabel setFont:[UIFont systemFontOfSize:labelFS]];
}

- (void)showAvatarImage {
    [self.avatarImageV setHidden:NO];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.avatarImageV setAlpha:1];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideAvatarImage {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.avatarImageV setAlpha:0];
    } completion:^(BOOL finished) {
        [self.avatarImageV setHidden:YES];
    }];
}

- (void)moveContentViewToTop {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.bottomContentViewConstraint setConstant:self.avatarImageV.frame.size.height];
        [self.contentV layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)moveContentViewToBottom {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.bottomContentViewConstraint setConstant:8];
        [self.contentV layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)enableContentEditing {
    [self.cityTF setEnabled:YES];
    [self.jobTF setEnabled:YES];
    [self.collegeTF setEnabled:YES];
    [self.homeTownTF setEnabled:YES];
    [self.intoTF setEnabled:YES];
    [self.bandTF setEnabled:YES];
    [self.bookTF setEnabled:YES];
    [self.movieTF setEnabled:YES];
    [self.placeTF setEnabled:YES];
    
    [self.cityTF becomeFirstResponder];
}

- (void)disableContentEditing {
    [self.cityTF setEnabled:NO];
    [self.jobTF setEnabled:NO];
    [self.collegeTF setEnabled:NO];
    [self.homeTownTF setEnabled:NO];
    [self.intoTF setEnabled:NO];
    [self.bandTF setEnabled:NO];
    [self.bookTF setEnabled:NO];
    [self.movieTF setEnabled:NO];
    [self.placeTF setEnabled:NO];
}

- (void)showEditButtons {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.editBt setTitle:@"cancel" forState:UIControlStateNormal];
        [self.settingsBt setTitle:@"save" forState:UIControlStateNormal];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideEditButtons {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.editBt setTitle:@"Edit" forState:UIControlStateNormal];
        [self.settingsBt setTitle:@"Settings" forState:UIControlStateNormal];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)moveContentViewToTopWithNumber: (NSInteger)num {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.bottomContentViewConstraint setConstant:self.avatarImageV.frame.size.height + self.bandTF.frame.size.height * num];
        [self.contentV layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)moveContentViewToBottomForEditing {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.bottomContentViewConstraint setConstant:self.avatarImageV.frame.size.height];
        [self.contentV layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)setUserDataInTextFields {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        NSMutableDictionary *dic = [[[UserInfo sharedInstance] userData] mutableCopy];
        [self.cityTF setText:[dic objectForKey:CURRENT_CITY]];
        [self.jobTF setText:[dic objectForKey:OCCUPATION]];
        [self.collegeTF setText:[dic objectForKey:COLLEGE]];
        [self.homeTownTF setText:[dic objectForKey:HOME_CITY]];
        //    self.intoTF setText:[dic objectForKey:]
        [self.bandTF setText:[dic objectForKey:BAND]];
        [self.bookTF setText:[dic objectForKey:BOOK]];
        [self.movieTF setText:[dic objectForKey:MOVIE]];
        [self.placeTF setText:[dic objectForKey:PLACE]];
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.cityTF) {
        [textField resignFirstResponder];
        [self.jobTF becomeFirstResponder];
    }else if (textField == self.jobTF) {
        [textField resignFirstResponder];
        [self.collegeTF becomeFirstResponder];
    }else if (textField == self.collegeTF) {
        [textField resignFirstResponder];
        [self.homeTownTF becomeFirstResponder];
    }else if (textField == self.homeTownTF) {
        [textField resignFirstResponder];
        [self.intoTF becomeFirstResponder];
    }else if (textField == self.intoTF) {
        [textField resignFirstResponder];
        [self.bandTF becomeFirstResponder];
    }else if (textField == self.bandTF) {
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
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.bandTF) {
        [self moveContentViewToTopWithNumber:1];
    }else if (textField == self.bookTF) {
        [self moveContentViewToTopWithNumber:2];
    }else if (textField == self.movieTF) {
        [self moveContentViewToTopWithNumber:3];
    }else if (textField == self.placeTF) {
        [self moveContentViewToTopWithNumber:4];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self moveContentViewToBottomForEditing];
}

#pragma mark - View Tap Gesture

- (IBAction)tapGestureForView:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

@end
