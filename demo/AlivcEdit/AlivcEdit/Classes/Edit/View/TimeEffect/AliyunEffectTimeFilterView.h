//
//  AliyunEffectTimeFilterView.h
//  qusdk
//
//  Created by Vienta on 2018/2/26.
//  Copyright © 2018年 Alibaba Group Holding Limited. All rights reserved.
//  时间特效View

#import <UIKit/UIKit.h>
@class AliyunTimelineView;
@protocol AliyunEffectTimeFilterDelegate <NSObject>
/**
 应用时间特效的效果
 */
- (void)applyTimeFilterButtonClick;

/**
 取消时间特效的效果
 */
- (void)noApplyTimeFilterButtonClick;

/**
 时间特效选中无效果
 */
- (void)didSelectNone;

/**
 时间特效瞬间变慢
 */
- (void)didSelectMomentSlow;

/**
 时间特效瞬间变快
 */
- (void)didSelectMomentFast;

/**
 反复
 */
- (void)didSelectRepeat;

/**
 倒放
 */
- (void)didSelectInvert:(void (^)(BOOL success))success;

@end

@interface AliyunEffectTimeFilterView : UIView
/**
 设置缩略图。frame自适应，不用设置frame
 
 */
@property (nonatomic, strong) AliyunTimelineView *timelineView;

/**
 此类的代理属性
 */
@property (nonatomic, weak) id<AliyunEffectTimeFilterDelegate> delegate;

@end
