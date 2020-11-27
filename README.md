# FUAliShortVideoProDemo 快速接入文档

FUAliShortVideoProDemo 是 FaceUnity SDK 快速对接阿里短视频的导读说明，

本文是在阿里云短视频demo 的基础上更新FaceUnity SDK 的使用,目前短视频中使用到FaceUnity SDK 美颜功能是美颜和美型 关于 FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)


## 快速集成方法

### 一、更新修改FcaeUnitySDK 的版本

在 `FUAliShortVideoProDemo/demo/AlivcRecord/AlivcRecord.podspec` 路径下,打开 `AlivcRecord.podspec` 修改 `Nama` 的版本号 
关于 `Nama` 和 `Nama-lite` 的区别 `Nama` 可以加载物理动效的道具 `Nama-lite` 则不可以加载物理动效的道具


### 二、FaceUnity SDK 的依赖库

`OpenGLES.framework`、`Accelerate.framework`、`CoreMedia.framework`、`AVFoundation.framework`、`libc++.tbd`、`CoreML.framework`
 
- 备注: 上述NamaSDK 依赖库使用 Pods 管理 会自动添加依赖,运行在iOS11以下系统时,需要手动添加`CoreML.framework`,并在**TARGETS -> Build Phases-> Link Binary With Libraries**将`CoreML.framework`手动修改为可选**Optional**

### 三、开始使用

在 AliyunMagicCameraViewController.m 中导入高级美颜的管理类,其中 `AlivcShortVideoFaceUnityManager.h` 是 `FaceUnity SDK 美颜管理者`

```C
//美颜
#if SDK_VERSION == SDK_VERSION_CUSTOM
#import "AlivcShortVideoFaceUnityManager.h"
#import "AlivcShortVideoRaceManager.h"
#endif
```

### 四、FaceUnity 美颜处理

```C
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
    CGFloat beautyWhite = self.beautyView.beautyParams.beautyWhite;
    CGFloat beautyBuffing = self.beautyView.beautyParams.beautyBuffing;
    CGFloat beautyRuddy = self.beautyView.beautyParams.beautyRuddy;
    //美型参数设置(这里用的是beautySkinParams)
    CGFloat beautyBigEye = self.beautyView.beautySkinParams.beautyBigEye;
    CGFloat beautySlimFace = self.beautyView.beautySkinParams.beautySlimFace;
    
    CVPixelBufferRef buf = [[AlivcShortVideoFaceUnityManager shareManager] RenderedPixelBufferWithRawSampleBuffer:sampleBuffer beautyWhiteValue:beautyWhite/100.0 blurValue:beautyBuffing/100.0 bigEyeValue:beautyBigEye/100.0 slimFaceValue:beautySlimFace/100.0 buddyValue:beautyRuddy/100.0];
    return buf;
}
```

### 五、道具销毁

在  `- (void)dealloc` 方法中调用 
  
  ```C
  // 销毁资源
  [[AlivcShortVideoFaceUnityManager shareManager] destoryItems];
  ```
        
### 快速集成完毕，关于 FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)