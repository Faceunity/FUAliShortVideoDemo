FUAliShortVideoDemo 是集成了 [Faceunity](https://github.com/Faceunity/FULiveDemo/tree/dev) 面部跟踪和虚拟道具功能和阿里短视频功能的Demo。

**本文是 FaceUnity SDK  快速对接阿里短视频的导读说明**

**关于  FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)**

##### 1.执行 pod install

   由于Pods中文件较多，没有上传该文件夹，在使用前请先执行“pod install”。

##### 2.添加道具资源

  在工程目录下/AliyunVideoClient_Entrance/Resources 下添加（3d贴纸 ，动漫滤镜，哈哈镜...）道具资源，

##### 3.添加道具切换UI

  在AliyunRecordBeautyView.m 类中，仿照原有**动图，MV模块**，添加 **3d贴纸 ，动漫滤镜，哈哈镜**...模块

##### 4.道具加载逻辑

  在AlivcShortVideoFaceUnityManager添加道具加载方法，加载3d贴纸 ，动漫滤镜，哈哈镜等道具：

```
- (void)loadItem:(NSString *)itemName;
```

加载方法：参数是bundle道具名称，传nil 将卸载道具。除MV外其他特效道具不能同时加载，在切换特效时会销毁前一个特效。









