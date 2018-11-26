//
//  MagicCameraView.h
//  AliyunVideo
//
//  Created by Vienta on 2017/1/3.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//  录制界面的view

#import <UIKit/UIKit.h>
#import "MagicCameraPressCircleView.h"
#import "AliyunRateSelectView.h"
#import "QUProgressView.h"
#import "AlivcRecordUIConfig.h"
@class AliyunEffectFilterInfo,AliyunEffectMvGroup,AliyunMagicCameraView;
@protocol MagicCameraViewDelegate <NSObject>

/**
 返回按钮被点击的代理方法
 */
- (void)backButtonClicked;

/**
 闪光灯按钮被点击的代理方法

 @return 闪光灯按钮图片名称
 */
- (NSString *)flashButtonClicked;

/**
 前后摄像头切换按钮被点击的代理方法
 */
- (void)cameraIdButtonClicked;

/**
 选中某个人脸动图
 
 @param index 序号
 @param cell cell对象
 */
- (void)effectItemFocusToIndex:(NSInteger)index cell:(UICollectionViewCell *)cell;

/**
 音乐按钮被点击的代理方法
 */
- (void)musicButtonClicked;

/**
 定时器按钮被点击的代理方法
 */
- (void)timerButtonClicked;

/**
 回删按钮被点击的代理方法
 */
- (void)deleteButtonClicked;

/**
 完成按钮被点击的代理方法
 */
- (void)finishButtonClicked;

/**
 选择某一种速度

 @param rate 某一种速度
 */
- (void)didSelectRate:(CGFloat)rate;

/**
 开始录制的代理方法
 */
- (void)recordButtonRecordVideo;

/**
 暂停录制的代理方法
 */
- (void)recordButtonPauseVideo;

/**
 完成录制的代理方法
 */
- (void)recordButtonFinishVideo;

/**
 基础美颜的美颜值改变
 
 @param beautyValue 美颜值（1-100）
 */
- (void)didChangeBeautyValue:(CGFloat)beautyValue;

/**
 选中某个滤镜
 
 @param filter 滤镜数据模型
 */
- (void)didSelectEffectFilter:(AliyunEffectFilterInfo *)filter;

/**
 高级美颜的美白值改变
 
 @param beautyWhiteValue 高级美颜：美白参数值
 */
- (void)didChangeAdvancedBeautyWhiteValue:(CGFloat)beautyWhiteValue;

/**
 高级美颜的磨皮值改变
 
 @param blurValue 高级美颜：磨皮参数值
 */
- (void)didChangeAdvancedBlurValue:(CGFloat)blurValue;

/**
 美肌的大眼值改变
 
 @param bigEyeValue 美肌：大眼参数值
 */
- (void)didChangeAdvancedBigEye:(CGFloat)bigEyeValue;

/**
 美肌的瘦脸值改变
 
 @param slimFaceValue 美肌：瘦脸参数值
 */
- (void)didChangeAdvancedSlimFace:(CGFloat)slimFaceValue;

/**
 高级美颜的红润值改变
 
 @param buddyValue 高级美颜：红润参数值
 */
- (void)didChangeAdvancedBuddy:(CGFloat)buddyValue;

/**
 选中某个MV
 
 @param mvGroup MV数据模型
 */
- (void)didSelectEffectMV:(AliyunEffectMvGroup *)mvGroup;


/**
 单击拍文字被点击的代理方法
 */
- (void)tapButtonClicked;

/**
 长按拍文字被点击的代理方法
 */
- (void)longPressButtonClicked;

/**
 切换高级美颜
 */
- (void)didChangeAdvancedMode;

/**
 切换普通美颜
 */
- (void)didChangeCommonMode;

/**
 退出AliyunRecordBeautyView的view
 
 @param view 此类的view
 @param button 退出按钮
 */
- (void)magicCameraView:(AliyunMagicCameraView *)view dismissButtonTouched:(UIButton *)button;

/**
 获取人脸动图的数据
 */
- (void)didFetchGIFListData;
@end

@interface AliyunMagicCameraView : UIView

/**
 预览view
 */
@property (nonatomic, strong) UIView *previewView;

/**
 此类的代理方法
 */
@property (nonatomic, weak) id<MagicCameraViewDelegate> delegate;

/**
 闪光灯按钮
 */
@property (nonatomic, strong) UIButton *flashButton;


/**
 进度条
 */
@property (nonatomic, strong) QUProgressView *progressView;

/**
 最大时间
 */
@property (nonatomic, assign) CGFloat maxDuration;

/**
 准确的视频个数
 */
@property (nonatomic, assign) NSInteger realVideoCount;

/**
 完成按钮
 */
@property (nonatomic, strong) UIButton *finishButton;

/**
 倒计时按钮
 */
@property (nonatomic, strong) UIButton *countdownButton;

/**
 音乐按钮
 */
@property (nonatomic, strong) UIButton *musicButton;

/**
 录制按钮
 */
@property (nonatomic, strong) MagicCameraPressCircleView *circleBtn;

/**
 速度选择器
 */
@property (nonatomic, strong) AliyunRateSelectView *rateView;

/**
 顶部view
 */
@property (nonatomic, strong) UIView *topView;

/**
 底部view
 */
@property (nonatomic, strong) UIView *bottomView;

/**
 如果为Yes，只显示录制按钮和时间
 */
@property (nonatomic, assign) BOOL hide;

/**
 是否正在录制
 */
@property (nonatomic, assign) BOOL recording;

/**
 隐藏底部的相关view（点击录制按钮旁边左右两个按钮弹出的view时需要隐藏底部view）
 */
@property (nonatomic, assign) BOOL bottomHide;


/**
 刷新进度条的进度

 @param percent 进度
 */
- (void)recordingPercent:(CGFloat)percent;

/**
 停止录制时的一些状态恢复
 */
- (void)destroy;

/**
 手指按下录制按钮
 */
- (void)recordButtonTouchDown;

/**
 手指松开录制按钮
 */
- (void)recordButtonTouchUp;

/**
 取消beautyView(点击录制按钮旁边左右两个按钮弹出的view)
 */
- (void)cancelRecordBeautyView;

/**
 指定初始化
 
 @param uiConfig 短视频拍摄界面UI配置
 @return self对象
 */
- (instancetype)initWithUIConfig:(AlivcRecordUIConfig *)uiConfig;

/**
 根据新的动图数组刷新ui
 
 @param effectItems 新的动图数组
 */
- (void)refreshUIWithGifItems:(NSArray *)effectItems;


/**
 根据新的mv数组刷新ui
 
 @param mvItems 新的mv数组
 */
- (void)refreshUIWithMVItems:(NSMutableArray *)mvItems;

/**
 动图实际应用时候调用此方法刷新UI选中状态
 */
- (void)refreshUIWhenThePasterInfoApplyedWithIndex:(NSInteger)applyedIndex;

/**
 录制按钮的UI恢复到点击录制前
 */
- (void)resetRecordButtonUI;


@end
