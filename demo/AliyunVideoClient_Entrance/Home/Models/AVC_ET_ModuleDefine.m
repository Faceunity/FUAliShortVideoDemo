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
        case AVC_ET_ModuleType_SmartVideo:
            return [@"趣视频" localString];
            break;
        case AVC_ET_ModuleType_RTC:
            return [@"视频通话" localString];
            
        case AVC_ET_ModuleType_RTC_Audio:
            return [@"语音通话" localString];
            
            break;
        case AVC_ET_ModuleType_VideoClip_Basic:
            return [@"视频裁剪" localString];
            break;
        case AVC_ET_ModuleType_VideoShooting_Basic:
            return [@"视频拍摄" localString];
            break;
        case AVC_ET_ModuleType_Smartboard:
            return [@"互动白板" localString];
            break;
        case AVC_ET_ModuleType_RaceBeauty:
            return @"美颜美型";
            break;
        case AVC_ET_ModuleType_FaceDetect:
            return @"人脸识别";
            break;
        case AVC_ET_ModuleType_MetalPreview:
            return @"Metal预览";
            break;
        case AVC_ET_ModuleType_VideoPlayConfig:
            return [@"视频播放" localString];
        case AVC_ET_ModuleType_VideoPlayList:
            return [@"播放列表" localString];
        case AVC_ET_ModuleType_VideoPlayShift:
            return [@"直播时移" localString];
        case AVC_ET_ModuleType_Draft:
            return [@"草稿" localString];
        case AVC_ET_ModuleType_Template:
            return [@"剪同款" localString];
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
            return [UIImage imageNamed:@"avc_home_videoCrop"];
            break;
        case AVC_ET_ModuleType_SmartVideo:
            return [UIImage imageNamed:@"avc_home_shortVideo"];
            break;
        case AVC_ET_ModuleType_RTC:
            return [UIImage imageNamed:@"avc_home_rtc_video"];
            
        case AVC_ET_ModuleType_RTC_Audio:
            return [UIImage imageNamed:@"avc_home_rtc_audio"];
            break;
        case AVC_ET_ModuleType_VideoShooting_Basic:
            return [UIImage imageNamed:@"avc_home_videoShooting"];
            break;
        case AVC_ET_ModuleType_VideoClip_Basic:
            return [UIImage imageNamed:@"avc_home_videoCrop"];
            break;
        case AVC_ET_ModuleType_Smartboard:
            return [UIImage imageNamed:@"avc_home_videoEdit"];
            break;
        case AVC_ET_ModuleType_RaceBeauty:
            return [UIImage imageNamed:@"beauty"];
            break;
        case AVC_ET_ModuleType_FaceDetect:
            return [UIImage imageNamed:@"avc_home_shortVideo"];
            break;
        case AVC_ET_ModuleType_MetalPreview:
            return [UIImage imageNamed:@"avc_home_shortVideo"];
            break;
        case AVC_ET_ModuleType_VideoPlayConfig:
            return [UIImage imageNamed:@"avc_home_videoPlay"];
        case AVC_ET_ModuleType_VideoPlayList:
            return [UIImage imageNamed:@"avc_home_videoPlay"];
        case AVC_ET_ModuleType_VideoPlayShift:
            return [UIImage imageNamed:@"avc_home_videoPlay"];
        case AVC_ET_ModuleType_Draft:
            return [UIImage imageNamed:@"avc_home_shortVideo"];
        case AVC_ET_ModuleType_Template:
            return [UIImage imageNamed:@"avc_home_shortVideo"];
    }

}

@end
