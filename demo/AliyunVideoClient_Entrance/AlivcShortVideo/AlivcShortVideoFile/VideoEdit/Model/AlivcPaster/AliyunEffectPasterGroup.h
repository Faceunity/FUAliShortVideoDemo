//
//  AliyunEffectPasterInfo.h
//  AliyunVideo
//
//  Created by dangshuai on 17/3/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectInfo.h"
#import "AliyunEffectPasterInfo.h"

/**
 动图组信息
 */
@interface AliyunEffectPasterGroup : AliyunEffectInfo

@property (nonatomic, copy) NSString *isNew;
@property (nonatomic, copy) NSString *level;
@property (nonatomic, copy) NSString *preview;
@property (nonatomic, copy) NSString *sort;

/**
 动图列表
 */
@property (nonatomic, strong) NSArray<AliyunEffectPasterInfo> *pasterList;

@end
