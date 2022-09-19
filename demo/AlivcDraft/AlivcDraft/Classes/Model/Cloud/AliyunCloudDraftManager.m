//
//  AliyunCloudDraftManager.m
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/30.
//

#import "AliyunCloudDraftManager+Private.h"
#import <AliyunVideoSDKPro/AliyunDraft+Cloud.h>
#import "AliyunCloudDraftModel+Private.h"
#import "AliyunLocalDraftManager+Private.h"

@implementation AliyunCloudDraftManager
@synthesize isLoading = _isLoading;

- (instancetype) initWithLoader:(AliyunDraftLoader *)loader localManager:(AliyunLocalDraftManager *)localMgr {
    self = [super init];
    if (self) {
        _cloudList = @[].mutableCopy;
        _loader = loader;
        _localManager = localMgr;
    }
    return self;
}

- (NSArray<AliyunDraftInfo *> *) list {
    return _cloudList.copy;
}

- (void) setIsLoading:(BOOL)isLoading {
    if (_isLoading == isLoading) {
        return;
    }
    _isLoading = isLoading;
    
    if ([_cloudStateDelegate respondsToSelector:@selector(onAliyunDraftInfo:stateDidChange:)]) {
        [_cloudStateDelegate onAliyunCloudDraftManager:self loadDidChange:isLoading];
    }
}

- (void) refreshList {
    self.isLoading = YES;
    __weak typeof(self) weakSelf = self;
    [_loader requestProjects:^(id response) {
        [weakSelf responseProjects:response];
    }];
}

- (void) responseProjects:(NSArray *)projects {
    if (![projects isKindOfClass:NSArray.class]) {
        return;
    }
    
    _cloudList = @[].mutableCopy;
    for (NSDictionary *dict in projects) {
        AliyunCloudDraftModel *model = [[AliyunCloudDraftModel alloc] initWithDict:dict];
        
        AliyunLocalDraftModel *localModel = [_localManager findModelWithProjectId:model.projectId];
        [model connect:localModel];
        [_cloudList addObject:model];
    }
    [self notifyListDidChange];
    self.isLoading = NO;
}

- (AliyunCloudDraftModel *) findDraftWithId:(NSString *)projectId {
    for (AliyunCloudDraftModel *model in _cloudList) {
        if ([model.projectId isEqualToString:projectId]) {
            return model;
        }
    }
    return nil;
}

- (void) downloadCloudDraft:(AliyunCloudDraftModel *)cloudDraft completion:(OnLoadDraftCompletion)completion {
    NSAssert(cloudDraft.state == AliyunDraftState_Cloud, @"其他状态都不需要再次下载");
    
    AliyunLocalDraftManager *localMgr = _localManager;
    AliyunDraftLoader *loader = _loader;
    cloudDraft.state = AliyunDraftState_syncing;
    [_loader downloadWithUrl:cloudDraft.projectUrl completion:^(NSString *path) {
        if (![NSFileManager.defaultManager fileExistsAtPath:path]) {
            cloudDraft.state = AliyunDraftState_Cloud;
            if (completion) {
                completion(NO);
            }
            return;
        }
        
        [localMgr.originMgr downloadDraftWithProjectFile:path resourceDownloader:^(NSArray<AliyunDraftLoadTask *> *tasks) {
            for (AliyunDraftLoadTask *task in tasks) {
                [loader download:task];
            }
        } completion:^(AliyunDraft *draft, NSError *error) {
            if (error || !draft) {
                cloudDraft.state = AliyunDraftState_Cloud;
                if (completion) {
                    completion(NO);
                }
                return;
            }
            
            AliyunLocalDraftModel *targetLocalDraft = [localMgr findModelWithDraft:draft];
            [targetLocalDraft.draft changeProjectId:cloudDraft.projectId];
            [cloudDraft connect:targetLocalDraft];
            
            if (cloudDraft.state == AliyunDraftState_syncing) {
                cloudDraft.state = AliyunDraftState_Cloud;
            }
            if (completion) {
                completion(YES);
            }
        }];
    }];
}

- (void) addCloud:(AliyunCloudDraftModel *)cloud {
    [_cloudList addObject:cloud];
    [self notifyListDidChange];
}

- (void) uploadLocalDraft:(AliyunLocalDraftModel *)localModel completion:(void(^)(BOOL isSuccess))completion {
    NSAssert(localModel.state == AliyunDraftState_Local, @"其他状态不需要再次上传");
    
    localModel.state = AliyunDraftState_syncing;
    __weak typeof(self) weakSelf = self;
    __block NSString *projectUrl;
    AliyunDraftLoader *loader = _loader;
    [localModel.draft uploadWithResourceUploader:^(NSArray<AliyunDraftLoadTask *> *tasks) {
        for (AliyunDraftLoadTask *task in tasks) {
            [loader upload:task];
        }
    } projectUploader:^(AliyunDraftProjectUploadTask *projTask) {
        [loader addDraft:localModel projectFile:projTask.projectFilePath completion:^(NSString *projectId, NSString *aProjUrl, NSError *error) {
            if (error || projectId.length == 0 || aProjUrl.length == 0) {
                [projTask onFailWithError:error];
                return;
            }
            
            projectUrl = aProjUrl;
            [projTask.draft changeProjectId:projectId];
            [projTask onSuccess];
        }];
    } completion:^(NSError *error) {
        if (error) {
            localModel.state = AliyunDraftState_Local;
            if (completion) {
                completion(NO);
            }
            return;
        }
        
        AliyunCloudDraftModel *cloud = [[AliyunCloudDraftModel alloc] initWithLocal:localModel projectUrl:projectUrl];
        [cloud connect:localModel];
        [weakSelf addCloud:cloud];
        if (localModel.state == AliyunDraftState_syncing) {
            localModel.state = AliyunDraftState_Local;
        }
        if (completion) {
            completion(YES);
        }
    }];
}

- (void) uploadAllLocalDraft:(void(^)(BOOL))completion {
    NSMutableArray<AliyunLocalDraftModel *> *targetList = @[].mutableCopy;
    for (AliyunLocalDraftModel *model in _localManager.localList) {
        if (model.state == AliyunDraftState_Local) {
            [targetList addObject:model];
        }
    }
    
    __block BOOL isSuccess = YES;
    void(^onFinish)(void) = ^{
        if (completion) {
            completion(isSuccess);
        }
    };
    
    __block int total = (int)targetList.count;
    if (total == 0) {
        onFinish();
        return;
    }
    
    __block int current = 0;
    void(^onSingleFinish)(BOOL) = ^(BOOL aIsOk){
        isSuccess = isSuccess && aIsOk;
        ++current;
        if (total == current) {
            onFinish();
        }
    };
    
    for (AliyunLocalDraftModel *model in targetList) {
        [self uploadLocalDraft:model completion:^(BOOL isSuccess) {
            onSingleFinish(isSuccess);
        }];
    }
}

- (void) deleteDraftWithId:(NSString *)projectId {
    [_loader deleteProejct:projectId];
    AliyunCloudDraftModel *model = [self findDraftWithId:projectId];
    if (model) {
        [model disconnect];
        [_cloudList removeObject:model];
        [self notifyListDidChange];
    }
}

- (void) checkDraftsState {
    for (AliyunCloudDraftModel *model in _cloudList) {
        if (!model.connectInfo) {
            continue;
        }
        
        if (![model.connectInfo.modifiedTime isEqualToString:model.modifiedTime]) {
            [model disconnect];
        }
    }
}

@end
