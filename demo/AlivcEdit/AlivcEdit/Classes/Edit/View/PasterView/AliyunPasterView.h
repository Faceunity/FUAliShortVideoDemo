//
//  AliyunPasterView.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/7.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AliyunVideoSDKPro/AliyunPasterController.h>
#import <AliyunVideoSDKPro/AliyunPasterUIEventProtocol.h>
#import "AliyunColor.h"

@protocol AliyunPasterViewActionTarget <NSObject>

/**
 点击事件的回调

 @param obj 当前点击事件发生的PasterView
 */
- (void)oneClick:(id)obj;


/**
 
 删除一个动图
 */
- (void)deleteEndPaster;


/**
 点击了动画按钮
 */
- (void)clickAnimation;

@end


/**
 动图编辑view
 */
@interface AliyunPasterView : UIView

/**
 编辑状态开关：YES 开启编辑状态。NO 关闭编辑状态
 */
@property (nonatomic, assign) BOOL editStatus;

/**
 选中状态
 */
@property (nonatomic, assign) BOOL selectStatus;

/**
 当前动图为字幕的情况下的文字颜色
 */
@property (nonatomic, strong) AliyunColor *textColor;
/**
 当前动图为字幕的情况下的文字内容
 */
@property (nonatomic, copy) NSString *text;
/**
 当前动图为字幕的情况下的文字 字体名字
 */
@property (nonatomic, copy) NSString *textFontName;

/**
 调整贴图位置、大小、角度等信息的SDK暴露出来的代理
 */
@property (nonatomic, weak) id<AliyunPasterUIEventProtocol> delegate;
@property (nonatomic, weak) id<AliyunPasterViewActionTarget> actionTarget;
@property (nonatomic, assign) CGSize nativeDisplaySize; //用native控件播放视频的容器大小
@property (nonatomic, assign) CGSize renderedMediaSize; //需要渲染到的视频分辨率

/**
 初始化一个pasterView

 @param pasterController 动图控制器
 @return AliyunPasterView实例
 */
- (id)initWithPasterController:(AliyunPasterController *)pasterController;


/**
 当前这个view这个位置上是否存在一个动图

 @param point 坐标
 @param view 目标view
 @return YES：存在。NO：不存在
 */
- (BOOL)touchPoint:(CGPoint)point fromView:(UIView *)view;

/**
 拖动事件

 @param fp 起点
 @param tp 终点
 */
- (void)touchMoveFromPoint:(CGPoint)fp to:(CGPoint)tp;

/**
 拖动事件结束
 */
- (void)touchEnd;

/**
 当前动图为字幕的情况下，获取当前pasterview上的字幕文字图片

 @return 字幕文字图片
 */
- (UIImage *)textImage;

/**
 当前动图为字幕的情况下，文字的颜色

 @return 文字颜色
 */
- (UIColor *)contentColor;

/**
 当前动图为字幕的情况下，文字边框的颜色

 @return 边框颜色
 */
- (UIColor *)strokeColor;

/*
 计算旋转旋转按钮角度
 */
-(void)calculateRotateButtonAngle;
@end
