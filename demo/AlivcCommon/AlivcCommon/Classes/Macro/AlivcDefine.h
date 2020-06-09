//
//  AlivcDefine.h
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/5/9.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 阿里云视频云工具包对外输出产品定义

 - AlivcOutputProductTypeSmartVideo: 趣视频
 - AlivcOutputProductTypeShortVideo: 短视频
 - AlivcOutputProductTypePlayVideo: 播放器
  - AlivcOutputProductTypeLongVideo: 长视频
 - AlivcOutputProductTypeAll: 全量包
 */
typedef NS_ENUM(NSInteger,AlivcOutputProductType){
    AlivcOutputProductTypeSmartVideo,
    AlivcOutputProductTypeShortVideo,
    AlivcOutputProductTypePlayVideo,
    AlivcOutputProductTypeLongVideo,
    AlivcOutputProductTypeAll
};


//资源删除通知
extern NSString * const AliyunEffectResourceDeleteNotification;
//系统字体名称
extern NSString * const AlivcSystemFontName;
//用户token本地存储字符串
extern NSString * const AlivcUserLocalPath;
//视频开始发布的通知
extern NSString * const AlivcNotificationVideoStartPublish;
//视频发布成功的通知
extern NSString * const AlivcNotificationVideoPublishSuccess;
//随机用户成功的通知
extern NSString * const AlivcNotificationRandomUserSuccess;
//发布流程结束的通知
extern NSString * const AlivcNotificationPublishFlowEnd;

extern NSString * const AlivcEditPlayerPasterFontName;
//趣视频的服务地址
extern NSString * const kAlivcQuUrlString;
// 播放器服务地址
extern NSString * const AlivcVideoPlayUrlString;

@interface AlivcDefine : NSObject
@end
