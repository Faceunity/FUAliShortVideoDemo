//
//  AliyunPublishViewController.h
//  qusdk
//
//  Created by Worthy on 2017/11/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//  短视频模块的发布界面

#import <UIKit/UIKit.h>
#import "AliyunMediaConfig.h"
#import "AlivcShortVideoRoute.h"

@interface AlivcExportViewController : UIViewController
/**
 背景图片
 */
@property (nonatomic, strong) UIImage *backgroundImage;

/**
 短视频路径
 */
@property (nonatomic, strong) NSString *taskPath;

/**
 合成信息配置
 */
@property (nonatomic, strong) AliyunMediaConfig *config;
/**
 完成的回调
 */
@property (nonatomic, copy) AlivcEditFinishBlock finishBlock;

/**
 输出大小
 */
@property (nonatomic, assign) CGSize outputSize;
@end
