//
//  AliyunTabBarCell.m
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/1.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AliyunTabBarCell.h"

@interface AliyunTabBarCell()

@property(nonatomic, strong)UIView *tagLine;

@end

@implementation AliyunTabBarCell

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.itemBtn];
        [self.contentView addSubview:self.tagLine];
    }
    return self;
}

-(void)setTitle:(NSString *)title icon:(UIImage *)icon{
    [self.itemBtn setTitle:title forState:UIControlStateNormal];
    [self.itemBtn setImage:icon forState:UIControlStateNormal];
}

-(UIButton *)itemBtn{
    if (!_itemBtn) {
        _itemBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        [_itemBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 10)];
        _itemBtn.userInteractionEnabled = NO;
        _itemBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _itemBtn;
}

-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    self.tagLine.hidden = !selected;
}

-(UIView *)tagLine{
    if (!_tagLine) {
        _tagLine = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.bounds)/4, CGRectGetHeight(self.frame)+5, CGRectGetWidth(self.contentView.frame)/2, 2)];
        _tagLine.backgroundColor = AlivcOxRGB(0x00C1DE);
        _tagLine.hidden = YES;
    }
    return _tagLine;
}


@end
