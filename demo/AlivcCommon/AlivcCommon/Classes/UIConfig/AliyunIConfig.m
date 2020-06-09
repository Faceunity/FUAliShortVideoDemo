//
//  AliyunIConfig.m
//  AliyunVideo
//
//  Created by mengt on 2017/4/25.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunIConfig.h"
#import "UIColor+AlivcHelper.h"

static AliyunIConfig *uiConfig;

@implementation AliyunIConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _backgroundColor = RGBToColor(35, 42, 66);
        _timelineBackgroundCollor = [UIColor colorWithWhite:0 alpha:0.34];
        _timelineDeleteColor = [UIColor redColor];
        _timelineTintColor = [UIColor colorWithHexString:@"0xFC4448"];
        _durationLabelTextColor = [UIColor redColor];
        _hiddenDurationLabel = NO;
        _hiddenFlashButton = NO;
        _hiddenBeautyButton = NO;
        _hiddenCameraButton = NO;
        _hiddenImportButton = NO;
        _hiddenDeleteButton = NO;
        _hiddenFinishButton = NO;
        _recordOnePart = NO;
        _filterArray = @[@"Filter/炽黄",@"Filter/粉桃",@"Filter/海蓝",@"Filter/红润",@"Filter/灰白",@"Filter/经典",@"Filter/麦茶",@"Filter/浓烈",@"Filter/柔柔",@"Filter/闪耀",@"Filter/鲜果",@"Filter/雪梨",@"Filter/阳光",@"Filter/优雅",@"Filter/朝阳",@"Filter/波普",@"Filter/光圈",@"Filter/海盐",@"Filter/黑白",@"Filter/胶片",@"Filter/焦黄",@"Filter/蓝调",@"Filter/迷糊",@"Filter/思念",@"Filter/素描",@"Filter/鱼眼",@"Filter/马赛克",@"Filter/模糊"];
        _imageBundleName = @"AlivcCore";
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
    

    NSString *path = [NSString stringWithFormat:@"AlivcCore.bundle/%@",imageName];
    
    return path;
}

- (NSString *)filterPath:(NSString *)filterName {
//    NSString *filterPath = [NSString stringWithFormat:@"AlivcCore.bundle/%@",filterName];
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filterName];
//    if (_filterBundleName) {
//         path = [[[NSBundle mainBundle]bundlePath] stringByAppendingPathComponent:filterName];
//    }
    return path;
}

@end
