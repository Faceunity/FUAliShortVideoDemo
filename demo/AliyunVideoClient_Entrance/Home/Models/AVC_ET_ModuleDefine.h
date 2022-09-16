//
//  AVC_ET_ModuleDefine.h
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/3/22.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
  模块的定义与分类分类

 - AVC_ET_ModuleType_ApsaraV: apsaraV
 - AVC_ET_ModuleType_VideoShooting: 视频拍摄
 - AVC_ET_ModuleType_VideoEdit: 视频编辑
 - AVC_ET_ModuleType_VideoUpload: 视频上传
 - AVC_ET_ModuleType_VideoLive: 视频直播
 - AVC_ET_ModuleType_VideoPaly: 视频播放
 - AVC_ET_ModuleType_LiveAnswer: 直播答题
 - AVC_ET_ModuleType_MagicCamera:魔法相机
 - AVC_ET_ModuleType_VideoClip:视频裁剪
 - AVC_ET_ModuleType_SmartVideo:趣视频
 AVC_ET_ModuleType_Temp_ShortVideo_Demo:原先短视频的demo
 */
typedef NS_ENUM(NSInteger,AVC_ET_ModuleType){
    
    AVC_ET_ModuleType_VideoShooting = 1 << 0,//短视频 - 视频拍摄
    AVC_ET_ModuleType_VideoEdit = 1 << 1,//短视频 - 视频编辑
    AVC_ET_ModuleType_VideoClip = 1 << 2,//短视频 - 视频裁剪
    AVC_ET_ModuleType_SmartVideo = 1 << 3, //短视频解决方案 - 趣视频
    AVC_ET_ModuleType_VideoLive = 1 << 4,//互动直播
    AVC_ET_ModuleType_PushFlow = 1 << 5,//推流的demo（直播推流）
    AVC_ET_ModuleType_VideoUpload = 1 << 6, //上传
    AVC_ET_ModuleType_VideoPaly = 1 << 7, //播放器
    AVC_ET_ModuleType_VideoShooting_Basic = 1 << 8,//短视频 - 视频拍摄 - 基础版
    AVC_ET_ModuleType_VideoClip_Basic = 1 << 9,//短视频 - 视频裁剪 - 基础版
    
    AVC_ET_ModuleType_RTC = 1 << 10,
    AVC_ET_ModuleType_RTC_Audio = 1 << 11,
    
    AVC_ET_ModuleType_Smartboard = 1 << 12,//互动白板
    
    AVC_ET_ModuleType_RaceBeauty = 1 << 13,//race美颜美型
    AVC_ET_ModuleType_FaceDetect = 1 << 14,//race人脸识别

    AVC_ET_ModuleType_MetalPreview = 1 << 15,//Metal 预览

    AVC_ET_ModuleType_VideoPlayConfig = 1 << 16, //播放配置
    AVC_ET_ModuleType_VideoPlayList = 1 << 17, //播放列表
    AVC_ET_ModuleType_VideoPlayShift = 1 << 18, //直播时移
    
    AVC_ET_ModuleType_Draft = 1 << 19, // 草稿
    AVC_ET_ModuleType_Template = 1 << 20, // 剪同款
};


@interface AVC_ET_ModuleDefine : NSObject


/**
 指定初始化方法

 @param type 模块类型
 @return 实例变量
 */
- (instancetype)initWithModuleType:(AVC_ET_ModuleType )type;


/**
 类型
 */
@property (assign, nonatomic) AVC_ET_ModuleType type;

/**
 描述
 */
@property (strong, nonatomic, readonly) NSString *name;

/**
 图片0000、
    QQQ
 */
@property (strong, nonatomic, readonly) UIImage *image;


#pragma mark - 类方法
/**
 模块功能对应的描述

 @param type 模块功能
 @return 描述
 */
+ (NSString *)nameWithModuleType:(AVC_ET_ModuleType )type;


/**
 模块功能对应的图片

 @param type 模块功能
 @return 图片
 */
+ (UIImage *__nullable)imageWithModuleType:(AVC_ET_ModuleType )type;

@end

NS_ASSUME_NONNULL_END
