//
//  AliyunPaseterAnimationView.h
//  qusdk
//
//  Created by Vienta on 2017/5/9.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//
// 动图序列帧播放
#import <UIKit/UIKit.h>

/**
 动图序列帧播放view
 */
@interface AliyunPaseterAnimationView : UIImageView

@property (nonatomic, copy) void (^textAppearanceBlock)(BOOL isAppear);

/**
 设置动图信息

 @param imagePaths 动图序列帧路径集合
 @param duration 总时长
 */
- (void)setupImages:(NSArray *)imagePaths duration:(CGFloat)duration;

/**
 设置字幕信息

 @param imagePaths 字幕序列帧路径集合
 @param duration 总时长
 @param beginTime 文字开始时间
 @param textDuration 文字总时长
 */
- (void)setupImages:(NSArray *)imagePaths duration:(CGFloat)duration textBeginTime:(CGFloat)beginTime textDuration:(CGFloat)textDuration;
/**
 更新动图信息
 
 @param imagePaths 动图序列帧路径集合
 @param duration 总时长
 */
- (void)updateImages:(NSArray *)imagePaths duration:(CGFloat)duration;

/**
 开始预览
 */
- (void)run;

/**
 停止预览
 */
- (void)stop;



@end
