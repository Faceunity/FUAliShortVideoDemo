//
//  AliyunCloudDraftManager+Private.h
//  Pods
//
//  Created by coder.pi on 2021/8/2.
//

#ifndef AliyunCloudDraftManager_Private_h
#define AliyunCloudDraftManager_Private_h

#import "AliyunCloudDraftManager.h"
#import "AliyunDraftBaseManager+Private.h"
#import "AliyunLocalDraftManager.h"
#import "AliyunDraftLoader.h"
#import "AliyunCloudDraftModel.h"

@interface AliyunCloudDraftManager ()
@property (nonatomic, strong, readonly) AliyunDraftLoader *loader;
@property (nonatomic, weak, readonly) AliyunLocalDraftManager *localManager;
@property (nonatomic, strong) NSMutableArray<AliyunCloudDraftModel *> *cloudList;

- (instancetype) initWithLoader:(AliyunDraftLoader *)loader localManager:(AliyunLocalDraftManager *)localMgr;
@end

#endif /* AliyunCloudDraftManager_Private_h */
