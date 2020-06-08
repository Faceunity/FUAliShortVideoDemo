//
//  AlivcShortVideoRoute.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2018/10/19.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcShortVideoRoute.h"
#import "AliyunIConfig.h"
//#import "AliyunEffectPrestoreManager.h"

@interface AlivcShortVideoRoute()

@property (nonatomic, strong)AliyunMediaConfig *mediaConfig;//视频选择页参数配置类

@property (nonatomic, strong)AlivcRecordUIConfig *recordUIConfig;//录制UI配置类

//@property (nonatomic, strong)AlivcEditUIConfig *editUIConfig;//编辑UI配置类

@property (nonatomic, strong)NSString *editInputVideoPath;//编辑传入参数：单个视频的本地路径

@property (nonatomic, assign)BOOL hasRecordMusic;//录制的时候是否带音乐

@property (nonatomic, assign)BOOL isMixedVideo;//是否是合拍的视频

@property (nonatomic, strong)NSString *editInputMediasPath;//编辑传入参数：多个媒体资源的本地存放文件夹路径

@property (nonatomic, copy)AlivcRecordFinishBlock recordFinishBlock;//录制完成回调

@property (nonatomic, copy)AlivcEditFinishBlock editFinishBlock;//编辑完成回调

@property (nonatomic, copy)AlivcCropFinishBlock cropFinishBlock;//裁剪完成回调

@end

static AlivcShortVideoRoute *_instance = nil;

@implementation AlivcShortVideoRoute

+ (instancetype)shared{
   
    return [[self alloc]init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance) {
            _instance = [super allocWithZone:zone];
//            [AlivcImage setImageBundleName:@"AlivcShortVideoImage"];
            [AliyunIConfig setConfig:[[AliyunIConfig alloc]init]];//注册功能配置类
            
            Class aliyunEffectPrestoreManager = NSClassFromString(@"AliyunEffectPrestoreManager");
            if (aliyunEffectPrestoreManager) {
                NSObject *obj = [[aliyunEffectPrestoreManager alloc]init];
                if ([obj respondsToSelector:@selector(insertInitialData)]) {
                    [obj performSelector:@selector(insertInitialData)];//初始化动图资源
                }
                
            }
            
        }
        
    });
    return _instance;
}
// 为了严谨，也要重写copyWithZone 和 mutableCopyWithZone
-(id)copyWithZone:(NSZone *)zone
{
    return _instance;
}
-(id)mutableCopyWithZone:(NSZone *)zone
{
    return _instance;
}

- (UIViewController *)alivcViewControllerWithType:(AlivcViewControlType )type{

    
//    if (type == AlivcViewControlEdit) {//暂时不放开直接从编辑页面进入,因为录制直接进编辑，可以用到这个，所以开启
//        type = AlivcViewControlEditVideoSelect;
//    }
    UIViewController *controller;
    switch (type) {
        case AlivcViewControlEditParam:
        {//短视频编辑参数配置页
            Class viewControllerClass = NSClassFromString(@"AliyunConfigureViewController");
            controller = [[viewControllerClass alloc]init];
        }
            break;
        case AlivcViewControlEditVideoSelect:
        {//短视频编辑视频选择页
            Class viewControllerClass = NSClassFromString(@"AliyunCompositionViewController");
            controller = [[viewControllerClass alloc]init];
            [controller setValue:self.mediaConfig forKey:@"compositionConfig"];
        }
            break;
        case AlivcViewControlEdit:
        {//短视频编辑页
            Class viewControllerClass = NSClassFromString(@"AliyunEditViewController");
            controller = [[viewControllerClass alloc]init];
            if (self.mediaConfig) {
                [controller setValue:self.mediaConfig forKey:@"config"];
            }
            if (self.editInputVideoPath) {
                [controller setValue:self.editInputVideoPath forKey:@"videoPath"];
            }
            if (self.editInputMediasPath) {
                [controller setValue:self.editInputMediasPath forKey:@"taskPath"];
            }
//            if (self.editUIConfig) {
//                [controller setValue:self.editUIConfig forKey:@"uiConfig"];
//            }
            if (self.editFinishBlock) {
                [controller setValue:self.editFinishBlock forKey:@"finishBlock"];
            }
            
            [controller setValue:@(self.hasRecordMusic) forKey:@"hasRecordMusic"];
            [controller setValue:@(self.isMixedVideo) forKey:@"isMixedVideo"];
            
            //把变量复位
            self.hasRecordMusic = NO;
            self.isMixedVideo = NO;
            
        }
            break;
        case AlivcViewControlRecordParam:
        {//短视频拍摄参数配置页
            Class viewControllerClass = NSClassFromString(@"AliyunRecordParamViewController");
            controller = [[viewControllerClass alloc]init];
        }
            break;
        case AlivcViewControlRecord:
        {//短视频拍摄页
            
            Class viewControllerClass;
            
            if (self.mediaConfig.beautyType == AlivcBeautyTypeRace) {
                viewControllerClass = NSClassFromString(@"AliyunMagicCameraRaceViewController");
            }else {
                viewControllerClass = NSClassFromString(@"AliyunMagicCameraViewController");
            }
            
            controller = [[viewControllerClass alloc]init];

            if (self.mediaConfig) {
                [controller setValue:self.mediaConfig forKey:@"quVideo"];
            }
            
//            Class viewControllerClass = NSClassFromString(@"AliyunMagicCameraViewController");
//            controller = [[viewControllerClass alloc]init];
//
//            if (self.mediaConfig) {
//                [controller setValue:self.mediaConfig forKey:@"quVideo"];
//            }
//            if (self.recordUIConfig) {
//                [controller setValue:self.recordUIConfig forKey:@"uiConfig"];
//            }
//            if (self.recordFinishBlock) {
//                [controller setValue:self.recordFinishBlock forKey:@"finishBlock"];
//            }
            
        }
            break;
        case AlivcViewControlRecordMix:
        {//短视频拍摄页
            
            Class viewControllerClass;
            if (self.mediaConfig.beautyType == AlivcBeautyTypeRace) {
                viewControllerClass = NSClassFromString(@"AliyunMagicCameraMixRaceViewController");
            }else {
                viewControllerClass = NSClassFromString(@"AliyunMagicCameraMixViewController");
            }
            controller = [[viewControllerClass alloc]init];
            
            if (self.mediaConfig) {
                [controller setValue:self.mediaConfig forKey:@"quVideo"];
            }
            if (self.recordUIConfig) {
                [controller setValue:self.recordUIConfig forKey:@"uiConfig"];
            }
            if (self.recordFinishBlock) {
                [controller setValue:self.recordFinishBlock forKey:@"finishBlock"];
            }
//            if (self.editInputMediasPath) {
//                [controller setValue:self.editInputMediasPath forKey:@"taskPath"];
//            }
        }
            break;
        case AlivcViewControlCropParam:
        {//短视频裁剪参数配置页
            Class viewControllerClass = NSClassFromString(@"AliyunConfigureViewController");
            controller = [[viewControllerClass alloc]init];
            [controller setValue:@"YES" forKey:@"isClipConfig"];
        }
            break;
            
        case AlivcViewControlCropBasicParam:
        {//短视频裁剪参数配置页
            Class viewControllerClass = NSClassFromString(@"AlivcBase_ConfigureViewController");
            controller = [[viewControllerClass alloc]init];
         
        }
           break;
        case AlivcViewControlCropVideoSelect:
        {//短视频裁剪页
            Class viewControllerClass = NSClassFromString(@"AliyunCropViewController");
            controller = [[viewControllerClass alloc]init];
            [controller setValue:self.mediaConfig forKey:@"cutInfo"];
        }
            break;
        case AlivcViewControlCrop:
        {//短视频裁剪视频选择页
            Class viewControllerClass = NSClassFromString(@"AliyunPhotoViewController");
            controller = [[viewControllerClass alloc]init];
            [controller setValue:self.mediaConfig forKey:@"cutInfo"];
        }
            break;
        case AlivcViewControlRecordBasicParam:
        {//短视频裁剪视频选择页
            Class viewControllerClass = NSClassFromString(@"AlivcBase_RecordParamViewController");
            controller = [[viewControllerClass alloc]init];
        }
            break;
        case AlivcViewControlRaceBeauty:
        {//短视频裁剪视频选择页
            Class viewControllerClass = NSClassFromString(@"AlivcRaceBeautyOpenGLVC");
            controller = [[viewControllerClass alloc]init];
        }
            break;
            
        case AlivcViewControlFaceDetect:
        {//短视频裁剪视频选择页
            Class viewControllerClass = NSClassFromString(@"AlivcRaceFaceDetectGLPointVC");
            controller = [[viewControllerClass alloc]init];
        }
            break;
        case AlivcViewControlMetalPreview:
        {//短视频裁剪视频选择页
            Class viewControllerClass = NSClassFromString(@"AlivcRaceBeautyMetalRenderController");
            controller = [[viewControllerClass alloc]init];
        }
            break;
        default:
            break;
    }
    
    return controller;
}

-(AliyunMediaConfig *)mediaConfig{
    
    if (!_mediaConfig) {//默认配置
        _mediaConfig = [AliyunMediaConfig defaultConfig];
        _mediaConfig.minDuration = 2.0;
        _mediaConfig.maxDuration = 10.0*60;
        _mediaConfig.fps = 25;
        _mediaConfig.gop = 5;
        _mediaConfig.cutMode = AliyunMediaCutModeScaleAspectFill;
        _mediaConfig.videoOnly = NO;
        _mediaConfig.backgroundColor = [UIColor blackColor];
        
    }
    return _mediaConfig;
}

- (AlivcBeautyType)currentBeautyType {
    return self.mediaConfig.beautyType;
}

#pragma mark - Register
-(void)registerMediaConfig:(AliyunMediaConfig *)config{
    _mediaConfig = config;
}

- (void)registerRecordUIConfig:(AlivcRecordUIConfig *)config{
    _recordUIConfig = config;
}

//- (void)registerEditUIConfig:(AlivcEditUIConfig *)config{
//    _editUIConfig = config;
//}

- (void)registerEditVideoPath:(NSString *)singleVideoPath{
    _editInputVideoPath = singleVideoPath;
}

- (void)registerEditMediasPath:(NSString *)mediasPath{
    _editInputMediasPath = mediasPath;
}

- (void)registerRecordFinishBlock:(AlivcRecordFinishBlock)block{
    _recordFinishBlock = block;
}

- (void)registerEditFinishBlock:(AlivcEditFinishBlock)block{
    _editFinishBlock = block;
}

- (void)registerCropFinishBlock:(AlivcCropFinishBlock)block{
    _cropFinishBlock = block;
}

- (void)registerHasRecordMusic:(BOOL)hasRecordMusic {
    _hasRecordMusic = hasRecordMusic;
}

- (void)registerIsMixedVideo:(BOOL)isMixedVideo {
    _isMixedVideo = isMixedVideo;
}
#pragma mark - other

@end
