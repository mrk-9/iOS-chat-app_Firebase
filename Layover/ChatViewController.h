//
//  ChatViewController.h
//  Layovr
//
//  Created by Daniel Drescher on 08/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSQMessages.h"

@interface ChatViewController : JSQMessagesViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSString *chatRoom;
@property (nonatomic, strong) NSString *otherId;
@property (nonatomic, strong) NSString *otherAvatarUrl;
@property (nonatomic, strong) NSMutableArray *chatHistory;

- (void)setOtherInfoWithUID: (NSString *)uid andDictionary: (NSDictionary *)otherDic andImage: (UIImage *)image;

@end
