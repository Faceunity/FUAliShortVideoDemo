//
//  AliyunVodPublishManager2.h
//  AliyunVideoSDKPro
//
//  Created by Worthy Zhang on 2018/12/28.
//  Copyright © 2018 Alibaba Group Holding Limited. All rights reserved.
//

#import <AliyunVideoSDKPro/AliyunEditor.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class AliyunVodPublishManager2;
@class UploadStreamFileInfo;

/**
 上传回调类
 */
/****
 A class that defines upload callbacks.
 */
@protocol AliyunIVodUploadCallback <NSObject>

/**
 上传成功

 @param manager AliyunVodPublishManager2
 */
/****
 The callback when the upload is successful.

 @param manager AliyunVodPublishManager2
 */
- (void)publishManagerUploadSuccess:(AliyunVodPublishManager2 *)manager;

/**
 上传失败

 @param manager AliyunVodPublishManager2
 @param code 错误码
 @param message 错误描述
 */
/****
 The callback when an error occurs during upload.

 @param manager AliyunVodPublishManager2
 @param code The error code.
 @param message The error message.
 */
- (void)publishManager:(AliyunVodPublishManager2 *)manager uploadFailedWithCode:(NSString *)code message:(NSString *)message;

/**
 上传进度

 @param manager AliyunVodPublishManager2
 @param uploadedSize 已上传数据大小
 @param totalSize 所有数据大小
 */
/****
 The callback that outputs the upload progress.

 @param manager AliyunVodPublishManager2
 @param uploadedSize The uploaded file size.
 @param totalSize The total file size.
 */
- (void)publishManager:(AliyunVodPublishManager2 *)manager uploadProgressWithUploadedSize:(long long)uploadedSize totalSize:(long long)totalSize;

/**
 上传token过期

 @param manager AliyunVodPublishManager2
 */
/****
 The callback when the token expires.

 @param manager AliyunVodPublishManager2
 */
- (void)publishManagerUploadTokenExpired:(AliyunVodPublishManager2 *)manager;

/**
 上传超时，开始尝试重试

 @param manager AliyunVodPublishManager2
 */
/****
 The callback when the upload is retried.

 @param manager AliyunVodPublishManager2
 */
- (void)publishManagerUploadRetry:(AliyunVodPublishManager2 *)manager;

/**
 重试成功，开始继续上传

 @param manager AliyunVodPublishManager2
 */
/****
 The callback when the retry is successful.

 @param manager AliyunVodPublishManager2
 */
- (void)publishManagerUploadRetryResume:(AliyunVodPublishManager2 *)manager;

@end

/**
 上传状态

 - AliyunVodUploadImage: 上传图片
 - AliyunVodUploadVideo: 上传视频
 */
/****
 Upload types.

 - AliyunVodUploadImage: Image upload
 - AliyunVodUploadVideo: Video upload
 */
typedef NS_OPTIONS(NSInteger, AliyunVodUploadState) {
    AliyunVodUploadImage,
    AliyunVodUploadVideo,
};

/**
 发布管理器
 */
/****
 A class that defines publish managers.
 */
@interface AliyunVodPublishManager2 : NSObject

/**
 合成导出回调类
 */
/****
 The export callback.
 */
@property (nonatomic, weak) id<AliyunIExporterCallback> exportCallback;

/**
 合成自定义渲染回调
 */
/****
 The custom render callback.
 */
@property (nonatomic, weak) id<AliyunIRenderCallback> customRenderCallback;

/**
 上传回调类
 */
/****
 The upload callback.
 */
@property (nonatomic, weak) id<AliyunIVodUploadCallback> uploadCallback;

/**
 当前上传状态
 */
/****
 The upload state.
 */
@property (nonatomic, assign) AliyunVodUploadState uploadState;

/**
 上传视频本地路径
 */
/****
 The path of the video to be uploaded.
 */
@property (nonatomic, copy) NSString *videotPath;

/**
 上传图片本地路径
 */
/****
 The path of the image to be uploaded.
 */
@property (nonatomic, copy) NSString *imagePath;

/**
 上传是否开启日志上报，默认开启
 */
/****
 Enable upload log report or not. Default is true.
 */
@property (nonatomic, assign) BOOL reportEnabled;

/**
 边导出边上传的分片大小，默认1MB；最少100KB
 */
/****
 The partSize for upload with export. default 1MB; MinValue:100KB
 */
@property (nonatomic, assign) NSUInteger uploadPartSize;


#pragma mark - export

/**
 合成导出视频

 @param taskPath taskPath
 @param outputPath 导出视频路径
 @return 返回值
 */
/****
 Starts exporting.

 @param taskPath The path of the taskPath folder.
 @param outputPath The video output path.
 @return A return value.
 */
- (int)exportWithTaskPath:(NSString *)taskPath outputPath:(NSString *)outputPath;

/**
 合成并上传
 
 @param taskPath taskPath
 @param outputPath 导出视频路径
 @param vodUploadAddress 点播上传地址
 @param vodUploadAuth 点播上传凭证
 @return 返回值
 */
/****
 Start exporting and upload at the same time
 
 @param taskPath The path of the taskPath folder.
 @param outputPath The video output path.
 @param vodUploadAddress The upload URL.
 @param vodUploadAuth The upload credential.
 */
- (int)exportWithTaskPath:(NSString *)taskPath outputPath:(NSString *)outputPath
            uploadAddress:(NSString *)vodUploadAddress uploadAuth:(NSString *)vodUploadAuth;

/**
 合成导出到流上传文件
 
 @param taskPath taskPath
 @param outputPath 导出视频路径
 @param outStreamFile 输出到流上传文件
 @return 返回值 输出到流文件
 */
/****
 Start exporting to outputPath and streamFile
 
 @param taskPath The path of the taskPath folder.
 @param outputPath The video output path.
 @param outStreamFile The stream file for output
 */
- (UploadStreamFileInfo *)exportToStreamFileWithTaskPath:(NSString *)taskPath
                                              outputPath:(NSString *)outputPath
                                                   error:(NSError **)error;

/**
 暂停合成导出

 @return 返回值
 */
/****
 Pauses exporting.

 @return A return value.
 */
- (int)pauseExport;

/**
 继续合成导出

 @return 返回值
 */
/****
 Resumes exporting.

 @return A return value.
 */
- (int)resumeExport;

/**
 取消合成导出

 @return 返回值
 */
/****
 Cancels exporting.

 @return A return value.
 */
- (int)cancelExport;

#pragma mark - upload

/**
 上传流文件
 
 @param streamFile 流文件
 @param vodUploadAddress 点播上传地址
 @param vodUploadAuth 点播上传凭证
 */
/****
 Upload a streamFile
 
 @param streamFile
 @param vodUploadAddress The upload URL.
 @param vodUploadAuth The upload credential.
 */
- (int)uploadStreamFile:(UploadStreamFileInfo *)streamFile
          uploadAddress:(NSString *)vodUploadAddress
             uploadAuth:(NSString *)uploadAuth;

/**
 上传封面

 @param imagePath 封面图片路径
 @param vodUploadAddress 点播上传地址
 @param vodUploadAuth 点播上传凭证
 @return 返回值
 */
/****
 Uploads a thumbnail.

 @param imagePath The path of the thumbnail image.
 @param vodUploadAddress The upload URL.
 @param vodUploadAuth The upload credential.
 @return A return value.
 */
- (int)uploadImageWithPath:(NSString *)imagePath
              uploadAddress:(NSString *)vodUploadAddress
                 uploadAuth:(NSString *)vodUploadAuth;

/**
 上传视频

 @param videoPath 视频路径
 @param vodUploadAddress 点播上传地址
 @param vodUploadAuth 点播上传凭证
 @return 返回值
 */
/****
 Uploads a video.

 @param videoPath The path of the video.
 @param vodUploadAddress The upload URL.
 @param vodUploadAuth The upload credential.
 @return A return value.
 */
- (int)uploadVideoWithPath:(NSString *)videoPath
              uploadAddress:(NSString *)vodUploadAddress
                 uploadAuth:(NSString *)vodUploadAuth;

/**
 暂停上传

 @return 返回值
 */
/****
 Pauses uploading.

 @return A return value.
 */
- (int)pauseUpload;

/**
 继续上传

 @return 返回值
 */
/****
 Resumes uploading.

 @return A return value.
 */
- (int)resumeUpload;

/**
 取消上传

 @return 返回值
 */
/****
 Cancels uploading.

 @return A return value.
 */
- (int)cancelUpload;

/**
 刷新上传凭证

 @param vodUploadAuth 新的上传凭证
 @return 返回值
 */
/****
 Updates the upload credential.

 @param vodUploadAuth The new upload credential.
 @return A return value.
 */
- (int)refreshWithUploadAuth:(NSString *)vodUploadAuth;

@end

NS_ASSUME_NONNULL_END
