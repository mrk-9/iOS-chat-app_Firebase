//
//  CameraViewController.m
//  Layovr
//
//  Created by Daniel Drescher on 07/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "CameraViewController.h"
#import "LLSimpleCamera.h"
#import "RootViewController.h"

#define TimeStamp [NSString stringWithFormat: @"%f", [[NSDate date] timeIntervalSince1970] * 1000]

@interface CameraViewController() {
    BOOL isFromProfile;
    BOOL isCancel;
}
@property (strong, nonatomic) LLSimpleCamera *camera;
@property (strong, nonatomic) UILabel *errorLabel;

@property (weak, nonatomic) IBOutlet UIButton *snapButton;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageV;
@property (weak, nonatomic) IBOutlet UIButton *switchButton;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.camera = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPresetHigh
                                                 position:LLCameraPositionRear
                                             videoEnabled:YES];
    
    // attach to a view controller
    [self.camera attachToViewController:self withFrame:CGRectMake(0, 70, screenRect.size.width, screenRect.size.width)];
    
    // you probably will want to set this to YES, if you are going view the image outside iOS.
    self.camera.fixOrientationAfterCapture = NO;

    // take the required actions on a device change
    __weak typeof(self) weakSelf = self;
    [self.camera setOnDeviceChange:^(LLSimpleCamera *camera, AVCaptureDevice * device) {
        
        NSLog(@"Device changed.");
        
        // device changed, check if flash is available
        if([camera isFlashAvailable]) {
            weakSelf.flashButton.hidden = NO;
            
            if(camera.flash == LLCameraFlashOff) {
                weakSelf.flashButton.selected = NO;
            }
            else {
                weakSelf.flashButton.selected = YES;
            }
        }
        else {
            weakSelf.flashButton.hidden = YES;
        }
    }];
    
    [self.camera setOnError:^(LLSimpleCamera *camera, NSError *error) {
        NSLog(@"Camera error: %@", error);
        
        if([error.domain isEqualToString:LLSimpleCameraErrorDomain]) {
            if(error.code == LLSimpleCameraErrorCodeCameraPermission ||
               error.code == LLSimpleCameraErrorCodeMicrophonePermission) {
                
                if(weakSelf.errorLabel) {
                    [weakSelf.errorLabel removeFromSuperview];
                }
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
                label.text = @"We need permission for the camera.\nPlease go to your settings.";
                label.numberOfLines = 2;
                label.lineBreakMode = NSLineBreakByWordWrapping;
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont systemFontOfSize:13.0f];
                label.textColor = [UIColor redColor];
                label.textAlignment = NSTextAlignmentCenter;
                [label sizeToFit];
                label.center = CGPointMake(screenRect.size.width / 2.0f, screenRect.size.height / 2.0f);
                weakSelf.errorLabel = label;
                [weakSelf.view addSubview:weakSelf.errorLabel];
            }
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // start the camera
    [self.camera start];
    
    [self.useBt setEnabled:NO];
    [self.retakeBt setEnabled:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    isCancel = NO;
    [self showPopupAlertWithString:@"Every time you check in you will be prompted to snap a photo for your profile.\nMake it good! This is your one shot and it will last the duration of your Stay." isError:NO textAlign:NSTextAlignmentCenter];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Camera Buttons Touch Up

- (IBAction)toggleTouchUp:(UIButton *)sender {
    [self.camera togglePosition];
}

- (IBAction)flashTouchUp:(UIButton *)sender {
    if(self.camera.flash == LLCameraFlashOff) {
        BOOL done = [self.camera updateFlashMode:LLCameraFlashOn];
        if(done) {
            self.flashButton.selected = YES;
            self.flashButton.tintColor = [UIColor yellowColor];
        }
    }
    else {
        BOOL done = [self.camera updateFlashMode:LLCameraFlashOff];
        if(done) {
            self.flashButton.selected = NO;
            self.flashButton.tintColor = [UIColor whiteColor];
        }
    }
}

- (IBAction)snapTouchUp:(UIButton *)sender {
    // capture
    [self.camera capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
        if(!error) {
            
            // We should stop the camera, we are opening a new vc, thus we don't need it anymore.
            // This is important, otherwise you may experience memory crashes.
            // Camera is started again at viewWillAppear after the user comes back to this view.
            // I put the delay, because in iOS9 the shutter sound gets interrupted if we call it directly.
            [camera performSelector:@selector(stop) withObject:nil afterDelay:0.2];
            
            [self.avatarImageV setHidden:NO];
            [self.avatarImageV setImage:image];
            [self.view bringSubviewToFront:self.avatarImageV];
            
            [self.useBt setEnabled:YES];
            [self.retakeBt setEnabled:YES];
            [self.snapBt setEnabled:NO];
        }
        else {
            NSLog(@"An error has occured: %@", error);
        }
    } exactSeenImage:YES];
}

- (IBAction)retakeTouchUp:(UIButton *)sender {
    [self.avatarImageV setHidden:YES];
    
    [self.retakeBt setEnabled:NO];
    [self.useBt setEnabled:NO];
    [self.snapBt setEnabled:YES];
    
    [self.camera start];
}

- (IBAction)cancelTouchUp:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:ISUSEFROMCAMERA];

    isCancel = YES;
    [self showPopupAlertWithString:@"Bad light? Stuck in line?\nYou can always add a photo later but you will not be able to message (or be messaged!) until you add one." isError:NO textAlign:NSTextAlignmentCenter];
}

- (IBAction)useTouchUp:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:ISUSEFROMCAMERA];
    NSData *avatarData = [NSData dataWithData:UIImageJPEGRepresentation(self.avatarImageV.image, 0.2)];
    [[NSUserDefaults standardUserDefaults] setObject:avatarData forKey:AVATARIMAGE];
    
    FIRStorage *avatarStorage = [FIRStorage storage];
    FIRStorageReference *avatarRef = [[[avatarStorage referenceForURL:FIR_STORAGEURL] child:AVATARS] child:[self newAvatarName]];
    
    [avatarRef putData:avatarData metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
        if (error) {
            [self showPopupAlertWithString:error.localizedDescription isError:YES textAlign:NSTextAlignmentCenter];
        }else {
            NSString *photoURL = metadata.downloadURL.absoluteString;
            NSLog(@"%@", photoURL);
            [[[UserInfo sharedInstance] userData] setValue:photoURL forKey:PHOTO];
            
            // Save the avatar image URL in database
            [[[[[[FIRDatabase database] reference] child:USERS_REF] child:[FIRAuth auth].currentUser.uid] child:PHOTO] setValue:photoURL];
            
            // Save the avatar image URL in user profile
            FIRUserProfileChangeRequest *changeRequest = [[FIRAuth auth].currentUser profileChangeRequest];
            [changeRequest setPhotoURL:metadata.downloadURL];
            [changeRequest commitChangesWithCompletion:^(NSError * _Nullable error) {
                
            }];
        }
    }];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:AVATAR_ISEXISTED];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:AVATAR_ISDOWNLOADED];
    
    [self showProfileViewController];
}

#pragma mark - Custom Method

- (NSString *)newAvatarName {
    return [NSString stringWithFormat:@"%@_%@.jpg", [FIRAuth auth].currentUser.uid, TimeStamp];
}

- (void)showProfileViewController {
    RootViewController *rootVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RootViewController"];
    
    [rootVC setIsFromCameraView:YES];
    
    if (isFromProfile) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self presentViewController:rootVC animated:YES completion:^{
            //        [rootVC showProfileView];
        }];
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

- (void)dismissButtonPressed:(id)sender {
    if ([sender isKindOfClass:[UIView class]]) {
        [(UIView*)sender dismissPresentingPopup];

        if (isCancel) {
            [self showProfileViewController];
        }
    }
}

- (void)setIsFromProfileView: (BOOL)sender{
    isFromProfile = sender;
}

@end
