//
//  UpdateDepartureViewController.h
//  Layovr
//
//  Created by Daniel Muller on 22/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdateDepartureViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *peersButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;

@property (weak, nonatomic) IBOutlet UILabel *departTimeLabel;
@end
