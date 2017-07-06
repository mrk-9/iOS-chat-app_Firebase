//
//  MessageDepartCell.h
//  Layovr
//
//  Created by Daniel Drescher on 07/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface MessageDepartCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageV;
@property (weak, nonatomic) IBOutlet UIButton *avatarImageButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *departStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *departTimeLabel;

- (void)setBlurLevelWithUID: (NSString *)peerUID withFlag: (BOOL)isPeerList;

- (void)setAvatarImageWithURL: (NSString *)url uid: (NSString *)peerUID;

@end
