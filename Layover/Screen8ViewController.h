//
//  Screen8ViewController.h
//  Layovr
//
//  Created by Daniel Drescher on 04/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Screen8ViewController : UIViewController

@property (weak, nonatomic) IBOutlet CustomPlaceholderTextField *firstInterestTF;
@property (weak, nonatomic) IBOutlet CustomPlaceholderTextField *secondInterestTF;
@property (weak, nonatomic) IBOutlet CustomPlaceholderTextField *thirdInterestTF;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *almostLabel;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@end
