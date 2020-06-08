//
//  AliyunEffectMvInfo.h
//  AliyunVideo
//
//  Created by dangshuai on 17/3/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectInfo.h"
#import "AliyunEffectMvInfo.h"


/**
 MV比例

 - AliyunEffectMVRatio9To16: 9:16
 - AliyunEffectMVRatio3To4: 3:4
 - AliyunEffectMVRatio1To1: 1:1
 - AliyunEffectMVRatio4To3: 4:3
 - AliyunEffectMVRatio16To9: 16:9
 */
typedef NS_ENUM(NSInteger, AliyunEffectMVRatio) {
    AliyunEffectMVRatio9To16,
    AliyunEffectMVRatio3To4,
    AliyunEffectMVRatio1To1,
    AliyunEffectMVRatio4To3,
    AliyunEffectMVRatio16To9,
};

/**
 MV组信息
 */
@interface AliyunEffectMvGroup : AliyunEffectInfo

/**
 MV列表
 */
@property (nonatomic, copy) NSArray <AliyunEffectMvInfo *> *mvList;

/**
 根据MV比例获取MV资源本地路径

 @param r MV比例
 @return MV资源本地路径
 */
- (NSString *)localResoucePathWithVideoRatio:(AliyunEffectMVRatio)r;

@end
