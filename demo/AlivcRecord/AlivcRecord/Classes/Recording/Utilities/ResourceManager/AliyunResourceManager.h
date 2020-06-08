//
//  AliyunResourceManager.h
//  AliyunVideo
//
//  Created by Vienta on 2017/1/23.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AliyunPasterInfoGroup.h"

/**
 资源类型

 - AliyunResourceTypeFacePaster: 人脸动图
 */
typedef NS_ENUM(NSUInteger, AliyunResourceType) {
    AliyunResourceTypeFacePaster,
};

@interface AliyunResourceManager : NSObject

/**
 根据类型获取

 @param type 资源类型
 @return 数据类型
 */
+ (NSString *)pathWithType:(AliyunResourceType)type;

/**
 加载

 @return 加载本地人脸动图数组
 */
- (NSArray *)loadLocalFacePasters;

@end
