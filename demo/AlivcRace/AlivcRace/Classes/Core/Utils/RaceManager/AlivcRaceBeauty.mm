//
//  AlivcRaceBeauty.m
//  AlivcRace
//
//  Created by 孙震 on 2020/2/20.
//

#import "AlivcRaceBeauty.h"
#import <AliyunRace/aliyun_beautify.h>
#import <AVFoundation/AVFoundation.h>

@interface AlivcRaceBeauty()

@property (nonatomic,assign)CGSize size;
@property (nonatomic,assign) BOOL hasInit;
@property (nonatomic,assign) int initResult;

@end

static race_t beautify = nullptr;

@implementation AlivcRaceBeauty

- (instancetype)init {
    if (self =[super init]) {
        self.size = CGSizeZero; 
        self.hasInit = NO;
        self.initResult = 0;
    }
    return self;
}

- (void)clear {
    aliyun_beautify_destroy(beautify);
    beautify = nullptr;
    self.hasInit = NO;
    self.initResult = 0;
}


- (int)customRenderWithBuffer:(CMSampleBufferRef)sampleBuffer skinBuffing:(CGFloat)skinBuffingValue skinWhitening:(CGFloat)skinWhiteningValue sharpen:(CGFloat)sharpenValue bigEye:(CGFloat)bigEyeValue longFace:(CGFloat)longFaceValue cutFace:(CGFloat)cutFaceValue thinFace:(CGFloat)thinFaceValue lowerJaw:(CGFloat)lowerJawValue mouthWidth:(CGFloat)mouthWidthValue thinNose:(CGFloat)thinNoseValue thinMandible:(CGFloat)thinMandibleValue cutCheek:(CGFloat)cutCheekValue{
    
    if(!self.hasInit) {
        self.initResult = aliyun_beautify_create(&beautify);
        aliyun_beautify_setFaceDebug(beautify, NO);
        aliyun_setLogLevel(ALR_LOG_LEVEL_WARN);
        self.hasInit = YES;
        
    }
    //初始化失败 直接返回0
    if (self.initResult < 0) {
        NSLog(@"race sdk 初始化失败！！！！可能是由于license过期导致,请检查license");
        return 0;
    }
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    if(!pixelBuffer) { ;
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

    //美颜美型渲染
    int tex = aliyun_beautify_processSampleBuffer(beautify, sampleBuffer);
    return tex;
}

@end
