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
@protocol AliyunEffectFilter2ViewDelegate <NSObject>
@optional

/**
 选中某个滤镜滤镜

 @param filter 滤镜数据模型
 */
- (void)didSelectEffectFilter:(AliyunEffectFilterInfo *)filter;


@end

@interface AliyunEffectFilterView : UIView

/**
 此类的代理
 */
@property (nonatomic, weak) id<AliyunEffectFilter2ViewDelegate> delegate;

/**
 选中的滤镜数据模型
 */
@property (nonatomic, strong) AliyunEffectInfo *selectedEffect;

/**
 录制中的滤镜hideTop为Yes,编辑中的滤镜hideTop为No
 */
@property (nonatomic, assign) BOOL hideTop;


/**
 更新选中的滤镜

 @param filter 滤镜名称
 */
- (void)updateSelectedFilter:(AliyunEffectInfo *)filter;
@end
