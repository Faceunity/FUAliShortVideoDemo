//
//  AliyunLocalDraftManager.h
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/31.
//

#import "AliyunDraftBaseManager.h"
#import "AliyunLocalDraftModel.h"
#import <AliyunVideoSDKPro/AliyunDraftManager.h>

@interface AliyunLocalDraftManager : AliyunDraftBaseManager
@property (nonatomic, assign, readonly) int needSyncDraftCount;
@property (nonatomic, strong, readonly) AliyunDraftManager *originMgr;

- (AliyunLocalDraftModel *) copyDraft:(AliyunLocalDraftModel *)draft toPath:(NSString *)path withTitle:(NSString *)title;
- (void) deleteDraft:(AliyunLocalDraftModel *)draft;
@end
