//
//  SignUpViewController.h
//  Layovr
//
//  Created by Daniel Drescher on 03/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVSwitch.h"

@interface SignUpViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *signUpLabel;
@property (weak, nonatomic) IBOutlet CustomPlaceholderTextField *emailTextF;
@property (weak, nonatomic) IBOutlet CustomPlaceholderTextField *passwordTextF;
@property (weak, nonatomic) IBOutlet CustomPlaceholderTextField *retypeTextF;
@property (weak, nonatomic) IBOutlet CustomPlaceholderTextField *usernameTextF;
@property (weak, nonatomic) IBOutlet CustomPlaceholderTextField *ageTextF;
@property (weak, nonatomic) IBOutlet UIButton *continueBt;
@property (weak, nonatomic) IBOutlet UIButton *signInBt;

@end
