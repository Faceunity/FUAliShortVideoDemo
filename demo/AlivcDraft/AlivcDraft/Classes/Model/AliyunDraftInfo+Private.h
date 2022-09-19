//
//  AliyunDraftInfo+Private.h
//  Pods
//
//  Created by coder.pi on 2021/7/31.
//

#ifndef AliyunDraftInfo_Private_h
#define AliyunDraftInfo_Private_h

#import "AliyunDraftInfo.h"

@interface AliyunDraftInfo ()
@property (nonatomic, weak, readonly) AliyunDraftInfo *connectInfo;
@property (nonatomic, assign) AliyunDraftState state;
@property (nonatomic, copy) NSString *projectId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *modifiedTime;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) size_t size;
@property (nonatomic, strong) AEPSource *cover;

- (void) connect:(AliyunDraftInfo *)info;
- (void) disconnect;
- (instancetype) initWithState:(AliyunDraftState)state;
@end

#endif /* AliyunDraftInfo_Private_h */
