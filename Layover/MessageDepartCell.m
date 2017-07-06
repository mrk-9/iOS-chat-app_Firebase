//
//  MessageDepartCell.m
//  Layovr
//
//  Created by Daniel Drescher on 07/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "MessageDepartCell.h"

@implementation MessageDepartCell

- (void)awakeFromNib {
    [self.avatarImageV.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.avatarImageV.layer setBorderWidth:2];
    [self.avatarImageV.layer setCornerRadius:10];
    [self.avatarImageV setClipsToBounds:YES];
    [self.avatarImageV setImage:[UIImage imageNamed:@"user.png"]];
    
    [self.avatarImageV setTag:0];
    
//    FXBlurView *blurV = [[FXBlurView alloc] initWithFrame:CGRectMake(0, 0, self.avatarImageV.frame.size.width, self.avatarImageV.frame.size.height)];
//    [blurV setBackgroundColor:[UIColor clearColor]];
//    [blurV setBlurRadius:20];
//    
//    [self.avatarImageV addSubview:blurV];
//    for (UIView *subV in self.peerProfileImageV.subviews) {
//        [subV removeFromSuperview];
//    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // Changes here after init'ing self
    }
    
    return self;
}

- (void)setAvatarImageWithURL: (NSString *)url uid: (NSString *)peerUID {
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.png", DocumentDirectory, peerUID];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [self.avatarImageV setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]]];
        [self.avatarImageV setTag:1];
    }else{
        [[[FIRStorage storage] referenceForURL:url] writeToFile:[NSURL URLWithString:[NSString stringWithFormat:@"file:%@", filePath]] completion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
            
        }];
    }
    
//    [[[FIRStorage storage] referenceForURL:url] dataWithMaxSize:1 * 1024 * 1024 completion:^(NSData * _Nullable data, NSError * _Nullable error) {
//        if (!error) {
//            [self.avatarImageV setImage:[UIImage imageWithData:data]];
//        }
//    }];
}

- (void)setBlurLevelWithUID: (NSString *)peerUID withFlag: (BOOL)isPeerList {
    
    for (UIView *subV in self.avatarImageV.subviews) {
        [subV removeFromSuperview];
    }
    
    NSMutableDictionary *contactList = [[UserInfo sharedInstance] userContactList];
    NSInteger blurL = 0;
    BOOL isExisted = NO;
    for (id key in contactList) {
        NSMutableDictionary *itemDic = [contactList objectForKey:key];
        if ([[itemDic objectForKey:USERID] isEqualToString:peerUID]) {
            if ([itemDic objectForKey:STATUS]) {
                blurL = [[itemDic objectForKey:STATUS] integerValue];
            }else{
                blurL = BlurLevel5;
            }
            
            if (isPeerList == NO) {
                [self.messageLabel setText:[itemDic objectForKey:LAST_MESSAGE]];
            }
            isExisted = YES;
            break;
        }
    }
    
    if (isExisted == NO) {
        blurL = BlurLevel5;
    }
    
    if (blurL == BlurLevel1) {
        return;
    }
    
    FXBlurView *blurV = [[FXBlurView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [blurV setBackgroundColor:[UIColor clearColor]];
    [blurV setBlurRadius:blurL * 5];

    [self.avatarImageV addSubview:blurV];
}

@end
