//
//  AliyunEffectPasterTimeItemCopy.m
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/14.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AliyunEffectPasterTimeItemCopy.h"

@implementation AliyunEffectPasterTimeItemCopy

+(AliyunEffectPasterTimeItemCopy *)copyPropertysForAliyunEffectPasterTimeItem:(AliyunEffectPasterTimeItem *)effectPasterTimeItem{
    AliyunEffectPasterTimeItemCopy *copy = [AliyunEffectPasterTimeItemCopy new];
    if (effectPasterTimeItem) {
        copy.beginTime = effectPasterTimeItem.beginTime;
        copy.endTime = effectPasterTimeItem.endTime;
        copy.shrink = effectPasterTimeItem.shrink;
        copy.minTime = effectPasterTimeItem.minTime;
        copy.maxTime = effectPasterTimeItem.maxTime;
    }
    return copy;
}

-(void)setPropertysInAliyunEffectPasterTimeItem:(AliyunEffectPasterTimeItem *)effectPasterTimeItem{
    if (effectPasterTimeItem) {
        effectPasterTimeItem.beginTime = self.beginTime;
        effectPasterTimeItem.endTime = self.endTime;
        effectPasterTimeItem.shrink = self.shrink;
        effectPasterTimeItem.minTime = self.minTime;
        effectPasterTimeItem.maxTime = self.maxTime;
    }
}


@end
