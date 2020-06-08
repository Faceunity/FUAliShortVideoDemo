# 通用

## 1.提示category方法没找到

Build Setting -- other linker flags 添加  -ObjC

## 2.debug包和release包的区别

debug包包含模拟器和真机版本，可以保证模拟器编译通过

release包提交app store时使用，原因是apple要求动态库提交不能包含模拟器版本

## 3.提示符号重复duplicate symbol

短视频内部包含的上传的代码，集成了上传sdk会报，对功能没有影响

## 4.pod库支持
专业版：
pod 'AliyunVideoSDKPro'
pod 'QuCore-ThirdParty'
pod 'VODUpload'
pod 'AliyunOSSiOS'
标准版：
pod 'AliyunVideoSDKStd'
pod 'QuCore-ThirdParty'
pod 'VODUpload'
pod 'AliyunOSSiOS'
基础版：
pod 'AliyunVideoSDKBasic'
pod 'QuCore-ThirdParty'
pod 'VODUpload'
pod 'AliyunOSSiOS'

## 5.导入提示image not found

短视频sdk使用的动态库，需要在Embedded Binaries中添加对应的framework


## 6.bitcode问题

sdk不支持bitcode，需要在设置中把Enable Bitcode设为no。
打包出现"failed to verify bitcode"错误，需要取消勾选rebuild for bitcode选项。

## 6.提示[NSDictionary oss_dictionaryWithXMLData:]: unrecognized selector sent to class

需要依赖AliyunOSSiOS.framework


# 录制


## 1.录制完成后取不到视频

需要在回调函数里获取视频

## 3.如何实现横屏录制

录制时候设置rotate角度值，录制的视频方向会以第一段视频的角度值为准

## 4.录制过程中切换音乐，没有生效

录制过程中不支持更换音乐

## 5.全屏录制方案如何实现

录制分辨率9：16，显示有两种方案，一种和demo一样iphonex上下留黑边，另一种可以调整view布局上下撑，满左右一部分内容不显示



# 裁剪 

## 1.裁剪提示-1008错误

关闭shouldOptimize

## 2.裁剪提示-700004错误
输出路径没有设置

## 3.如何实现没有黑边的裁剪

根据原始分辨率，做一个缩放，缩放后的分辨率保证是偶数

## 4.如何裁剪一段音乐

videoSize和ouptutSize都无需设置



# 编辑

## 1.编辑完成后，合成crash，报错提示[null length] 

检查水印路径有没有正确设置

## 2.使用音乐无法选择开始时间，结束时间

目前的接口只支持选择视频的开始时间，结束时间，3.6版本已支持

## 3.调用音量接口会破音

默认值100代表原声，大于100可能会破音，建议0-100

## 3.滤镜mv等资源找不到

资源拷贝到项目中需要用folder方式导入，文件夹是蓝色的

## 4.导入视频，提示operation not permit

从系统相册导入的视频，需要调用系统接口获取，同时保证对应的AVAseset没有被销毁

## 4.加入音频后无法调节音量和添加、删除音效
注意加的音频需要为pcm、mp3等音频文件，不能为视频文件


# 上传

## 1.上传报错，提示没有授权

获取STS流程简单介绍：

1.阿里云主账户创建子账户 --- 给子账户授权AliyunSTSAssumeRoleAccess

2.使用子账户---创建角色 --- 给角色授权VODFULL

3.通过调用STS的SDK，获取STS，参考：https://help.aliyun.com/document_detail/28788.html

主要需要注意的点：

1.调用STS的SDK中的ak必须要是子账户的ak

2.修改policy为点播的全量权限：

String policy = "{\n" +

                "    \"Version\": \"1\", \n" +
                
                "    \"Statement\": [\n" +
                
                "        {\n" +
                
                "            \"Action\": [\n" +
                
                "                \"vod:*\"\n" +
                
                "            ], \n" +
                
                "            \"Resource\": [\n" +
                
                "                \"*\" \n" +
                
                "            ], \n" +
                
                "            \"Effect\": \"Allow\"\n" +
                
                "        }\n" +
                
                "    ]\n" +
                
                “}”
                
                2.上传过程中断网，不会走失败流程
                
                上传过程中断网，会自动重试，如果不想走重试接口，可以手动调用取消上传
                
                3.上传后的视频，通过服务端SDK下载的视频格式为m3u8
                转码配置里面，如果勾选了hls选项，会生成m3u8格式视频
                
                
                
                
                
                
                
                
                

