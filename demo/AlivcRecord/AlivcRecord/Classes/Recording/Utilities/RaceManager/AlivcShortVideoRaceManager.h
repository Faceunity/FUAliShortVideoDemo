//
//  AlivcShortVideoRaceManager.h
//  AliyunVideoClient_Entrance
//
//  Created by 郦立 on 2019/9/19.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AlivcPushBeautyParams.h"

@interface AlivcShortVideoRaceManager : NSObject

+ (AlivcShortVideoRaceManager *)shareManager;

- (void)clear;


/// 根据美颜美型参数，对race进行设置以及返回一个值
/// @param sampleBuffer 相机数据
/// @param skinBuffingValue 磨皮
/// @param skinWhiteningValue 美白
/// @param sharpenValue 锐化
/// @param  bigEyeValue 大眼
/// @param longFaceValue 脸长
/// @param cutFaceValue 削脸
/// @param thinFaceValue 瘦脸
/// @param lowerJawValue 下巴
/// @param mouthWidthValue 唇宽
/// @param thinNoseValue 瘦鼻
/// @param thinMandibleValue 下颌
/// @param cutCheekValue 颧骨
- (int)customRenderWithBuffer:(CMSampleBufferRef)sampleBuffer
                  skinBuffing:(CGFloat)skinBuffingValue
                skinWhitening:(CGFloat)skinWhiteningValue
                      sharpen:(CGFloat)sharpenValue
                       bigEye:(CGFloat)bigEyeValue
                     longFace:(CGFloat)longFaceValue
                      cutFace:(CGFloat)cutFaceValue
                     thinFace:(CGFloat)thinFaceValue
                     lowerJaw:(CGFloat)lowerJawValue
                   mouthWidth:(CGFloat)mouthWidthValue
                     thinNose:(CGFloat)thinNoseValue
                 thinMandible:(CGFloat)thinMandibleValue
                     cutCheek:(CGFloat)cutCheekValue;

@end

