//
//  CustomPlaceholderTextField.m
//  Layovr
//
//  Created by Daniel Drescher on 02/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "CustomPlaceholderTextField.h"

@implementation CustomPlaceholderTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void) drawPlaceholderInRect:(CGRect)rect {
    
    UIColor *colour = [UIColor lightGrayColor];
    
    if ([self.placeholder respondsToSelector:@selector(drawInRect:withAttributes:)]) {
        // iOS7 and later
        NSDictionary *attributes = @{NSForegroundColorAttributeName: colour, NSFontAttributeName: self.font};
        CGRect boundingRect = [self.placeholder boundingRectWithSize:rect.size options:0 attributes:attributes context:nil];
        [self.placeholder drawAtPoint:CGPointMake(0, (rect.size.height/2)-boundingRect.size.height/2) withAttributes:attributes];
    }
//    else {
//        // iOS 6
//        [colour setFill];
//        [self.placeholder drawInRect:rect withFont:self.font lineBreakMode:NSLineBreakByTruncatingTail alignment:self.textAlignment];
//    }
}

@end
