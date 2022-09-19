//
//  AliyunDraftInfo.m
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/31.
//

#import "AliyunDraftInfo+Private.h"

@implementation AliyunDraftInfo

- (void) setState:(AliyunDraftState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    if ([_delegate respondsToSelector:@selector(onAliyunDraftInfo:stateDidChange:)]) {
        [_delegate onAliyunDraftInfo:self stateDidChange:_state];
    }
}

- (instancetype) initWithState:(AliyunDraftState)state {
    self = [super init];
    if (self) {
        _state = state;
    }
    return self;
}

- (void) onConnect {}
- (void) onDisconnect {}

- (void) connect:(AliyunDraftInfo *)info {
    if (_connectInfo == info) {
        return;
    }
    if (_connectInfo) {
        AliyunDraftInfo *otherInfo = _connectInfo;
        _connectInfo = nil;
        [otherInfo disconnect];
    }
    
    if (![info.projectId isEqualToString:self.projectId] ||
        ![info.modifiedTime isEqualToString:self.modifiedTime]) {
        return;
    }
    
    _connectInfo = info;
    [self onConnect];
    
    [info connect:self];
}

- (void) disconnect {
    AliyunDraftInfo *otherInfo = _connectInfo;
    if (!otherInfo) {
        return;
    }
    _connectInfo = nil;
    [self onDisconnect];
    
    [otherInfo disconnect];
}

@end
