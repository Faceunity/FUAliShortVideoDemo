//
//  AliyunPasterInfo.h
//  AliyunVideo
//
//  Created by Vienta on 2017/1/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@protocol AliyunPasterInfo;

@interface AliyunPasterInfo : JSONModel

/**
 动图ID
 */
@property (nonatomic, assign) NSInteger eid;

/**
 动图图标
 */
@property (nonatomic, copy) NSString *icon;

/**
 动图名称
 */
@property (nonatomic, copy) NSString *name;

/**
 组名
 */
@property (nonatomic, copy) NSString *groupName;

/**
 组ID
 */
@property (nonatomic, assign) NSInteger groupId;


/**
 下载资源的URL
 */
@property (nonatomic, copy) NSString *url;

/**
 校验下载资源是否完整
 */
@property (nonatomic, copy) NSString *md5;

@property (nonatomic, copy) NSString *preview;

/**
 类型
 */
@property (nonatomic, assign) NSInteger type;

/**
 本地路径
 */
@property (nonatomic, copy) NSString *bundlePath;


/**
 通过字典初始化一个人脸动图

 @param dict 字典
 @return self 对象
 */
- (id)initWithDict:(NSDictionary *)dict;

/**
 通过本地路径获取一个人脸动图模型

 @param path 本地路径
 @return self对象
 */
- (id)initWithBundleFile:(NSString *)path;

/**
 目录路径

 @return 路径地址
 */
- (NSString *)directoryPath;

/**
 文件路径

 @return 路径地址
 */
- (NSString *)filePath;

/**
 文件是否存在

 @return 是否存在
 */
- (BOOL)fileExist;

@end
