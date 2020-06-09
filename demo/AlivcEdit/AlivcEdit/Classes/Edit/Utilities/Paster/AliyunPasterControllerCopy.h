//
//  AliyunPasterControllerCopy.h
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/6.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AliyunVideoSDKPro/AliyunPasterController.h>
#import "AliyunPasterController+ActionType.h"
@class AliyunEffectCaptionCopy;
@class AliyunEffectSubtitleCopy;

/**
 动图参数深拷贝类，用来保存动图位置大小等信息，需要恢复已删除的动图时需要新创建一个动图，然后通过重新赋值来达到恢复目的（坑！SDK未提供恢复功能，目前只能这么处理）
 */
@interface AliyunPasterControllerCopy : NSObject

/**
 设置动图的view
 @warning:一定要设置
 */
@property (nonatomic, strong) UIView *pasterView;

/**
 动图类型
 */
@property (nonatomic, assign) AliyunPasterEffectType pasterType;

/**
 动图的旋转角度  单位：弧度
 */
@property (nonatomic, assign) CGFloat pasterRotate;

/**
 动图的位置(x,y)
 */
@property (nonatomic, assign) CGPoint pasterPosition;

/**
 动图的宽高
 */
@property (nonatomic, assign) CGSize pasterSize;

/**
 动图的位置大小
 */
@property (nonatomic, assign) CGRect pasterFrame;

/**
 动图镜像
 */
@property (nonatomic, assign) BOOL mirror;

/**
 文字内容
 */
@property (nonatomic, copy) NSString *subtitle;

/**
 文字位置 相对于动图本身的位置大小
 */
@property (nonatomic, assign, readonly) CGRect subtitleFrame;

/**
 文字的后台配置字体
 */
@property (nonatomic, copy, readonly) NSString *subtitleConfigFontName;

/**
 文字的后台配置字体的id
 */
@property (nonatomic, assign, readonly) NSInteger subtitleConfigFontId;

/**
 文字是否描边
 */
@property (nonatomic, assign) BOOL subtitleStroke;

/**
 文字颜色
 */
@property (nonatomic, strong) UIColor *subtitleColor;

/**
 文字描边颜色
 */
@property (nonatomic, strong) UIColor *subtitleStrokeColor;

/**
 文字的背景颜色
 */
@property (nonatomic, strong) UIColor *subtitleBackgroundColor;

/**
 文字字体
 */
@property (nonatomic, copy) NSString *subtitleFontName;

/**
 关键帧图片
 */
@property (nonatomic, strong, readonly) UIImage *kernelImage;

/**
 动图开始时间  单位：s
 */
@property (nonatomic, assign) CGFloat pasterStartTime;

/**
 动图结束时间  单位：s
 */
@property (nonatomic, assign) CGFloat pasterEndTime;

/**
 动图持续时间 单位：s
 */
@property (nonatomic, assign) CGFloat pasterDuration;

/**
 动图最小持续时间 单位：s
 */
@property (nonatomic, assign) CGFloat pasterMinDuration;

/**
 编辑区域
 */
@property (nonatomic, assign) CGSize displaySize;


/**
 视频输出分辨率
 */
@property (nonatomic, assign) CGSize outputSize;

/**
 预览大小
 */
@property (nonatomic, assign) CGSize previewRenderSize;


@property (nonatomic, copy)NSString *resoucePath;

/**
 唯一id
 */
@property (nonatomic, assign) int eid;


/**
 字幕图片
 */
@property (nonatomic, strong)UIImage *textImage;


/**
 纯字幕参数深拷贝类
 */
@property (nonatomic, strong)AliyunEffectSubtitleCopy *effectSubtitle;

/**
 气泡字幕参数深拷贝类
 */
@property (nonatomic, strong)AliyunEffectCaptionCopy *effectCaption;

@property (nonatomic, assign) TextActionType actionType;
@property (nonatomic, assign) TextActionType tempActionType;
 
/**
 拷贝一份PasterController

 @param pasterController 需要copy的AliyunPasterController
 */
-(instancetype)copyPropertysForPasterController:(AliyunPasterController *)pasterController;

/**
 获取Copy的属性

 @param pasterController 需要获取Copy属性的pasterController
 */
-(void)setPropertysInPasterController:(AliyunPasterController *)pasterController;


@end
