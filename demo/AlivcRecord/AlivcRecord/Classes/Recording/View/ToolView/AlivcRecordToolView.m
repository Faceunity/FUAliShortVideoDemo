//
//  AlivcRecordToolView.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/2/28.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcRecordToolView.h"
#import "NSString+AlivcHelper.h"

@interface AlivcRecordToolView()
@property(nonatomic, strong)UIView *slideView;
@property(nonatomic, strong)UIButton *clickBtn;
@property(nonatomic, strong)UIButton *holdBtn;
@property(nonatomic, strong)UIButton *cursor;
@property(nonatomic, strong)UIButton *deleteBtn;

@property(nonatomic, strong)CAShapeLayer *triangleLayer;

@end

@implementation AlivcRecordToolView

- (instancetype)initWithFrame:(CGRect)frame{
    self =[super initWithFrame:frame];
    if (self) {
        _touchMode =AlivcRecordButtonTouchModeClick;
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews{
    CGFloat btnSize = 80;
    CGFloat slideViewWidth =btnSize*2;
    _clickBtn =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnSize, 30)];
    _slideView =[[UIView alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.frame)-slideViewWidth+btnSize)/2, 3, slideViewWidth, 30)];
    _holdBtn =[[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(_slideView.frame)-btnSize, 0, btnSize, 30)];
    [_clickBtn setTitle:[@"单击拍" localString] forState:UIControlStateNormal];
    _clickBtn.titleLabel.font =[UIFont systemFontOfSize:14];
    [_clickBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_holdBtn setTitle:[@"长按拍" localString] forState:UIControlStateNormal];
    _holdBtn.titleLabel.font =[UIFont systemFontOfSize:14];
    [_holdBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateNormal];
    [_holdBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _deleteBtn =[[UIButton alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.frame)-70)/2, 2, 70, 40)];
    _deleteBtn.hidden =YES;
    _deleteBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_deleteBtn setTitle:[@"回删" localString] forState:UIControlStateNormal];
    [_deleteBtn setImage:[AlivcImage imageNamed:@"shortVideo_deleteButton"] forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_deleteBtn];

    [_slideView addSubview:_clickBtn];
    [_slideView addSubview:_holdBtn];
    [self addSubview:_slideView];
    
    
}
- (CAShapeLayer *)triangleLayer{
    if (!_triangleLayer) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(CGRectGetMidX(self.frame)-7, CGRectGetHeight(self.frame)-5)];
        [path addLineToPoint:CGPointMake(CGRectGetMidX(self.frame), CGRectGetHeight(self.frame)-10-5)];
        [path addLineToPoint:CGPointMake(CGRectGetMidX(self.frame)+7, CGRectGetHeight(self.frame)-5)];
        _triangleLayer = [CAShapeLayer layer];// 颜色设置和cell颜色一样
        _triangleLayer.fillColor = [UIColor whiteColor].CGColor;
        _triangleLayer.strokeColor = [UIColor whiteColor].CGColor;
        _triangleLayer.path = path.CGPath;
    }
    return _triangleLayer;
}

- (void)showDeleteButton:(BOOL)show{
    [_deleteBtn setHidden:!show];
    [_slideView setHidden:show];
    if (_showIndicator && !show) {
        [self.layer addSublayer:self.triangleLayer];
    }else{
        if (_triangleLayer) {
            [self.triangleLayer removeFromSuperlayer];
        }
    }
}

- (void)setShowIndicator:(BOOL)showIndicator{
    _showIndicator = showIndicator;
    [self.triangleLayer removeFromSuperlayer];
    if (_showIndicator) {
        [self.layer addSublayer:self.triangleLayer];  //底部三角形
    }
}

- (void)deleteAction:(UIButton *)btn{
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcRecordToolViewDeleteVideoPart)]) {
        [self.delegate alivcRecordToolViewDeleteVideoPart];
    }
}

- (void)buttonAction:(UIButton *)btn{
    _touchMode =AlivcRecordButtonTouchModeLongPress;
    if ([btn.titleLabel.text isEqualToString:[@"单击拍" localString]]) {
        _touchMode =AlivcRecordButtonTouchModeClick;
    }
    __weak typeof(self)weakSelf = self;
    [self updateSlideViewFrameWithTouchMode:_touchMode completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(alivcRecordToolViewSwitchTouchMode:)]) {
            [self.delegate alivcRecordToolViewSwitchTouchMode:weakSelf.touchMode];
        }
    }];
    
}

- (void)updateSlideViewFrameWithTouchMode:(AlivcRecordButtonTouchMode)touchMode completion:(void (^)(void))completion{
    __weak typeof(self)weakSelf =self;
    if (touchMode == AlivcRecordButtonTouchModeClick) {
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.slideView.transform = CGAffineTransformIdentity;
            [weakSelf.holdBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateNormal];
            [weakSelf.clickBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        } completion:^(BOOL finished) {
            if (finished) {
                completion();
            }
        }];
    }else{
        CGFloat centerW =CGRectGetWidth(_slideView.frame)-CGRectGetWidth(_clickBtn.frame)-CGRectGetWidth(_holdBtn.frame);
        CGFloat moveX =(CGRectGetWidth(_clickBtn.frame)+CGRectGetWidth(_holdBtn.frame))/2 +centerW;
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.slideView.transform = CGAffineTransformMakeTranslation(-moveX, 0);
            [weakSelf.clickBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateNormal];
            [weakSelf.holdBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        } completion:^(BOOL finished) {
            if (finished) {
                completion();
            }
        }];
    }
}


@end
