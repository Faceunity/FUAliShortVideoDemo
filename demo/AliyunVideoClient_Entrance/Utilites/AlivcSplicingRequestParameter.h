//
//  AlivcSplicingRequestParameter.h
//  AliyunVideoClient_Entrance
//
//  Created by 王凯 on 2018/5/19.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlivcSplicingRequestParameter : NSObject

@end


@interface AlivcSplicingRequestParameter(videoPlay)

/**
 带默认cateId的参数

 @param accessKeyId accessKeyId
 @param accessKeySecret accessKeySecret
 @param securityToken securityToken
 @return 请求字符串
 */
- (NSString*)appendPlayListWithAccessKeyId:(NSString *)accessKeyId accessKeySecret:(NSString *)accessKeySecret securityToken:(NSString *)securityToken;

/**
 生成请求参数

 @param accessKeyId accessKeyId
 @param accessKeySecret accessKeySecret
 @param securityToken securityToken
 @param cateId 分类id，用于筛选
 @param pageNo 分页查询的页码
 @param pageCount 每个页码对应的个数
 @return 请求字符串
 */
- (NSString*)appendPlayListWithAccessKeyId:(NSString *)accessKeyId accessKeySecret:(NSString *)accessKeySecret securityToken:(NSString *)securityToken cateId:(NSString *)cateId pageNo:(NSInteger )pageNo pageCount:(NSInteger )pageCount;

@end
