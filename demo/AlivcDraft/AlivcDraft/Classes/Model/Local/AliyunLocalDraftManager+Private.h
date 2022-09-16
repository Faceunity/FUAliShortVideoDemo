//
//  AliyunLocalDraftManager+Private.h
//  Pods
//
//  Created by coder.pi on 2021/8/2.
//

#ifndef AliyunLocalDraftManager_Private_h
#define AliyunLocalDraftManager_Private_h

#import "AliyunLocalDraftManager.h"

@interface AliyunLocalDraftManager () <AliyunDraftManagerDelegate>
@property (nonatomic, strong) NSMutableArray<AliyunLocalDraftModel *> *localList;
- (instancetype) initWithUserId:(NSString *)userId;
- (AliyunLocalDraftModel *) findModelWithDraft:(AliyunDraft *)draft;
- (AliyunLocalDraftModel *) findModelWithProjectId:(NSString *)projectId;
@end

#endif /* AliyunLocalDraftManager_Private_h */
