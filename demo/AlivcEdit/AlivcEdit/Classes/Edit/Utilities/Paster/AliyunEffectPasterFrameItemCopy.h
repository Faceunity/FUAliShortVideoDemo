//
//  AliyunEffectPasterFrameItemCopy.h
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/14.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AliyunVideoSDKPro/AliyunEffectPasterFrameItem.h>

/**
 气泡字幕内关于位置参数的深拷贝类
 */
@interface AliyunEffectPasterFrameItemCopy : NSObject

@property (nonatomic, assign) CGFloat time;
@property (nonatomic, assign) int pic;
@property (nonatomic, copy) NSString *picPath;

/**
 拷贝一份AliyunEffectPasterFrameItem
 
 @param effectPasterFrameItem 需要copy的AliyunEffectPasterFrameItem
 */
+(AliyunEffectPasterFrameItemCopy *)copyPropertysForAliyunEffectPasterFrameItem:(AliyunEffectPasterFrameItem *)effectPasterFrameItem;

/**
 获取Copy的属性
 
 @param effectPasterFrameItem 需要获取Copy属性的AliyunEffectPasterFrameItem
 */
-(void)setPropertysInAliyunEffectPasterFrameItem:(AliyunEffectPasterFrameItem *)effectPasterFrameItem;

@end
