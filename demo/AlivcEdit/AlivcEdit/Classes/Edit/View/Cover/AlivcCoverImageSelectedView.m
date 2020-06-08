//
//  AlivcCoverImageSelectedView.m
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/12/26.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcCoverImageSelectedView.h"
#import "AlivcEditBottomHeaderView.h"
#import "AliyunTimelineView.h"

@interface AlivcCoverImageSelectedView ()
/**
 占位view
 */
@property (nonatomic, strong) UIView *timeLinePalletView;

@end

@implementation AlivcCoverImageSelectedView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self configBaseUI];
    }
    return self;
}

- (void)configBaseUI{
    [self addSubview:self.timeLinePalletView];
    
    AlivcEditBottomHeaderView *headerView = [[AlivcEditBottomHeaderView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 45)];
    
    [headerView setTitle:NSLocalizedString(@"封面", nil) icon:[AlivcImage imageNamed:@"shortVideo_edit_timeFliter_coverImage"]];
    [self addSubview:headerView];
    __weak typeof(self)weakSelf = self;
    [headerView bindingApplyOnClick:^{
        [weakSelf apply];
    } cancelOnClick:^{
        [weakSelf noApply];
    }];
    
    self.backgroundColor = [UIColor blackColor];
}

/**
 重写timelineView的set方法
 
 @param timelineView 进度条
 */
-(void)setTimelineView:(AliyunTimelineView *)timelineView{
    _timelineView = timelineView;
    if (_timelineView) {
        _timelineView.frame = CGRectMake(0, 15, CGRectGetWidth(_timeLinePalletView.frame), CGRectGetHeight(_timeLinePalletView.frame)-10);
        _timelineView.backgroundColor = self.backgroundColor;
        [_timeLinePalletView addSubview:_timelineView];
    }
}


/**
 占位view的懒加载
 
 @return 占位view
 */
- (UIView *)timeLinePalletView{
    if (!_timeLinePalletView) {
        _timeLinePalletView = [[UIView alloc]initWithFrame:CGRectMake(0, 44, ScreenWidth, 40)];
        _timeLinePalletView.backgroundColor = [UIColor clearColor];
        if (_timelineView) {
            _timelineView.frame = CGRectMake(0, 5, CGRectGetWidth(_timeLinePalletView.frame), CGRectGetHeight(_timeLinePalletView.frame)-10);
            _timelineView.backgroundColor = self.backgroundColor;
            [_timeLinePalletView addSubview:_timelineView];
        }
    }
    return _timeLinePalletView;
}

#pragma mark - Response
/**
 点击应用的触发方法
 */
- (void)apply{
    if ([self.delegate respondsToSelector:@selector(applyCoverImageSelectedView:)]) {
        [self.delegate applyCoverImageSelectedView:self];
    }
}

/**
 点击取消的触发方法
 */
- (void)noApply{
    if ([self.delegate respondsToSelector:@selector(cancelCoverImageSelectedView:)]) {
        [self.delegate cancelCoverImageSelectedView:self];
    }
}
@end
