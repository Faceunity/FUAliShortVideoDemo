//
//  AliyunPasterControllerCopy.m
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/6.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AliyunPasterControllerCopy.h"
#import "AliyunEffectCaptionCopy.h"
#import "AliyunEffectSubtitleCopy.h"

@class AliyunEffectSubtitle;
@class AliyunEffectCaption;

@implementation AliyunPasterControllerCopy
-(instancetype)copyPropertysForPasterController:(AliyunPasterController *)pasterController{
    if (pasterController.pasterType == AliyunPasterEffectTypeCaption) {
        AliyunEffectCaption *caption = [pasterController getEffectPaster];
        self.effectCaption = [[AliyunEffectCaptionCopy new] copyPropertysForAliyunEffectCaption:caption];
    }else if (pasterController.pasterType == AliyunPasterEffectTypeSubtitle){
        AliyunEffectSubtitle *subtitle = [pasterController getEffectPaster];
        self.effectSubtitle = [[AliyunEffectSubtitleCopy new] copyPropertysForAliyunEffectSubtitle:subtitle];
    }
    self.pasterRotate = pasterController.pasterRotate;
    self.pasterType = pasterController.pasterType;
    self.pasterPosition = pasterController.pasterPosition;
    self.pasterSize = pasterController.pasterSize;
    self.pasterFrame = pasterController.pasterFrame;
    self.mirror = pasterController.mirror;
    self.subtitle = [pasterController.subtitle copy];
    self.subtitleStroke = pasterController.subtitleStroke;
    self.subtitleColor = [pasterController.subtitleColor copy];
    self.subtitleStroke = pasterController.subtitleStroke;
    self.subtitleStrokeColor = [pasterController.subtitleStrokeColor copy];
    self.subtitleBackgroundColor = [pasterController.subtitleBackgroundColor copy];
    self.subtitleFontName = [pasterController.subtitleFontName copy];
//    self.kernelImage = [pasterController.kernelImage copy];
    self.pasterStartTime = pasterController.pasterStartTime;
    self.pasterEndTime = pasterController.pasterEndTime;
    self.pasterDuration = pasterController.pasterDuration;
    self.pasterMinDuration = pasterController.pasterMinDuration;
    self.displaySize =  pasterController.displaySize;
    self.outputSize = pasterController.outputSize;
    self.previewRenderSize = pasterController.previewRenderSize;
    self.actionType = [pasterController actionType];
    self.tempActionType = [pasterController tempActionType];
    //_iconPath:/var/mobile/Containers/Data/Application/F77AD814-8C7B-4392-8C38-1FEAAD80126E/Documents/com.duanqu.demo/QPRes/pasterRes/STICKER/878-chun/chun/icon.png
    self.resoucePath = [self getResoucePathWithIconPath:[[pasterController getIconPath] copy]];
//    self.resoucePath = [_resoucePath substringToIndex:_resoucePath.length-9];
    return self;
}
-(NSString *)getResoucePathWithIconPath:(NSString *)iconPath{
    NSArray *pathArr = [iconPath componentsSeparatedByString:@"/"];
    NSMutableString *resouceStr = [NSMutableString string];
    for (int i=0; i<pathArr.count; i++) {
        if (i>6 && i<=13) {
            [resouceStr appendString:pathArr[i]];
            if (i<13) {
               [resouceStr appendString:@"/"];
            }
        }
    }
    return resouceStr;
}

-(void)setPropertysInPasterController:(AliyunPasterController *)pasterController{
    pasterController.pasterRotate = self.pasterRotate;
//    pasterController.pasterType = self.pasterType;
    pasterController.pasterPosition = self.pasterPosition;
    pasterController.pasterSize = self.pasterSize;
    pasterController.pasterFrame = self.pasterFrame;
    pasterController.mirror = self.mirror;
    pasterController.subtitle = [self.subtitle copy];
    pasterController.subtitleStroke = self.subtitleStroke;
    pasterController.subtitleColor = [self.subtitleColor copy];
    pasterController.subtitleStroke = self.subtitleStroke;
    pasterController.subtitleStrokeColor = [self.subtitleStrokeColor copy];
    pasterController.subtitleBackgroundColor = [self.subtitleBackgroundColor copy];
    pasterController.subtitleFontName = [self.subtitleFontName copy];
    //    self.kernelImage = [pasterController.kernelImage copy];
    pasterController.pasterStartTime = self.pasterStartTime;
    pasterController.pasterEndTime = self.pasterEndTime;
    pasterController.pasterDuration = self.pasterDuration;
    pasterController.pasterMinDuration = self.pasterMinDuration;
    pasterController.displaySize =  self.displaySize;
    pasterController.outputSize = self.outputSize;
    pasterController.previewRenderSize = self.previewRenderSize;
    [pasterController setActionType:self.actionType];
    [pasterController setTempActionType:self.tempActionType];
    if (pasterController.pasterType == AliyunPasterEffectTypeCaption) {
        AliyunEffectCaption *caption = [pasterController getEffectPaster];
        [self.effectCaption setPropertysInAliyunEffectCaption:caption];
    }else if (pasterController.pasterType == AliyunPasterEffectTypeSubtitle){
        AliyunEffectSubtitle *subtitle = [pasterController getEffectPaster];
        [self.effectSubtitle setPropertysInAliyunEffectSubtitle:subtitle];
    }
    
}


@end
