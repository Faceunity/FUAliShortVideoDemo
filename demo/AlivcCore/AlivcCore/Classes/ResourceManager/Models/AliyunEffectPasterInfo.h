//
//  AliyunEffectPasterList.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol AliyunEffectPasterInfo
@end

/**
 动图信息model
 */
@interface AliyunEffectPasterInfo : JSONModel

/**
 资源路径
 */
@property (nonatomic, copy) NSString *resourcePath;

@property (nonatomic ,copy) NSString *configFontName;
@property (nonatomic, strong) NSNumber *configFontId;
@property (nonatomic, assign) NSInteger pid;
@property (nonatomic, copy) NSString *fontId;

/**
 动图icon
 */
@property (nonatomic, copy) NSString *icon;

/**
 动图名字
 */
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *priority;

/**
 网络资源的url
 */
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *md5;
@property (nonatomic, copy) NSString *preview;
@property (nonatomic, copy) NSString *sort;
@property (nonatomic, copy) NSString *type;

- (float)defaultDuration;

@end
