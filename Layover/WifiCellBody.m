//
//  WifiCellBody.m
//  Layovr
//
//  Created by Daniel Drescher on 06/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "WifiCellBody.h"

@implementation WifiCellBody

- (void)awakeFromNib {
    [self.statusImageV setImage:[UIImage imageNamed:@"wifi_status.png"]];
    [self.lockImageV setImage:[UIImage imageNamed:@"lock.png"]];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        //
    }
    
    return self;
}

@end
