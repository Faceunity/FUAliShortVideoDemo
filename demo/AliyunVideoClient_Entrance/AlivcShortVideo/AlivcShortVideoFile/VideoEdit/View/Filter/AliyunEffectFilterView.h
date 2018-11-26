//
//  AliyunEffectFilterView.h
//  qusdk
//
//  Created by Vienta on 2018/1/12.
//  Copyright © 2018年 Alibaba Group Holding Limited. All rights reserved.
//  编辑中滤镜、录制中滤镜、编辑中滤镜特效公用的view

#import <UIKit/UIKit.h>
#import "AliyunEffectFilterInfo.h"
#import "AliyunEffectMvGroup.h"
#import "AliyunTimelineView.h"
@protocol AliyunEffectFilter2ViewDelegate <NSObject>
@optional

/**
 选中某个滤镜滤镜

 @param filter 滤镜数据模型
 */
- (void)didSelectEffectFilter:(AliyunEffectFilterInfo *)filter;


// 以下都是滤镜特效相关的
/**
 应用滤镜特效的效果
 */
- (void)applyButtonClick;

/**
 取消滤镜特效的效果
 */
- (void)noApplyButtonClick;

/**
 开始长按的时候的代理方法

 @param animtinoFilter 滤镜特效数据模型
 */
- (void)didBeganLongPressEffectFilter:(AliyunEffectFilterInfo *)animtinoFilter;

/**
 结束长按的时候的代理方法
 */
- (void)didEndLongPress;

/**
 滤镜特效的回删
 */
- (void)didRevokeButtonClick;

/**
 长按过程中定时调用的代理方法（每0.1秒调用一次）
 */
- (void)didTouchingProgress;

@end

@interface AliyunEffectFilterView : UIView

/**
 此类的代理
 */
@property (nonatomic, weak) id<AliyunEffectFilter2ViewDelegate> delegate;

/**
 选中的滤镜或特效的数据模型
 */
@property (nonatomic, strong) AliyunEffectInfo *selectedEffect;

/**
 录制中的滤镜hideTop为Yes,编辑中的滤镜hideTop为No
 */
@property (nonatomic, assign) BOOL hideTop;

/**
 设置缩略图。frame自适应，不用设置frame
 
 */
@property (nonatomic, strong) AliyunTimelineView *timelineView;


/**
 刷新数据

 @param eType 数据类型
 */
- (void)reloadDataWithEffectType:(NSInteger)eType;

/**
 让特效处于初始状态
 */
- (void)specialFilterReset;

/**
 结束长按手势 - 用与添加特效到视频最后时，结束长按手势
 */
- (void)endLongPress;
@end
