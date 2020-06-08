//
//  AlivcShortVideoRaceManager.m
//  AliyunVideoClient_Entrance
//
//  Created by 郦立 on 2019/9/19.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AlivcShortVideoRaceManager.h"
#import <AVFoundation/AVFoundation.h>
#import <GLKit/GLKit.h>
#import <AliyunRace/aliyun_beautify.h> 

@interface AlivcShortVideoRaceManager()

@property (nonatomic,assign)uint32_t textureOut;
@property (nonatomic,assign)CGSize size;
@property (nonatomic,strong)NSLock *lock;
@property (nonatomic,assign) BOOL hasInit;
@property (nonatomic,assign) int initResult;

@end

static AlivcShortVideoRaceManager *manager = nil;
static race_t beautify = nullptr;

@implementation AlivcShortVideoRaceManager

+ (AlivcShortVideoRaceManager *)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AlivcShortVideoRaceManager alloc] init];
        manager.size = CGSizeZero;
        manager.lock = [[NSLock alloc]init];
        manager.hasInit = NO;
        manager.initResult = 0;
    });
    return manager;
}

- (void)clear {
    [self.lock lock];
//    aliyun_destroyTexture(manager.textureOut);
    manager.textureOut = 0;
    aliyun_beautify_destroy(beautify);
    beautify = nullptr;
    manager.hasInit = NO;
    manager.initResult = 0;
    [self.lock unlock];
}


- (int)customRenderWithBuffer:(CMSampleBufferRef)sampleBuffer skinBuffing:(CGFloat)skinBuffingValue skinWhitening:(CGFloat)skinWhiteningValue sharpen:(CGFloat)sharpenValue bigEye:(CGFloat)bigEyeValue longFace:(CGFloat)longFaceValue cutFace:(CGFloat)cutFaceValue thinFace:(CGFloat)thinFaceValue lowerJaw:(CGFloat)lowerJawValue mouthWidth:(CGFloat)mouthWidthValue thinNose:(CGFloat)thinNoseValue thinMandible:(CGFloat)thinMandibleValue cutCheek:(CGFloat)cutCheekValue{
    [self.lock lock];
    
    if(!self.hasInit) {
        self.initResult = aliyun_beautify_create(&beautify);
        aliyun_beautify_setFaceDebug(beautify, NO);
        aliyun_setLogLevel(ALR_LOG_LEVEL_WARN);
        self.hasInit = YES;
        
    }
    //初始化失败 直接返回0
    if (self.initResult < 0) {
        [self.lock unlock];
        return 0;
    }
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    if(!pixelBuffer) {
        [self.lock unlock];
        return 0;
    }
    aliyun_beautify_setFaceSwitch(beautify,YES);
    /**
     1、脸长、下巴、唇宽三项参数设置值时数据取反，设置值时加上负号即可（数值越大，脸越长、下巴越长、唇越宽）
     2.美型参数统一调整为原来的3倍，调节明显
     */
    //美颜
    aliyun_beautify_setSkinBuffing(beautify, skinBuffingValue); //磨皮
    aliyun_beautify_setSkinWhitening(beautify, skinWhiteningValue); //美白
    aliyun_beautify_setSharpen(beautify, sharpenValue); //锐化
    //美型
    aliyun_beautify_setFaceShape(beautify, ALR_FACE_TYPE_BIG_EYE, bigEyeValue * 3);//大眼
    aliyun_beautify_setFaceShape(beautify, ALR_FACE_TYPE_LONG_FACE, longFaceValue * -3);//脸长3
    aliyun_beautify_setFaceShape(beautify, ALR_FACE_TYPE_CUT_FACE, cutFaceValue * 3);//削脸
    aliyun_beautify_setFaceShape(beautify, ALR_FACE_TYPE_THIN_FACE, thinFaceValue * 3);//瘦脸
    aliyun_beautify_setFaceShape(beautify, ALR_FACE_TYPE_LOWER_JAW, lowerJawValue * -3);//下巴
    aliyun_beautify_setFaceShape(beautify, ALR_FACE_TYPE_MOUTH_WIDTH, mouthWidthValue * -3);//唇宽
    aliyun_beautify_setFaceShape(beautify, ALR_FACE_TYPE_THIN_NOSE, thinNoseValue * 3);//瘦鼻
    aliyun_beautify_setFaceShape(beautify, ALR_FACE_TYPE_THIN_MANDIBLE, thinMandibleValue * 3);//下颌
    aliyun_beautify_setFaceShape(beautify, ALR_FACE_TYPE_CUT_CHEEK, cutCheekValue*3);//颧骨
//    NSLog(@"Race Debug-------------------Start \n");
//    NSLog(@"\n 最终设置值 \n 磨皮：%f,\n 美白：%f,\n 锐化：%f,\n ---------- \n 削脸：%f,\n 瘦脸：%f,\n 脸长：%f,\n 下巴：%f,\n 大眼：%f,\n 瘦鼻：%f,\n 唇宽：%f,\n 下颌：%f,\n 颧骨：%f,\n ",skinBuffingValue,skinWhiteningValue,sharpenValue,cutFaceValue*3,thinFaceValue * 3,longFaceValue * -3,lowerJawValue * -3,bigEyeValue*3,thinNoseValue*3,mouthWidthValue * -3,thinMandibleValue*3,cutCheekValue*3);
//    NSLog(@"Race Debug-------------------End \n");
    //美颜美型渲染
    int tex = aliyun_beautify_processSampleBuffer(beautify, sampleBuffer);
    [self.lock unlock];
    return tex;
}

@end
