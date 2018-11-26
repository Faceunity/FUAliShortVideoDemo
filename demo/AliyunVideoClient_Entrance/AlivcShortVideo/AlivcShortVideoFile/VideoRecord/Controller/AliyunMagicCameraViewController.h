//
//  ViewController.h
//  AliyunVideo
//
//  Created by Vienta on 2016/12/29.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlivcShortVideoRoute.h"

@interface AliyunMagicCameraViewController : UIViewController

/**
 视频参数配置
 */
@property (nonatomic, strong) AliyunMediaConfig *quVideo;

/**
 视频拍摄界面UI配置，可不传
 */
@property (nonatomic, strong, nullable) AlivcRecordUIConfig *uiConfig;

/**
 拍摄完成的回调
 */
@property (nonatomic, copy, nullable) AlivcRecordFinishBlock finishBlock;

@end

