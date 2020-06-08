//
//  AliyunResourceRequestManager.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//       

#import <Foundation/Foundation.h>
#import "AliyunPage.h"
#import "AliyunEffectPasterInfo.h"

typedef enum : NSUInteger {
    kPasterCategoryFront = 1,   //前置动图分类
    kPasterCategoryBack = 2   //后置动图分类
} kPasterCategory;


@class AliyunMusicPickModel;


@interface AliyunResourceRequestManager : NSObject



/**
 资源data 数据请求
 
 @param typeTag 素材类别 参考EffectResourceModel的AliyunEffectType注释
 @param success 成功回调
 @param failure 失败回调
 */
//+ (void)requestWithEffectTypeTag:(NSInteger)typeTag
//                         success:(void(^)(NSArray *resourceListArray))success
//                         failure:(void(^)(NSError *error))failure __deprecated_msg("素材分发服务为官方demo演示使用，无法达到商业化使用程度。请自行搭建相关的服务");


/**
 获取太合音乐数据
 @param page     分页器
 @param success  成功的回调
 @param failure  失败的回调
 */
+ (void)fetchMusicWithPage:(AliyunPage *)page
                       success:(void(^)(NSArray<AliyunMusicPickModel *> *musicList))success
                       failure:(void(^)(NSString *errorStr))failure;__deprecated_msg("素材分发服务为官方demo演示使用，无法达到商业化使用程度。请自行搭建相关的服务");


/**
 获取音乐的下载地址
 
 @param musicId 音乐id
 @param success 成功的回调
 @param failure 失败的回调
 */
+ (void)fetchMusicPlayUrl:(NSString *)musicId
                  success:(void(^)(NSString *playPath,NSString *expireTime))success
                  failure:(void(^)(NSString *errorStr))failure;__deprecated_msg("素材分发服务为官方demo演示使用，无法达到商业化使用程度。请自行搭建相关的服务");



/**
 获取动图分类信息
 
 @param pasterCategory 分组的分类
 @param success  成功的回调
 @param failure  失败的回调
 */
+ (void)fetchPasterCategoryWithType:(kPasterCategory)pasterCategory
                            success:(void(^)(NSArray *resourceListArray))success
                            failure:(void(^)(NSString *errorStr))failure;__deprecated_msg("素材分发服务为官方demo演示使用，无法达到商业化使用程度。请自行搭建相关的服务");



/**
 获取某个分组下的动图列表

 @param pasterCategory 动图分类的类型
 @param pasterCategoryId 动图分类的id
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)fetchPasterListWithType:(kPasterCategory)pasterCategory
               pasterCategoryId:(NSInteger)pasterCategoryId
                        success:(void(^)(NSArray<AliyunEffectPasterInfo> *resourceListArray))success
                        failure:(void(^)(NSString *errorStr))failure;__deprecated_msg("素材分发服务为官方demo演示使用，无法达到商业化使用程度。请自行搭建相关的服务");


/**
 字幕列表

 @param success 成功回调
 @param failure 失败回调
 */
+ (void)fetchCaptionListWithSuccess:(void(^)(NSArray *resourceListArray))success
                            failure:(void(^)(NSString *errorStr))failure;__deprecated_msg("素材分发服务为官方demo演示使用，无法达到商业化使用程度。请自行搭建相关的服务");


/**
 获取字幕下载类别

 @param textPasterCategoryId 字幕分类id
 @param success 成功的回调
 @param failure 失败的回调
 */
+ (void)fetchTextPasterListWithTextPasterCategoryId:(NSInteger)textPasterCategoryId
                            success:(void(^)(NSArray<AliyunEffectPasterInfo> *resourceListArray))success
                            failure:(void(^)(NSString *errorStr))failure;__deprecated_msg("素材分发服务为官方demo演示使用，无法达到商业化使用程度。请自行搭建相关的服务");


/**
 获取MV列表

 @param success 成功回调
 @param failure 失败回调
 */
+ (void)fetchMVListSuccess:(void(^)(NSArray *resourceListArray))success
                   failure:(void(^)(NSString *errorStr))failure;__deprecated_msg("素材分发服务为官方demo演示使用，无法达到商业化使用程度。请自行搭建相关的服务");


/**
获取特效列表

@param success 成功回调
@param failure 失败回调
*/
+ (void)fetchSpecialEffectListSuccess:(void(^)(NSArray *resourceListArray))success
                              failure:(void(^)(NSString *errorStr))failure;__deprecated_msg("素材分发服务为官方demo演示使用，无法达到商业化使用程度。请自行搭建相关的服务");

/**
获取特效列表

@param success 成功回调
@param failure 失败回调
*/
+ (void)fetchTransitionListSuccess:(void(^)(NSArray *resourceListArray))success
                           failure:(void(^)(NSString *errorStr))failure;__deprecated_msg("素材分发服务为官方demo演示使用，无法达到商业化使用程度。请自行搭建相关的服务");


@end
