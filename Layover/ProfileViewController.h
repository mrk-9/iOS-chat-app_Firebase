//
//  ProfileViewController.h
//  Layovr
//
//  Created by Daniel Drescher on 07/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *topV;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageV;
@property (weak, nonatomic) IBOutlet UIView *contentV;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomContentViewConstraint;

@property (weak, nonatomic) IBOutlet UIButton *editBt;
@property (weak, nonatomic) IBOutlet UIButton *settingsBt;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet CustomPlaceholderTextField *cityTF;
@property (weak, nonatomic) IBOutlet UILabel *jobLabel;
@property (weak, nonatomic) IBOutlet CustomPlaceholderTextField *jobTF;
@property (weak, nonatomic) IBOutlet UILabel *collegeLabel;
@property (weak, nonatomic) IBOutlet CustomPlaceholderTextField *collegeTF;
@property (weak, nonatomic) IBOutlet UILabel *homeTownLabel;
@property (weak, nonatomic) IBOutlet CustomPlaceholderTextField *homeTownTF;
@property (weak, nonatomic) IBOutlet UILabel *intoLabel;
@property (weak, nonatomic) IBOutlet CustomPlaceholderTextField *intoTF;
@property (weak, nonatomic) IBOutlet UILabel *bandLabel;
@property (weak, nonatomic) IBOutlet CustomPlaceholderTextField *bandTF;
@property (weak, nonatomic) IBOutlet UILabel *bookLabel;
@property (weak, nonatomic) IBOutlet CustomPlaceholderTextField *bookTF;
@property (weak, nonatomic) IBOutlet UILabel *movieLabel;
@property (weak, nonatomic) IBOutlet CustomPlaceholderTextField *movieTF;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet CustomPlaceholderTextField *placeTF;
@end
