//
//  AlivcShortVideoTempSave.h
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2019/5/23.
//  Copyright © 2019年 Alibaba. All rights reserved.
//  临时存储

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlivcShortVideoTempSave : NSObject
    
/**
 单例 - 短视频的临时存储
 
 @return 实例
 */
+ (instancetype)shared;
    
/**
 存储相册资源
 
 @param asset 相册资源
 */
- (void)saveResources:(id )asset;

@end

NS_ASSUME_NONNULL_END
