//
//  AlivcShortVideoRoute.h
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2018/10/19.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AliyunMediaConfig.h"
#import "AlivcEditUIConfig.h"
#import "AlivcRecordUIConfig.h"

NS_ASSUME_NONNULL_BEGIN

/**
 短视频视图控制器类型 - 只支持专业版和标准版

 - AlivcViewControlEditParam:        短视频编辑参数配置页
 - AlivcViewControlEditVideoSelect:  短视频编辑视频选择页
 - AlivcViewControlEdit:             短视频编辑页
 - AlivcViewControlRecordParam:      短视频拍摄参数配置页
 - AlivcViewControlRecord:           短视频拍摄页
 - AlivcViewControlCropParam:        短视频裁剪参数配置页
 - AlivcViewControlCropVideoSelect:  短视频裁剪视频选择页
 - AlivcViewControlCrop:             短视频裁剪页
 */
typedef NS_ENUM(NSInteger, AlivcViewControlType){
    AlivcViewControlEditParam = 0,
    AlivcViewControlEditVideoSelect,
    AlivcViewControlEdit, //目前暂不支持直接进入编辑界面，因为视频选择界面处理了视频的编解码，
    AlivcViewControlRecordParam,
    AlivcViewControlRecord,
    AlivcViewControlCropParam,
    AlivcViewControlCropVideoSelect,
    AlivcViewControlCrop,
};

#pragma mark - FinishBlock Define - 最终输出以block参数的形式给出
/**
 编辑完成动作类型定义

 @param outputPath 编辑完成的视频的输出路径
 */
typedef void (^AlivcEditFinishBlock)(NSString *outputPath);

/**
 录制完成动作类型定义
 
 @param outputPath 录制完成输出路径
 */
typedef void (^AlivcRecordFinishBlock)(NSString *outputPath);

/**
 裁剪完成动作类型定义
 
 @param outputPath 录制完成输出路径
 */
typedef void (^AlivcCropFinishBlock)(NSString *outputPath);


#pragma mark - RouteClassDefine

/**
 短视频单独模块集成入口类
 */
@interface AlivcShortVideoRoute : NSObject

/**
 单例 - 短视频的界面管理器，路由机制

 @return 实例
 */
+ (instancetype)shared;


/**
 注册一个视频配置，目前所有模块公用一个视频配置，想要不同的配置，获取视图控制器之前，调用此方法更新值

 @param config 视频配置
 */
-(void)registerMediaConfig:(AliyunMediaConfig *__nullable)config;

#pragma mark - Record 录制输入输出配置

/**
 输入 短视频录制页面的配置

 @param config 录制页面UI配置类
 */
-(void)registerRecordUIConfig:(AlivcRecordUIConfig *__nullable)config;

/**
 输入 注册一个录制完成动作
 输出 block里的参数
 @param block 完成动作
 */
- (void)registerRecordFinishBlock:(AlivcRecordFinishBlock )block;

#pragma mark - Edit 编辑输入输出配置

/**
 注册编辑页面的UI配置类
 
 @param config 编辑页面UI配置类
 */
-(void)registerEditUIConfig:(AlivcEditUIConfig *__nullable)config;

/**
 配置视频编辑界面的单个视频路径

 @param singleVideoPath 编辑界面的单个视频路径
 */
- (void)registerEditVideoPath:(NSString *__nullable)singleVideoPath;

/**
 配置视频编辑界面的多个媒体资源的路径

 @param mediasPath 多个媒体资源的路径
 */
- (void)registerEditMediasPath:(NSString *__nullable)mediasPath;

/**
 注册一个编辑完成动作
 
 @param block 完成动作
 */
- (void)registerEditFinishBlock:(AlivcEditFinishBlock )block;

#pragma mark - Crop 裁剪参数输入输出配置

/**
 注册一个裁剪完成动作
 
 @param block 完成动作
 */
- (void)registerCropFinishBlock:(AlivcCropFinishBlock )block;


/**
 获取一个短视频模块的一个视图控制器
 
 @param type 控制器类型
 @return 功能接入口控制器
 */
-(UIViewController *)alivcViewControllerWithType:(AlivcViewControlType )type;

@end
NS_ASSUME_NONNULL_END
