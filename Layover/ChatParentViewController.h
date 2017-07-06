//
//  ChatParentViewController.h
//  Layovr
//
//  Created by Daniel Muller on 27/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatParentViewController : UIViewController

- (void)setOtherInfoWithUID: (NSString *)uid andDictionary: (NSDictionary *)otherDic andImage: (UIImage *)image;

- (void)setBackButtonLabelWithText: (NSString *)text;

@end
