//
//  AliyunMediaConfig.m
//  AliyunVideo
//
//  Created by Worthy on 2017/3/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunMediaConfig.h"

@implementation AliyunMediaConfig

-(instancetype)copyWithZone:(NSZone *)zone{
    AliyunMediaConfig *config = [AliyunMediaConfig allocWithZone:zone];
    config.sourcePath =self.sourcePath;
    config.sourceDuration = self.sourceDuration;
    config.outputPath = self.outputPath;
    config.outputSize = self.outputSize;
    config.startTime = self.startTime;
    config.endTime = self.endTime;
    config.minDuration = self.minDuration;
    config.maxDuration = self.maxDuration;
    config.cutMode = self.cutMode;
    config.videoQuality = self.videoQuality;
    config.encodeMode =self.encodeMode;
    config.fps = self.fps;
    config.gop =self.gop;
    config.avAsset = self.avAsset;
    config.phAsset = self.phAsset;
    config.phImage = self.phImage;
    config.videoOnly = self.videoOnly;
    config.videoRotate = self.videoRotate;
    config.backgroundColor = self.backgroundColor;
    config.gpuCrop = self.gpuCrop;
    config.hasEnd = self.hasEnd;
    config.beautyType = self.beautyType;
    config.videoFlipH = self.videoFlipH;
    return config;
}
-(instancetype)mutableCopyWithZone:(NSZone *)zone{
    AliyunMediaConfig *config = [AliyunMediaConfig allocWithZone:zone];
    config.sourcePath =self.sourcePath;
    config.sourceDuration = self.sourceDuration;
    config.outputPath = self.outputPath;
    config.outputSize = self.outputSize;
    config.startTime = self.startTime;
    config.endTime = self.endTime;
    config.minDuration = self.minDuration;
    config.maxDuration = self.maxDuration;
    config.cutMode = self.cutMode;
    config.videoQuality = self.videoQuality;
    config.encodeMode =self.encodeMode;
    config.fps = self.fps;
    config.gop =self.gop;
    config.avAsset = self.avAsset;
    config.phAsset = self.phAsset;
    config.phImage = self.phImage;
    config.videoOnly = self.videoOnly;
    config.videoRotate = self.videoRotate;
    config.backgroundColor = self.backgroundColor;
    config.gpuCrop = self.gpuCrop;
    config.hasEnd = self.hasEnd;
    config.videoFlipH = self.videoFlipH;
    config.beautyType = self.beautyType;
    return config;
}


+ (instancetype)cutConfigWithOutputPath:(NSString *)outputPath
                             outputSize:(CGSize)outputSize
                            minDuration:(CGFloat)minDuration
                            maxDuration:(CGFloat)maxDuration
                                cutMode:(AliyunMediaCutMode)cutMode
                           videoQuality:(AliyunMediaQuality)videoQuality
                                    fps:(int)fps
                                    gop:(int)gop {
    AliyunMediaConfig *config = [[AliyunMediaConfig alloc] init];
    config.outputPath = outputPath;
    config.outputSize = outputSize;
    config.minDuration = minDuration;
    config.maxDuration = maxDuration;
    config.cutMode = cutMode;
    config.videoQuality = videoQuality;
    config.fps = fps;
    config.gop = gop;
    return config;
}

+ (instancetype)recordConfigWithOutpusPath:(NSString *)outputPath
                                outputSize:(CGSize)outputSize
                               minDuration:(CGFloat)minDuration
                               maxDuration:(CGFloat)maxDuration
                              videoQuality:(AliyunMediaQuality)videoQuality
                                    encode:(AliyunEncodeMode)encodeMode
                                       fps:(int)fps
                                       gop:(int)gop {
    AliyunMediaConfig *config = [[AliyunMediaConfig alloc] init];
    config.outputPath = outputPath;
    config.outputSize = outputSize;
    config.minDuration = minDuration;
    config.maxDuration = maxDuration;
    config.videoQuality = videoQuality;
    config.fps = fps;
    config.gop = gop;
    config.encodeMode = encodeMode;
    return config;
}

+ (instancetype)invertConfig {
    AliyunMediaConfig *config = [[AliyunMediaConfig alloc] init];
    return config;
}

+ (instancetype)defaultConfig{
    AliyunMediaConfig *config = [[AliyunMediaConfig alloc] init];
    config.outputSize = CGSizeMake(720, 1280);
    config.videoQuality = AliyunMediaQualityHight;
    config.gop = 250;
    config.fps = 30;
    return config;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _fps = 25;
        _gop = 5;
        _videoQuality = 1;
        _backgroundColor = [UIColor blackColor]; 
    }
    return self;
}

- (CGSize)updateVideoSizeWithRatio:(CGFloat)r {
    
    CGFloat w = _outputSize.width;
    CGFloat h = ceilf(w / r);
    _outputSize = CGSizeMake(w, h);
    [self evenOutputSize];
    return _outputSize;
}

- (CGSize)fixedSize {
    [self evenOutputSize];
    if (_videoRotate == 90 || _videoRotate == 270) {
        return CGSizeMake(MAX(_outputSize.height, _outputSize.width), MIN(_outputSize.height, _outputSize.width));
    }
 
    return _outputSize;
}
//容错，导出须为偶数
- (void)evenOutputSize {
    int w = (int)_outputSize.width;
    int h = ceil(_outputSize.height);
    int fixedW = w / 2 * 2;
    int fixedH = h / 2 * 2;
    _outputSize = CGSizeMake((int)fixedW, (int)fixedH);
}

- (AliyunMediaRatio)mediaRatio {
    float aspects[5] = {9/16.0, 3/4.0, 1.0, 4/3.0,16/9.0};
    CGSize fixedSize = [self fixedSize];
    float videoAspect = fixedSize.width/fixedSize.height;
    int index = 0;
    for (int i = 0; i < 5; i++) {
        index = i;
        if (videoAspect <= aspects[i]) break;
    }
    if (index > 0) {
        if (fabsf(videoAspect - aspects[index]) > fabsf(videoAspect-aspects[index-1])) {
            index = index-1;
        }
    }
    return index;
}

- (CGFloat)maxDuration {
    if (_maxDuration < 0) {
        _maxDuration = 15;
    }
    return _maxDuration;
}

- (CGFloat)minDuration {
    if (_minDuration < 0) {
        _minDuration = 2;
    }
    return _minDuration;
}

@end
