//
//  AliyunCloudDraftModel+Private.h
//  Pods
//
//  Created by coder.pi on 2021/7/31.
//

#ifndef AliyunCloudDraftModel_Private_h
#define AliyunCloudDraftModel_Private_h

#import "AliyunCloudDraftModel.h"
#import "AliyunLocalDraftModel.h"
#import "AliyunDraftInfo+Private.h"

@interface AliyunCloudDraftModel ()
@property (nonatomic, copy) NSString *projectUrl;
@property (nonatomic, assign) NSTimeInterval innerBackupTime;
- (instancetype) initWithDict:(NSDictionary *)dict;
- (instancetype) initWithLocal:(AliyunLocalDraftModel *)model projectUrl:(NSString *)projectUrl;
@end

#endif /* AliyunCloudDraftModel_Private_h */
