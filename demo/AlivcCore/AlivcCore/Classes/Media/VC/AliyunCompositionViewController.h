//
//  QUCompositionViewController.h
//  AliyunVideo
//
//  Created by Worthy on 2017/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//  

#import <UIKit/UIKit.h>
#import "AliyunMediaConfig.h"

typedef NS_ENUM(NSUInteger, AlivcCompositionViewControllerType) {
    AlivcCompositionViewControllerTypeVideoEdit, //资源选择(编辑功能)
    AlivcCompositionViewControllerTypeVideoMix //资源选择(合拍功能)
};

/**
 进入编辑页面前的相册选择功能
 */
@interface AliyunCompositionViewController : UIViewController

@property (nonatomic, strong) AliyunMediaConfig *compositionConfig;
@property (nonatomic, assign) BOOL isOriginal;
@property (nonatomic, assign) AlivcCompositionViewControllerType controllerType;
@end
