//
//  AliyunPaintColorItemCell.m
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/3.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AliyunPaintColorItemCell.h"

@implementation AliyunPaintColorItemCell
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)setupSubviews{
    _colorView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    _colorView.backgroundColor = [UIColor clearColor];
    _colorView.layer.cornerRadius = 3;
    _colorView.layer.masksToBounds = YES;
    [self.contentView addSubview:_colorView];
    _colorView.center = self.contentView.center;
}
@end
