//
//  AlivcBottomMenuSpecialFilterView.h
//  AliyunVideoClient_Entrance
//
//  Created by 孙震 on 2019/9/10.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlivcBottomMenuView.h"
#import "AliyunEffectFilterInfo.h"

@class AliyunEffectFilter;

NS_ASSUME_NONNULL_BEGIN

typedef void(^DidSelectEffectFilterBlock)(AliyunEffectFilterInfo *filterInfo);

@interface AlivcBottomMenuSpecialFilterView : AlivcBottomMenuView
/**
 选中的滤镜数据模型
 */
@property (nonatomic, strong) AliyunEffectInfo *selectedEffect;

@property (nonatomic,copy) void (^didChangeEffectFinish)(AliyunEffectFilter* effect);

/**
 注册选中滤镜的回调事件
 
 @param block 选中滤镜的回调
 */
-(void)registerDidSelectEffectFilterBlock:(DidSelectEffectFilterBlock)block;

/**
 跳转下载更多的回调事件
 @param block 下载的滤镜回调
 */
-(void)registerDidShowMoreEffectFilterBlock:(void(^)(void))block;


- (void)fetchEffectGroupDataWithCurrentShowGroup:(nullable AliyunEffectInfo *)group;

-(void)showRegulatorView:(nullable AliyunEffectFilter*)effect paramList:(nullable NSArray*)paramList;

@end

NS_ASSUME_NONNULL_END
