//
//  AliyunVideoConfig.m
//  AliyunVideoClient_Entrance
//
//  Created by coder.pi on 2022/2/24.
//  Copyright © 2022 Aliyun. All rights reserved.
//

#import "AliyunVideoConfig.h"
#import "AVC_ShortVideo_Config.h"
#import "AlivcMacro.h"

#if SDK_VERSION == SDK_VERSION_BASE
#import <AliyunVideoSDKBasic/AliyunVideoSDKInfo.h>
#import <AliyunVideoSDKBasic/AliyunVideoLicense.h>
#else
#import <AliyunVideoSDKPro/AliyunVideoSDKInfo.h>
#import <AliyunVideoSDKPro/AliyunVideoLicense.h>
#endif

typedef void(^SetupCallback)(BOOL isFinish, NSString *errMsg, BOOL isLicenseValid, NSString *licenseErrorMsg);
@interface AliyunVideoConfig()<AliyunVideoLicenseEventDelegate>
@end

@implementation AliyunVideoConfig

static NSString * s_formatLicenseErrorCode(AliyunVideoLicenseResultCode code) {
    switch (code) {
        case AliyunVideoLicenseResultCodeUninitialized: return @"SDK初始中...";
        case AliyunVideoLicenseResultCodeSuccess: return @"成功";
        case AliyunVideoLicenseResultCodeExpired: return @"过期";
        case AliyunVideoLicenseResultCodeInvalid: return @"无效";
        default: return @"未知错误";
    }
}

static NSString * s_formatLicenseRefreshRespCode(AliyunVideoLicenseRefreshCode code) {
    switch (code) {
        case AliyunVideoLicenseRefreshCodeUninitialized: return @"SDK初始化中...";
        case AliyunVideoLicenseRefreshCodeSuccess: return @"成功";
        case AliyunVideoLicenseRefreshCodeInvalid: return @"证书无效";
        case AliyunVideoLicenseRefreshCodeServerError: return @"服务端出错，请稍后重试";
        case AliyunVideoLicenseRefreshCodeNetworkError: return @"网络出错，请检查本地网络";
        default: return @"未知错误";
    }
}

static NSString * s_formatLicenseFeatureType(AliyunVideoFeatureType type) {
    switch (type) {
        case AliyunVideoFeatureTypeMV: return @"MV";
        case AliyunVideoFeatureTypeSticker: return @"动态贴纸";
        case AliyunVideoFeatureTypeCropCompose: return @"裁剪压缩";
        case AliyunVideoFeatureTypeCaption: return @"字幕";
        default: return @"未知增值服务";
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        AliyunVideoLicenseManager.EventDelegate = self;
    }
    return self;
}

+ (AliyunVideoConfig *) Shared {
    static AliyunVideoConfig *s_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_shared = [AliyunVideoConfig new];
    });
    return s_shared;
}

+ (BOOL) IsSetupFinish {
    return AliyunVideoLicenseManager.HasInitialized;
}

+ (void) Setup {
    if (self.IsSetupFinish)
    {
        return;
    }
    
    [AliyunVideoConfig Shared];
    [AliyunVideoSDKInfo setLogLevel:kAlivcLogLevel];

    NSError *error = [AliyunVideoSDKInfo registerSDK];
    NSAssert2(error == nil, @"初始化SDK失败！%@；%@", error.localizedDescription, error.localizedRecoverySuggestion);
    ALIVC_CHECK_LICENSE_SETTING
}

+ (BOOL) CheckLicense:(NSString **)errMsg {
    AliyunVideoLicenseResultCode code = [AliyunVideoLicenseManager Check];
    if (code == AliyunVideoLicenseResultCodeSuccess) {
        return YES;
    }
    
    if (errMsg) {
        *errMsg = s_formatLicenseErrorCode(code);
    }
    return NO;
}

+ (void) RefreshLicense:(void(^)(BOOL isSuccess, NSString *errMsg))callback {
    [AliyunVideoLicenseManager Refresh:^(AliyunVideoLicenseRefreshCode code) {
        if (!callback) {
            return;
        }
        
        callback(code == AliyunVideoLicenseRefreshCodeSuccess, s_formatLicenseRefreshRespCode(code));
    }];
}

+ (UIViewController *) TopViewController {
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = UIApplication.sharedApplication.windows;
        for (UIWindow *tmp in windows) {
            if (tmp.windowLevel == UIWindowLevelNormal) {
                window = tmp;
                break;
            }
        }
    }
    NSAssert(window.windowLevel == UIWindowLevelNormal, @"Can not found showing window");
    
    UIViewController *topViewController = window.rootViewController;
    while (topViewController) {
        if (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
        } else if ([topViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)topViewController;
            topViewController = nav.topViewController;
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
        } else {
            return topViewController;
        }
    }
    return nil;
}

+ (void) AlertLicenseError:(NSString *)errMsg {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"授权失败" message:errMsg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:confirm];
    [self.TopViewController presentViewController:alert animated:YES completion:nil];
}

// MARK: - AliyunVideoLicenseEventDelegate
- (void) onAliyunVideoLicenseCheckError:(AliyunVideoLicenseResultCode)errCode {
    NSString *msg = [NSString stringWithFormat:@"短视频SDK授权错误：%@", s_formatLicenseErrorCode(errCode)];
    [AliyunVideoConfig AlertLicenseError:msg];
    [AliyunVideoLicenseManager Refresh:nil]; // 验证失败主动刷新一下证书
}

- (void) onAliyunVideoLicenseFeatureCheck:(AliyunVideoFeatureType)featureType error:(AliyunVideoLicenseResultCode)errCode {
    NSString *msg = [NSString stringWithFormat:@"增值服务 %@ %@", s_formatLicenseFeatureType(featureType), s_formatLicenseErrorCode(errCode)];
    [AliyunVideoConfig AlertLicenseError:msg];
    [AliyunVideoLicenseManager Refresh:nil]; // 验证失败主动刷新一下证书
}

@end
