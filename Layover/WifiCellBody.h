//
//  WifiCellBody.h
//  Layovr
//
//  Created by Daniel Drescher on 06/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WifiCellBody : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *lockImageV;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageV;

@end
