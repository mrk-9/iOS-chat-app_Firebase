//
//  CameraViewController.h
//  Layovr
//
//  Created by Daniel Drescher on 07/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *cancelBt;
@property (weak, nonatomic) IBOutlet UIButton *retakeBt;
@property (weak, nonatomic) IBOutlet UIButton *toggleBt;
@property (weak, nonatomic) IBOutlet UIButton *useBt;
@property (weak, nonatomic) IBOutlet UIButton *flashBt;
@property (weak, nonatomic) IBOutlet UIButton *snapBt;

- (void)setIsFromProfileView: (BOOL)sender;

@end
