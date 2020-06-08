//
//  AliyunMediaConfig.h
//  AliyunVideo
//
//  Created by Worthy on 2017/3/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

/**
 清晰度

 - AliyunMediaQualityVeryHight: 超高清
 - AliyunMediaQualityHight: 高清
 - AliyunMediaQualityMedium: 普通
 - AliyunMediaQualityLow: 低
 - AliyunMediaQualityPoor: 很低
 - AliyunMediaQualityExtraPoor: 差
 */
typedef NS_ENUM(NSInteger, AliyunMediaQuality) {
    AliyunMediaQualityVeryHight,
    AliyunMediaQualityHight,
    AliyunMediaQualityMedium,
    AliyunMediaQualityLow,
    AliyunMediaQualityPoor,
    AliyunMediaQualityExtraPoor
};


/**
裁剪模式

 - AliyunMediaCutModeScaleAspectFill: 填充
 - AliyunMediaCutModeScaleAspectCut: 裁剪
 */
typedef NS_ENUM(NSInteger, AliyunMediaCutMode) {
    AliyunMediaCutModeScaleAspectFill = 0,
    AliyunMediaCutModeScaleAspectCut = 1
};

/**
 编码格式

 - AliyunEncodeModeSoftH264: 软编：提升质量、牺牲速度
 - AliyunEncodeModeHardH264: 硬编：提升速度、牺牲视频质量
 */
typedef NS_ENUM(NSInteger, AliyunEncodeMode) {
    AliyunEncodeModeHardH264,
    AliyunEncodeModeSoftFFmpeg
};

/**
 视频比例

 - AliyunMediaRatio9To16: 9：16
 - AliyunMediaRatio3To4: 3：4
 - AliyunMediaRatio1To1: 1：1
 - AliyunMediaRatio4To3: 4：3
 - AliyunMediaRatio16To9: 16：9
 */
typedef NS_ENUM(NSInteger, AliyunMediaRatio) {
    AliyunMediaRatio9To16,
    AliyunMediaRatio3To4,
    AliyunMediaRatio1To1,
    AliyunMediaRatio4To3,
    AliyunMediaRatio16To9,
};


/**
 媒体资源类型

 - kPhotoMediaTypeVideo: 视频
 - kPhotoMediaTypePhoto: 图片
 */
typedef NS_ENUM(NSInteger, kPhotoMediaType) {
    kPhotoMediaTypeVideo,
    kPhotoMediaTypePhoto,
};

/**
 美颜依赖类型

 - AlivcBeautyTypeRace: Race
 - AlivcBeautyTypeFaceUnity: FaceUnity
 */
typedef NS_ENUM(NSInteger, AlivcBeautyType) {
    AlivcBeautyTypeRace,
    AlivcBeautyTypeFaceUnity,
};

@class AVAsset;
@interface AliyunMediaConfig : NSObject<NSCopying,NSMutableCopying>

/**
 原视频路径
 */
@property (nonatomic, strong) NSString *sourcePath;

/**
 原视频时长
 */
@property (nonatomic, assign) CGFloat sourceDuration;

/**
 输出路径
 */
@property (nonatomic, strong) NSString *outputPath;

/**
 输出大小
 */
@property (nonatomic, assign) CGSize outputSize;

/**
 开始时间
 */
@property (nonatomic, assign) CGFloat startTime;

/**
 结束时间
 */
@property (nonatomic, assign) CGFloat endTime;

/**
 最小时长
 */
@property (nonatomic, assign) CGFloat minDuration;

/**
 最大时长
 */
@property (nonatomic, assign) CGFloat maxDuration;

/**
 裁剪模式
 */
@property (nonatomic, assign) AliyunMediaCutMode cutMode;

/**
 视频录制清晰度
 */
@property (nonatomic, assign) AliyunMediaQuality videoQuality;

/**
 编码格式
 */
@property (nonatomic, assign) AliyunEncodeMode encodeMode;

/**
 帧率
 */
@property (nonatomic, assign) int fps;

/**
 关键帧间隔
 */
@property (nonatomic, assign) int gop;

/**
 系统音视频信息类
 */
@property (nonatomic, strong) AVAsset *avAsset;

/**
 系统相册图片信息类
 */
@property (nonatomic, strong) PHAsset *phAsset;

@property (nonatomic, strong) UIImage *phImage;

/**
 是否仅展示视频
 */
@property (nonatomic, assign) BOOL videoOnly;

/**
 视频角度，以第一段为准 0/90/180/270
 */
@property (nonatomic, assign) int videoRotate;

/**
 填充的背景颜色
 */
@property (nonatomic, assign) UIColor *backgroundColor;

/**
 是否开启GUP剪裁
 */
@property (nonatomic, assign) BOOL gpuCrop;

/**
 是否有片尾
 */
@property (nonatomic, assign) BOOL hasEnd;

/**
 美颜类型
 */
@property (nonatomic, assign)AlivcBeautyType beautyType;

/**
 录制的视频是否左右翻转
 */
@property (nonatomic, assign) BOOL videoFlipH;


/**
 获取一个裁剪配置信息类

 @param outputPath 输出路径
 @param outputSize 输出大小
 @param minDuration 最小裁剪时长
 @param maxDuration 最大裁剪时长
 @param cutMode 裁剪模式
 @param videoQuality 视频清晰度
 @param fps 帧率
 @param gop 码率
 @return 裁剪配置信息类
 */
+ (instancetype)cutConfigWithOutputPath:(NSString *)outputPath
                             outputSize:(CGSize)outputSize
                            minDuration:(CGFloat)minDuration
                            maxDuration:(CGFloat)maxDuration
                                cutMode:(AliyunMediaCutMode)cutMode
                           videoQuality:(AliyunMediaQuality)videoQuality
                                    fps:(int)fps
                                    gop:(int)gop;

/**
 获取一个录制配置信息类

 @param outputPath 输出路径
 @param outputSize 输出大小
 @param minDuration 最小录制时长
 @param maxDuration 最大录制时长
 @param videoQuality 视频清晰度
 @param encodeMode 编码方式
 @param fps 帧率
 @param gop 码率
 @return 录制配置信息类
 */
+ (instancetype)recordConfigWithOutpusPath:(NSString *)outputPath
                                outputSize:(CGSize)outputSize
                               minDuration:(CGFloat)minDuration
                               maxDuration:(CGFloat)maxDuration
                              videoQuality:(AliyunMediaQuality)videoQuality
                                    encode:(AliyunEncodeMode)encodeMode
                                       fps:(int)fps
                                       gop:(int)gop;

/**
 初始化config

 @return 初始化后的config
 */
+ (instancetype)invertConfig;

/**
 获取一个默认属性的config

 @return 默认属性的config
 */
+ (instancetype)defaultConfig;

/**
 根据视频角度获取视频大小

 @param r 视频角度
 @return 视频大小
 */
- (CGSize)updateVideoSizeWithRatio:(CGFloat)r;

/**
 获取视频比例

 @return 视频比例
 */
- (AliyunMediaRatio)mediaRatio;

/**
 修正视频size

 @return 修正后的视频size
 */
- (CGSize)fixedSize;

@end
