//
//  QUCompressManager.h
//  AliyunVideo
//
//  Created by Worthy on 2017/3/25.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AliyunMediaConfig.h"

@interface AliyunCompressManager : NSObject

@property (nonatomic, strong) AliyunMediaConfig *config;

- (instancetype)initWithMediaConfig:(AliyunMediaConfig *)config;

/**
 使用aliyunSDK进行转码压缩

 @param sourcePath 原视频路径
 @param outputPath 视频输出路径
 @param outputSize 输出分辨率
 @param success 成功回调
 @param failure 失败回调
 */
- (void)compressWithSourcePath:(NSString *)sourcePath
                    outputPath:(NSString *)outputPath
                    outputSize:(CGSize)outputSize
                       success:(void (^)(void))success
                       failure:(void(^)(int errorCode))failure;

/**
 使用aliyunSDK进行图片压缩

 @param sourceImage 原图片路径
 @param outputSize 图片输出分辨率
 @return 压缩后的图片
 */
- (UIImage *)compressImageWithSourceImage:(UIImage *)sourceImage
                               outputSize:(CGSize)outputSize;

/**
 aliyunSDK停止视频压缩
 */
- (void)stopCompress;

/**
 使用系统转码进行视频压缩

 @param sourcePath 原视频路径
 @param outputPath 视频输出路径
 @param complete 完成回调
 */
- (void)compressWithAVFoundationSourcePath:(NSString *)sourcePath
                                outputPath:(NSString *)outputPath
                                  complete:(void (^)(AVAssetExportSessionStatus status))complete;




@end
