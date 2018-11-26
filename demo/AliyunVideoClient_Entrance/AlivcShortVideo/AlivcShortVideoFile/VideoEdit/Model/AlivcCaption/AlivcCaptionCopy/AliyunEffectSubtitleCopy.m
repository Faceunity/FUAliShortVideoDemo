//
//  AliyunEffectSubtitleCopy.m
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/14.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AliyunEffectSubtitleCopy.h"
#import <AliyunVideoSDKPro/AliyunEffectSubtitle.h>

@implementation AliyunEffectSubtitleCopy

-(id)copyPropertysForAliyunEffectSubtitle:(AliyunEffectSubtitle *)effectSubtitle{
    if (effectSubtitle) {
        self.text = [effectSubtitle.text copy];
        self.fontName = [effectSubtitle.fontName copy];
        self.textColor = [effectSubtitle.textColor copy];
        self.strokeColor = [effectSubtitle.strokeColor copy];
        self.isStroke = effectSubtitle.isStroke;
        self.textLabelColor =[effectSubtitle.textLabelColor copy];
        self.hasTextLabel = effectSubtitle.hasTextLabel;
    }
    return self;
}

-(void)setPropertysInAliyunEffectSubtitle:(AliyunEffectSubtitle *)effectSubtitle{
    if (effectSubtitle) {
        effectSubtitle.text = [self.text copy];
        effectSubtitle.fontName =[self.fontName copy];
        effectSubtitle.textColor =[self.textColor copy];
        effectSubtitle.strokeColor =[self.strokeColor copy];
        effectSubtitle.isStroke =self.isStroke;
        effectSubtitle.textLabelColor = [self.textLabelColor copy];
        effectSubtitle.hasTextLabel =self.hasTextLabel;
    }
}



@end
