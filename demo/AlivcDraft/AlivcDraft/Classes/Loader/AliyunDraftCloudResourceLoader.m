//
//  AliyunDraftCloudResourceLoader.m
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/21.
//

#import "AliyunDraftCloudResourceLoader.h"
#import "NSString+AlivcHelper.h"
#import "AliyunEffectResourceModel.h"
#import "AliyunResourceFontDownload.h"
#import "AliyunResourceRequestManager.h"
#import "AliyunResourceDownloadManager.h"
#import "AliyunMusicPickModel.h"
#import "AliyunMusicPickViewController.h"
#import "AliyunDBHelper.h"

@implementation AliyunDraftCloudResourceInfo
@synthesize path = _path;

- (NSString *) downloadTargetId {
    if (self.type == AliyunDraftResourceType_Font ||
        self.type == AliyunDraftResourceType_Music) {
        return self.eid;
    }
    return self.gid;
}

+ (BOOL) IsCloudPath:(NSString *)path {
    AliyunDraftResourceType type = [self PathToType:path];
    return (type != AliyunDraftResourceType_Unknown);
}

+ (BOOL) IsCloudUrl:(NSString *)url {
    return [url hasPrefix:AliyunDraftResourceUrl.CloudUrl];
}

+ (AliyunEffectType) ResourceTypeToEffectType:(AliyunDraftResourceType)resType {
    switch (resType) {
        case AliyunDraftResourceType_AnimationEffect: return AliyunEffectTypeSpecialFilter;
        case AliyunDraftResourceType_MV: return AliyunEffectTypeMV;
        case AliyunDraftResourceType_Filter: return AliyunEffectTypeFilter;
        case AliyunDraftResourceType_Music: return AliyunEffectTypeMusic;
        case AliyunDraftResourceType_Font: return AliyunEffectTypeFont;
        case AliyunDraftResourceType_Sticker: return AliyunEffectTypePaster;
        case AliyunDraftResourceType_Bubble: return AliyunEffectTypeCaption;
        case AliyunDraftResourceType_Transition: return AliyunEffectTypeTransition;
        case AliyunDraftResourceType_LutFilter: return AliyunEffectTypeTransitionLutFilter;

        default: return 0;
    }
}

+ (NSString *) RootPathWithType:(AliyunDraftResourceType)type {
    AliyunEffectType effectType = [self ResourceTypeToEffectType:type];
    if (effectType == 0) {
        return nil;
    }
    NSString *path = [AliyunEffectResourceModel storageDirectoryWithEffectType:effectType];
    return [NSHomeDirectory() stringByAppendingPathComponent:path];
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

static NSString * s_findDirRecursive(NSString *dirPath, NSString *target, BOOL skip) {
    NSArray *files = [NSFileManager.defaultManager enumeratorAtPath:dirPath].allObjects;
    for (NSString *fileName in files) {
        BOOL isDir = NO;
        NSString *path = [dirPath stringByAppendingPathComponent:fileName];
        if (![NSFileManager.defaultManager fileExistsAtPath:path isDirectory:&isDir] || !isDir) {
            continue;
        }
        
        if (!skip && [fileName isEqualToString:target]) {
            return fileName;
        }
        
        NSString *result = s_findDirRecursive(path, target, NO);
        if (result) {
            return [fileName stringByAppendingPathComponent:result];
        }
    }

    return nil;
}

+ (NSString *) FontPathWithGroupPath:(NSString *)groupPath {
    NSString *fontName = s_findFileInDirWithPrefix(groupPath, @"font.");
    if (fontName) {
        return [groupPath stringByAppendingPathComponent:fontName];
    }
    return nil;
}

+ (NSString *) MusicPathWithGroupPath:(NSString *)groupPath {
    NSString *musicName = s_findFileInDirWithPrefix(groupPath, nil);
    if (musicName) {
        return [groupPath stringByAppendingPathComponent:musicName];
    }
    return nil;
}

+ (NSString *) RealPathWithType:(AliyunDraftResourceType)type gid:(NSString *)gid eid:(NSString *)eid {
    NSString *rootPath = [self RootPathWithType:type];
    if (![NSFileManager.defaultManager fileExistsAtPath:rootPath]) {
        return nil;
    }
    
    if (eid.length == 0) {
        return nil;
    }
    
    NSString *groupNamePrefix = nil;
    if (type == AliyunDraftResourceType_Font) {
        groupNamePrefix = [NSString stringWithFormat:@"%@-", eid];
    } else if (type == AliyunDraftResourceType_Music) {
        NSInteger keyId = [AliyunMusicPickModel KeyIdFromMusicId:eid];
        groupNamePrefix = [NSString stringWithFormat:@"%ld-", keyId];
    } else {
        groupNamePrefix = [NSString stringWithFormat:@"%@-", gid];
    }
    NSString *groupFile = s_findFileInDirWithPrefix(rootPath, groupNamePrefix);
    if (!groupFile) {
        return nil;
    }
    NSString *groupFilePath = [rootPath stringByAppendingPathComponent:groupFile];
    
    if (type == AliyunDraftResourceType_Font) {
        return [self FontPathWithGroupPath:groupFilePath];
    }
    
    if (type == AliyunDraftResourceType_Music) {
        return [self MusicPathWithGroupPath:groupFilePath];
    }
    
    if (type == AliyunDraftResourceType_MV ||
        type == AliyunDraftResourceType_AnimationEffect ||
        type == AliyunDraftResourceType_Transition) {
        NSString *subPath = s_findDirRecursive(groupFilePath, eid, YES);
        if (subPath) {
            return [groupFilePath stringByAppendingPathComponent:subPath];
        }
        return nil;
    }

    NSString *targetNamePrefix = [NSString stringWithFormat:@"%@-", eid];
    NSString *targetName = s_findFileInDirWithPrefix(groupFilePath, targetNamePrefix);
    if (!targetName) {
        return nil;
    }
    
    NSString *path = [groupFilePath stringByAppendingPathComponent:targetName];
    targetName = s_findFileInDirWithPrefix(path, nil);
    if (targetName) {
        return [path stringByAppendingPathComponent:targetName];
    }

    return nil;
}

static NSArray<NSString *> * s_separateName(NSString *name) {
    NSArray *list = [name componentsSeparatedByString:@"-"];
    if (list.count < 2) {
        return nil;
    }
    return list;
}

static NSString * s_getIdFromName(NSString *name) {
    return s_separateName(name).firstObject;
}

+ (AliyunDraftResourceId *) ResourceIdWithPath:(NSString *)path type:(AliyunDraftResourceType)type {
    AliyunDraftResourceId *resId = [AliyunDraftResourceId new];
    if (type == AliyunDraftResourceType_Music) {
        path = [path stringByDeletingLastPathComponent];
        NSArray<NSString *> *idAndName = s_separateName(path.lastPathComponent);
        if (!idAndName) {
            return nil;
        }
        
        NSInteger keyId = idAndName.firstObject.intValue;
        NSString *name = idAndName.lastObject;
        
        NSArray *musicList = AliyunMusicPickViewController.CachesRemoteMusicList;
        for (AliyunMusicPickModel *model in musicList) {
            if (model.keyId == keyId) {
                resId.eid = model.musicId;
                resId.name = name;
                return resId;
            }
        }
        return nil;
    }
    
    if (type == AliyunDraftResourceType_Font) {
        path = [path stringByDeletingLastPathComponent];
        resId.eid = s_getIdFromName(path.lastPathComponent);
        return resId;
    }
    
    if (type == AliyunDraftResourceType_MV ||
        type == AliyunDraftResourceType_AnimationEffect ||
        type == AliyunDraftResourceType_Transition) {
        resId.eid = path.lastPathComponent;
        path = [[path stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
        resId.gid = s_getIdFromName(path.lastPathComponent);
        return resId;
    }
    
    path = [path stringByDeletingLastPathComponent];
    resId.eid = s_getIdFromName(path.lastPathComponent);
    path = [path stringByDeletingLastPathComponent];
    resId.gid = s_getIdFromName(path.lastPathComponent);
    return resId;
}

- (NSString *) path {
    if (!_path) {
        _path = [AliyunDraftCloudResourceInfo RealPathWithType:self.type gid:self.gid eid:self.eid];
    }
    return _path;
}

@end

@interface __ResourceCaches : NSObject
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *musicUrlInfo;
@property (nonatomic, strong) NSMutableArray<AliyunEffectResourceModel *> *mvList;
@property (nonatomic, strong) NSMutableArray<AliyunEffectResourceModel *> *stickerGroupList;
@property (nonatomic, strong) NSMutableArray<AliyunEffectResourceModel *> *bubbleGroupList;
@property (nonatomic, strong) NSMutableArray<AliyunEffectResourceModel *> *animationEffectGroupList;
@property (nonatomic, strong) NSMutableArray<AliyunEffectResourceModel *> *transitionGroupList;
@end

typedef void(^OnDownloadFinish)(BOOL isSuccess);

@interface __DraftResourceDownloadTask : NSObject
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, copy, readonly) NSString *taskKey;
@property (nonatomic, assign) AliyunDraftResourceType type;
@property (nonatomic, copy) NSString *targetId;
@property (nonatomic, copy) NSString *targetName;
@property (nonatomic, copy) OnDownloadFinish onFinish;
@property (nonatomic, strong) NSMutableArray<OnDownloadFinish> *callbackList;

// help
@property (nonatomic, strong) __ResourceCaches *caches;
@property (nonatomic, strong) AliyunResourceFontDownload *fontDownloader;
@property (nonatomic, strong) AliyunResourceDownloadManager *downloader;
@property (nonatomic, strong) AliyunDBHelper *dbHelper;

+ (NSString *) TaskKeyWithType:(AliyunDraftResourceType)type targetId:(NSString *)targetId;
- (instancetype) initWithType:(AliyunDraftResourceType)type targetId:(NSString *)targetId;
- (void) start;
@end

@interface AliyunDraftCloudResourceLoader ()
@property (nonatomic, strong) __ResourceCaches *caches;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSMutableDictionary<NSString *, __DraftResourceDownloadTask *> *runningTask;
@property (nonatomic, strong) AliyunDBHelper *dbHelper;
@end

@implementation AliyunDraftCloudResourceLoader

+ (AliyunDraftCloudResourceLoader *) Shared {
    static dispatch_once_t onceToken;
    static AliyunDraftCloudResourceLoader *s_shared = nil;
    dispatch_once(&onceToken, ^{
        s_shared = [AliyunDraftCloudResourceLoader new];
    });
    return s_shared;
}

- (void) dealloc {
    [_dbHelper closeDB];
    _dbHelper = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _caches = [__ResourceCaches new];
        _runningTask = @{}.mutableCopy;
        _queue = dispatch_queue_create("com.aliyun.svideo.soluction.resource.loader", DISPATCH_QUEUE_SERIAL);
        _dbHelper = [AliyunDBHelper new];
        [_dbHelper openResourceDBSuccess:nil failure:nil];
    }
    return self;
}

- (void) addTaskWithInfo:(AliyunDraftCloudResourceInfo *)info completion:(OnDownloadFinish)completion {
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(_queue, ^{
        OnDownloadFinish onFinish = ^(BOOL isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(isSuccess);
                }
            });
        };

        // 再次检查
        if ([NSFileManager.defaultManager fileExistsAtPath:info.path]) {
            onFinish(YES);
            return;
        }
        
        AliyunDraftCloudResourceLoader *strongSelf = weakSelf;
        if (!strongSelf) {
            onFinish(NO);
            return;
        }
        
        NSString *key = [__DraftResourceDownloadTask TaskKeyWithType:info.type targetId:info.downloadTargetId];
        __DraftResourceDownloadTask *task = [strongSelf.runningTask objectForKey:key];
        if (!task) {
            task = [[__DraftResourceDownloadTask alloc] initWithType:info.type targetId:info.downloadTargetId];
            task.targetName = info.name;
            task.dbHelper = weakSelf.dbHelper;
            task.caches = weakSelf.caches;
            task.onFinish = ^(BOOL isSucess) {
                AliyunDraftCloudResourceLoader *strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                dispatch_sync(strongSelf.queue, ^{
                    [strongSelf.runningTask removeObjectForKey:key];
                });
            };
            [strongSelf.runningTask setObject:task forKey:key];
        }
        if (completion) {
            [task.callbackList addObject:onFinish];
        }
        [task start];
    });
}

+ (BOOL) LoadFromUrl:(NSString *)urlString completion:(void(^)(AliyunDraftCloudResourceInfo *))completion {
    void(^onFinish)(AliyunDraftCloudResourceInfo *) = ^(AliyunDraftCloudResourceInfo *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(info);
            }
        });
    };
    
    AliyunDraftCloudResourceInfo *info = [[AliyunDraftCloudResourceInfo alloc] initWithUrl:urlString];
    if (!info || info.isInApp) {
        onFinish(nil);
        return NO;
    }

    if ([NSFileManager.defaultManager fileExistsAtPath:info.path]) {
        onFinish(info);
        return YES;
    }
    
    [self.Shared addTaskWithInfo:info completion:^(BOOL isSuccess) {
        if ([NSFileManager.defaultManager fileExistsAtPath:info.path]) {
            onFinish(info);
        } else {
            onFinish(nil);
        }
    }];
    return YES;
}

+ (BOOL) LoadFromPath:(NSString *)path completion:(void(^)(AliyunDraftCloudResourceInfo *))completion {
    void(^onFinish)(AliyunDraftCloudResourceInfo *) = ^(AliyunDraftCloudResourceInfo *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(info);
            }
        });
    };
    
    AliyunDraftResourceType type = [AliyunDraftCloudResourceInfo PathToType:path];
    if (type == AliyunDraftResourceType_Unknown) {
        onFinish(nil);
        return NO;
    }
    
    AliyunDraftResourceId *resId = [AliyunDraftCloudResourceInfo ResourceIdWithPath:path type:type];
    if (!resId) {
        return NO;
    }
    
    AliyunDraftCloudResourceInfo *info = [[AliyunDraftCloudResourceInfo alloc] initWithType:type isInApp:NO gid:resId.gid eid:resId.eid name:resId.name];
    onFinish(info);
    return YES;
}

@end

@implementation __ResourceCaches

- (instancetype)init
{
    self = [super init];
    if (self) {
        _musicUrlInfo = @{}.mutableCopy;
    }
    return self;
}

- (void) fetchMusicUrl:(NSString *)musicId musicName:(NSString *)musicName completion:(void(^)(AliyunEffectResourceModel *model))completion {
    void(^onFinish)(NSString *) = ^(NSString *url) {
        if (!url) {
            completion(nil);
            return;
        }
        
        AliyunEffectResourceModel *music = [AliyunEffectResourceModel new];
        music.eid = [AliyunMusicPickModel KeyIdFromMusicId:musicId];
        music.name = musicName;
        music.url = url;
        music.effectType = AliyunEffectTypeMusic;
        completion(music);
    };
    
    NSString *url = [_musicUrlInfo objectForKey:musicId];
    if (url) {
        onFinish(url);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [AliyunResourceRequestManager fetchMusicPlayUrl:musicId
                                            success:^(NSString *playPath, NSString *expireTime) {
        if (playPath) {
            weakSelf.musicUrlInfo[musicId] = playPath;
        }
        onFinish(playPath);
    } failure:^(NSString *errorStr) {
        onFinish(nil);
    }];
}

static AliyunEffectResourceModel * s_findResModelInList(NSArray<AliyunEffectResourceModel *> *list, NSString *eid) {
    if (!list) {
        return nil;
    }
    
    NSInteger intEid = eid.intValue;
    for (AliyunEffectResourceModel *model in list) {
        if (model.eid == intEid) {
            return model;
        }
    }
    return nil;
}

static NSMutableArray<AliyunEffectResourceModel *> * s_convertResModelList(NSArray *list, AliyunEffectType type) {
    NSMutableArray<AliyunEffectResourceModel *> *result = @[].mutableCopy;
    for (NSDictionary *tmp in list) {
        assert([tmp isKindOfClass:NSDictionary.class]);
        AliyunEffectResourceModel *model = [[AliyunEffectResourceModel alloc] initWithDictionary:tmp error:nil];
        model.effectType = type;
        [result addObject:model];
    }
    return result;
}

- (void) fetchList:(NSArray *)list
            withId:(NSString *)targetId
              type:(AliyunEffectType)type
         fetchFunc:(void(^)(void(^callback)(NSArray *)))fetchFunc
      fetchSubFunc:(void(^)(AliyunEffectResourceModel *, void(^callback)(NSArray<AliyunEffectPasterInfo> *)))fetchSubFunc
    changeListFunc:(void(^)(NSMutableArray<AliyunEffectResourceModel *> *list))changeListFunc
        completion:(void(^)(AliyunEffectResourceModel *))completion{
    __block NSArray *targetList = nil;
    void(^onFinish)(void) = ^{
        AliyunEffectResourceModel *model = s_findResModelInList(targetList, targetId);
        if (!model || !fetchSubFunc || model.pasterList.count > 0) {
            completion(model);
            return;
        }
        
        fetchSubFunc(model, ^(NSArray<AliyunEffectPasterInfo> *list) {
            if (list) {
                model.pasterList = list;
                completion(model);
            } else {
                completion(nil);
            }
        });
    };
    
    if (list) {
        targetList = list;
        onFinish();
        return;
    }
    
    fetchFunc(^(NSArray *list){
        if (list) {
            NSMutableArray<AliyunEffectResourceModel *> *resultList = s_convertResModelList(list, type);
            changeListFunc(resultList);
            targetList = resultList;
        }
        onFinish();
    });
}

- (void) fetchStickerGroup:(NSString *)gid completion:(void(^)(AliyunEffectResourceModel *))completion {
    __weak typeof(self) weakSelf = self;
    [self fetchList:_stickerGroupList withId:gid type:AliyunEffectTypePaster fetchFunc:^(void (^callback)(NSArray *)) {
        [AliyunResourceRequestManager fetchPasterCategoryWithType:kPasterCategoryBack success:^(NSArray *resourceListArray) {
            callback(resourceListArray);
        } failure:^(NSString *errorStr) {
            callback(nil);
        }];
    } fetchSubFunc:^(AliyunEffectResourceModel *model, void (^callback)(NSArray<AliyunEffectPasterInfo> *)) {
        [AliyunResourceRequestManager fetchPasterListWithType:kPasterCategoryBack
                                             pasterCategoryId:model.eid
                                                      success:^(NSArray<AliyunEffectPasterInfo> *resourceListArray) {
            callback(resourceListArray);
        } failure:^(NSString *errorStr) {
            callback(nil);
        }];
    } changeListFunc:^(NSMutableArray<AliyunEffectResourceModel *> *list) {
        weakSelf.stickerGroupList = list;
    } completion:completion];
}

- (void) fetchBubbleGroup:(NSString *)gid completion:(void(^)(AliyunEffectResourceModel *))completion {
    __weak typeof(self) weakSelf = self;
    [self fetchList:_bubbleGroupList withId:gid type:AliyunEffectTypeCaption fetchFunc:^(void (^callback)(NSArray *)) {
        [AliyunResourceRequestManager fetchCaptionListWithSuccess:^(NSArray *resourceListArray) {
            callback(resourceListArray);
        } failure:^(NSString *errorStr) {
            callback(nil);
        }];
    } fetchSubFunc:^(AliyunEffectResourceModel *model, void (^callback)(NSArray<AliyunEffectPasterInfo> *list)) {
        [AliyunResourceRequestManager fetchTextPasterListWithTextPasterCategoryId:model.eid success:^(NSArray<AliyunEffectPasterInfo> *resourceListArray) {
            callback(resourceListArray);
        } failure:^(NSString *errorStr) {
            callback(nil);
        }];
    } changeListFunc:^(NSMutableArray<AliyunEffectResourceModel *> *list) {
        weakSelf.bubbleGroupList = list;
    } completion:completion];
}

- (void) fetchMV:(NSString *)gid completion:(void(^)(AliyunEffectResourceModel *))completion {
    __weak typeof(self) weakSelf = self;
    [self fetchList:_mvList withId:gid type:AliyunEffectTypeMV fetchFunc:^(void (^callback)(NSArray *)) {
        [AliyunResourceRequestManager fetchMVListSuccess:^(NSArray *resourceListArray) {
            callback(resourceListArray);
        } failure:^(NSString *errorStr) {
            callback(nil);
        }];
    } fetchSubFunc:nil
     changeListFunc:^(NSMutableArray<AliyunEffectResourceModel *> *list) {
        weakSelf.mvList = list;
    } completion:completion];
}

- (void) fetchAnimationEffect:(NSString *)gid completion:(void(^)(AliyunEffectResourceModel *))completion {
    __weak typeof(self) weakSelf = self;
    [self fetchList:_animationEffectGroupList withId:gid type:AliyunEffectTypeSpecialFilter fetchFunc:^(void (^callback)(NSArray *)) {
        [AliyunResourceRequestManager fetchSpecialEffectListSuccess:^(NSArray *resourceListArray) {
            callback(resourceListArray);
        } failure:^(NSString *errorStr) {
            callback(nil);
        }];
    } fetchSubFunc:nil
     changeListFunc:^(NSMutableArray<AliyunEffectResourceModel *> *list) {
        weakSelf.animationEffectGroupList = list;
    } completion:completion];
}

- (void) fetchTransition:(NSString *)gid completion:(void(^)(AliyunEffectResourceModel *))completion {
    __weak typeof(self) weakSelf = self;
    [self fetchList:_transitionGroupList withId:gid type:AliyunEffectTypeTransition fetchFunc:^(void (^callback)(NSArray *)) {
        [AliyunResourceRequestManager fetchTransitionListSuccess:^(NSArray *resourceListArray) {
            callback(resourceListArray);
        } failure:^(NSString *errorStr) {
            callback(nil);
        }];
    } fetchSubFunc:nil
     changeListFunc:^(NSMutableArray<AliyunEffectResourceModel *> *list) {
        weakSelf.transitionGroupList = list;
    } completion:completion];
}

@end

@implementation __DraftResourceDownloadTask

+ (NSString *) TaskKeyWithType:(AliyunDraftResourceType)type targetId:(NSString *)targetId {
    return [NSString stringWithFormat:@"%d-%@", (int)type, targetId];
}

- (instancetype) initWithType:(AliyunDraftResourceType)type targetId:(NSString *)targetId {
    self = [super init];
    if (self) {
        _taskKey = [__DraftResourceDownloadTask TaskKeyWithType:type targetId:targetId];
        _type = type;
        _targetId = targetId;
        _callbackList = @[].mutableCopy;
    }
    return self;
}

- (void) handleFinish:(BOOL)isSuccess {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __DraftResourceDownloadTask *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        if (strongSelf.onFinish) {
            strongSelf.onFinish(isSuccess);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            for (OnDownloadFinish callback in strongSelf.callbackList) {
                callback(isSuccess);
            }
        });
    });
}

- (void) downloadFont {
    NSInteger fontId = _targetId.intValue;
    if (!_fontDownloader) {
        _fontDownloader = [AliyunResourceFontDownload new];
    }
    
    __weak typeof(self) weakSelf = self;
    [_fontDownloader downloadFontWithFontId:fontId progress:nil completion:^(AliyunEffectResourceModel *newModel, NSError *error) {
        [weakSelf handleFinish:(newModel != nil)];
    }];
}

- (AliyunResourceDownloadManager *) downloader {
    if (!_downloader) {
        _downloader = [AliyunResourceDownloadManager new];
    }
    return _downloader;
}

- (void) downloadModel:(AliyunEffectResourceModel *)model {
    if (!model) {
        [self handleFinish:NO];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    AliyunResourceDownloadTask *task = [[AliyunResourceDownloadTask alloc] initWithModel:model];
    [self.downloader addDownloadTask:task progress:^(CGFloat progress) {} completionHandler:^(AliyunEffectResourceModel *newModel, NSError *error) {
        if (newModel && newModel.effectType != AliyunEffectTypeMusic) {
            [weakSelf.dbHelper insertDataWithEffectResourceModel:newModel];
        }
        
        [weakSelf handleFinish:(error == nil)];
    }];
}

- (void) downloadMusic {
    __weak typeof(self) weakSelf = self;
    [_caches fetchMusicUrl:_targetId musicName:_targetName completion:^(AliyunEffectResourceModel *model) {
        [weakSelf downloadModel:model];
    }];
}

- (void) downloadMV {
    __weak typeof(self) weakSelf = self;
    [_caches fetchMV:_targetId completion:^(AliyunEffectResourceModel *model) {
        [weakSelf downloadModel:model];
    }];
}

- (void) downloadSticker {
    __weak typeof(self) weakSelf = self;
    [_caches fetchStickerGroup:_targetId completion:^(AliyunEffectResourceModel *model) {
        [weakSelf downloadModel:model];
    }];
}

- (void) downloadAnimationEffect {
    __weak typeof(self) weakSelf = self;
    [_caches fetchAnimationEffect:_targetId completion:^(AliyunEffectResourceModel *model) {
        [weakSelf downloadModel:model];
    }];
}

- (void) downloadTransition {
    __weak typeof(self) weakSelf = self;
    [_caches fetchTransition:_targetId completion:^(AliyunEffectResourceModel *model) {
        [weakSelf downloadModel:model];
    }];
}

- (void) downloadBubble {
    __weak typeof(self) weakSelf = self;
    [_caches fetchBubbleGroup:_targetId completion:^(AliyunEffectResourceModel *model) {
        [weakSelf downloadModel:model];
    }];
}

- (void) start {
    if (_isRunning) {
        return;
    }
    _isRunning = YES;
    
    switch (_type) {
        case AliyunDraftResourceType_Font: {
            [self downloadFont];
            break;
        }
        case AliyunDraftResourceType_Music: {
            [self downloadMusic];
            break;
        }
        case AliyunDraftResourceType_MV: {
            [self downloadMV];
            break;
        }
        case AliyunDraftResourceType_Sticker: {
            [self downloadSticker];
            break;
        }
        case AliyunDraftResourceType_AnimationEffect: {
            [self downloadAnimationEffect];
            break;
        }
        case AliyunDraftResourceType_Bubble: {
            [self downloadBubble];
            break;
        }
        case AliyunDraftResourceType_Transition: {
            [self downloadTransition];
            break;
        }
        default:
            [self handleFinish:NO];
            break;
    }
}

@end
