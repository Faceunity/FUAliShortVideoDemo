//
//  AliyunMusicPickModel.h
//  qusdk
//
//  Created by Worthy on 2017/6/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AliyunMusicPickModel : NSObject

/**
 本地路径
 */
@property (nonatomic, copy) NSString *path;

/**
 名称
 */
@property (nonatomic, copy) NSString *name;

/**
 作者
 */
@property (nonatomic, copy) NSString *artist;

/**
 开始时间 - 裁剪的时候的记录
 */
@property (nonatomic, assign) CGFloat startTime;

/**
 时长
 */
@property (nonatomic, assign) CGFloat duration;

/**
 下载进度
 */
@property (nonatomic, assign) CGFloat downloadProgress;

/**
 是否是展开状态
 */
@property (nonatomic, assign) BOOL expand;

/**
 音乐唯一标志符
 */
@property (nonatomic, copy) NSString *musicId;

/**
 下载的时候作为唯一标志符
 */
@property (assign, nonatomic) NSInteger keyId;

/**
 是否被包含在数据库中
 */
@property (nonatomic, assign) BOOL isDBContain;
@end
