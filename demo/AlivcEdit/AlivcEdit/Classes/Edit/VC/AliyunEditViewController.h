//
//  QUEditViewController.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlivcShortVideoRoute.h"
#import "AlivcEditUIConfig.h"

@interface AliyunEditViewController : UIViewController


/**
 多个资源的本地存放文件夹路径 - 从相册选择界面进入传这个值
 */
@property (nonatomic, strong) NSString *taskPath;

/**
 单个视频的本地路径 - 录制进入编辑传这个值
 */
@property (nonatomic, strong) NSString *videoPath;

/**
 视频配置参数
 */
@property (nonatomic, strong) AliyunMediaConfig *config;

/**
 编辑界面的UI配置
 */
@property (nonatomic, strong) AlivcEditUIConfig *uiConfig;


/**
 完成的回调
 */
@property (nonatomic, copy) AlivcEditFinishBlock finishBlock;


/**
 录制的时候是否带音乐
 */
@property (nonatomic, assign) BOOL hasRecordMusic;


/**
 是否是合拍的视频
 */
@property (nonatomic, assign) BOOL isMixedVideo;

#define kLinearSwipFragmentShader  @"precision mediump float; uniform sampler2D inputImageTexture; uniform float uAlpha; varying vec2 textureCoordinate; uniform float offset; float w = 0.2; float g = 1.0; uniform int direction; uniform int wipeMode;const int LEFT = 0;const int TOP = 1;const int RIGHT = 2;const int BOTTOM = 3;const int APPEAR = 0;const int DISAPPEAR = 1;void main(){vec4 gamma = vec4(g, g, g, 1.0);vec4 color0 = pow(texture2D(inputImageTexture, textureCoordinate), gamma);float correction = mix(w, -w, offset);float coord = textureCoordinate.x;if(direction == LEFT){coord = 1.0 - textureCoordinate.x;}else if(direction == RIGHT){coord = textureCoordinate.x;}else if(direction == TOP){coord = 1.0 - textureCoordinate.y;}else if(direction == BOTTOM){coord = textureCoordinate.y;}float choose = smoothstep(offset - w, offset + w, coord + correction); float alpha = choose;if(wipeMode == APPEAR){alpha = 1.0 - choose;}else if(wipeMode == DISAPPEAR){alpha = choose;}gl_FragColor = vec4(color0.r,color0.g,color0.b,color0.a*alpha);}"

@end
