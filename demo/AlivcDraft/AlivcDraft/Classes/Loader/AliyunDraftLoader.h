//
//  AliyunDraftLoader.h
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/20.
//

#import <Foundation/Foundation.h>

@class AliyunDraftLoadTask;
@class AliyunDraftInfo;
@interface AliyunDraftLoader : NSObject
@property (nonatomic, assign, readonly) BOOL enabled;
@property (nonatomic, copy, readonly) NSString *baseUrl;
@property (nonatomic, copy, readonly) NSString *userId;

- (instancetype) initWithBaseUrl:(NSString *)baseUrl userId:(NSString *)userId;

- (void) requestProjects:(void(^)(id response))completion;
- (void) downloadWithUrl:(NSString *)urlString completion:(void(^)(NSString *path))completion;
- (void) download:(AliyunDraftLoadTask *)task;
- (void) upload:(AliyunDraftLoadTask *)task;
- (void) addDraft:(AliyunDraftInfo *)draft projectFile:(NSString *)projectFile completion:(void(^)(NSString *projectId, NSString *projectUrl, NSError *error))completion;
- (void) deleteProejct:(NSString *)projectId;

@end
