//
//  AlivcShootVCUIConfig.h
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/10/9.
//  Copyright © 2018年 Alibaba. All rights reserved.
//  短视频拍摄界面的UI配置

#import "AlivcShortVideoUIConfig.h"

@interface AlivcRecordUIConfig : AlivcShortVideoUIConfig

/**
 音乐按钮图片
 */
@property (strong, nonatomic) UIImage *musicImage;

@property (strong, nonatomic) UIImage *filterImage;

/**
 闪光灯按钮图片 - 开启
 */
@property (strong, nonatomic) UIImage *ligheImageOpen;

/**
 闪光灯按钮图片 - 自动
 */
@property (strong, nonatomic) UIImage *ligheImageAuto;

/**
 闪光灯按钮图片 - 关闭
 */
@property (strong, nonatomic) UIImage *ligheImageClose;

/**
 闪光灯按钮图片 - 不可用
 */
@property (strong, nonatomic) UIImage *ligheImageUnable;

/**
 倒计时图片
 */
@property (strong, nonatomic) UIImage *countdownImage;

/**
 切换摄像头的图片
 */
@property (strong, nonatomic) UIImage *switchCameraImage;

/**
 完成的按钮图片 - 不可用
 */
@property (strong, nonatomic) UIImage *finishImageUnable;

/**
 完成的按钮图片 - 可用
 */
@property (strong, nonatomic) UIImage *finishImageEnable;

/**
 底部滤镜，美颜，美型对应的按钮图片
 */
@property (strong, nonatomic) UIImage *faceImage;

/**
 底部动图mv对应的按钮图片
 */
@property (strong, nonatomic) UIImage *magicImage;

/**
 拍摄按钮图片 - 未开始拍摄
 */
@property (strong, nonatomic) UIImage *videoShootImageNormal;

/**
 拍摄按钮图片 - 拍摄中
 */
@property (strong, nonatomic) UIImage *videoShootImageShooting;

/**
 拍摄按钮图片 - 长按中
 */
@property (strong, nonatomic) UIImage *videoShootImageLongPressing;

/**
 回删对应的图片
 */
@property (strong, nonatomic) UIImage *deleteImage;

/**
 拍摄中红点对应的图片
 */
@property (strong, nonatomic) UIImage *dotImage;

/**
 向上的三角形对应的图片
 */
@property (strong, nonatomic) UIImage *triangleImage;

@end
