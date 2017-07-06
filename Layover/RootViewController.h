//
//  RootViewController.h
//  Layovr
//
//  Created by Daniel Drescher on 06/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController

@property BOOL isFromCameraView;
//@property UIImage *avatarImage;

@property (weak, nonatomic) IBOutlet UIImageView *bgImageV;
@property (weak, nonatomic) IBOutlet UIView *topV;
@property (weak, nonatomic) IBOutlet UIView *seperateV;

@property (weak, nonatomic) IBOutlet UIImageView *netImageV;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageV;
@property (weak, nonatomic) IBOutlet UIImageView *messageImageV;

@property (weak, nonatomic) IBOutlet MIBadgeButton *messageButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewTopConstraint;

- (void)showProfileView;

- (void)setBadgeNumberInMessage: (NSInteger) count;

@end
