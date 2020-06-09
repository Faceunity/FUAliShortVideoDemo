//
//  AlivcTabbarHeaderView.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2018/10/10.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcTabbarHeaderView.h"

@interface AlivcTabbarHeaderView()

@property(nonatomic, strong)UIButton *leftBtn;//左按钮
@property(nonatomic, strong)UIButton *rightBtn;//右按钮
@property(nonatomic, strong)UIView *leftLine;//左分割线
@property(nonatomic, strong)UIView *rightLine;//右分割线

@end

@implementation AlivcTabbarHeaderView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self layerSubviews];
    }
    return self;
}
-(void)layerSubviews{
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.leftBtn];
    [self addSubview:self.rightBtn];
    [self addSubview:self.leftLine];
    [self addSubview:self.rightLine];
    [self addSubview:self.tabbar];
}


-(UIButton*)leftBtn{
    if (!_leftBtn) {
        _leftBtn= [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 40, 40)];
        [_leftBtn setImage:[AlivcImage imageNamed:@"shortVideo_edit_goBack"] forState:UIControlStateNormal];
    }
    return _leftBtn;
}
-(UIButton*)rightBtn{
    if (!_rightBtn) {
        _rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds)-45, 0, CGRectGetWidth(self.leftBtn.bounds), CGRectGetHeight(self.leftBtn.bounds))];
        [_rightBtn setImage:[AlivcImage imageNamed:@"shortVideo_edit_affirm"] forState:UIControlStateNormal];
    }
    return _rightBtn;
}
-(UIView*)leftLine{
    if (!_leftLine) {
        _leftLine = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.leftBtn.frame)+5, 8, 1, CGRectGetHeight(self.leftBtn.bounds)-16)];
        _leftLine.backgroundColor = AlivcOxRGBA(0xC3C5C6, 0.9);
    }
    return _leftLine;
}
-(UIView*)rightLine{
    if (!_rightLine) {
        _rightLine = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.rightBtn.frame)-5-1, 8, 1, CGRectGetHeight(self.leftBtn.bounds)-16)];
        _rightLine.backgroundColor = AlivcOxRGBA(0xC3C5C6, 0.9);
    }
    return _rightLine;
}


-(AlivcTabbarView *)tabbar{
    CGFloat leftWidth =CGRectGetWidth(self.bounds)-CGRectGetMinX(self.rightLine.frame);
    CGFloat tabBarWidth =CGRectGetWidth(self.bounds)-CGRectGetMaxX(self.leftLine.frame)-leftWidth;
    if (!_tabbar) {
        _tabbar = [[AlivcTabbarView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.leftLine.frame), 0, tabBarWidth, CGRectGetHeight(self.bounds))];
    }
    return _tabbar;
}


-(void)bindingApplyOnClick:(OnClickBlock)applyOnClick cancelOnClick:(OnClickBlock)cancelOnClick{
    [self.leftBtn aliyunOnClickBlock:cancelOnClick];
    [self.rightBtn aliyunOnClickBlock:applyOnClick];
}


@end
