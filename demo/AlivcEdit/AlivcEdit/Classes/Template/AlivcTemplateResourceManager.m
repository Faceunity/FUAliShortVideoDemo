//
//  AlivcTemplateResourceManager.m
//  AFNetworking
//
//  Created by Bingo on 2021/11/22.
//

#import "AlivcTemplateResourceManager.h"
#import "AliyunEffectFontManager.h"
#import "AliyunDraftAppResourceLoader.h"
#import "AliyunDraftCloudResourceLoader.h"
#import "NSString+AlivcHelper.h"
#import <Photos/PHPhotoLibrary.h>
#import <AFNetworking/AFNetworking.h>

@implementation AlivcTemplateResourceManager

+ (NSString *)hardcodeTemplatePath {
    NSString *bundle = [[NSBundle mainBundle] bundlePath];
    NSString *str = [bundle stringByAppendingPathComponent:@"Template"];
    return str;
}

+ (NSString *)rootPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"com.aliyun.video"];
}

// Documents/com.aliyun.video/resource
+ (NSString *)localResourcePath {
    return [[self rootPath] stringByAppendingPathComponent:@"resource"];
}

// Documents/com.aliyun.video/resource/template
+ (NSString *)localTemplatePath {
    return [[self localResourcePath] stringByAppendingPathComponent:@"template"];
}

// Documents/com.aliyun.video/template_build
+ (NSString *)builtTemplatePath {
    return [[self rootPath] stringByAppendingPathComponent:@"template_build"];
}

// Documents/com.aliyun.video/template_export
+ (NSString *)exportTemplatePath {
    return [[self rootPath] stringByAppendingPathComponent:@"template_export"];
}

// Documents/com.aliyun.video/template_project
+ (NSString *)projectTemplatePath {
    return [[self rootPath] stringByAppendingPathComponent:@"template_project"];
}

// Documents/com.aliyun.video/template_apply
+ (NSString *)applyTemplatePath {
    return [[self rootPath] stringByAppendingPathComponent:@"template_apply"];
}

// Documents/com.aliyun.video/template_download
+ (NSString *)resourceDownloadPath {
    return [[self rootPath] stringByAppendingPathComponent:@"template_download"];
}

static NSError * s_createError(NSString *msg) {
    return [NSError errorWithDomain:@"com.aliyun.svideo.template.resource" code:-10000 userInfo:@{
        NSLocalizedDescriptionKey : msg ? msg : @""
    }];
}

// 导入时，要有合格的url（http或自定义协议，通过自定义协议组装的路径必须正确），reset=YES时忽略已有的path
+ (AliyunResourceImport *)templateResourceImport:(NSString *)taskPath reset:(BOOL)reset {
    AliyunResourceImport *import = [AliyunResourceImport new];
    import.resourceLoadTasksCallback = ^(id taskManager, NSArray<AliyunTemplateResourceLoadTask *> *tasks) {
        [tasks enumerateObjectsUsingBlock:^(AliyunTemplateResourceLoadTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if (task.resource.source.path.length > 0 && !reset) {
                [task onIgnore];
            }
            else {
                NSString *url = task.resource.source.URL;
                if (url.length > 0) {
                    NSString *path = nil;
                    if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) {
                        [task onIgnore];
                        return;
                    }
                    // alivc_resource://relation
                    if ([url hasPrefix:@"alivc_resource://relation?path="]) {
                        path = [taskPath stringByAppendingPathComponent:[url substringFromIndex:@"alivc_resource://relation?path=".length]];
                    }
                    else {
                        path = url;
                    }
                    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                        [task onFail:[NSError errorWithDomain:@"" code:-4 userInfo:nil]];
                        return;
                    }
                    
                    AEPSource *newSource = [AEPSource SourceWithType:task.resource.source.type sourceId:task.resource.source.sourceId url:nil path:path];
                    [task onSuccess:newSource];
                }
                else {
                    [task onFail:[NSError errorWithDomain:@"" code:-5 userInfo:nil]];
                }
            }
        }];
    };
    return import;
}

static BOOL s_checkFontName(NSString *fontName) {
    if (fontName.length == 0) {
        return NO;
    }
    
    UIFont *font = [UIFont fontWithName:fontName size:10];
    return font != nil;
}

+ (AEPSource *)registFontSouce:(AEPSource *)fontSource {
    if (s_checkFontName(fontSource.sourceId)) {
        return fontSource;
    }
    
    NSString *fontPath = nil;
    if (fontSource.sourceId.length > 0) {
        fontPath = [AliyunEffectFontManager.manager findFontPathWithName:fontSource.sourceId];
    }
    
    if (![NSFileManager.defaultManager fileExistsAtPath:fontPath]) {
        fontPath = fontSource.path;
    }
    
    if (![NSFileManager.defaultManager fileExistsAtPath:fontPath]) {
        return nil;
    }
    
    AEPSource *resultSource = [fontSource createWithPath:fontPath];
    NSString *registerName = [AliyunEffectFontManager.manager registerFontWithFontPath:fontPath];
    if (s_checkFontName(registerName)) {
        return [resultSource createWithSourceId:registerName];
    }
    
    return nil;
}

+ (AliyunResourceImport *)projectResourceImport:(NSString *)taskPath reset:(BOOL)reset shouldDownload:(BOOL)shouldDownload {
    
    AliyunResourceImport *import = [AliyunResourceImport new];
    import.resourceLoadTasksCallback = ^(id taskManager, NSArray<AliyunTemplateResourceLoadTask *> *tasks) {
        
        void(^onSuccess)(AliyunTemplateResourceLoadTask *, NSString *, NSString *) = ^(AliyunTemplateResourceLoadTask *task, NSString *path, NSString *url) {
            AEPSource *newSource = [AEPSource SourceWithType:task.resource.source.type sourceId:task.resource.source.sourceId url:nil path:path];
            [task onSuccess:newSource];
        };
        
        void(^onFail)(AliyunTemplateResourceLoadTask *, NSString *) = ^(AliyunTemplateResourceLoadTask *task, NSString *desc) {
            [task onFail:s_createError(desc)];
        };
        
        [tasks enumerateObjectsUsingBlock:^(AliyunTemplateResourceLoadTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
           
            // path已存在情况处理
            if (!reset && task.resource.source.path.length > 0) {
                if ([task.resource.source.path containsString:@"mobile/Media/DCIM"]) {
                    [self requestPhotoAuthorization:^(BOOL hasAuthorized) {
                        if (task.resource.source.isLocal && hasAuthorized) {
                            [task onIgnore];
                        } else {
                            onFail(task, @"资源未授权");
                        }
                    }];
                    return;
                }
                else if (task.resource.source.isLocal) {
                    [task onIgnore];
                    return;
                }
            }
            
            // 字体
            if (task.resource.source.type == AEPSourceType_Font) {
                AEPSource *fontSouce = [self registFontSouce:task.resource.source];
                if (fontSouce) {
                    [task onSuccess:fontSouce];
                    return;
                }
                
                if (task.resource.source.URL.length == 0) {
                    [task onIgnore];
                    return;
                }
            }
            
            // 本地内置资源
            NSString *url = task.resource.source.URL;
            if (url.length == 0) {
                [task onIgnore];
                return;
            }
            if ([AliyunDraftAppResourceInfo IsAppUrl:url]) {
                AliyunDraftAppResourceInfo *appResource = [AliyunDraftAppResourceInfo InfoFromUrl:url];
                if (appResource.type == AliyunDraftResourceType_MV || appResource.type == AliyunDraftResourceType_Bubble || appResource.type == AliyunDraftResourceType_Sticker) {
                    // 兼容editviewcontroller，如果是mv/bubble/sticker使用cloud路径代替
                    AliyunDraftCloudResourceInfo *cloudInfo = [[AliyunDraftCloudResourceInfo alloc] initWithType:appResource.type
                                                                                                         isInApp:NO
                                                                                                             gid:appResource.gid
                                                                                                             eid:appResource.eid
                                                                                                            name:appResource.name];
                    if ([NSFileManager.defaultManager fileExistsAtPath:cloudInfo.path]) {
                        onSuccess(task, cloudInfo.path, url);
                        return;
                    }
                }
                
                if ([NSFileManager.defaultManager fileExistsAtPath:appResource.path]) {
                    onSuccess(task, appResource.path, url);
                    return;
                }
                
                // 改为网络资源进行尝试
                AliyunDraftResourceUrl *urlInfo = [[AliyunDraftResourceUrl alloc] initWithType:appResource.type
                                                                                       isInApp:NO
                                                                                           gid:appResource.gid
                                                                                           eid:appResource.eid
                                                                                          name:appResource.name];
                url = urlInfo.url;
            }
            
            // 本地下载资源
            if ([AliyunDraftCloudResourceInfo IsCloudUrl:url]) {
                if (shouldDownload) {
                    BOOL isSuccess = [AliyunDraftCloudResourceLoader LoadFromUrl:url completion:^(AliyunDraftCloudResourceInfo *info) {
                        if ([NSFileManager.defaultManager fileExistsAtPath:info.path]) {
                            onSuccess(task, info.path, url);
                        } else {
                            onFail(task, @"下载OSS资源失败");
                        }
                    }];
                    if (!isSuccess) {
                        onFail(task, @"找不到对应的OSS资源");
                    }
                    return;
                }
                else {
                    [task onIgnore];
                }
            }
            
            // 本地相对资源
            if ([url hasPrefix:@"alivc_resource://relation?path="]) {
                NSString *path = [taskPath stringByAppendingPathComponent:[url substringFromIndex:@"alivc_resource://relation?path=".length]];
                if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                    [task onFail:[NSError errorWithDomain:@"" code:-4 userInfo:nil]];
                    onFail(task, @"本地不存在流资源");
                    return;
                }
                
                onSuccess(task, path, url);
                return;
            }
            
            if (shouldDownload) {
                [self downloadWithUrl:task.resource.source.URL completion:^(NSString *path) {
                    if ([NSFileManager.defaultManager fileExistsAtPath:path]) {
                        onSuccess(task, path, url);
                    } else {
                        onFail(task, @"资源下载失败");
                    }
                }];
            }
            else {
                [task onIgnore];
            }
            
        }];
        
        
    };
    return import;
}

// 导出时需要有合格的path，或者http开头的url，其他的会失败
+ (AliyunResourceExport *)templateResourceExport:(NSString *)taskPath {
    AliyunResourceExport *export = [AliyunResourceExport new];
    export.resourceLoadTasksCallback = ^(AliyunResourceExport *exporter, NSArray<AliyunTemplateResourceLoadTask *> *tasks) {
        
        [tasks enumerateObjectsUsingBlock:^(AliyunTemplateResourceLoadTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *url = task.resource.source.URL;
            if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) {
                AEPSource *newSource = [AEPSource SourceWithType:task.resource.source.type sourceId:task.resource.source.sourceId url:task.resource.source.URL path:nil];
                [task onSuccess:newSource];
            }
            else {
                NSString *path = task.resource.source.path;
                if (path.length > 0){
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    if (![fileManager fileExistsAtPath:path]) {
                        [task onFail:[NSError errorWithDomain:@"" code:-1 userInfo:nil]];
                        return;
                    }
                    NSString *rootDir = [taskPath stringByAppendingString:@"/"];
                    if ([path hasPrefix:rootDir]) {
                        path = [path substringFromIndex:rootDir.length];
                    }
                    else {
                        NSString *fileName = [path lastPathComponent];
                        NSString *toPath = [rootDir stringByAppendingPathComponent:fileName];
                        NSError *err = nil;
                        if (![fileManager fileExistsAtPath:toPath])
                        {
                            [fileManager copyItemAtPath:path toPath:toPath error:&err];
                            if (err) {
                                [task onFail:[NSError errorWithDomain:@"" code:-2 userInfo:nil]];
                                return;
                            }
                        }
                        path = fileName;
                    }
                    NSString *url = [NSString stringWithFormat:@"%@%@", @"alivc_resource://relation?path=", path];
                    AEPSource *newSource = [AEPSource SourceWithType:task.resource.source.type sourceId:task.resource.source.sourceId url:url path:nil];
                    [task onSuccess:newSource];
                }
                else {
                    [task onFail:[NSError errorWithDomain:@"" code:-3 userInfo:nil]];
                }
            }
        }];
    };
    return export;
}

+ (AliyunResourceExport *)projectResourceExport:(NSString *)taskPath {
    AliyunResourceExport *export = [AliyunResourceExport new];
    export.resourceLoadTasksCallback = ^(id taskManager, NSArray<AliyunTemplateResourceLoadTask *> *tasks) {

        for (AliyunTemplateResourceLoadTask *task in tasks) {
            
            AEPResourceModel *resource = (AEPResourceModel *)task.resource;
            NSString *path = resource.source.path;
            if (path.length == 0) {
                [task onIgnore];
                continue;
            }
            if (resource.source.type == AEPSourceType_Font) {
                if (![NSFileManager.defaultManager fileExistsAtPath:path]) {
                    if (resource.source.sourceId.length == 0) {
                        [task onIgnore]; // 默认系统字体不处理
                        continue;
                    }
                    path = [AliyunEffectFontManager.manager registerFontWithFontName:resource.source.sourceId];
                }
            }

            if ([AliyunDraftAppResourceInfo IsAppPath:path]) {
                AliyunDraftAppResourceInfo *appResource = [AliyunDraftAppResourceInfo InfoFromPath:path];
                if (appResource) {
                    AEPSource *newSource = [AEPSource SourceWithType:task.resource.source.type sourceId:task.resource.source.sourceId url:appResource.url path:nil];
                    [task onSuccess:newSource];
                    continue;
                }
                else {
                    [task onFail:s_createError(@"内置资源不存在")];
                    return;
                }
            }

            if ([AliyunDraftCloudResourceInfo IsCloudPath:path]) {
                // 先检查是否从内置资源转换而来
                AliyunDraftResourceType resType = [AliyunDraftCloudResourceInfo PathToType:path];
                NSString *cloudRootPath = [AliyunDraftCloudResourceInfo RootPathWithType:resType];
                NSString *appRootPath = [AliyunDraftAppResourceInfo RootPathWithType:resType];
                if (appRootPath.length > 0) {
                    NSString *appPath = [path stringByReplacingOccurrencesOfString:cloudRootPath withString:appRootPath];
                    if ([NSFileManager.defaultManager fileExistsAtPath:appPath]) {
                        AliyunDraftAppResourceInfo *appRes = [AliyunDraftAppResourceInfo InfoFromPath:appPath];
                        if (appRes) {
                            AEPSource *newSource = [AEPSource SourceWithType:task.resource.source.type sourceId:task.resource.source.sourceId url:appRes.url path:nil];
                            [task onSuccess:newSource];
                            continue;
                        }
                    }
                }

                BOOL isSuccess = [AliyunDraftCloudResourceLoader LoadFromPath:path completion:^(AliyunDraftCloudResourceInfo *info) {
                    if (info) {
                        AEPSource *newSource = [AEPSource SourceWithType:task.resource.source.type sourceId:task.resource.source.sourceId url:info.url path:nil];
                        [task onSuccess:newSource];
                    } else {
                        [task onFail:s_createError(@"本地资源不存在")];
                    }
                }];
                if (!isSuccess) {
                    [task onFail:s_createError(@"本地资源不存在")];
                    return;
                }
                continue;
            }
            
            if ([path hasPrefix:NSHomeDirectory()]) {
                if (![NSFileManager.defaultManager fileExistsAtPath:path]) {
                    [task onFail:s_createError(@"本地媒体资源不存在")];
                    return;
                }
                
                [self copyFile:path toDir:taskPath forTask:task];
                continue;
            }
            
            [self requestPhotoAuthorization:^(BOOL hasAuthorized) {
                if ([NSFileManager.defaultManager fileExistsAtPath:path]) {
                    [self copyFile:path toDir:taskPath forTask:task];
                } else {
                    [task onFail:s_createError(@"本地媒体资源不存在")];
                }
            }];
            continue;
        }
    };
    
    
    return export;
}

+ (void)copyFile:(NSString *)filePath toDir:(NSString *)taskPath forTask:(AliyunTemplateResourceLoadTask *)task {
    AEPResourceModel *resource = (AEPResourceModel *)task.resource;
    BOOL isMainResource = (resource.module == AEPResourceModule_MainVideo);
    void(^onFail)(NSString *) = ^(NSString *msg) {
        if (isMainResource) {
            msg = [NSString stringWithFormat:@"拷贝主流资源失败：%@", msg];
            [task onFail:s_createError(msg)];
        } else {
            [task onIgnore];
        }
    };
    
    NSString *rootDir = [taskPath stringByAppendingString:@"/"];
    if ([filePath hasPrefix:rootDir]) {
        filePath = [filePath substringFromIndex:rootDir.length];
    }
    else {
        NSString *fileName = [filePath lastPathComponent];
        NSString *toPath = [rootDir stringByAppendingPathComponent:fileName];
        NSError *err = nil;
        [[NSFileManager defaultManager] copyItemAtPath:filePath toPath:toPath error:&err];
        if (err) {
            onFail(err.description);
            return;
        }
        filePath = fileName;
    }
    NSString *url = [NSString stringWithFormat:@"%@%@", @"alivc_resource://relation?path=", filePath];
    AEPSource *newSource = [AEPSource SourceWithType:task.resource.source.type sourceId:task.resource.source.sourceId url:url path:nil];
    [task onSuccess:newSource];
}

+ (void) requestPhotoAuthorization:(void(^)(BOOL hasAuthorized))completion {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        void(^mainThreadLoad)(BOOL) = ^(BOOL hasAuthorized) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(hasAuthorized);
            });
        };
        
        if (status == PHAuthorizationStatusAuthorized) {
            mainThreadLoad(YES);
        } else {
            mainThreadLoad(NO);
        }
    }];
}


+ (AFURLSessionManager *) manager {
    static AFURLSessionManager *_urlManager = nil;
    if (!_urlManager) {
        _urlManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
    }
    return _urlManager;
}

+ (void)downloadWithUrl:(NSString *)urlString completion:(void(^)(NSString *path))completion {

    if (urlString.length == 0) {
        if (completion) {
            completion(nil);
        }
        return;
    }

    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSString *dir = [self resourceDownloadPath];
    if (![myFileManager fileExistsAtPath:dir]) {
        [myFileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *fileNamePre = [NSString aliyun_MD5:urlString];
    NSArray *paths = [myFileManager contentsOfDirectoryAtPath:dir error:nil];
    for (NSString *path in paths) {
        if ([path hasPrefix:fileNamePre]) {
            if (completion) {
                completion([dir stringByAppendingPathComponent:path]);
            }
            return;
        }
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        if (completion) {
            completion(nil);
        }
        return;
    }

    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *task = [self.manager downloadTaskWithRequest:req progress:nil destination:^NSURL * (NSURL *targetPath, NSURLResponse *response) {
        NSString *path = [[self resourceDownloadPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@", fileNamePre, response.suggestedFilename]];
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSString *path = filePath.path;
        if ([path hasPrefix:@"file://"]) {
            path = [path substringFromIndex:@"file://".length];
        }
        completion(path);
    }];
    [task resume];
}

@end
