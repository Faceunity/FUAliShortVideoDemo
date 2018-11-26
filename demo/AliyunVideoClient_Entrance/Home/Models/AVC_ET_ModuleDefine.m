//
//  AVC_ET_ModuleDefine.m
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/3/22.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AVC_ET_ModuleDefine.h"
#import "NSString+AlivcHelper.h"

@implementation AVC_ET_ModuleDefine

- (instancetype)init{
    self = [self initWithModuleType:AVC_ET_ModuleType_VideoPaly];
    return self;
}

- (instancetype)initWithModuleType:(AVC_ET_ModuleType)type{
    self = [super init];
    if (self) {
        _type = type;
        _name = [AVC_ET_ModuleDefine nameWithModuleType:type];
        _image = [AVC_ET_ModuleDefine imageWithModuleType:type];
    }
    return self;
}

+ (NSString *)nameWithModuleType:(AVC_ET_ModuleType)type{
    switch (type) {
        case AVC_ET_ModuleType_VideoEdit:
            return [@"视频编辑" localString];
            break;
        case AVC_ET_ModuleType_VideoLive:
            return [@"互动直播" localString];
            break;
        case AVC_ET_ModuleType_VideoPaly:
            return [@"视频播放" localString];
            break;
        case AVC_ET_ModuleType_VideoUpload:
            return [@"视频上传" localString];
            break;
        case AVC_ET_ModuleType_VideoShooting:
            return [@"视频拍摄" localString];
            break;
        case AVC_ET_ModuleType_PushFlow:
            return [@"直播推流" localString];
            break;
        case AVC_ET_ModuleType_VideoClip:
            return [@"视频裁剪" localString];
            break;
        case AVC_ET_ModuleType_ShortVideo:
            return [@"趣视频" localString];
            break;
        case AVC_ET_ModuleType_RTC:
            return [@"RTC" localString];
            break;
        case AVC_ET_ModuleType_VideoClip_Basic:
            return [@"视频裁剪" localString];
            break;
        case AVC_ET_ModuleType_VideoShooting_Basic:
            return [@"视频拍摄" localString];
            break;
            
    }
}

+ (UIImage *__nullable)imageWithModuleType:(AVC_ET_ModuleType)type{
    switch (type) {
        case AVC_ET_ModuleType_VideoEdit:
            return [UIImage imageNamed:@"avc_home_videoEdit"];
            break;
        case AVC_ET_ModuleType_VideoLive:
            return [UIImage imageNamed:@"avc_home_videoLive"];
            break;
        case AVC_ET_ModuleType_VideoPaly:
            return [UIImage imageNamed:@"avc_home_videoPlay"];
            break;
        case AVC_ET_ModuleType_VideoUpload:
            return [UIImage imageNamed:@"avc_home_videoUpload"];
            break;
        case AVC_ET_ModuleType_VideoShooting:
            return [UIImage imageNamed:@"avc_home_videoShooting"];
            break;
        case AVC_ET_ModuleType_PushFlow:
            return [UIImage imageNamed:@"avc_home_videoLive"];
            break;
        case AVC_ET_ModuleType_VideoClip:
            return [UIImage imageNamed:@"avc_home_videoShooting"];
            break;
        case AVC_ET_ModuleType_ShortVideo:
            return [UIImage imageNamed:@"avc_home_shortVideo"];
            break;
        case AVC_ET_ModuleType_RTC:
            return [UIImage imageNamed:@"avc_home_videoPlay"];
            break;
        case AVC_ET_ModuleType_VideoShooting_Basic:
            return [UIImage imageNamed:@"avc_home_videoShooting"];
            break;
        case AVC_ET_ModuleType_VideoClip_Basic:
            return [UIImage imageNamed:@"avc_home_videoEdit"];
            break;
    }

}


+ (NSArray <AVC_ET_ModuleDefine *>*)allModules{
    NSMutableArray *mArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < 7; i ++) {
        AVC_ET_ModuleType type = (AVC_ET_ModuleType)i;
        AVC_ET_ModuleDefine *module = [[AVC_ET_ModuleDefine alloc]initWithModuleType:type];
        [mArray addObject:module];
    }
    return (NSArray *)mArray;
}


+ (NSArray <AVC_ET_ModuleDefine *>*)allDemos{
    NSMutableArray *mArray = [[NSMutableArray alloc]init];
    for (int i = 7; i < 12; i ++) {
        AVC_ET_ModuleType type = (AVC_ET_ModuleType)i;
        AVC_ET_ModuleDefine *module = [[AVC_ET_ModuleDefine alloc]initWithModuleType:type];
        [mArray addObject:module];
    }
    return (NSArray *)mArray;
}

@end
