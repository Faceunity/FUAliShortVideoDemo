//
//  AlivcRecordBeautyView.h
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/5/5.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcBottomMenuView.h"
#import "AlivcPushBeautyParams.h"
#import "AlivcBeautySettingUIDefine.h"
//#import "AlivcLiveBeautifySettingsViewController.h"
//#import "_AlivcLiveBeautifyLevelView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AlivcRecordBeautyViewDelegate <NSObject>

@optional

/**
 基础美颜等级改变

 @param level 基础美颜等级
 */
- (void)alivcRecordBeautyDidChangeBaseBeautyLevel:(NSInteger)level;

/**
 美颜类型改变

 @param type 美颜类型：高级、基础
 */
- (void)alivcRecordBeautyDidChangeBeautyType:(AlivcBeautySettingViewStyle)type;

/**
 如何获取faceunity介绍
 */
- (void)alivcRecordBeautyDidSelectedGetFaceUnityLink;

@end

@interface AlivcRecordBeautyView : AlivcBottomMenuView

@property (nonatomic,weak)id<AlivcRecordBeautyViewDelegate>delegate;

/**
 美颜参数
 */
@property (nonatomic,strong)AlivcPushBeautyParams *beautyParams;

/**
 美型参数
 */
@property (nonatomic,strong)AlivcPushBeautyParams *beautySkinParams;

/**
 当前美颜类型
 */
@property (nonatomic,assign)AlivcBeautySettingViewStyle currentBeautyType;

/**
 当前基础美颜级别
 */
@property (nonatomic,assign)NSInteger currentBaseBeautyLevel;

/**
 改变levelView的标题

 @param title 标题
 */
- (void)setLevelViewTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
