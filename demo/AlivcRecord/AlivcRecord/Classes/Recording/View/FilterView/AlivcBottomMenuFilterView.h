//
//  AlivcBottomMenuFilterView.h
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/5/6.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcBottomMenuView.h"
#import "AliyunEffectFilterInfo.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^DidSelectEffectFilterBlock)(AliyunEffectFilterInfo *filterInfo);

@interface AlivcBottomMenuFilterView : AlivcBottomMenuView

/**
 选中的滤镜数据模型
 */
@property (nonatomic, strong) AliyunEffectInfo *selectedEffect;

/**
 注册选中滤镜的回调事件

 @param block 选中滤镜的回调
 */
-(void)registerDidSelectEffectFilterBlock:(DidSelectEffectFilterBlock)block;

@end

NS_ASSUME_NONNULL_END
