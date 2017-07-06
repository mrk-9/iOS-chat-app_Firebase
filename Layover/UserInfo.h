//
//  UserInfo.h
//  Layovr
//
//  Created by Daniel Drescher on 09/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (nonatomic, retain) NSMutableDictionary *userData;
@property (nonatomic, retain) NSMutableDictionary *userBlockList;
@property (nonatomic, retain) NSMutableDictionary *userContactList;
@property (nonatomic, retain) NSMutableDictionary *userNotifications;

//- (NSDictionary *)userData;

- (void)initUserInfo;

+ (id)sharedInstance;

- (void)setUserInfo: (NSDictionary *)sender;
- (void)getUserInfo: (NSString *)uid;

@end
