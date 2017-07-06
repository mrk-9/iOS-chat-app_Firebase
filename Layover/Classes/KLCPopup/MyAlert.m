//
//  MyAlert.m
//  Layovr
//
//  Created by Daniel Drescher on 10/06/16.
//  Copyright © 2016 griebel. All rights reserved.
//

#import "MyAlert.h"

@implementation MyAlert

+ (UIView *)alertLabel: (NSString *)msg isError: (BOOL)isError textAlign: (NSTextAlignment)align{
    CGFloat w = [[UIScreen mainScreen] bounds].size.height / 2;
    
    UILabel* contentLabel = [[UILabel alloc] init];
    [contentLabel setTextAlignment:align];
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.textColor = [UIColor blackColor];
    contentLabel.font = [UIFont boldSystemFontOfSize: w * 32 / 667];
    [contentLabel setNumberOfLines:0];
//    [contentLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [contentLabel setFrame:CGRectMake(0, 0, w * 9 / 10, CGFLOAT_MAX)];
    
    NSMutableAttributedString *att_msg = [[NSMutableAttributedString alloc] init];
    
//    NSMutableDictionary *attriDic = [NSMutableDictionary dictionary];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    
    [paragraphStyle setLineSpacing: w * 16 / 667];
    [paragraphStyle setAlignment:NSTextAlignmentJustified];
    
    UIColor *textColor;
    if (isError) {
        textColor = [UIColor redColor];
    }else {
        textColor = [UIColor blackColor];
    }
//    attriDic[NSParagraphStyleAttributeName] = paragraphStyle;
    NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: textColor};
    
//    [att_msg addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, att_msg.length)];
    
    NSAttributedString *content = [[NSAttributedString alloc] initWithString:msg attributes:attributes];
    [att_msg appendAttributedString:content];
    
//    [att_msg setAttributes:attriDic range:NSMakeRange(0, att_msg.length)];
//    [att_msg drawInRect:CGRectMake(0, 0, w * 9 / 10, CGFLOAT_MAX)];
    
    [contentLabel setAttributedText:att_msg];
    [contentLabel sizeToFit];
    
    UIView *labelV = [[UIView alloc] initWithFrame:CGRectMake(w / 20, w / 10, contentLabel.frame.size.width, contentLabel.frame.size.height)];
    [labelV addSubview:contentLabel];
    
    return labelV;
}

+ (UIButton *)alertButton: (UIView *)labelV {
    CGFloat w = [[UIScreen mainScreen] bounds].size.height / 2;
    
    UIButton* ok = [UIButton buttonWithType:UIButtonTypeCustom];

    [ok setBackgroundImage:[UIImage imageNamed:@"got_it.png"] forState:UIControlStateNormal];
    [ok setFrame:CGRectMake(w * 2 / 5, labelV.frame.origin.y + labelV.frame.size.height + w / 12, w / 5, w / 5)];
    
    return ok;
}

+ (UIView *)alertView: (UIView *)labelV withButton: (UIButton *)ok {
    CGFloat w = [[UIScreen mainScreen] bounds].size.height / 2;
    
    // Generate content view to present
    UIView* contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 12.0;

    [contentView setFrame:CGRectMake(w / 12, 0, w, ok.frame.origin.y + ok.frame.size.height + w / 15)];

    [contentView addSubview:labelV];
    [contentView addSubview:ok];
    
    return contentView;
}

@end
