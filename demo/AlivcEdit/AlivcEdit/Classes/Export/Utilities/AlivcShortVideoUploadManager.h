//
//  AlivcShortVideoUploadManager.h
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/11/9.
//  Copyright © 2018年 Alibaba. All rights reserved.
//  上传管理器

#import <Foundation/Foundation.h>
#import <AliyunVideoSDKPro/AliyunPublishManager.h>

@class AliyunUploadSVideoInfo;
@class AlivcShortVideoUploadManager;

typedef NS_ENUM(NSInteger,AlivcUploadStatus){
    AlivcUploadStatusSuccess = 0,
    AlivcUploadStatusUploading,
    AlivcUploadStatusFailure,
    AlivcUploadStatusCancel,
    AlivcUploadStatusPause
};

@protocol AlivcShortVideoUploadManagerDelegate <NSObject>

@required
/**
 上传状态回调

 @param manager manager
 @param newStatus 新的状态
 */
- (void)uploadManager:(AlivcShortVideoUploadManager *)manager uploadStatusChangedTo:(AlivcUploadStatus )newStatus;

/**
 上传进度回调

 @param manager manager
 @param progress 0-1
 */
- (void)uploadManager:(AlivcShortVideoUploadManager *)manager updateProgress:(CGFloat )progress;

@optional

/**
 上传完成回调

 @param manager manager
 @param vid 视频id
 @param imageUrl 封面url
 */
- (void)uploadManager:(AlivcShortVideoUploadManager *)manager succesWithVid:(NSString *)vid coverImageUrl:(NSString *)imageUrl;

@end

@interface AlivcShortVideoUploadManager : NSObject

/**
 单例 - 主要为了使用方便和模块间的低耦合

 @return 实例
 */
+ (instancetype)shared;

/**
 本次上传发生事情的回调代理
 */
@property (nonatomic, weak) id<AlivcShortVideoUploadManagerDelegate> managerDelegate;

/**
 设置上传信息
 
 @param imagePath 图片地址
 @param videoInfo 视频信息
 @param videoPath 视频路径
 */
- (void)setCoverImagePath:(NSString *)imagePath videoInfo:(AliyunUploadSVideoInfo *)videoInfo videoPath:(NSString *)videoPath;

/**
 开始上传
 */
- (void)startUpload;

/**
 上传 - 自带sts

 @param keyId keyId
 @param keySecret keySecret
 @param token token
 @return 成功或者失败
 */
//- (BOOL)startUploadWithKey:(NSString *)keyId secres:(NSString *)keySecret token:(NSString *)token;


/**
 暂停上传

 @return 是否成功
 */
- (int)pauseUpload;

/**
 继续上传

 @return 是否成功
 */
- (int)resumeUpload;

/**
 取消上传
 */
- (void)cancelUpload;


- (AlivcUploadStatus)currentStatus;

- (NSString *)coverImagePath;












@end
