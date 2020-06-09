//
//  AliyunIConfig.h
//  AliyunVideo
//
//  Created by mengt on 2017/4/25.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AliyunIConfig : NSObject


/**
 录制模式

 - AliyunIRecordActionTypeCombination: 空
 - AliyunIRecordActionTypeClick: 单击拍
 - AliyunIRecordActionTypeHold: 长按拍
 */
typedef NS_ENUM(NSInteger, AliyunIRecordActionType) {
    AliyunIRecordActionTypeCombination = 0,
    AliyunIRecordActionTypeClick,
    AliyunIRecordActionTypeHold
};



/**
 背景颜色
 */
@property (nonatomic, strong) UIColor *backgroundColor;

/**
 timelineView（缩略图）的TintColor
 */
@property (nonatomic, strong) UIColor *timelineTintColor;
/**
 timelineView（缩略图）的背景色
 */
@property (nonatomic, strong) UIColor *timelineBackgroundCollor;

/**
 缩略图裁剪掉部分的颜色
 */
@property (nonatomic, strong) UIColor *timelineDeleteColor;

/**
 时长显示的字体颜色
 */
@property (nonatomic, strong) UIColor *durationLabelTextColor;

/**
 裁剪底部分割线的颜色
 */
@property (nonatomic, strong) UIColor *cutBottomLineColor;

/**
 裁剪顶部分割线的颜色
 */
@property (nonatomic, strong) UIColor *cutTopLineColor;

/**
 无滤镜效果的文字
 */
@property (nonatomic,strong) NSString *noneFilterText;

/**
 隐藏时间显示lab
 */
@property (nonatomic, assign) BOOL hiddenDurationLabel;

/**
 隐藏比例按钮
 */
@property (nonatomic, assign) BOOL hiddenRatioButton;

/**
 隐藏美颜按钮
 */
@property (nonatomic, assign) BOOL hiddenBeautyButton;

/**
 隐藏拍照按钮
 */
@property (nonatomic, assign) BOOL hiddenCameraButton;

/**
 隐藏闪光灯开关按钮
 */
@property (nonatomic, assign) BOOL hiddenFlashButton;

/**
 隐藏视频导入按钮
 */
@property (nonatomic, assign) BOOL hiddenImportButton;

/**
 隐藏删除按钮
 */
@property (nonatomic, assign) BOOL hiddenDeleteButton;

/**
 隐藏完成按钮
 */
@property (nonatomic, assign) BOOL hiddenFinishButton;

/**
 只录制一段视频
 */
@property (nonatomic, assign) BOOL recordOnePart;

/**
 显示相机按钮
 */
@property (nonatomic, assign) BOOL showCameraButton;

/**
 图片资源的BundleName，
 这个可以在整体打包替换图片资源，只要图片名对上，然后这里改成你打包的BundleName就可以了
 */
@property (nonatomic, strong) NSString *imageBundleName;

/**
 滤镜特效的BundleName
 */
@property (nonatomic, strong) NSString *filterBundleName;

/**
 录制模式
 */
@property (nonatomic, assign) AliyunIRecordActionType recordType;

/**
 滤镜效果数组
 */
@property (nonatomic, strong) NSArray *filterArray;

/**
 获取当前配置

 @return 当前配置
 */
+ (AliyunIConfig *)config;

/**
 设置一个配置

 @param c 配置类
 */
+ (void)setConfig:(AliyunIConfig *)c;

- (NSString *)imageName:(NSString *)imageName;

- (NSString *)filterPath:(NSString *)filterName;

@end
