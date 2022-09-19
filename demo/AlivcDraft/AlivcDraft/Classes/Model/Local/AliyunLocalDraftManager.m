//
//  AliyunLocalDraftManager.m
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/31.
//

#import "AliyunLocalDraftManager+Private.h"
#import "AliyunDraftBaseManager+Private.h"
#import "AliyunLocalDraftModel+Private.h"
#import "AliyunDraftInfo+Private.h"

@implementation AliyunLocalDraftManager

- (instancetype) initWithUserId:(NSString *)userId {
    self = [super init];
    if (self) {
        _originMgr = [[AliyunDraftManager alloc] initWithId:userId];
        _originMgr.delegate = self;
        _localList = @[].mutableCopy;
        [self refreshList];
    }
    return self;
}

- (NSArray<AliyunDraftInfo *> *) list {
    return _localList.copy;
}

- (AliyunLocalDraftModel *) findModelWithProjectId:(NSString *)projectId {
    for (AliyunLocalDraftModel *model in _localList) {
        if ([model.projectId isEqualToString:projectId]) {
            return model;
        }
    }
    return nil;
}

- (AliyunLocalDraftModel *) findModelWithDraft:(AliyunDraft *)draft {
    for (AliyunLocalDraftModel *model in _localList) {
        if (model.draft == draft) {
            return model;
        }
    }
    return nil;
}

- (void) refreshList {
    NSMutableArray *list = @[].mutableCopy;
    NSArray<AliyunDraft *> *draftList = _originMgr.draftList;
    for (AliyunDraft *draft in draftList) {
        AliyunLocalDraftModel *model = [self findModelWithDraft:draft];
        if (!model) {
            model = [[AliyunLocalDraftModel alloc] initWithDraft:draft];
        }
        [list addObject:model];
    }
    _localList = list;
    [self notifyListDidChange];
}

- (AliyunLocalDraftModel *) copyDraft:(AliyunLocalDraftModel *)draft toPath:(NSString *)path withTitle:(NSString *)title {
    AliyunDraft *newDraft = [_originMgr copyDraft:draft.draft toPath:path withTitle:title];
    return [self findModelWithDraft:newDraft];
}

- (int) needSyncDraftCount {
    int c = 0;
    for (AliyunLocalDraftModel *model in _localList) {
        if (model.state != AliyunDraftState_Synced) {
            ++c;
        }
    }
    return c;
}

- (void) deleteDraft:(AliyunLocalDraftModel *)draft {
    [draft disconnect];
    [_originMgr deleteDraft:draft.draft];
}

// MARK: - AliyunDraftManagerDelegate
- (void) onAliyunDraftManager:(AliyunDraftManager *)mgr listDidChange:(NSArray<AliyunDraft *> *)list {
    [self refreshList];
}
@end
