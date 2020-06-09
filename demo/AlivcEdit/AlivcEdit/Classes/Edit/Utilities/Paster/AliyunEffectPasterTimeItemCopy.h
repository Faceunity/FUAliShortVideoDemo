//
//  AliyunEffectPasterTimeItemCopy.h
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/14.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AliyunVideoSDKPro/AliyunEffectPasterTimeItem.h>

/**
 气泡字幕内关于时间参数的深拷贝类
 */
@interface AliyunEffectPasterTimeItemCopy : NSObject

@property (nonatomic, assign) CGFloat beginTime;
@property (nonatomic, assign) CGFloat endTime;
@property (nonatomic, assign) BOOL shrink;
@property (nonatomic, assign) CGFloat minTime;
@property (nonatomic, assign) CGFloat maxTime;

/**
 拷贝一份AliyunEffectPasterTimeItem
 
 @param effectPasterTimeItem 需要copy的AliyunEffectPasterTimeItem
 */
+(AliyunEffectPasterTimeItemCopy *)copyPropertysForAliyunEffectPasterTimeItem:(AliyunEffectPasterTimeItem *)effectPasterTimeItem;

/**
 获取Copy的属性
 
 @param effectPasterTimeItem 需要获取Copy属性的AliyunEffectPasterTimeItem
 */
-(void)setPropertysInAliyunEffectPasterTimeItem:(AliyunEffectPasterTimeItem *)effectPasterTimeItem;

@end
