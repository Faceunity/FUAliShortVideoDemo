//
//  AlivcBottomMenuBaseView.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/4/29.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcBottomMenuBaseView.h"
#import "UIView+AlivcHelper.h"

@interface AlivcBottomMenuBaseView ()

@property (nonatomic, strong)UIView *splitLine;
@property (nonatomic, assign)CGRect showRect;
@property (nonatomic, assign)CGRect hideRect;
@property (nonatomic, strong)UIButton *hudButton;

@end

@implementation AlivcBottomMenuBaseView

-(instancetype)init{
    self =[super init];
    if (self) {
        self.hidden = YES;
        _safeTop = 0.f;
    }
    [self addSubview:self.splitLine];
    [self addSubview:self.contentView];
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    _showRect = frame;
    _hideRect = CGRectMake(frame.origin.x, ScreenHeight, frame.size.width, frame.size.height);
    self =[super initWithFrame:_showRect];
    self.hidden = YES;
    if (self) {
        _safeTop = 0.f;
    }
    [self addSubview:self.splitLine];
    [self addSubview:self.contentView];
    return self;
}
-(void)setSafeTop:(CGFloat)safeTop{
    _safeTop = safeTop;
    self.splitLine.frame = CGRectOffset(self.splitLine.frame, 0, safeTop);
    self.contentView.frame = CGRectOffset(self.contentView.frame, 0, safeTop);
    if (_headerView) {
        _headerView.frame =CGRectOffset(_headerView.frame, 0, safeTop);
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    if (CGRectContainsPoint(CGRectMake(0, 0, CGRectGetWidth(self.bounds), _safeTop), [touches.anyObject locationInView:self])) {
        [self hide];
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self removeVisualEffectView];
    [self addVisualEffectWithFrame:CGRectMake(0, _safeTop, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)-_safeTop)];
    self.splitLine.frame =CGRectMake(0, CGRectGetHeight(self.headerView.frame)+_safeTop, ScreenWidth, 0.7);
    self.contentView.frame =CGRectMake(0, CGRectGetMaxY(self.splitLine.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-CGRectGetMaxY(self.splitLine.frame));
}

-(UIView *)splitLine{
    if (!_splitLine) {
        _splitLine =[[UIView alloc]initWithFrame:CGRectMake(0, _safeTop, ScreenWidth, 0.7)];
        _splitLine.backgroundColor =[UIColor colorWithWhite:1 alpha:0.6];
    }
    return _splitLine;
}
-(UIButton *)hudButton{
    if (!_hudButton) {
        _hudButton =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-CGRectGetHeight(self.frame))];
        _hudButton.backgroundColor =[UIColor clearColor];
        [_hudButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    }
    _hudButton.frame =CGRectMake(0, 0, ScreenWidth, ScreenHeight-CGRectGetHeight(self.frame));
    return _hudButton;
}

-(UIView *)contentView{
    if (!_contentView) {
        _contentView =[[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.splitLine.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-CGRectGetMaxY(self.splitLine.frame))];
        _contentView.backgroundColor =[UIColor clearColor];
    }
    return _contentView;
}


-(void)setHeaderView:(UIView *)headerView{
    _headerView = headerView;
    [self addSubview:headerView];
}

-(void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
}

-(void)show{
    if (self.superview) {
        [self.superview addSubview:self.hudButton];
        [self.superview bringSubviewToFront:self];
    }
    self.frame = _hideRect;
    self.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = _showRect;
    }];
}
-(void)hide{
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = _hideRect;
    } completion:^(BOOL finished) {
        self.hidden =YES;
        
    }];
    [self.hudButton removeFromSuperview];
}


@end
