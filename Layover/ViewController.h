//
//  ViewController.h
//  Layover
//
//  Created by Daniel Drescher on 31/05/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *signInLabel;
@property (weak, nonatomic) IBOutlet CustomPlaceholderTextField *emailTextF;
@property (weak, nonatomic) IBOutlet CustomPlaceholderTextField *passwordTextF;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordBt;
@property (weak, nonatomic) IBOutlet UIButton *continueBt;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@end

