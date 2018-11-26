//
//  AlivcTabbarBaseView.m
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/3.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcTabbarBaseView.h"
#import "UIView+AlivcHelper.h"

@interface AlivcTabbarBaseView()

@property(nonatomic, assign, readonly)CGRect initFrame;//初始化的frame，动画隐藏view后再显示的时候需要用到

@end

@implementation AlivcTabbarBaseView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _initFrame = frame;
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews{
//    [self addVisualEffect];
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.topLine];
    [self addSubview:self.bootomView];
    [self addSubview:self.bootomLine];
    [self addSubview:self.contentView];
    
}

#pragma mark - Functions

-(void)showInView:(UIView *)superView animation:(BOOL)animation completion:(void (^ _Nullable)(BOOL))completion{
    [self removeFromSuperview];
    [superView addSubview:self];
    __weak typeof(self)weakSelf = self;
    self.frame = CGRectMake(self.frame.origin.x, ScreenHeight, self.frame.size.width, self.frame.size.height);
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.frame = _initFrame;
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    }else{
        self.frame = _initFrame;
    }
}

-(void)hiddenAnimation:(BOOL)animation completion:(void (^ _Nullable)(BOOL))completion{
    __weak typeof(self)weakSelf = self;
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.frame = CGRectMake(self.frame.origin.x, ScreenHeight, self.frame.size.width, self.frame.size.height);
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
            [weakSelf removeFromSuperview];
        }];
    }else{
        [self removeFromSuperview];
    }
}


#pragma mark - GET

-(UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.topLine.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.bounds) - CGRectGetHeight(self.bootomView.bounds) - CGRectGetHeight(self.bootomLine.bounds) -CGRectGetHeight(self.topLine.bounds))];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}
-(UIView *)bootomLine{
    if (!_bootomLine) {
        _bootomLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.bootomView.frame)-CPV_LineView_Height, CGRectGetWidth(self.frame), CPV_LineView_Height)];
        _bootomLine.backgroundColor = AlivcOxRGBA(0xc3c5c6,0.5);
    }
    return _bootomLine;
}
-(UIView *)bootomView{
    if (!_bootomView) {
        _bootomView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-CPV_BootomView_Height, CGRectGetWidth(self.frame), CPV_BootomView_Height)];
        _bootomView.backgroundColor = [UIColor clearColor];
    }
    return _bootomView;
}
-(UIView *)topLine{
    if (!_topLine) {
        _topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CPV_LineView_Height)];
        _topLine.backgroundColor = AlivcOxRGBA(0xc3c5c6,0.5);
    }
    return _topLine;
}

@end
