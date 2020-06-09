//
//  AliyunEffectCaptionCopy.m
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/14.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AliyunEffectCaptionCopy.h"
#import "AliyunEffectPasterTimeItemCopy.h"
#import "AliyunEffectPasterFrameItemCopy.h"

@implementation AliyunEffectCaptionCopy

-(id)copyPropertysForAliyunEffectCaption:(AliyunEffectCaption *)effectCaption{
    if (effectCaption) {
        self.text = [effectCaption.text copy];
        self.captionFontName = [effectCaption.captionFontName copy];
        self.captionFontId = effectCaption.captionFontId;
        self.textRelativeToBeginTime = effectCaption.textRelativeToBeginTime;
        self.textRelativeToEndTime = effectCaption.textRelativeToEndTime;
        self.textFrame = effectCaption.textFrame;
        self.textCenter = effectCaption.textCenter;
        self.textSize = effectCaption.textSize;
        self.kernelImage = [effectCaption.kernelImage copy];
        self.textStroke = effectCaption.textStroke;
        self.textColor = [effectCaption.textColor copy];
        self.textStrokeColor = [effectCaption.textStrokeColor copy];
        self.textLabelColor = [effectCaption.textLabelColor copy];
        self.fontName = [effectCaption.fontName copy];
        
        self.timeItems = [self copyEffectPasterTimeItems:effectCaption.timeItems];
        self.frameItems = [self copyEffectPasterFrameItems:effectCaption.frameItems];
        
        self.originDuration = effectCaption.originDuration;
        self.originTextDuration = effectCaption.originTextDuration;
        self.originTextBeginTime = effectCaption.originTextBeginTime;
    }
    return self;
}
-(void)setPropertysInAliyunEffectCaption:(AliyunEffectCaption *)effectCaption{
    if (effectCaption) {
        effectCaption.text = [self.text copy];
        effectCaption.captionFontName = [self.captionFontName copy];
        effectCaption.captionFontId = self.captionFontId;
        effectCaption.textRelativeToBeginTime = self.textRelativeToBeginTime;
        effectCaption.textRelativeToEndTime = self.textRelativeToEndTime;
        effectCaption.textFrame = self.textFrame;
        effectCaption.textCenter = self.textCenter;
        effectCaption.textSize = self.textSize;
        effectCaption.kernelImage = [self.kernelImage copy];
        effectCaption.textStroke = self.textStroke;
        effectCaption.textColor = [self.textColor copy];
        effectCaption.textStrokeColor = [self.textStrokeColor copy];
        effectCaption.textLabelColor = [self.textLabelColor copy];
        effectCaption.fontName = [self.fontName copy];
        effectCaption.originDuration = self.originDuration;
        effectCaption.originTextDuration = self.originTextDuration;
        effectCaption.originTextBeginTime = self.originTextBeginTime;
        [self setPropertysInEffectPasterTimeItems:effectCaption.timeItems];
        [self setPropertysInEffectPasterFrameItems:effectCaption.frameItems];
    }
}


-(NSArray<AliyunEffectPasterTimeItemCopy *> *)copyEffectPasterTimeItems:(NSArray<AliyunEffectPasterTimeItem *> *)items{
    NSMutableArray *copyMutArr = [NSMutableArray arrayWithCapacity:8];
    for (AliyunEffectPasterTimeItem *item in items) {
        [copyMutArr addObject:[AliyunEffectPasterTimeItemCopy copyPropertysForAliyunEffectPasterTimeItem:item]];
    }
    return copyMutArr;
}

-(NSArray<AliyunEffectPasterFrameItemCopy *> *)copyEffectPasterFrameItems:(NSArray<AliyunEffectPasterFrameItem *> *)items{
    NSMutableArray *copyMutArr = [NSMutableArray arrayWithCapacity:8];
    for (AliyunEffectPasterFrameItem *item in items) {
        [copyMutArr addObject:[AliyunEffectPasterFrameItemCopy copyPropertysForAliyunEffectPasterFrameItem:item]];
    }
    return copyMutArr;
}


-(void)setPropertysInEffectPasterTimeItems:(NSArray<AliyunEffectPasterTimeItem *> *)items{
    for (int i = 0; i<self.timeItems.count; i++) {
        AliyunEffectPasterTimeItemCopy *copy = self.timeItems[i];
        AliyunEffectPasterTimeItem *item = items[i];
        [copy setPropertysInAliyunEffectPasterTimeItem:item];
    }
}

-(void)setPropertysInEffectPasterFrameItems:(NSArray<AliyunEffectPasterFrameItem *> *)items{
    for (int i = 0; i<self.frameItems.count; i++) {
        AliyunEffectPasterFrameItemCopy *copy = self.frameItems[i];
        AliyunEffectPasterFrameItem *item = items[i];
        [copy setPropertysInAliyunEffectPasterFrameItem:item];
    }
}

@end
