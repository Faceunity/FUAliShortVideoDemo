//
//  AliyunDraftConfig.m
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/9.
//

#import "AliyunDraftConfig.h"
#import "AliyunPathManager.h"
#import "AliyunLocalDraftManager+Private.h"
#import "AliyunCloudDraftManager+Private.h"

@implementation AliyunDraftConfig

+ (AliyunDraftConfig *) Shared {
    static AliyunDraftConfig *s_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_shared = [AliyunDraftConfig new];
    });
    return s_shared;
}

- (BOOL) hasService {
    return _loader.enabled;
}

#define USER_KEY @"DRAFT_CONFIG_USER_ID"
#define SERVER_URL @"DRAFT_CONFIG_SERVER_URL"

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *uid = [NSUserDefaults.standardUserDefaults stringForKey:USER_KEY];
        if (uid.length == 0) {
            self.userId = @"Coder.Pi";
        } else {
            self.userId = uid;
        }
        self.serverUrl = [NSUserDefaults.standardUserDefaults stringForKey:SERVER_URL];
    }
    return self;
}

- (void) resetLoader {
    NSAssert(_userId.length > 0, @"必须设置用户");
    _loader = [[AliyunDraftLoader alloc] initWithBaseUrl:_serverUrl userId:_userId];
    if (_loader.enabled) {
        _cloudManager = [[AliyunCloudDraftManager alloc] initWithLoader:_loader localManager:_localManager];
    } else {
        _cloudManager = nil;
    }
}

- (void) setUserId:(NSString *)userId {
    if (userId.length == 0) {
        return;
    }
    
    if ([_userId isEqualToString:userId]) {
        return;
    }
    
    _userId = userId;
    [NSUserDefaults.standardUserDefaults setObject:_userId forKey:USER_KEY];
    _localManager = [[AliyunLocalDraftManager alloc] initWithUserId:_userId];
    _templateManager = [[AliyunLocalDraftManager alloc] initWithUserId:[_userId stringByAppendingString:@".template"]];
    [self resetLoader];
}

- (void) setServerUrl:(NSString *)serverUrl {
    if ([_serverUrl isEqualToString:serverUrl]) {
        return;
    }
    
    _serverUrl = serverUrl;
    [NSUserDefaults.standardUserDefaults setObject:_serverUrl forKey:SERVER_URL];
    [self resetLoader];
}

@end
