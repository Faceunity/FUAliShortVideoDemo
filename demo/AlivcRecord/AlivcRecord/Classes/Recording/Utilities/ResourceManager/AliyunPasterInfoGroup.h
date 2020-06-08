//
//  AliyunPasterInfoGroup.h
//  AliyunVideo
//
//  Created by Vienta on 2017/1/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//  人脸动图组，目前是只有一组

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
#import "AliyunPasterInfo.h"

@interface AliyunPasterInfoGroup : JSONModel

/**
 groupID
 */
@property (nonatomic, assign) NSInteger eid;

/**
 图片
 */
@property (nonatomic, copy) NSString *icon;

/**
 简介
 */
@property (nonatomic, copy) NSString *desc;

/**
 是否是新的
 */
@property (nonatomic, assign) BOOL isNew;

/**
 名称
 */
@property (nonatomic, copy) NSString *name;

/**
 人脸动图数组
 */
@property (nonatomic, strong) NSArray<AliyunPasterInfo> *pasterList;

@end
