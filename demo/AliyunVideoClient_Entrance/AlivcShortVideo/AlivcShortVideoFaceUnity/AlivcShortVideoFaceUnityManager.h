//
//  AlivcShortVideoFaceUnityManager.h
//  AliyunVideoClient_Entrance
//
//  Created by 张璠 on 2018/7/13.
//  Copyright © 2018年 Alibaba. All rights reserved.
//  faceUnity管理类

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface AlivcShortVideoFaceUnityManager : NSObject

+ (AlivcShortVideoFaceUnityManager *)shareManager;
/**销毁全部道具*/
- (void)destoryItems;
- (NSInteger)OutputVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer textureName:(NSInteger)textureName beautyWhiteValue:(CGFloat)beautyWhiteValue blurValue:(CGFloat)blurValue bigEyeValue:(CGFloat)bigEyeValue slimFaceValue:(CGFloat)slimFaceValue buddyValue:(CGFloat)buddyValue;
- (CVPixelBufferRef)RenderedPixelBufferWithRawSampleBuffer:(CMSampleBufferRef)sampleBuffer beautyWhiteValue:(CGFloat)beautyWhiteValue blurValue:(CGFloat)blurValue bigEyeValue:(CGFloat)bigEyeValue slimFaceValue:(CGFloat)slimFaceValue buddyValue:(CGFloat)buddyValue;
@end
