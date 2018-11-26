//
//  AlivcLiveEnvManager.m
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/10/17.
//  Copyright © 2018年 Alibaba. All rights reserved.
//
#import "AlivcLiveEnvManager.h"
#import "AlivcProfile.h"
#import "AlivcUserInfoManager.h"

NSString * AlivcAppServer_UrlPreString = @"http://100.67.146.142";//预发
NSString * AlivcAppServer_AppID = @"sh-4zf93fr7";

NSString *const AlivcAppServer_StsAccessKey = @"com.alivc.sts.stsAccessKey";
NSString *const AlivcAppServer_StsSecretKey = @"com.alivc.sts.stsSecretKey";
NSString *const AlivcAppServer_StsSecurityToken = @"com.alivc.sts.stsSecurityToken";
NSString *const AlivcAppServer_StsExpiredTime = @"com.alivc.sts.stsExpiredTime";
NSString *const AlivcAppServer_Mode = @"com.alivc.app.mode";

@implementation AlivcLiveEnvManager

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //        int mode = [[[NSUserDefaults standardUserDefaults] objectForKey:AlivcAppServer_Mode] intValue];
        [AlivcLiveEnvManager AlivcAppServerSetTestEnvMode:0]; // 默认是新加坡环境
    });
}

+ (void) AlivcAppServerSetTestEnvMode:(int)mode {
    
    if(mode == 0) { // 预发
        AlivcAppServer_UrlPreString = @"http://100.67.146.142";
        AlivcAppServer_AppID = @"sh-4zf93fr7";
    }else if(mode == 1) { //上海
        AlivcAppServer_UrlPreString = @"http://live-appserver-sh.alivecdn.com";
        AlivcAppServer_AppID = @"sh-hrjbxns6";
    }else if (mode == 2){//日常
        AlivcAppServer_UrlPreString = @"http://11.239.168.59:8080";
        AlivcAppServer_AppID = @"sh-l6h3x42a";
    }else if (mode == 3){//新加坡
        AlivcAppServer_UrlPreString = @"http://live-appserver-sig.alivecdn.com";
        AlivcAppServer_AppID = @"sg-37nisbt8";
    }
    
    // 记录环境
    [[NSUserDefaults standardUserDefaults] setObject:@(mode) forKey:AlivcAppServer_Mode];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //更换用户
    AlivcProfile *profile = [AlivcProfile shareInstance];
    [AlivcUserInfoManager randomAUserSuccess:^(AlivcLiveUser *liveUser) {
        profile.userId = liveUser.userId;
        profile.avatarUrlString = liveUser.avatarUrlString;
        profile.nickname = liveUser.nickname;
        //        [AlivcLiveRoomManager stsWithAppUid:liveUser.userId success:NULL failure:NULL];
    } failure:^(NSString * _Nonnull errDes) {
        
    }];
    
}

+ (int)mode{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:AlivcAppServer_Mode] intValue];
}
@end
