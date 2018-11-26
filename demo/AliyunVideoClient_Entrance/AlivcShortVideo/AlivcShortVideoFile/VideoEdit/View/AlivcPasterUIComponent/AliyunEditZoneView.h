//
//  AliyunEditZoneView.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/8.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunPasterView.h"

@protocol AliyunEditZoneViewDelegate <NSObject>

/**
 接收到点击触摸事件的代理方法

 @param point 当前点击的坐标
 */
- (void)currentTouchPoint:(CGPoint)point;

/**
 接收到移动触摸事件的代理方法

 @param fp 起点
 @param tp 终点
 */
- (void)mv:(CGPoint)fp to:(CGPoint)tp;

/**
 触摸事件结束
 */
- (void)touchEnd;

@end

/**
 动图编辑空间
 */
@interface AliyunEditZoneView : UIView

@property (nonatomic, weak) id<AliyunEditZoneViewDelegate> delegate;

/**
 编辑状态
 */
@property (nonatomic, assign) BOOL editStatus;

/**
 当前动图调整编辑view
 */
@property (nonatomic, weak) AliyunPasterView *currentPasterView;

@end
