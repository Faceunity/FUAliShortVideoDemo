//
//  AlivcEditItemManager.m
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/12/26.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcEditItemManager.h"
#import "AlivcEditItemModel.h"
#import "AlivcEditUIConfig.h"
#import "AVC_ShortVideo_Config.h"
#import "NSString+AlivcHelper.h"
#import "AlivcDefine.h"

@implementation AlivcEditItemManager
+ (NSArray <AlivcEditItemModel*>*)defaultModelsWithUIConfig:(AlivcEditUIConfig *)uiConfig{
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSInteger defaultAllValue = 10;
    AlivcOutputProductType productType = kAlivcProductType;
    if (productType == AlivcOutputProductTypeSmartVideo) {
        defaultAllValue = 11;
    }
    for (NSInteger i = 0; i < defaultAllValue; i++) {
        AlivcEditItemModel *model =[AlivcEditItemManager configModelsWithIndex:i withUIConfig:uiConfig];
        if (model) {
            [resultArray addObject:model];
        }else{
            NSLog(@"#Wrong:model can't be null");
        }
    }
    return (NSArray *)resultArray;
}

+ (AlivcEditItemModel *)configModelsWithIndex:(NSInteger)index withUIConfig:(AlivcEditUIConfig *)uiConfig{
    AlivcEditItemModel *model = [[AlivcEditItemModel alloc]initWithType:index];
    switch (model.itemType) {
        case AliyunEditSouceClickTypeFilter:
        {
            model.title = [@"滤镜" localString];
            model.showImage = uiConfig.filterImage;
            model.selString = @"filterButtonClicked:";
        }
            break;
        case AliyunEditSouceClickTypeMusic:
        {
            model.title = [@"音乐" localString];
            model.showImage = uiConfig.musicImage;
            model.selString = @"musicButtonClicked:";
        }
            break;
        case AliyunEditSouceClickTypePaster:
        {
            model.title = [@"动图" localString];
            model.showImage = uiConfig.pasterImage;
            model.selString = @"pasterButtonClicked:";
        }
            break;
        case AliyunEditSouceClickTypeCaption:
        {
            model.title = [@"字幕" localString];
            model.showImage = uiConfig.captionImage;
            model.selString = @"subtitleButtonClicked:";
        }
            break;
        case AliyunEditSouceClickTypeMV:
        {
            model.title = [@"MV" localString];
            model.showImage = uiConfig.mvImage;
            model.selString = @"mvButtonClicked:";
        }
            break;
        case AliyunEditSouceClickTypeEffect:
        {
            model.title = [@"特效" localString];
            model.showImage = uiConfig.effectImage;
            model.selString = @"effectButtonClicked:";
        }
            break;
        case AliyunEditSouceClickTypeTimeFilter:
        {
            model.title = [@"变速" localString];
            model.showImage = uiConfig.timeImage;
            model.selString = @"timeButtonClicked:";
        }
            break;
        case AliyunEditSouceClickTypeTranslation:
        {
            model.title = [@"转场" localString];
            model.showImage = uiConfig.translationImage;
            model.selString = @"translationButtonCliked:";
        }
            break;
        case AliyunEditSouceClickTypePaint:
        {
            model.title = [@"涂鸦" localString];
            model.showImage = uiConfig.paintImage;
            model.selString = @"paintButtonClicked:";
        }
            break;
        case AliyunEditSouceClickTypeCover:
        {
            model.title = [@"封面" localString];
            model.showImage = uiConfig.coverImage;
            model.selString = @"coverButtonClicked:";
        }
            break;
        case AliyunEditSouceClickTypeEffectSound:
        {
            model.title = [@"音效" localString];
            model.showImage = uiConfig.soundImage;
            model.selString = @"soundButtonClicked:";
        }
            break;
        default:
            return nil;
    }
    return model;
}

@end
