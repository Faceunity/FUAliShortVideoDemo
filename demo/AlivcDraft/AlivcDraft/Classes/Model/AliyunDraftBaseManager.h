//
//  AliyunDraftBaseManager.h
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/31.
//

#import "AliyunDraftInfo.h"

@class AliyunDraftBaseManager;
@protocol AliyunDraftBaseManagerDelegate <NSObject>
- (void) onAliyunDraftBaseManager:(AliyunDraftBaseManager *)mgr listDidChange:(NSArray<AliyunDraftInfo *> *)list;
@end

@interface AliyunDraftBaseManager : NSObject
@property (nonatomic, weak) id<AliyunDraftBaseManagerDelegate> delegate;
@property (nonatomic, strong, readonly) NSArray<AliyunDraftInfo *> *list;

- (void) refreshList;
@end
