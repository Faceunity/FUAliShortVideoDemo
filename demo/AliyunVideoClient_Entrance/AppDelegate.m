//
//  AppDelegate.m
//  AliyunVideoClient_Entrance
//
//  Created by 孙震 on 2019/11/15.
//  Copyright © 2019 孙震. All rights reserved.
//

#import "AppDelegate.h"
#import "AVC_ShortVideo_Config.h"
#import "AlivcHomeViewController.h"
#import "AlivcUIConfig.h"
#import "UIImage+AlivcHelper.h"
#import "AlivcMacro.h"
#import "AlivcDefine.h"
#import "AliyunVideoConfig.h"

#import <UMCommon/UMCommon.h>
#import <UMAnalytics/MobClick.h>

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window =[[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    UINavigationController *nav =[[UINavigationController alloc]initWithRootViewController:[AlivcHomeViewController new]];
    [self.window setRootViewController:nav];
    [self.window makeKeyAndVisible];
    [self settingNavBar];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self checkVersion];
    });
    [AliyunVideoConfig Setup];
    [self UMengInit];

    return YES;
}

- (void)settingNavBar{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [nav.navigationBar setBackgroundImage:[UIImage avc_imageWithColor:[AlivcUIConfig shared].kAVCBackgroundColor] forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setShadowImage:[UIImage new]];
    nav.navigationBar.tintColor = [UIColor whiteColor];
    [nav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}


#pragma mark - Public Method
- (void)UMengInit{
    NSString *appkey;
    if(kAlivcProductType == AlivcOutputProductTypeSmartVideo) {
        appkey = @"5c6d176eb465f5fccb000468";
    }else{
        appkey = @"5d80828b3fc195f979000bae";
    }
    NSString *channel = @"Aliyun"; //渠道标记
    [UMConfigure setLogEnabled:YES];//此处在初始化函数前面是为了打印初始化的日志
    [MobClick setCrashReportEnabled:YES];
    [UMConfigure initWithAppkey:appkey channel:channel];
}

#pragma mark - 版本更新

- (void)checkVersion{
    //确定对外输出的产品类型
    AlivcOutputProductType productType = kAlivcProductType;
    
    NSString *plistString = nil;
    switch (productType) {
        case AlivcOutputProductTypeSmartVideo:
            plistString = @"https://vod-download.cn-shanghai.aliyuncs.com/apsaravideo-upgrade/ios/littleVideo.plist";
            break;
        case AlivcOutputProductTypeAll:
            plistString = @"https://alivc-demo-cms.alicdn.com/versionProduct/installPackage/allModule/allModule_update_iOS.plist";
            
        default:
            break;
    }
    if (plistString) {
        NSString *releaseNoteString = [self releaseNoteStringWithString:plistString];
        if (releaseNoteString) {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"检测到新版本，是否更新？" , nil) message:releaseNoteString preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:[@"确定" localString] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",plistString]] options:@{} completionHandler:nil];
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",plistString]]];
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    exit(0);
                });
            }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[@"取消" localString] style:UIAlertActionStyleDefault handler:nil];
            
            
            [alertC addAction:confirmAction];
            [alertC addAction:cancelAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.window.rootViewController presentViewController:alertC animated:YES completion:nil];
            });
        }
    }
    
}

/**
 检查本地版本号与服务器版本号，看下有无更新
 
 @param plistString 服务器版本号所在的url字符串
 @return nil - 无更新， 有值 - 有更新并且返回更新内容
 */
- (NSString *)releaseNoteStringWithString:(NSString *)plistString{
    
    
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:plistString]];
    NSString *releaseNote = dic[@"items"][0][@"metadata"][@"releaseNote"];
    NSString *onLineVersion = dic[@"items"][0][@"metadata"][@"bundle-version"];
    
    
    
    NSString *localVerson = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    if([localVerson compare:onLineVersion options:NSNumericSearch] == NSOrderedAscending){
        return releaseNote;
    }
    return nil;
}



- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    
    UINavigationController *navigationController = (id)self.window.rootViewController;
    if ([navigationController isKindOfClass:[UINavigationController class]]) {
        return [navigationController.visibleViewController supportedInterfaceOrientations];
    }
    return navigationController.supportedInterfaceOrientations;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"\n ===> 程序暂停 !");
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"\n ===> 进入后台 ！");
}


@end
