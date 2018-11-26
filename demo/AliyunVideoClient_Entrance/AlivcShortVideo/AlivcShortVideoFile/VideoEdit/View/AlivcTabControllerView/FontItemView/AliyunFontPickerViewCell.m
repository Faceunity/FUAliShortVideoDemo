//
//  AliyunFontPickerViewCell.m
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/4.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AliyunFontPickerViewCell.h"

@interface AliyunFontPickerViewCell()

@property(nonatomic, strong)UILabel *lab;

@end

@implementation AliyunFontPickerViewCell

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _lab = [[UILabel alloc]initWithFrame:self.bounds];
        _lab.backgroundColor = [UIColor clearColor];
        _lab.textAlignment = NSTextAlignmentCenter;
        _lab.textColor = [UIColor colorWithWhite:0.9 alpha:0.8];
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:_lab];
    }
    return self;
}

-(void)setText:(NSString *)text{
    if (text) {
        _lab.text = text;
    }
}
-(void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    if (isSelected) {
        _lab.textColor = AlivcOxRGB(0x00C1DE);
        _lab.font = [UIFont systemFontOfSize:24];
    }else{
        _lab.textColor = [UIColor colorWithWhite:0.9 alpha:0.8];
        _lab.font = [UIFont systemFontOfSize:18];
    }
}

@end
