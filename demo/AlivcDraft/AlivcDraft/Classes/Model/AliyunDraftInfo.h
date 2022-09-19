//
//  AliyunDraftInfo.h
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/31.
//

#import <Foundation/Foundation.h>
#import <AliyunVideoSDKPro/AEPSource.h>

typedef NS_ENUM(NSUInteger, AliyunDraftState) {
    AliyunDraftState_Local,     // 本地的，未同步到云端
    AliyunDraftState_Cloud,     // 云端的，未同步到本地
    AliyunDraftState_syncing,   // 正在同步中
    AliyunDraftState_Synced,    // 本地和云端已经同步
};

@class AliyunDraftInfo;
@protocol AliyunDraftInfoDelegate <NSObject>
- (void) onAliyunDraftInfo:(AliyunDraftInfo *)info stateDidChange:(AliyunDraftState)state;
@end

@interface AliyunDraftInfo : NSObject
@property (nonatomic, weak) id<AliyunDraftInfoDelegate> delegate;
@property (nonatomic, assign, readonly) AliyunDraftState state;
@property (nonatomic, copy, readonly) NSString *projectId;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *modifiedTime;
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, assign, readonly) size_t size;
@property (nonatomic, strong, readonly) AEPSource *cover;
@end
