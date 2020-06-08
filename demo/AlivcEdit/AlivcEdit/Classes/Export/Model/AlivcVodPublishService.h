//
//  AlivcVodPublishService.h
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/5/22.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AliyunVideoSDKPro/AliyunVodPublishManager.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,AlivcVodServiceUploadStatus){
    AlivcVodServiceUploadStatusDefault = 1,
    AlivcVodServiceUploadStatusUploading,
    AlivcVodServiceUploadStatusPause,
    AlivcVodServiceUploadStatusExpired
};

@protocol AlivcVodPublishServiceDelegate <NSObject>
//上传

/**
 上传成功回调

 @param uploadType 当前成功的上传类型
 */
- (void)uploadSuccessWithUploadType:(AliyunVodUploadState)uploadType;

/**
 上传失败回调

 @param uploadType 当前失败的上传类型
 @param code 错误码
 @param message 错误信息
 */
- (void)uploadFailedWithUploadType:(AliyunVodUploadState)uploadType withErrorCode:(NSString *)code message:(NSString *)message;

/**
 上传进度回调

 @param uploadType 当前回调的上传类型
 @param uploadedSize 上传的大小
 @param totalSize 总大小
 */
- (void)uploadProgressWithUploadType:(AliyunVodUploadState)uploadType withUploadedSize:(long long)uploadedSize totalSize:(long long)totalSize;
@end

@interface AlivcVodPublishService : NSObject

+ (AlivcVodPublishService *)service;

@property (nonatomic, assign) AlivcVodServiceUploadStatus uploadStatus;

/**
 导出视频

 @param taskPath task路径
 @param outputPath 输出文件路径
 @return 执行结果
 */
- (BOOL)exportWithTaskPath:(NSString *)taskPath outputPath:(NSString *)outputPath;

/**
 暂停合成

 @return 执行结果
 */
- (int)pauseExport;

/**
 继续合成

 @return 执行结果
 */
- (int)resumeExport;

- (int)cancelExport;

@property (nonatomic, assign) AliyunVodUploadState uploadType;
@property (nonatomic, weak) id<AlivcVodPublishServiceDelegate> delegate;
@property (nonatomic, weak) id<AliyunIExporterCallback> exportCallback;

- (void)uploadWithImagePath:(NSString *)imagePath withResult:(nullable void(^)(BOOL result))result;

- (void)uploadVideoWithPath:(NSString *)videoPath withCoverImagePath:(NSString *)imagePath withDesc:(NSString *)desc withTag:(NSString *)tag withResultCode:(nullable void(^)(int resultCode))result;

- (int)pauseUpload;

- (int)resumeUpload;

- (int)cancelUpload;

@end

NS_ASSUME_NONNULL_END
