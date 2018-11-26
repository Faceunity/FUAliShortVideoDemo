//
//  AliyunEffectPasterFrameItemCopy.m
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/14.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AliyunEffectPasterFrameItemCopy.h"

@implementation AliyunEffectPasterFrameItemCopy

+(AliyunEffectPasterFrameItemCopy *)copyPropertysForAliyunEffectPasterFrameItem:(AliyunEffectPasterFrameItem *)effectPasterFrameItem{
    AliyunEffectPasterFrameItemCopy *copy = [AliyunEffectPasterFrameItemCopy new];
    if (effectPasterFrameItem) {
        copy.time = effectPasterFrameItem.time;
        copy.pic = effectPasterFrameItem.pic;
        copy.picPath = [effectPasterFrameItem.picPath copy];
    }
    return copy;
}

-(void)setPropertysInAliyunEffectPasterFrameItem:(AliyunEffectPasterFrameItem *)effectPasterFrameItem{
    if (effectPasterFrameItem) {
        effectPasterFrameItem.time = self.time;
        effectPasterFrameItem.pic = self.pic;
        effectPasterFrameItem.picPath = [self.picPath copy];
    }
}

@end
