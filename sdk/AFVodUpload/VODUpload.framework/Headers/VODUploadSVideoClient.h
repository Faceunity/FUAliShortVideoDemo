//
//  VODUploadSimpleClient.h
//  VODUpload
//
//  Created by Worthy on 2017/11/2.
//  Copyright © 2017年 Leigang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VODUploadSVideoModel.h"

@protocol VODUploadSVideoClientDelegate <NSObject>

- (void)uploadSuccessWithResult:(VodSVideoUploadResult *)result;

- (void)uploadFailedWithCode:(NSString *)code message:(NSString *)message;

- (void)uploadProgressWithUploadedSize:(long long)uploadedSize totalSize:(long long)totalSize;

- (void)uploadTokenExpired;

- (void)uploadRetry;

- (void)uploadRetryResume;

@optional
- (void)uploadSuccessWithVid:(NSString *)vid imageUrl:(NSString *)imageUrl __deprecated_msg("using uploadSuccessWithResult: instead");

@end

@interface VODUploadSVideoClient : NSObject

@property (nonatomic, weak) id<VODUploadSVideoClientDelegate> delegate;

/**
 transcode default value is YES
 */
@property (nonatomic, assign) BOOL transcode;

/**
 Max retry count, default value is INT_MAX
 Client will retry automatically in every 2 seconds when network is unavailable
 */
@property (nonatomic, assign) uint32_t maxRetryCount;

/**
 Sets single object download's max time
 */
@property (nonatomic, assign) NSTimeInterval timeoutIntervalForRequest;

/**
 directory path about create record uploadId file
 */
@property (nonatomic, copy) NSString * recordDirectoryPath;

/**
 record upload progress, default value is YES
 */
@property (nonatomic, assign) BOOL recordUploadProgress;

/**
 size of upload part, default value is 1024 * 1024
 */
@property (nonatomic, assign) NSInteger uploadPartSize;

/**
 vod region, defalut value is "cn-shanghai"
 */
@property (nonatomic, copy) NSString *region;

/**
 开始上传

 @param videoPath 视频文件路径
 @param imagePath 图片文件路径
 @param svideoInfo 短视频上传信息
 @param accessKeyId STS accessKeyId
 @param accessKeySecret  STS accessKeySecret
 @param accessToken STS accessToken
 @return 调用接口是否成功
 */
- (BOOL)uploadWithVideoPath:(NSString *)videoPath
                  imagePath:(NSString *)imagePath
                 svideoInfo:(VodSVideoInfo *)svideoInfo
                accessKeyId:(NSString *)accessKeyId
            accessKeySecret:(NSString *)accessKeySecret
                accessToken:(NSString *)accessToken;

/**
 暂停上传
 */
- (void)pause;

/**
 恢复上传
 */
- (void)resume;

/**
 刷新STS凭证，并继续上传

 @param accessKeyId STS accessKeyId
 @param accessKeySecret  STS accessKeySecret
 @param accessToken STS accessToken
 @param expireTime STS expireTime
 */
- (void)refreshWithAccessKeyId:(NSString *)accessKeyId
               accessKeySecret:(NSString *)accessKeySecret
                   accessToken:(NSString *)accessToken
                    expireTime:(NSString *)expireTime;

/**
 取消上传
 */
- (void)cancel;

@end
