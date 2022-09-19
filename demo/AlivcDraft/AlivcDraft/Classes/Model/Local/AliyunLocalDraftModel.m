//
//  AliyunLocalDraftModel.m
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/30.
//

#import "AliyunLocalDraftModel+Private.h"
#import "AliyunDraftInfo+Private.h"

@implementation AliyunLocalDraftModel

- (instancetype) init {
    return [super initWithState:AliyunDraftState_Local];
}

- (instancetype) initWithDraft:(AliyunDraft *)draft {
    self = [self init];
    if (self) {
        _draft = draft;
    }
    return self;
}

- (void) onConnect {
    self.state = AliyunDraftState_Synced;
}
- (void) onDisconnect {
    self.state = AliyunDraftState_Local;
}

- (NSString *) projectId { return _draft.projectId; }
- (NSString *) title { return _draft.title; }
- (NSString *) modifiedTime { return _draft.modifiedTime; }
- (NSTimeInterval) duration { return _draft.duration; }
- (size_t) size { return _draft.size / 1024; }
- (AEPSource *) cover { return _draft.cover; }

@end
