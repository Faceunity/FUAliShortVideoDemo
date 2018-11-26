//
//  AlivcLiveEnvManager.h
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/10/17.
//  Copyright © 2018年 Alibaba. All rights reserved.
//  互动直播环境管理

#import <Foundation/Foundation.h>

extern NSString * AlivcAppServer_UrlPreString;
extern NSString * AlivcAppServer_AppID;

extern NSString *const AlivcAppServer_StsAccessKey;
extern NSString *const AlivcAppServer_StsSecretKey;
extern NSString *const AlivcAppServer_StsSecurityToken;
extern NSString *const AlivcAppServer_StsExpiredTime;
extern NSString *const AlivcAppServer_Mode;

@interface AlivcLiveEnvManager : NSObject
+ (void) AlivcAppServerSetTestEnvMode:(int)mode;
+ (int)mode;
@end
