//
//  AliyunEditButtonsView.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AlivcEditItemModel;

//素材类别 1: 字体 2: 动图 3:imv 4:滤镜 5:音乐 6:字幕 7:动效滤镜
typedef NS_ENUM(NSInteger, AliyunEditMaterialType) {
    AliyunEditMaterialTypeFont      = 1,
    AliyunEditMaterialTypePaster    = 2,
    AliyunEditMaterialTypeMV        = 3,
    AliyunEditMaterialTypeFilter    = 4,
    AliyunEditMaterialTypeMusic     = 5,
    AliyunEditMaterialTypeTime      = 6,
};


@protocol AliyunEditButtonsViewDelegate <NSObject>
//滤镜
- (void)filterButtonClicked:(AliyunEditMaterialType)type;

//音乐
- (void)musicButtonClicked;

//动图
- (void)pasterButtonClicked;

//字幕
- (void)subtitleButtonClicked;

//MV
- (void)mvButtonClicked:(AliyunEditMaterialType)type;

//音效
- (void)soundButtonClicked;

//特效
- (void)effectButtonClicked;

//时间特效
- (void)timeButtonClicked;

//转场
- (void)translationButtonCliked;

//涂鸦
- (void)paintButtonClicked;

//封面选择
- (void)coverButtonClicked;
@end



@interface AliyunEditButtonsView : UIView

- (instancetype)initWithModels:(NSArray <AlivcEditItemModel *>*)models;

@property (nonatomic, weak) id<AliyunEditButtonsViewDelegate> delegate;

@end



