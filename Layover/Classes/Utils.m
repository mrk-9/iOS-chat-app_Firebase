//
//  Utils.m
//  Hayden
//
//  Created by Daniel Drescher on 07/04/15.
//  Copyright (c) 2015 Matti. All rights reserved.
//

#import "Utils.h"

@implementation Utils

#pragma mark - NSUserDefaults
+ (void)setObjectToUserDefaults:(id)object inUserDefaultsForKey:(NSString*)key{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)getObjectFromUserDefaultsForKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

#pragma mark - Image
+ (UIImage*)imageFromColor:(UIColor*)color forSize:(CGSize)size withCornerRadius:(CGFloat)radius{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContext(size);
    
    //Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius] addClip];
    //Draw your image
    [image drawInRect:rect];
    
    //Get the image, here setting the UIImageView image
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    //Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - NSDate->NSString
//    NSDate *date = [Utils dateFromString:dict[@"date"] format:@"yyyy-MM-dd HH:mm:ss" timezone:@"UTC"];
+ (NSDate*)dateFromString:(NSString*)datestring format:(NSString*)format timezone:(NSString *)timezone{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:timezone]];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:datestring];
    
    return dateFromString;
}
+ (NSString*)dateToString:(NSDate*)date format:(NSString*)format timezone:(NSString *)timezone{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:timezone]];
    NSString *stringDate = [dateFormatter stringFromDate:[NSDate date]];
    
    return stringDate;
}

#pragma mark - Other
+ (BOOL)NSStringIsValidEmail:(NSString *)checkString{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}
+ (NSString*)generateChatRoom:(NSString*)id1 second:(NSString*)id2{
    NSString *chatroom = ([id1 compare:id2] < 0) ? [NSString stringWithFormat:@"%@%@", id1, id2] : [NSString stringWithFormat:@"%@%@", id2, id1];

    return chatroom;
}

@end

@implementation NSString (containsCategory)
- (BOOL) containsString:(NSString *)substring{
    NSRange range = [self rangeOfString:substring];
    BOOL found = (range.location != NSNotFound);
    return found;
}
@end