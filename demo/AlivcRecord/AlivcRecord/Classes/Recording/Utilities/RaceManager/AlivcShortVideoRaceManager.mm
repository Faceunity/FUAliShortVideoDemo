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

#if TARGET_IPHONE_SIMULATOR !=1
#import <queen/Queen.h>
#endif

@interface AlivcShortVideoRaceManager()

@property (nonatomic,assign)CGSize size;
@property (nonatomic,strong)NSLock *lock;
@property (nonatomic,assign) BOOL hasInit;

#if TARGET_IPHONE_SIMULATOR !=1
@property (nonatomic, strong) QueenEngine *beautyEngine;
#endif

@property(nonatomic) CVPixelBufferRef newPixelBuffer;
@property(nonatomic,assign) int cameraRotate;
@property(nonatomic,strong)NSThread *processPixelThread;


@end

static AlivcShortVideoRaceManager *manager = nil;

@implementation AlivcShortVideoRaceManager

+ (AlivcShortVideoRaceManager *)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AlivcShortVideoRaceManager alloc] init];
        manager.size = CGSizeZero;
        manager.lock = [[NSLock alloc]init];
        manager.hasInit = NO;
    });
    return manager;
}

-(void)clearBeautyEngine{
#if TARGET_IPHONE_SIMULATOR !=1
    self.beautyEngine = nil;
#endif
}

- (void)clear {

#if TARGET_IPHONE_SIMULATOR !=1
    [self.lock lock];
    manager.hasInit = NO;
    if (self.processPixelThread && !self.processPixelThread.isCancelled) {
        [self performSelector:@selector(clearBeautyEngine) onThread:self.processPixelThread withObject:nil waitUntilDone:YES];
        [self.processPixelThread cancel];
    } else {
        NSAssert(self.beautyEngine == nil, @"can not clear beaut engine out of process pixel thread");
    }
//    [[NSRunLoop currentRunLoop] cancelPerformSelectorsWithTarget:self];
    _newPixelBuffer = NULL;
    [self.lock unlock];
#endif
}


- (CVPixelBufferRef)customRenderWithBuffer:(CMSampleBufferRef)sampleBuffer rotate:(int)cameraRotate skinBuffing:(CGFloat)skinBuffingValue skinWhitening:(CGFloat)skinWhiteningValue sharpen:(CGFloat)sharpenValue bigEye:(CGFloat)bigEyeValue longFace:(CGFloat)longFaceValue cutFace:(CGFloat)cutFaceValue thinFace:(CGFloat)thinFaceValue lowerJaw:(CGFloat)lowerJawValue mouthWidth:(CGFloat)mouthWidthValue thinNose:(CGFloat)thinNoseValue thinMandible:(CGFloat)thinMandibleValue cutCheek:(CGFloat)cutCheekValue{
#if TARGET_IPHONE_SIMULATOR !=1

    [self.lock lock];
    
    if(!self.hasInit) {
        QueenEngineConfigInfo *configInfo = [QueenEngineConfigInfo new];
        // 引擎初始化
        self.beautyEngine = [[QueenEngine alloc] initWithConfigInfo:configInfo];
        // 打开磨皮锐化功能开关
        [self.beautyEngine setQueenBeautyType:kQueenBeautyTypeSkinBuffing enable:YES];
        // 打开美白功能开关
        [self.beautyEngine setQueenBeautyType:kQueenBeautyTypeSkinWhiting enable:YES];
        // 打开美型功能开关
        [self.beautyEngine setQueenBeautyType:kQueenBeautyTypeFaceShape enable:YES];

        self.hasInit = YES;
        
        self.processPixelThread = [[NSThread alloc] initWithTarget:self selector:@selector(initPixelThread) object:nil];
        [self.processPixelThread start];
    }

    _cameraRotate = cameraRotate;
    _newPixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    if(!_newPixelBuffer) {
        [self.lock unlock];
        return 0;
    }
    /**
     1、脸长、下巴、唇宽三项参数设置值时数据取反，设置值时加上负号即可（数值越大，脸越长、下巴越长、唇越宽）
     2.美型参数统一调整为原来的3倍，调节明显
     */
    //美颜
    // 设置磨皮系数
    [self.beautyEngine setQueenBeautyParams:kQueenBeautyParamsSkinBuffing value:skinBuffingValue];
    // 设置锐化系数
    [self.beautyEngine setQueenBeautyParams:kQueenBeautyParamsSharpen value:sharpenValue];
    // 设置美白系数
    [self.beautyEngine setQueenBeautyParams:kQueenBeautyParamsWhitening value:skinWhiteningValue];
    //美型
    
    // 设置大眼系数
    [self.beautyEngine setFaceShape:kQueenBeautyFaceShapeTypeBigEye value:bigEyeValue];//大眼
    [self.beautyEngine setFaceShape:kQueenBeautyFaceShapeTypeLongFace value:longFaceValue*-1];//脸长
    [self.beautyEngine setFaceShape:kQueenBeautyFaceShapeTypeCutFace value:cutFaceValue];//削脸
    [self.beautyEngine setFaceShape:kQueenBeautyFaceShapeTypeThinFace value:thinFaceValue];//瘦脸
    [self.beautyEngine setFaceShape:kQueenBeautyFaceShapeTypeLowerJaw value:lowerJawValue*-1];//下巴
    [self.beautyEngine setFaceShape:kQueenBeautyFaceShapeTypeMouthWidth value:mouthWidthValue*-1];//唇宽
    [self.beautyEngine setFaceShape:kQueenBeautyFaceShapeTypeThinNose value:thinNoseValue];//瘦鼻
    [self.beautyEngine setFaceShape:kQueenBeautyFaceShapeTypeThinMandible value:thinMandibleValue];//下颌
    [self.beautyEngine setFaceShape:kQueenBeautyFaceShapeTypeCutCheek value:cutCheekValue];//颧骨

//    NSLog(@"Race Debug-------------------Start \n");
//    NSLog(@"\n 最终设置值 \n 磨皮：%f,\n 美白：%f,\n 锐化：%f,\n ---------- \n 削脸：%f,\n 瘦脸：%f,\n 脸长：%f,\n 下巴：%f,\n 大眼：%f,\n 瘦鼻：%f,\n 唇宽：%f,\n 下颌：%f,\n 颧骨：%f,\n ",skinBuffingValue,skinWhiteningValue,sharpenValue,cutFaceValue*3,thinFaceValue * 3,longFaceValue * -3,lowerJawValue * -3,bigEyeValue*3,thinNoseValue*3,mouthWidthValue * -3,thinMandibleValue*3,cutCheekValue*3);
//    NSLog(@"Race Debug-------------------End \n");
    //美颜美型渲染
    [self performSelector:@selector(outputSampleBuffer) onThread:self.processPixelThread withObject:nil waitUntilDone:YES];
    
    [self.lock unlock];
#endif
    return _newPixelBuffer;
}

-(void)initPixelThread{
    [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
//    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    [[NSRunLoop currentRunLoop] run];
}

- (void)outputSampleBuffer
{
#if TARGET_IPHONE_SIMULATOR !=1
//    NSLog(@"thread====%@",[NSThread currentThread]);
    QEPixelBufferData *bufferData = [QEPixelBufferData new];
    bufferData.bufferIn = _newPixelBuffer;
    bufferData.bufferOut = _newPixelBuffer;
    bufferData.inputAngle = _cameraRotate;
    bufferData.outputAngle = _cameraRotate;
    // 对pixelBuffer进行图像处理，输出处理后的buffer
    kQueenResultCode resultCode = [self.beautyEngine processPixelBuffer:bufferData];
    if (resultCode != kQueenResultCodeOK)
    {
        NSLog(@"queen processPixelBuffer error == %i",(int)resultCode);
    }
#endif
}

@end
