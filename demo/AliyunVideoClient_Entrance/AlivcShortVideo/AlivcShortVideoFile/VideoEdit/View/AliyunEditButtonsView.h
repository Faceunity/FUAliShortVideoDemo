//
//  AliyunEditButtonsView.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlivcEditUIConfig.h"

//素材类别 1: 字体 2: 动图 3:imv 4:滤镜 5:音乐 6:字幕 7:动效滤镜
typedef NS_ENUM(NSInteger, AliyunEditButtonType) {
    AliyunEditButtonTypeFont      = 1,
    AliyunEditButtonTypePaster    = 2,
    AliyunEditButtonTypeMV        = 3,
    AliyunEditButtonTypeFilter    = 4,
    AliyunEditButtonTypeMusic     = 5,
    AliyunEditButtonTypeTime      = 6,
};

@protocol AliyunEditButtonsViewDelegate <NSObject>
//滤镜
- (void)filterButtonClicked:(AliyunEditButtonType)type;

//音乐
- (void)musicButtonClicked;

//动图
- (void)pasterButtonClicked;

//字幕
- (void)subtitleButtonClicked;

//MV
- (void)mvButtonClicked:(AliyunEditButtonType)type;

//特效
- (void)effectButtonClicked;

//时间特效
- (void)timeButtonClicked;

//转场
- (void)translationButtonCliked;

//涂鸦
- (void)paintButtonClicked;
@end



@interface AliyunEditButtonsView : UIView

- (instancetype)initWithConfig:(AlivcEditUIConfig *)uiConfig;

@property (nonatomic, weak) id<AliyunEditButtonsViewDelegate> delegate;

@end



