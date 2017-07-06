//
//  PeerListViewController.h
//  Layovr
//
//  Created by Daniel Muller on 22/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeerListViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *networkButton;
@property (weak, nonatomic) IBOutlet UIButton *departureButton;

@property (weak, nonatomic) IBOutlet UITableView *peerListTableView;
@end
