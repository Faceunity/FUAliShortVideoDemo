//
//  AliyunDraftBaseManager.m
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/31.
//

#import "AliyunDraftBaseManager.h"

@implementation AliyunDraftBaseManager

- (void) notifyListDidChange {
    if ([_delegate respondsToSelector:@selector(onAliyunDraftBaseManager:listDidChange:)]) {
        [_delegate onAliyunDraftBaseManager:self listDidChange:self.list];
    }
}

- (void) refreshList {
    NSAssert(NO, @"子类必须实现");
}

@end
