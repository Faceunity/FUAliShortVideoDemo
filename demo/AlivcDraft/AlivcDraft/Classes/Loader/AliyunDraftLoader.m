//
//  AliyunDraftLoader.m
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/20.
//

#import "AliyunDraftLoader.h"
#import "AliyunDraftConfig.h"
#import "AliyunPathManager.h"
#import "AliyunEffectFontManager.h"
#import <AliyunVideoSDKPro/AliyunVideoSDKPro.h>
#import <AFNetworking/AFNetworking.h>
#import <PhotosUI/PhotosUI.h>
#import "AliyunDraftAppResourceLoader.h"
#import "AliyunDraftCloudResourceLoader.h"
#import "AliyunReachability.h"

@interface AliyunDraftLoader()
@property (nonatomic, strong) AFURLSessionManager *manager;
@end

@implementation AliyunDraftLoader

- (instancetype) initWithBaseUrl:(NSString *)baseUrl userId:(NSString *)userId {
    self = [super init];
    if (self) {
        _userId = userId;
        _baseUrl = baseUrl;
    }
    return self;
}

- (BOOL) enabled {
    return _baseUrl.length > 0 && _userId.length > 0;
}

- (NSString *) urlWithPath:(NSString *)path {
    return [NSString stringWithFormat:@"%@/%@/%@", _baseUrl, path, _userId];
}
- (NSString *) requestProjectsUrl {
    return [self urlWithPath:@"get_projects"];
}
- (NSString *) requestUploadUrl {
    return [self urlWithPath:@"upload_resource"];
}
- (NSString *) requestAddProjectUrl {
    return [self urlWithPath:@"add_project"];
}
- (NSString *) requestDeleteProjectUrl {
    return [self urlWithPath:@"delete_project"];
}

- (AFURLSessionManager *) manager {
    if (!_manager) {
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
    }
    return _manager;
}

- (void) requestProjects:(void(^)(id response))completion {
    if (!self.enabled) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(@[]);
        });
        return;
    }
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:self.requestProjectsUrl]];
    NSURLSessionDataTask *task = [self.manager dataTaskWithRequest:req uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        completion([responseObject objectForKey:@"data"]);
    }];
    [task resume];
}

- (void) deleteProejct:(NSString *)projectId {
    if (!self.enabled || projectId.length == 0) {
        return;
    }
    
    NSURLRequest *req = [AFJSONRequestSerializer.serializer requestWithMethod:@"POST" URLString:self.requestDeleteProjectUrl parameters:@{
        @"project_id" : projectId
    } error:nil];
    NSURLSessionDataTask *task = [self.manager dataTaskWithRequest:req uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        NSLog(@"delete project(%@) response : %@, error: %@", projectId, responseObject, error);
    }];
    [task resume];
}

- (NSString *) destinationFilePath:(NSString *)filename {
    NSString *path = [AliyunPathManager.aliyunRootPath stringByAppendingPathComponent:AliyunDraftConfig.Shared.userId];
    [AliyunPathManager makeDirExist:path];
    return [path stringByAppendingPathComponent:filename];
}

- (void) downloadWithUrl:(NSString *)urlString completion:(void(^)(NSString *path))completion {
    if (!self.enabled) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(nil);
            }
        });
        return;
    }
    
    if (urlString.length == 0) {
        completion(nil);
        return;
    }
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        completion(nil);
        return;
    }

    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *task = [self.manager downloadTaskWithRequest:req progress:nil destination:^NSURL * (NSURL *targetPath, NSURLResponse *response) {
        NSString *path = [self destinationFilePath:response.suggestedFilename];
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        completion(filePath.path);
    }];
    [task resume];
}

static BOOL s_checkFontName(NSString *fontName) {
    if (fontName.length == 0) {
        return NO;
    }
    
    UIFont *font = [UIFont fontWithName:fontName size:10];
    return font != nil;
}

- (AEPSource *) registFontSouce:(AEPSource *)fontSource {
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

- (BOOL) tryToLoadFont:(AliyunDraftLoadTask *)task {
    AEPSource *fontSouce = [self registFontSouce:task.resource.source];
    if (fontSouce) {
        [task onSuccess:fontSouce];
        return YES;
    }
    
    if (task.resource.source.URL.length == 0) {
        [task onIgnore];
        return YES;
    }

    return NO;
}

- (void) requestPhotoAuthorization:(void(^)(BOOL hasAuthorized))completion {
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

static NSError * s_createError(NSString *msg) {
    return [NSError errorWithDomain:@"com.aliyun.svideo.draft" code:-1 userInfo:@{
        NSLocalizedDescriptionKey : msg ? msg : @""
    }];
}

- (void) download:(AliyunDraftLoadTask *)task {
    BOOL isFontResource = (task.resource.source.type == AEPSourceType_Font);
    if (isFontResource) {
        if ([self tryToLoadFont:task]) {
            return;
        }
    }
    
    if (task.resource.source.isLocal) {
        [task onIgnore];
        return;
    }
    
    BOOL isMainResource = (task.resource.module == AEPResourceModule_MainVideo);
    void(^onFail)(NSString *) = ^(NSString *msg) {
        if (isMainResource) {
            msg = [NSString stringWithFormat:@"找不到主流资源：%@", msg];
            [task onFailToStopWithError:s_createError(msg)];
        } else if (isFontResource) {
            [task onIgnore];
        } else {
            [task onFailToRemove];
        }
    };
    
    __weak typeof(self) weakSelf = self;
    void(^onSuccess)(NSString *) = ^(NSString *path) {
        [task onSuccess:[task.resource.source createWithPath:path]];
    };
    
    NSString *url = task.resource.source.URL;
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
                onSuccess(cloudInfo.path);
                return;
            }
        }
        
        if ([NSFileManager.defaultManager fileExistsAtPath:appResource.path]) {
            onSuccess(appResource.path);
            return;
        }
        
//        onFail(@"找不到内置资源，请升级App");
        // 改为网络资源进行尝试
        AliyunDraftResourceUrl *urlInfo = [[AliyunDraftResourceUrl alloc] initWithType:appResource.type
                                                                               isInApp:NO
                                                                                   gid:appResource.gid
                                                                                   eid:appResource.eid
                                                                                  name:appResource.name];
        url = urlInfo.url;
    }
    
    if ([AliyunDraftCloudResourceInfo IsCloudUrl:url]) {
        BOOL isSuccess = [AliyunDraftCloudResourceLoader LoadFromUrl:url completion:^(AliyunDraftCloudResourceInfo *info) {
            if ([NSFileManager.defaultManager fileExistsAtPath:info.path]) {
                onSuccess(info.path);
            } else {
                onFail(@"下载OSS资源失败");
            }
        }];
        if (!isSuccess) {
            onFail(@"找不到对应的OSS资源");
        }
        return;
    }
    
    void(^downloadRes)(void) = ^{
        [weakSelf downloadWithUrl:task.resource.source.URL completion:^(NSString *path) {
            if ([NSFileManager.defaultManager fileExistsAtPath:path]) {
                onSuccess(path);
            } else {
                onFail(@"资源下载失败");
            }
        }];
    };
    
    if (task.resource.source.path && [task.resource.source.path containsString:@"mobile/Media/DCIM"]) {
        [self requestPhotoAuthorization:^(BOOL hasAuthorized) {
            if (task.resource.source.isLocal) {
                [task onIgnore];
            } else {
                // 下载保底
                downloadRes();
            }
        }];
        return;
    }
    
    downloadRes();
}

- (void) uploadFile:(NSString *)filePath forTask:(AliyunDraftLoadTask *)task {
    BOOL isMainResource = (task.resource.module == AEPResourceModule_MainVideo);
    void(^onFail)(NSString *) = ^(NSString *msg) {
        if (isMainResource) {
            msg = [NSString stringWithFormat:@"上传主流失败：%@", msg];
            [task onFailToStopWithError:s_createError(msg)];
        } else {
            [task onIgnore];
        }
    };
    
    if (!self.enabled) {
        dispatch_async(dispatch_get_main_queue(), ^{
            onFail(@"请先配置服务器");
        });
        return;
    }
    
    if (![NSFileManager.defaultManager fileExistsAtPath:filePath]) {
        onFail(@"本地资源不存在");
        return;
    }
    
    NSMutableURLRequest *req = [AFHTTPRequestSerializer.serializer multipartFormRequestWithMethod:@"POST"
                                                                                        URLString:self.requestUploadUrl
                                                                                       parameters:nil
                                                                        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"file" error:nil];
    } error:nil];
    
    NSURLSessionUploadTask *uploadTask = [self.manager uploadTaskWithStreamedRequest:req progress:nil completionHandler:^(NSURLResponse *response, NSDictionary *responseObject, NSError *error) {
        if (error) {
            onFail(@"上传出错");
            return;
        }
        
        int code = [[responseObject objectForKey:@"code"] intValue];
        if (code == 0) {
            [task onSuccess:[task.resource.source createWithURL:[responseObject objectForKey:@"data"]]];
        } else {
            onFail([responseObject objectForKey:@"msg"]);
        }
    }];
    [uploadTask resume];
}

- (void) upload:(AliyunDraftLoadTask *)task {
    NSString *path = task.resource.source.path;
    
    if (task.resource.source.type == AEPSourceType_Font) {
        if (![NSFileManager.defaultManager fileExistsAtPath:path]) {
            if (task.resource.source.sourceId.length == 0) {
                [task onIgnore]; // 默认系统字体不处理
                return;
            }
            path = [AliyunEffectFontManager.manager registerFontWithFontName:task.resource.source.sourceId];
        }
    }
    
    BOOL isMainResource = (task.resource.module == AEPResourceModule_MainVideo);
    void(^onFail)(void) = ^{
        if (isMainResource) {
            [task onFailToStopWithError:s_createError(@"上传主流失败，本地资源不存在")];
        } else {
            [task onIgnore];
        }
    };

    if ([AliyunDraftAppResourceInfo IsAppPath:path]) {
        AliyunDraftAppResourceInfo *appResource = [AliyunDraftAppResourceInfo InfoFromPath:path];
        if (appResource) {
            [task onSuccess:[task.resource.source createWithURL:appResource.url]];
        } else {
            onFail();
        }
        return;
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
                    [task onSuccess:[task.resource.source createWithURL:appRes.url]];
                    return;
                }
            }
        }

        BOOL isSuccess = [AliyunDraftCloudResourceLoader LoadFromPath:path completion:^(AliyunDraftCloudResourceInfo *info) {
            if (info) {
                [task onSuccess:[task.resource.source createWithURL:info.url]];
            } else {
                onFail();
            }
        }];
        if (!isSuccess) {
            onFail();
        }
        return;
    }
    
    if ([path hasPrefix:NSHomeDirectory()]) {
        if (![NSFileManager.defaultManager fileExistsAtPath:path]) {
            onFail();
            return;
        }
        
        [self uploadFile:path forTask:task];
        return;
    }
    
    [self requestPhotoAuthorization:^(BOOL hasAuthorized) {
        if ([NSFileManager.defaultManager fileExistsAtPath:path]) {
            [self uploadFile:path forTask:task];
        } else {
            onFail();
        }
    }];
}

- (void) addDraft:(AliyunDraftInfo *)draft projectFile:(NSString *)projectFile completion:(void(^)(NSString *projectId, NSString *projectUrl, NSError *error))completion {
    if (!self.enabled) {
        if (completion) {
            completion(nil, nil, s_createError(@"请先配置服务器"));
        }
        return;
    }
    
    if (!projectFile || ![NSFileManager.defaultManager fileExistsAtPath:projectFile]) {
        completion(nil, nil, s_createError(@"工程文件不存在"));
        return;
    }
    
    NSMutableURLRequest *req = [AFHTTPRequestSerializer.serializer multipartFormRequestWithMethod:@"POST"
                                                                                        URLString:self.requestAddProjectUrl
                                                                                       parameters:nil
                                                                        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:projectFile] name:@"file" error:nil];
        [formData appendPartWithFormData:[draft.cover.URL dataUsingEncoding:NSUTF8StringEncoding] name:@"cover"];
        [formData appendPartWithFormData:[draft.title dataUsingEncoding:NSUTF8StringEncoding] name:@"name"];
        [formData appendPartWithFormData:[@(draft.size * 1024).stringValue dataUsingEncoding:NSUTF8StringEncoding] name:@"file_size"];
        [formData appendPartWithFormData:[@((int)draft.duration).stringValue dataUsingEncoding:NSUTF8StringEncoding] name:@"duration"];
        [formData appendPartWithFormData:[draft.modifiedTime dataUsingEncoding:NSUTF8StringEncoding] name:@"modified_time"];
    } error:nil];
    
    NSURLSessionUploadTask *uploadTask = [self.manager uploadTaskWithStreamedRequest:req progress:nil completionHandler:^(NSURLResponse *response, NSDictionary *responseObject, NSError *error) {
        if (error) {
            completion(nil, nil, error);
            return;
        }
        
        int code = [[responseObject objectForKey:@"code"] intValue];
        if (code == 0) {
            NSDictionary *data = [responseObject objectForKey:@"data"];
            NSString *projectId = [data objectForKey:@"id"];
            NSString *projectUrl = [data objectForKey:@"project_url"];
            completion(projectId, projectUrl, nil);
        } else {
            NSString *msg = [NSString stringWithFormat:@"上传工程失败：%@", [responseObject objectForKey:@"msg"]];
            NSLog(@"上传工程失败：%@", msg);
            completion(nil, nil, s_createError(msg));
        }
    }];
    [uploadTask resume];
}

@end
