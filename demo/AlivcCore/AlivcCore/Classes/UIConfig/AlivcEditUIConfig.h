//
//  AlivcEditVCUIConfig.h
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/10/9.
//  Copyright © 2018年 Alibaba. All rights reserved.
//  编辑界面的UI配置

#import "AlivcShortVideoUIConfig.h"

@interface AlivcEditUIConfig : AlivcShortVideoUIConfig

/**
 滤镜item对应的图片
 */
@property (strong, nonatomic) UIImage *filterImage;

/**
 音乐
 */
@property (strong, nonatomic) UIImage *musicImage;

/**
 动图
 */
@property (strong, nonatomic) UIImage *pasterImage;

/**
 字幕
 */
@property (strong, nonatomic) UIImage *captionImage;

/**
 MV
 */
@property (strong, nonatomic) UIImage *mvImage;

/**
 音效
 */
@property (strong, nonatomic) UIImage *soundImage;

/**
 特效
 */
@property (strong, nonatomic) UIImage *effectImage;

/**
 时间特效
 */
@property (strong, nonatomic) UIImage *timeImage;

/**
 转场
 */
@property (strong, nonatomic) UIImage *translationImage;

/**
 封面选择
 */
@property (strong, nonatomic) UIImage *coverImage;

/**
 涂鸦
 */
@property (strong, nonatomic) UIImage *paintImage;


/**
 播放对应图片
 */
@property (strong, nonatomic) UIImage *playImage;

/**
 暂停对应图片
 */
@property (strong, nonatomic) UIImage *pauseImage;

/**
 编辑完成对应图片
 */
@property (strong, nonatomic) UIImage *finishImage;


@end
