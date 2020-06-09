//
//  AliyunResourceRequestManager.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunResourceRequestManager.h"
#import <AliyunVideoSDKPro/AliyunHttpClient.h>
#import "AlivcAppServer.h"
#import "AliyunMusicPickModel.h"
#import "AlivcDefine.h"



@implementation AliyunResourceRequestManager

//素材分发服务为官方demo演示使用，无法达到商业化使用程度。请自行搭建相关的服务
+ (void)requestWithEffectTypeTag:(NSInteger)typeTag
                         success:(void(^)(NSArray *resourceListArray))success
                         failure:(void(^)(NSError *error))failure {
    
    AliyunHttpClient *client = [[AliyunHttpClient alloc] initWithBaseUrl:kAlivcQuUrlString];
    NSString *url = [NSString stringWithFormat:@"api/res/type/%ld", (long)typeTag];
    NSDictionary *param = @{@"type":@(typeTag),
                            @"bundleId":BundleID};

    [client GET:url parameters:param completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//        NSLog(@"%@",responseObject);
        if (error) {
            if (failure) {
                failure(error);
            }
        } else {
            if ( [responseObject isKindOfClass:[NSString class]] && [responseObject length] == 0) {
                NSError *error = [NSError errorWithDomain:@"Data Empty Error" code:-10001 userInfo:nil];
                if (failure) {
                    failure(error);
                }
                return ;
            }
            if ([responseObject isKindOfClass:[NSArray class]] && [responseObject count] == 0) {
                
                NSError *error = [NSError errorWithDomain:@"Data Empty Error" code:-10001 userInfo:nil];
                if (failure) {
                    failure(error);
                }
                return ;
            }
            
            if (success) {
                success((NSArray *)responseObject);
            }
        }
  
    }];
}



+ (void)fetchMusicWithPage:(AliyunPage *)page
                       success:(void(^)(NSArray<AliyunMusicPickModel *> *musicList))success
                       failure:(void(^)(NSString *errorStr))failure {
    
    NSMutableDictionary *parameters = @{}.mutableCopy;
    NSString *url = [NSString stringWithFormat:@"%@/music/getRecommendMusic",kAlivcQuUrlString];
    if (page) {
        [parameters setObject:@(page.currentPageNo) forKey:@"pageNo"];
        [parameters setObject:@(page.pageSize) forKey:@"pageSize"];
    }
    [AlivcAppServer getWithUrlString:url parameters:parameters completionHandler:^(NSString * _Nullable errString, NSDictionary * _Nullable resultDic) {
        if (errString) {
            failure(errString);
        }else{
            BOOL result = [resultDic[@"result"] boolValue];
            if (result) {
                page.totalRecords = [resultDic[@"data"][@"total"] intValue];
                NSMutableArray *musicList = @[].mutableCopy;
                for (NSDictionary *dict in resultDic[@"data"][@"musicList"]) {
                    AliyunMusicPickModel *musicModel = [[AliyunMusicPickModel alloc] initWithDictionary:dict];
                    [musicList addObject:musicModel];
                }
                success(musicList);
            }else{
                failure(resultDic[@"message"]);
            }
        }
    }];
}


+ (void)fetchMusicPlayUrl:(NSString *)musicId
                  success:(void(^)(NSString *playPath,NSString *expireTime))success
                  failure:(void(^)(NSString *errorStr))failure{
    NSMutableDictionary *parameters = @{}.mutableCopy;
    NSString *url = [NSString stringWithFormat:@"%@/music/getPlayPath",kAlivcQuUrlString];
    if (musicId) {
        [parameters setObject:musicId forKey:@"musicId"];
    }
    
    [AlivcAppServer getWithUrlString:url parameters:parameters completionHandler:^(NSString * _Nullable errString, NSDictionary * _Nullable resultDic) {
        if (errString) {
            failure(errString);
        }else{
            BOOL result = [resultDic[@"result"] boolValue];
            if (result) {
                NSString *playPath = resultDic[@"data"][@"playPath"];
                NSString *expireTime = resultDic[@"data"][@"expireTime"];
                success(playPath,expireTime);
            }else{
                failure(resultDic[@"message"]);
            }
        }
    }];
}


+ (void)fetchPasterCategoryWithType:(kPasterCategory)pasterCategory
                            success:(void(^)(NSArray *resourceListArray))success
                            failure:(void(^)(NSString *errorStr))failure {
    
    NSDictionary *param = @{@"type":@(pasterCategory)};
    NSString *url = [NSString stringWithFormat:@"%@/resource/getPasterInfo",kAlivcQuUrlString];
    [AlivcAppServer getWithUrlString:url parameters:param completionHandler:^(NSString * _Nullable errString, NSDictionary * _Nullable resultDic) {
        if (errString) {
            failure(errString);
        }else{
            BOOL result = [resultDic[@"result"] boolValue];
            if (result) {
                success(resultDic[@"data"]);
            }else{
                failure(resultDic[@"message"]);
            }
        }
    }];
}

+ (void)fetchPasterListWithType:(kPasterCategory)pasterCategory
               pasterCategoryId:(NSInteger)pasterCategoryId
                        success:(void(^)(NSArray<AliyunEffectPasterInfo> *resourceListArray))success
                        failure:(void(^)(NSString *errorStr))failure {
    NSDictionary *param = @{@"type":@(pasterCategory),@"pasterId":@(pasterCategoryId)};
    NSString *url = [NSString stringWithFormat:@"%@/resource/getPasterList",kAlivcQuUrlString];
    [AlivcAppServer getWithUrlString:url parameters:param completionHandler:^(NSString * _Nullable errString, NSDictionary * _Nullable resultDic) {
        if (errString) {
            failure(errString);
        }else{
            BOOL result = [resultDic[@"result"] boolValue];
            if (result) {
                NSMutableArray<AliyunEffectPasterInfo> *array = @[].mutableCopy;
                for (NSDictionary *dict in resultDic[@"data"]) {
                    AliyunEffectPasterInfo *info = [[AliyunEffectPasterInfo alloc] initWithDictionary:dict error:nil];
                    [array addObject:info];
                }
                success(array);
            }else{
                failure(resultDic[@"message"]);
            }
        }
    }];
}

+ (void)fetchCaptionListWithSuccess:(void(^)(NSArray *resourceListArray))success
                            failure:(void(^)(NSString *errorStr))failure {
    NSDictionary *param = @{};
    NSString *url = [NSString stringWithFormat:@"%@/resource/getTextPaster",kAlivcQuUrlString];
    [AlivcAppServer getWithUrlString:url parameters:param completionHandler:^(NSString * _Nullable errString, NSDictionary * _Nullable resultDic) {
        if (errString) {
            failure(errString);
        }else{
            BOOL result = [resultDic[@"result"] boolValue];
            if (result) {
                success(resultDic[@"data"]);
            }else{
                failure(resultDic[@"message"]);
            }
        }
    }];
}

+ (void)fetchTextPasterListWithTextPasterCategoryId:(NSInteger)textPasterCategoryId
                                            success:(void(^)(NSArray<AliyunEffectPasterInfo> *resourceListArray))success
                                            failure:(void(^)(NSString *errorStr))failure; {
    NSDictionary *param = @{@"textPasterId":@(textPasterCategoryId)};
    NSString *url = [NSString stringWithFormat:@"%@/resource/getTextPasterList",kAlivcQuUrlString];
    [AlivcAppServer getWithUrlString:url parameters:param completionHandler:^(NSString * _Nullable errString, NSDictionary * _Nullable resultDic) {
        if (errString) {
            failure(errString);
        }else{
            BOOL result = [resultDic[@"result"] boolValue];
            if (result) {
                NSMutableArray<AliyunEffectPasterInfo> *array = @[].mutableCopy;
                for (NSDictionary *dict in resultDic[@"data"]) {
                    AliyunEffectPasterInfo *info = [[AliyunEffectPasterInfo alloc] initWithDictionary:dict error:nil];
                    [array addObject:info];
                }
                success(array);
            }else{
                failure(resultDic[@"message"]);
            }
        }
    }];
}

+ (void)fetchMVListSuccess:(void(^)(NSArray *resourceListArray))success
                   failure:(void(^)(NSString *errorStr))failure {
    NSDictionary *param = @{}; 
     NSString *url = [NSString stringWithFormat:@"%@/resource/getMv",kAlivcQuUrlString];
    [AlivcAppServer getWithUrlString:url parameters:param completionHandler:^(NSString * _Nullable errString, NSDictionary * _Nullable resultDic) {
        if (errString) {
            failure(errString);
        }else{
            BOOL result = [resultDic[@"result"] boolValue];
            if (result) {
                success(resultDic[@"data"]);
            }else{
                failure(resultDic[@"message"]);
            }
        }
    }];
    
}

+ (void)fetchSpecialEffectListSuccess:(void(^)(NSArray *resourceListArray))success
                   failure:(void(^)(NSString *errorStr))failure {
    NSDictionary *param = @{};
     NSString *url = [NSString stringWithFormat:@"%@/resource/getMotionFilter",kAlivcQuUrlString];
    [AlivcAppServer getWithUrlString:url parameters:param completionHandler:^(NSString * _Nullable errString, NSDictionary * _Nullable resultDic) {
        if (errString) {
            failure(errString);
        }else{
            BOOL result = [resultDic[@"result"] boolValue];
            if (result) {
                success(resultDic[@"data"]);
            }else{
                failure(resultDic[@"message"]);
            }
        }
    }];
}

+ (void)fetchTransitionListSuccess:(void(^)(NSArray *resourceListArray))success
                   failure:(void(^)(NSString *errorStr))failure {
    NSDictionary *param = @{};
     NSString *url = [NSString stringWithFormat:@"%@/resource/getTransitions",kAlivcQuUrlString];
    [AlivcAppServer getWithUrlString:url parameters:param completionHandler:^(NSString * _Nullable errString, NSDictionary * _Nullable resultDic) {
        if (errString) {
            failure(errString);
        }else{
            BOOL result = [resultDic[@"result"] boolValue];
            if (result) {
                success(resultDic[@"data"]);
            }else{
                failure(resultDic[@"message"]);
            }
        }
    }];
}

@end
