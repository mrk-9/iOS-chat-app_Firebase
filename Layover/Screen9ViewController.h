//
//  Screen9ViewController.h
//  Layovr
//
//  Created by Daniel Drescher on 04/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Screen9ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet CustomPlaceholderTextField *bandTF;
@property (weak, nonatomic) IBOutlet CustomPlaceholderTextField *bookTF;
@property (weak, nonatomic) IBOutlet CustomPlaceholderTextField *movieTF;
@property (weak, nonatomic) IBOutlet CustomPlaceholderTextField *placeTF;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewTopContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerViewCenterX;

@property (weak, nonatomic) IBOutlet UILabel *youOnlyLabel;
@property (weak, nonatomic) IBOutlet UILabel *theRestlabel;
@property (weak, nonatomic) IBOutlet UILabel *pickLabel;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@end
