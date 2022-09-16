//
//  AliyunDraftAppResourceLoader.m
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/20.
//

#import "AliyunDraftAppResourceLoader.h"
#import "NSString+AlivcHelper.h"

#define ALIVC_RESOURCE_HOST "app"
#define ALIVC_RESOURCE_URL ALIVC_RESOURCE_SCHEME "://" ALIVC_RESOURCE_HOST

@implementation AliyunDraftAppResourceInfo

+ (NSString *) RootPathWithType:(AliyunDraftResourceType)type {
    NSString *path = NSBundle.mainBundle.resourcePath;
    switch (type) {
        case AliyunDraftResourceType_AnimationEffect: {
            return [path stringByAppendingPathComponent:@"Animation_Effects"];
        }
        case AliyunDraftResourceType_Bubble: {
            return [path stringByAppendingPathComponent:@"Caption"];
        }
        case AliyunDraftResourceType_Filter: {
            return [path stringByAppendingPathComponent:@"Filter"];
        }
        case AliyunDraftResourceType_MV: {
            return [path stringByAppendingPathComponent:@"MV"];
        }
        case AliyunDraftResourceType_Sticker: {
            return [path stringByAppendingPathComponent:@"Sticker"];
        }
        case AliyunDraftResourceType_Caption: {
            return [path stringByAppendingPathComponent:@"FlowerFont.bundle/font_effect"];
        }
        case AliyunDraftResourceType_LutFilter: {
            return [path stringByAppendingPathComponent:@"LutFilter.bundle"];
        }
        default: return nil;
    }
}

+ (AliyunDraftResourceType) PathToType:(NSString *)path {
    for (int i = 0; i < AliyunDraftResourceType_Unknown; ++i) {
        NSString *rootPath = [self RootPathWithType:(AliyunDraftResourceType)i];
        if (rootPath && [path hasPrefix:rootPath]) {
            return i;
        }
    }
    return AliyunDraftResourceType_Unknown;
}

#define MV_PATH @"103-beautiful life/beautiful life"
#define MV_ID @"103"

+ (AliyunDraftResourceId *) ResourceIdWithPath:(NSString *)path type:(AliyunDraftResourceType)type {
    AliyunDraftResourceId *resId = [AliyunDraftResourceId new];
    if (type == AliyunDraftResourceType_Sticker || type == AliyunDraftResourceType_Bubble || type == AliyunDraftResourceType_LutFilter) {
        path = path.stringByDeletingLastPathComponent;
        NSString *tmp = path.lastPathComponent;
        NSArray *ids = [tmp componentsSeparatedByString:@"-"];
        if (ids.count > 1) {
            resId.eid = ids.firstObject;
        }
        path = path.stringByDeletingLastPathComponent;
        tmp = path.lastPathComponent;
        ids = [tmp componentsSeparatedByString:@"-"];
        if (ids.count > 1) {
            resId.gid = ids.firstObject;
        }
    } else {
        resId.eid = path.lastPathComponent;
    }
    
    if (type == AliyunDraftResourceType_MV) {
        resId.gid = MV_ID;
    } else if (type == AliyunDraftResourceType_AnimationEffect) {
        path = path.stringByDeletingLastPathComponent;
        NSArray *ids = [path.lastPathComponent componentsSeparatedByString:@"-"];
        if (ids.count > 1) {
            resId.gid = ids.firstObject;
        }
    }
    return resId;
}

+ (BOOL) IsAppPath:(NSString *)path {
    AliyunDraftResourceType type = [self PathToType:path];
    return (type != AliyunDraftResourceType_Unknown);
}

+ (BOOL) IsAppUrl:(NSString *)url {
    return [url hasPrefix:AliyunDraftResourceUrl.AppUrl];
}

+ (AliyunDraftAppResourceInfo *) InfoFromPath:(NSString *)path
{
    AliyunDraftResourceType type = [self PathToType:path];
    if (type == AliyunDraftResourceType_Unknown) {
        return nil;
    }
    
    AliyunDraftResourceId *resId = [self ResourceIdWithPath:path type:type];
    return [[AliyunDraftAppResourceInfo alloc] initWithType:type isInApp:YES gid:resId.gid eid:resId.eid name:nil];
}

+ (AliyunDraftAppResourceInfo *) InfoFromUrl:(NSString *)urlString
{
    AliyunDraftAppResourceInfo *info = [[AliyunDraftAppResourceInfo alloc] initWithUrl:urlString];
    if (info && info.isInApp) {
        return info;
    }
    return nil;
}

static NSString * s_findFileInDirWithPrefix(NSString *dirPath, NSString *namePrefix) {
    NSArray *files = [NSFileManager.defaultManager enumeratorAtPath:dirPath].allObjects;
    if (files.count == 0) {
        return nil;
    }
    
    if (namePrefix.length == 0) {
        return files.firstObject;
    }
    
    for (NSString *fileName in files) {
        if ([fileName hasPrefix:namePrefix]) {
            return fileName;
        }
    }
    
    return nil;
}

+ (NSString *) RealPathWithType:(AliyunDraftResourceType)type gid:(NSString *)gid eid:(NSString *)eid {
    NSString *path = [self RootPathWithType:type];
    
    if (type == AliyunDraftResourceType_Sticker || type == AliyunDraftResourceType_Bubble || type == AliyunDraftResourceType_LutFilter) {
        NSString *gPath = s_findFileInDirWithPrefix(path, [NSString stringWithFormat:@"%@-", gid]);
        if (!gPath) {
            return nil;
        }
        gPath = [path stringByAppendingPathComponent:gPath];
        NSString *ePath = s_findFileInDirWithPrefix(gPath, [NSString stringWithFormat:@"%@-", eid]);
        if (!ePath) {
            return nil;
        }
        ePath = [gPath stringByAppendingPathComponent:ePath];
        NSString *lastPath = nil;
        if (type == AliyunDraftResourceType_LutFilter) {
            lastPath = @"lookup.png";
        }
        else {
            lastPath = s_findFileInDirWithPrefix(ePath, nil);
        }
        if (!lastPath) {
            return nil;
        }
        return [ePath stringByAppendingPathComponent:lastPath];
    }
    
    if (type == AliyunDraftResourceType_MV && (!gid || [gid isEqualToString:MV_ID])) {
        path = [path stringByAppendingPathComponent:MV_PATH];
    }
    
    if (type == AliyunDraftResourceType_AnimationEffect) {
        NSString *gPath = s_findFileInDirWithPrefix(path, [NSString stringWithFormat:@"%@-", gid]);
        if (!gPath) {
            return nil;
        }
        path = [path stringByAppendingPathComponent:gPath];
    }
    
    path = [path stringByAppendingPathComponent:eid];
    if ([NSFileManager.defaultManager fileExistsAtPath:path]) {
        return path;
    }
    return nil;
}

- (instancetype) initWithType:(AliyunDraftResourceType)type
                      isInApp:(BOOL)isInApp
                          gid:(NSString *)gid
                          eid:(NSString *)eid
                         name:(NSString *)name {
    self = [super initWithType:type isInApp:isInApp gid:gid eid:eid name:name];
    if (self && isInApp) {
        _path = [AliyunDraftAppResourceInfo RealPathWithType:type gid:gid eid:eid];
    }
    return self;
}

@end
