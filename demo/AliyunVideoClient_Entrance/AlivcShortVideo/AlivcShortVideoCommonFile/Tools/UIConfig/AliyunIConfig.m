//
//  AliyunIConfig.m
//  AliyunVideo
//
//  Created by mengt on 2017/4/25.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunIConfig.h"

static AliyunIConfig *uiConfig;

@implementation AliyunIConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _backgroundColor = RGBToColor(35, 42, 66);
        _timelineBackgroundCollor = RGBToColor(35, 42, 66);
        _timelineDeleteColor = [UIColor redColor];
        _timelineTintColor = RGBToColor(239, 75, 129);
        _durationLabelTextColor = [UIColor redColor];
        _hiddenDurationLabel = NO;
        _hiddenFlashButton = NO;
        _hiddenBeautyButton = NO;
        _hiddenCameraButton = NO;
        _hiddenImportButton = NO;
        _hiddenDeleteButton = NO;
        _hiddenFinishButton = NO;
        _recordOnePart = NO;
        _filterArray = @[@"filter/炽黄",@"filter/粉桃",@"filter/海蓝",@"filter/红润",@"filter/灰白",@"filter/经典",@"filter/麦茶",@"filter/浓烈",@"filter/柔柔",@"filter/闪耀",@"filter/鲜果",@"filter/雪梨",@"filter/阳光",@"filter/优雅",@"filter/朝阳",@"filter/波普",@"filter/光圈",@"filter/海盐",@"filter/黑白",@"filter/胶片",@"filter/焦黄",@"filter/蓝调",@"filter/迷糊",@"filter/思念",@"filter/素描",@"filter/鱼眼",@"filter/马赛克",@"filter/模糊"];
        _imageBundleName = @"QPSDK";
        _recordType = AliyunIRecordActionTypeClick;
        _filterBundleName = nil;
        _showCameraButton = NO;
    }
    return self;
}

+ (AliyunIConfig *)config {
    
    return uiConfig;
}

+ (void)setConfig:(AliyunIConfig *)c {
    uiConfig = c;
}

- (NSString *)imageName:(NSString *)imageName {
    

    NSString *path = [NSString stringWithFormat:@"%@.bundle/%@",_imageBundleName,imageName];
    
    return path;
}

- (NSString *)filterPath:(NSString *)filterName {
    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:filterName];
    if (_filterBundleName) {
        path = [[[NSBundle mainBundle] pathForResource:_filterBundleName ofType:@"bundle"] stringByAppendingPathComponent:filterName];
    }
    return path;
}

@end
