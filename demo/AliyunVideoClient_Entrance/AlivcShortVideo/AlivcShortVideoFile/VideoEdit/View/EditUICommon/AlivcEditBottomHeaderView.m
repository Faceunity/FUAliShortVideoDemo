//
//  AlivcEditBottomHeaderView.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2018/10/11.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcEditBottomHeaderView.h"
#import "AlivcEditIconButton.h"

//#define AEBH_Button_Size 45
#define AEBH_Icon_Size 40
#define AEBH_SeparatorLine_Height 0.6

@interface AlivcEditBottomHeaderView()

@property (nonatomic, strong)AlivcEditIconButton *iconBtn;
@property (nonatomic, strong)UIButton *cancelBtn;
@property (nonatomic, strong)UIButton *enterBtn;
@property (nonatomic, strong)UIView *separatorLine;//分割线


@end

@implementation AlivcEditBottomHeaderView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self layerSubviews];
    }
    return self;
}

-(void)layerSubviews{
    _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, (CGRectGetHeight(self.bounds)-CGRectGetHeight(self.bounds))/2, CGRectGetHeight(self.bounds), CGRectGetHeight(self.bounds))];
    [_cancelBtn setImage:[AlivcImage imageNamed:@"shortVideo_edit_close"] forState:UIControlStateNormal];
    [self addSubview:_cancelBtn];
    
    _iconBtn = [[AlivcEditIconButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_cancelBtn.frame), (CGRectGetHeight(self.bounds)-AEBH_Icon_Size)/2, CGRectGetWidth(self.bounds)-CGRectGetMaxX(_cancelBtn.frame)*2, AEBH_Icon_Size)];
    _iconBtn.userInteractionEnabled = NO;
    [_iconBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self addSubview:_iconBtn];
    
    _enterBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_iconBtn.frame), CGRectGetMinY(_cancelBtn.frame), CGRectGetHeight(_cancelBtn.bounds), CGRectGetHeight(_cancelBtn.bounds))];
    [_enterBtn setImage:[AlivcImage imageNamed:@"shortVideo_edit_affirm"] forState:UIControlStateNormal];
    [self addSubview:_enterBtn];
    //        [_iconBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 0)];

    _separatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.frame)-AEBH_SeparatorLine_Height, ScreenWidth, AEBH_SeparatorLine_Height)];
    _separatorLine.backgroundColor = AlivcOxRGB(0xc3c5c6);
    _separatorLine.alpha = 0.5;
    [self addSubview:_separatorLine];

}
-(void)hiddenButton{
    _cancelBtn.hidden = YES;
    _enterBtn.hidden = YES;
}

-(void)setTitle:(NSString *)titile icon:(UIImage *)icon{
    [_iconBtn setImage:icon forState:UIControlStateNormal];
    [_iconBtn setImage:icon forState:UIControlStateHighlighted];
    [_iconBtn setTitle:titile forState:UIControlStateNormal];
    [_iconBtn setTitle:titile forState:UIControlStateHighlighted];
}

-(void)bindingApplyOnClick:(OnClickBlock)applyOnClick cancelOnClick:(OnClickBlock)cancelOnClick{
    [_cancelBtn aliyunOnClickBlock:cancelOnClick];
    [_enterBtn aliyunOnClickBlock:applyOnClick];
}


@end
