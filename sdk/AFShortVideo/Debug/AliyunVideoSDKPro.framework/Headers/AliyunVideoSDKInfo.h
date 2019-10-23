//
//  AliyunVideoSDKInfo.h
//  QUSDK
//
//  Created by Worthy on 2017/5/23.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
// BUILD INFO
// AliyunAlivcCommitId:e7fe5e9
// AliyunMediaCoreCommitId:58f1215
// AliyunVideoSDKCommitId:9304907
// AliyunVideoSDKBuildId:11483076

#import <Foundation/Foundation.h>

/**
 专业版
 */
extern NSString* const kAliyunVideoSDKModulePro;

/**
 标准版
 */
extern NSString* const kAliyunVideoSDKModuleStandard;

/**
 基础版
 */
extern NSString* const kAliyunVideoSDKModuleBasic;

/**
 log等级

 - AlivcLogVerbose: Verbose
 - AlivcLogDebug: Debug
 - AlivcLogInfo: Info
 - AlivcLogWarn: Warn
 - AlivcLogError: Error
 - AlivcLogFatal: Fatal
 */
typedef NS_ENUM(NSInteger, AlivcLogLevel) {
    AlivcLogVerbose = 2,
    AlivcLogDebug,
    AlivcLogInfo,
    AlivcLogWarn,
    AlivcLogError,
    AlivcLogFatal
};


/**
 sdk基础信息与设置类
 */
@interface AliyunVideoSDKInfo : NSObject

/**
 获取版本号

 @return 版本号
 */
+ (NSString *)version;

/**
 获取module
 
 kAliyunVideoSDKModulePro
 kAliyunVideoSDKModuleStandard
 kAliyunVideoSDKModuleBasic
 @return module类型
 */
+ (NSString *)module;

/**
 获取alivc commit id
 版本build相关，开发者无需关心
 @return alivc commit id
 */
+ (NSString *)alivcCommitId;

/**
 获取mediacore commit id
 版本build相关，开发者无需关心
 @return mediacore commit id
 */
+ (NSString *)mediaCoreCommitId;

/**
 获取video sdk commid id
 版本build相关，开发者无需关心
 @return video sdk commid id
 */
+ (NSString *)videoSDKCommitId;

/**
 获取build id
 版本build相关，开发者无需关心
 @return build id
 */
+ (NSString *)videoSDKBuildId;

/**
 打印版本信息
 */
+ (void)printSDKInfo;

/**
 注册SDK
 目前无需调用
 */
+ (void)registerSDK;

/**
 设置日志等级

 @param level 日志等级
 默认值AlivcLogError，只有在报错时才有日志
 调试阶段可以设置为AlivcLogVerbose或AlivcLogDebug
 */
+ (void)setLogLevel:(AlivcLogLevel)level;

/**
 设置用户id
 设置业务层用户id，用于线上用户反馈问题的日志排查

 @param userId 用户id
 */
+ (void)setUserId:(NSString *)userId;

/**
 获取用户id

 @return 用户id
 */
+ (NSString *)userId;

/**
 设备信息上传

 @param conanUpload 是否上传
 */
+ (void)setDeviceInfoUpload:(BOOL)conanUpload;

/**
 获取设备信息上传

 @return 结果
 */
+ (BOOL)deviceInfoUpload;

@end
