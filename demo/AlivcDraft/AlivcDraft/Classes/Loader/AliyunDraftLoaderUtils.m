//
//  AliyunDraftLoaderUtils.m
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/21.
//

#import "AliyunDraftLoaderUtils.h"
#import "NSString+AlivcHelper.h"

@implementation AliyunDraftLoaderUtils

+ (NSString *) TypeToString:(AliyunDraftResourceType)type {
    switch (type) {
        case AliyunDraftResourceType_AnimationEffect: return @"animation_effects"; // 特效
        case AliyunDraftResourceType_Bubble: return @"bubble"; // 气泡字
        case AliyunDraftResourceType_Filter: return @"filter"; // 滤镜
        case AliyunDraftResourceType_MV: return @"mv"; // MV
        case AliyunDraftResourceType_Sticker: return @"sticker"; // 贴纸
        case AliyunDraftResourceType_Font: return @"font"; // 字体
        case AliyunDraftResourceType_Music: return @"music"; // 音乐
        case AliyunDraftResourceType_Transition: return @"transition"; // 转场
        case AliyunDraftResourceType_Caption: return @"caption"; // 花字
        case AliyunDraftResourceType_LutFilter: return @"lut_filter"; // 滤镜
        default: return nil;
    }
}

+ (AliyunDraftResourceType) StringToType:(NSString *)str {
    for (int i = 0; i < AliyunDraftResourceType_Unknown; ++i) {
        NSString *result = [self TypeToString:i];
        if ([str isEqualToString:result]) {
            return i;
        }
    }
    return AliyunDraftResourceType_Unknown;
}

@end

@implementation AliyunDraftResourceUrl

+ (NSString *) Scheme { return @"alivc_resource"; }
+ (NSString *) AppHost { return @"app"; }
+ (NSString *) CloudHost { return @"cloud"; }
+ (NSString *) UrlWithHost:(NSString *)host {
    return [NSString stringWithFormat:@"%@://%@", self.Scheme, host];
}
+ (NSString *) AppUrl { return [self UrlWithHost:self.AppHost]; }
+ (NSString *) CloudUrl { return [self UrlWithHost:self.CloudHost]; }

- (instancetype) initWithUrl:(NSString *)urlString {
    BOOL isApp = NO;
    if ([urlString hasPrefix:AliyunDraftResourceUrl.AppUrl]) {
        isApp = YES;
    } else if ([urlString hasPrefix:AliyunDraftResourceUrl.CloudUrl]) {
        isApp = NO;
    } else {
        return nil;
    }
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        return nil;
    }
    
    NSDictionary *query = url.query.aliyun_urlParseQuery;
    if (!query) {
        return nil;
    }
    AliyunDraftResourceType type = [AliyunDraftLoaderUtils StringToType:[query objectForKey:@"type"]];
    if (type == AliyunDraftResourceType_Unknown) {
        return nil;
    }

    return [self initWithType:type
                      isInApp:isApp
                          gid:[query objectForKey:@"gid"]
                          eid:[query objectForKey:@"id"]
                         name:[query objectForKey:@"name"]];
}

static NSString * s_generateUrl(BOOL isInApp, AliyunDraftResourceType type, NSString *gid, NSString *eid, NSString *name) {
    NSString *url = isInApp ? AliyunDraftResourceUrl.AppUrl : AliyunDraftResourceUrl.CloudUrl;
    url = [NSString stringWithFormat:@"%@?type=%@", url, [AliyunDraftLoaderUtils TypeToString:type]];
    if (gid.length > 0) {
        url = [NSString stringWithFormat:@"%@&gid=%@", url, gid.aliyun_urlEncode];
    }
    if (eid.length > 0) {
        url = [NSString stringWithFormat:@"%@&id=%@", url, eid.aliyun_urlEncode];
    }
    if (name.length > 0) {
        url = [NSString stringWithFormat:@"%@&name=%@", url, name.aliyun_urlEncode];
    }
    return url;
}

- (instancetype) initWithType:(AliyunDraftResourceType)type
                      isInApp:(BOOL)isInApp
                          gid:(NSString *)gid
                          eid:(NSString *)eid
                         name:(NSString *)name {
    self = [super init];
    if (self) {
        _type = type;
        _isInApp = isInApp;
        _gid = gid;
        _eid = eid;
        _name = name;
        _url = s_generateUrl(isInApp, type, gid, eid, name);
    }
    return self;
}

@end

@implementation AliyunDraftResourceId
@end
