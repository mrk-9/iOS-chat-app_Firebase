//
//  MyAlert.h
//  Layovr
//
//  Created by Daniel Drescher on 10/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyAlert : NSObject

+ (UIView *)alertLabel: (NSString *)msg isError: (BOOL)isError textAlign: (NSTextAlignment)align;
+ (UIButton *)alertButton: (UIView *)labelV;
+ (UIView *)alertView: (UIView *)labelV withButton: (UIButton *)ok;

@end
