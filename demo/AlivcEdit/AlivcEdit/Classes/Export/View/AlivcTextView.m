//
//  AlivcTextView.m
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2019/1/10.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcTextView.h"

@interface AlivcTextView ()

@property (assign, nonatomic) NSInteger maxCount;


@property (strong, nonatomic) UILabel *countLabel;

@end

@implementation AlivcTextView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self configBaseUI];
    }
    return self;
}

- (void)configBaseUI{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat beside = 8;
    CGFloat labelWidth = 50;
    
    _textField = [[UITextField alloc]initWithFrame:CGRectMake(beside, 0, width - beside * 2 - labelWidth - beside, height)];
    _textField.userInteractionEnabled = NO;
    _textField.textColor = [UIColor whiteColor];
    [self addSubview:_textField];
    
    _countLabel = [[UILabel alloc]init];
    _countLabel.frame = CGRectMake(CGRectGetMaxX(_textField.frame) + beside, 0, labelWidth, height);
    _countLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:_countLabel];
    self.backgroundColor = [UIColor blackColor];
}

- (void)setShowText:(NSString *)showText{
    _showText = showText;
    [self freshUI];
}

- (void)setMaxCount:(NSInteger)maxCount{
    _maxCount = maxCount;
    [self freshUI];
}

- (void)freshUI{
    self.textField.text = self.showText;
    self.countLabel.text = [self countTextWithShowString:self.showText];
}

- (NSString *)countTextWithShowString:(NSString *)showString{
    NSInteger length = showString.length;
    NSString *countString = [NSString stringWithFormat:@"[%ld/%ld]",(long)length,(long)_maxCount];
    return countString;
}

@end
