## 为了更好的方便用户集成，我们把Demo的代码架构调整为组件化，以下为Demo代码结构解析以供参考

	- demo  |- AlivcCommon 	    #公用组件
 		 	|- AlivcCore  	    #短视频公用组件
            |- AlivcPhotoPicker #短视频相册组件
		 	|- AlivcCrop	 	#短视频裁剪组件
			|- AlivcEdit	 	#短视频编辑组件
            |- AlivcDraft       #短视频草稿组件
		 	|- AlivcRecord	    #短视频录制组件
		 	|- AliyunVideoClient_Entrance	#短视频主工程
		 	
如果需要运行工程
在demo路径下，执行pod install
然后打开AliyunVideoClient_Entrance.xcworkspace运行即可


##各组件依赖关系为

  组件名         | 依赖的组件   
  ------------|---------
  AlivcConmmon  | 无
  AlivcCore     | AlivcConmmon
  AlivcCrop     | AlivcCore、AlivcConmmon
  AlivcPhotoPicker | AlivcCore 、AlivcConmmon
  AlivcRecord   |  AlivcCore 、AlivcConmmon
  AlivcDraft  |  AlivcCore 、AlivcConmmon
  AlivcEdit    |  AlivcCore 、AlivcConmmon 、AlivcDraft、AlivcPhotoPicker

## 如果需要集成demo源码可参考一下步骤进行集成：
### 步骤1、SDK文件拷贝
* 根据所需功能，拷贝对应组件到自己工程的PodFile同级目录下

  文件         | 描述    | 是否可选
  ------------|---------|-----------------
  AlivcConmmon  | 公用组件   		| 必须
  AlivcCore     | 短视频公用组件  	| 必须
  AlivcCrop     | 短视频裁剪组件  	| 可选
  AlivcEdit     | 短视频编辑组件  	| 可选
  AlivcRecord   | 短视频录制组件  	| 可选
  AlivcPhotoPicker | 短视频相册组件 | 可选
  
### 步骤2、配置PodFile文件
* 根据所需功能，拷贝PodFile配置文件
	
  		pod 'AlivcCommon', :path => 'AlivcCommon/'    //必选
		pod 'AlivcCore', :path => 'AlivcCore/'        //必选
		pod 'AlivcCrop', :path => 'AlivcCrop/'        //可选
		pod 'AlivcEdit', :path => 'AlivcEdit/'        //可选
		pod 'AlivcRecord', :path => 'AlivcRecord/'    //可选
		pod 'AlivcPhotoPicker', :path => 'AlivcPhotoPicker/'    //可选

控制台cd到工程中的PodFile目录下，执行：

		pod install
	
