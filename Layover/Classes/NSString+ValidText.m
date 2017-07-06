//
//  NSString+ValidText.m
//  Layovr
//
//  Created by Daniel Drescher on 03/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "NSString+ValidText.h"

@implementation NSString (ValidText)
- (BOOL)isValidString{
    NSString *rawString = self;
    NSCharacterSet *whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whiteSpace];
    if ([trimmed length] == 0) {
        return NO;
    }
    return YES;
}
@end
