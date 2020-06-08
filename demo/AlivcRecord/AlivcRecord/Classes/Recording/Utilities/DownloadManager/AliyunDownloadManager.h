//
//  AliyunDownloadManager.h
//  AliyunVideo
//
//  Created by Vienta on 2017/1/16.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//  下载管理类

#import <Foundation/Foundation.h>
#import "AliyunPasterInfo.h"

@interface AliyunDownloadTask : NSObject

/**
 正在下载的block回调
 */
@property(nonatomic, copy) void (^progressBlock)(NSProgress *progress);

/**
 下载完成的block回调
 */
@property(nonatomic, copy) void (^completionHandler)(NSString *filePath, NSError *error);

/**
 人脸动图模型
 */
@property(nonatomic, readonly) AliyunPasterInfo *pasterInfo;

// 模型的初始化方法，TODO:目前只有一种资源类型 先简单写 年后再拓展封装
- (id)initWithInfo:(AliyunPasterInfo *)pasterInfo;

@end




@interface AliyunDownloadManager : NSObject


/**
 下载管理器中添加任务

 @param task 任务
 */
- (void)addTask:(AliyunDownloadTask *)task;


/**
 下载管理器中添加任务

 @param task 任务
 @param progressBlock 正在下载的block回调
 @param completionHandler 下载完成的block回调
 */
- (void)addTask:(AliyunDownloadTask *)task
        progress:(void (^)(NSProgress*downloadProgress))progressBlock
completionHandler:(void(^)(NSString *filePath, NSError *error))completionHandler;


@end
