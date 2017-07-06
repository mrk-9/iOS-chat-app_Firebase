//
//  UserInfo.m
//  Layovr
//
//  Created by Daniel Drescher on 09/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "UserInfo.h"

@interface UserInfo() {
//    NSDictionary *userDic;
}

@end

@implementation UserInfo

- (void)initUserInfo {
    self.userData = [[NSMutableDictionary alloc] init];
    self.userBlockList = [[NSMutableDictionary alloc] init];
    self.userContactList = [[NSMutableDictionary alloc] init];
    self.userNotifications = [[NSMutableDictionary alloc] init];
}

+ (id)sharedInstance {
    static UserInfo *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UserInfo alloc] init];
    });
    return sharedInstance;
}

- (void)setUserInfo: (NSDictionary *)sender {
    self.userData = [sender mutableCopy];
}

- (void)getUserInfo: (NSString *)uid {
    [[[[[FIRDatabase database] reference] child:USERS_REF] child:uid] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (snapshot.value) {
            self.userData = snapshot.value;
        }
    }];
}

@end
