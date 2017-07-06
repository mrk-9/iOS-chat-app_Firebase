//
//  PeerProfileViewController.h
//  Layovr
//
//  Created by Daniel Drescher on 07/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeerProfileViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *contactButton;

@property (weak, nonatomic) IBOutlet UIImageView *peerProfileImageV;
@property (weak, nonatomic) IBOutlet UILabel *peerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *peerJobLabel;
@property (weak, nonatomic) IBOutlet UILabel *peerLocationLabel;

@property (weak, nonatomic) IBOutlet UILabel *peerDepartTimeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *meetYesImageV;
@property (weak, nonatomic) IBOutlet UIImageView *netYesImageV;
@property (weak, nonatomic) IBOutlet UIImageView *meetNoImageV;
@property (weak, nonatomic) IBOutlet UIImageView *netNoImageV;

@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UIButton *blockButton;

@property (weak, nonatomic) IBOutlet UITextView *otherInfoTextView;

- (void)setPeerInfo: (NSMutableDictionary *)sender withUID: (NSString *)uid;

- (void)setTextForBackButton: (NSString *)text;

@end
