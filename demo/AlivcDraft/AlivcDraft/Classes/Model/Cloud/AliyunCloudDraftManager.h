//
//  AliyunCloudDraftManager.h
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/30.
//

#import "AliyunDraftBaseManager.h"

typedef void(^OnLoadDraftCompletion)(BOOL isSuccess);

@class AliyunLocalDraftModel;
@class AliyunCloudDraftModel;
@class AliyunCloudDraftManager;
@protocol AliyunCloudDraftManagerDelegate <NSObject>
- (void) onAliyunCloudDraftManager:(AliyunCloudDraftManager *)cloudMgr loadDidChange:(BOOL)isLoading;
@end


@interface AliyunCloudDraftManager : AliyunDraftBaseManager
@property (nonatomic, weak) id<AliyunCloudDraftManagerDelegate> cloudStateDelegate;
@property (nonatomic, assign, readonly) BOOL isLoading;

- (AliyunCloudDraftModel *) findDraftWithId:(NSString *)projectId;
- (void) uploadLocalDraft:(AliyunLocalDraftModel *)localModel completion:(OnLoadDraftCompletion)completion;
- (void) uploadAllLocalDraft:(OnLoadDraftCompletion)completion;
- (void) downloadCloudDraft:(AliyunCloudDraftModel *)cloudDraft completion:(OnLoadDraftCompletion)completion;
- (void) deleteDraftWithId:(NSString *)projectId;

- (void) checkDraftsState;
@end
