//
//  AliyunEffectInfo.h
//  AliyunVideo
//
//  Created by dangshuai on 17/3/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

/**
 滤镜model基类
 */
@interface AliyunEffectInfo : JSONModel

/**
 数据ID
 */
@property (nonatomic, assign) NSInteger eid;

/**
 数据类型
 */
@property (nonatomic, assign) NSInteger effectType;

/**
 滤镜分组id
 */
@property (nonatomic, assign) NSInteger groupId;

/**
 图标
 */
@property (nonatomic, copy) NSString *icon;

/**
 名称
 */
@property (nonatomic, copy) NSString *name;

/**
 滤镜描述
 */
@property (nonatomic, copy) NSString *edescription;

/**
 是否在数据库里包含
 */
@property (nonatomic, assign) BOOL isDBContain;

/**
 分组名称
 */
@property (nonatomic, copy) NSString *groupName;

/**
 download URL
 */
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *md5;

/**
 资源路径
 */
@property (nonatomic, copy) NSString *resourcePath;


/**
 获取本地滤镜Icon路径

 @return 本地滤镜Icon路径
 */
- (NSString *)localFilterIconPath;

/**
 获取滤镜资源本地路径

 @return 滤镜资源本地路径
 */
- (NSString *)localFilterResourcePath;

@end
