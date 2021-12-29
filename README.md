# FUAliShortVideoProDemo 快速接入文档

FUAliShortVideoProDemo 是 FaceUnity SDK 快速对接阿里短视频的导读说明，

本文是在阿里云短视频demo 的基础上更新FaceUnity SDK 的使用,目前短视频中使用到FaceUnity SDK 美颜功能是美颜和美型 关于 FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo)


## 快速集成方法

### 一、更新修改FcaeUnitySDK 的版本

在 `FUAliShortVideoProDemo/demo/AlivcRecord/AlivcRecord.podspec` 路径下,打开 `AlivcRecord.podspec` 添加 `FURenderKit` 的依赖

### 二、导入 SDK

将  FaceUnity  文件夹全部拖入工程中，NamaSDK所需依赖库为 `OpenGLES.framework`、`Accelerate.framework`、`CoreMedia.framework`、`AVFoundation.framework`、`libc++.tbd`、`CoreML.framework`

- 备注: 运行在iOS11以下系统时,需要手动添加`CoreML.framework`,并在**TARGETS -> Build Phases-> Link Binary With Libraries**将`CoreML.framework`手动修改为可选**Optional**

### FaceUnity 模块简介

```objc
+ Abstract          // 美颜参数数据源业务文件夹
    + FUProvider    // 美颜参数数据源提供者
    + ViewModel     // 模型视图参数传递者
-FUManager          //nama 业务类
-authpack.h         //权限文件  
+FUAPIDemoBar     //美颜工具条,可自定义
+items            //美妆贴纸 xx.bundel文件

```

### 三、加入展示 FaceUnity SDK 美颜贴纸效果的  UI
1、在 AliyunMagicCameraViewController.m  中添加头文件
```objc
#import "FUManager.h"
#import "FUDemoManager.h"
```

2、在 `viewDidLoad` 方法中初始化FU `setupFaceUnityDemoInController` 会初始化FUSDK,和添加美颜工具条,具体实现可查看 `FUDemoManager.m`
```objc
    // faceunity ui
    CGFloat safeAreaBottom = 0;
    if (@available(iOS 11.0, *)) {
        safeAreaBottom = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    }
    
    if ([[AlivcShortVideoRoute shared] currentBeautyType] == AlivcBeautyTypeFaceUnity) {
    
        [FUDemoManager setupFaceUnityDemoInController:self originY:CGRectGetHeight(self.view.frame) - FUBottomBarHeight - safeAreaBottom];
    }
```

### 四、FaceUnity 美颜处理

```objc
// 集成faceunity
#warning 以下为faceunity高级美颜接入代码，如果未集成faceunity，可以把此回调方法注释掉，以避免产生额外的license校验请求。

- (CVPixelBufferRef)customRenderedPixelBufferWithRawSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    
    if ([[AlivcShortVideoRoute shared] currentBeautyType] == AlivcBeautyTypeRace) {
        return CMSampleBufferGetImageBuffer(sampleBuffer);
    }
    if (self.beautyView.currentBeautyType == AlivcBeautySettingViewStyle_ShortVideo_BeautyFace_Base) {
        return CMSampleBufferGetImageBuffer(sampleBuffer);
    }
    
    //注意这里美颜美型的参数是分开的beautyParams和beautySkinParams
    //美颜参数设置(这里用的是beautyParams)
//    CGFloat beautyWhite = self.beautyView.beautyParams.beautyWhite;
//    CGFloat beautyBuffing = self.beautyView.beautyParams.beautyBuffing;
//    CGFloat beautyRuddy = self.beautyView.beautyParams.beautyRuddy;
//    //美型参数设置(这里用的是beautySkinParams)
//    CGFloat beautyBigEye = self.beautyView.beautySkinParams.beautyBigEye;
//    CGFloat beautySlimFace = self.beautyView.beautySkinParams.beautySlimFace;
    
//    CVPixelBufferRef buf = [[AlivcShortVideoFaceUnityManager shareManager] RenderedPixelBufferWithRawSampleBuffer:sampleBuffer beautyWhiteValue:beautyWhite/100.0 blurValue:beautyBuffing/100.0 bigEyeValue:beautyBigEye/100.0 slimFaceValue:beautySlimFace/100.0 buddyValue:beautyRuddy/100.0];

    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (pixelBuffer) {

        [[FUTestRecorder shareRecorder] processFrameWithLog];
        CVPixelBufferRef resultBuffer = [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];
        if (resultBuffer) {
        
            [self checkAI]; //检测人脸人体提示语,正式环境请勿添加
            return resultBuffer;
            
        }else{
            
            return pixelBuffer;
        }
    }
    
    return pixelBuffer;
    
}
```

### 五、销毁道具和切换摄像头

1、视图控制器生命周期结束时 `[[FUManager shareManager] destoryItems];`销毁道具。

2、切换摄像头需要调用 `[[FUManager shareManager] onCameraChange];`切换摄像头

### 关于 FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo)
