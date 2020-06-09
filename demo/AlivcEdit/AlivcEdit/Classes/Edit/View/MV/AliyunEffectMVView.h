//
//  AliyunEffectFilterView.h
//  AliyunVideo
//
//  Created by dangshuai on 17/3/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//  编辑界面中MV的view

#import <UIKit/UIKit.h>
#import "AliyunEffectMvGroup.h"

@protocol AliyunEffectFilterViewDelegate <NSObject>

/**
 选中某一个MV后的触发的方法

 @param mvGroup MV的数据模型
 */
- (void)didSelectEffectMV:(AliyunEffectMvGroup *)mvGroup;

/**
 选择更多MV后触发的方法
 */
- (void)didSelectEffectMoreMv;

@end

@interface AliyunEffectMVView : UIView


/**
 此类的代理属性
 */
@property (nonatomic, assign) id<AliyunEffectFilterViewDelegate> delegate;

/**
 被选中MV的数据模型
 */
@property (nonatomic, strong) AliyunEffectInfo *selectedEffect;


/**
 被选中的MV的序号
 */
@property (nonatomic, assign) NSInteger selectIndex;

/**
 刷新数据
 @param eType MV的类型，查询类别type 1: 字体 2: 动图 3:mv 4:滤镜 5:音乐 6:字幕 7：特效
 */
- (void)reloadDataWithEffectType:(NSInteger)eType;

/**
 删除MV数据的时候刷新数据
 
 @param eType eType MV的类型，查询类别type 1: 字体 2: 动图 3:mv 4:滤镜 5:音乐 6:字幕 7：特效
 */
- (void)reloadDataWithEffectTypeWithDelete:(NSInteger)eType;
@end
