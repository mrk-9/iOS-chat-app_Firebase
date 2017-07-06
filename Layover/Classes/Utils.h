//
//  Utils.h
//  Hayden
//
//  Created by Daniel Drescher on 07/04/15.
//  Copyright (c) 2015 Matti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import "Constants.h"

@interface Utils : NSObject

+ (void)setObjectToUserDefaults:(id)object inUserDefaultsForKey:(NSString*)key;
+ (id)getObjectFromUserDefaultsForKey:(NSString *)key;
    
+ (UIImage*)imageFromColor:(UIColor*)color forSize:(CGSize)size withCornerRadius:(CGFloat)radius;

+ (BOOL)NSStringIsValidEmail:(NSString *)checkString;
+ (NSString*)generateChatRoom:(NSString*)id1 second:(NSString*)id2;

+ (NSDate*)dateFromString:(NSString*)datestring format:(NSString*)format timezone:(NSString *)timezone;
+ (NSString*)dateToString:(NSDate*)date format:(NSString*)format timezone:(NSString *)timezone;

@end


@interface NSString (containsCategory)
- (BOOL) containsString:(NSString *)substring;
@end