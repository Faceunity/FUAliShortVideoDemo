//
//  AlivcVideoPlayManager.h
//  AliyunVideoClient_Entrance
//
//  Created by 王凯 on 2018/5/21.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlivcVideoPlayManager : NSObject

/*
 * 功能：播放器播放列表请求
 *
 */
+ (void)requestPlayListWithSucess:(void (^)(NSArray *ary, long total))sucess failure:(void (^)(NSString *))failure;


/*
 * 功能：播放器播放列表请求
 * 
 */
+ (void)requestPlayListVodPlayWithAccessKeyId:(NSString *)accessKeyId accessSecret:(NSString *)accessSecret securityToken:(NSString *)securityToken sucess:(void (^)(NSArray *ary, long total))sucess failure:(void (^)(NSString *errString))failure;

/*
 * 功能：播放器播放列表请求
 *
 */
+ (void)requestPlayListVodPlayWithAccessKeyId:(NSString *)accessKeyId accessSecret:(NSString *)accessSecret securityToken:(NSString *)securityToken cateId:(NSString *)cateId pageNo:(NSInteger )pageNo pageCount:(NSInteger )pageCount sucess:(void (^)(NSArray *ary, long total))sucess failure:(void (^)(NSString *errString))failure;
@end
