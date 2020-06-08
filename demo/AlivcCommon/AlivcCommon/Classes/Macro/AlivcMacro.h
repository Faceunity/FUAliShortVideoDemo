//
//  AlivcMacro.h
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/10/17.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#ifndef AlivcMacro_h
#define AlivcMacro_h

 
#define kAlivcProductType AlivcOutputProductTypeShortVideo

//#define OPEN_LONGVIDEO_PRIVATECODE //打开长视频单独逻辑


#define kAlivcLogLevel 5

#define isRace NO

// Include any system framework and library headers here that should be included in all compilation units.
// You will also need to set the Prefix Header build setting of one or more of your targets to reference this file.
#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight  [UIScreen mainScreen].bounds.size.height
#define SizeWidth(W) (W *CGRectGetWidth([[UIScreen mainScreen] bounds])/320)
#define SizeHeight(H) (H *(ScreenHeight)/568)
#define RGBToColor(R,G,B)  [UIColor colorWithRed:(R * 1.0) / 255.0 green:(G * 1.0) / 255.0 blue:(B * 1.0) / 255.0 alpha:1.0]
#define rgba(R,G,B,A)  [UIColor colorWithRed:(R * 1.0) / 255.0 green:(G * 1.0) / 255.0 blue:(B * 1.0) / 255.0 alpha:A]


#define BundleID [[NSBundle mainBundle] bundleIdentifier]
//#define BundleID @"com.aliyun.apsaravideo"

//#define BundleID @"com.aliyun.aliyunvideosdkpro"
// 注释为Release版
//#define kQPEnableDevNetwork

#define kIntroduceUrl @"https://alivc-demo.aliyuncs.com/td.html"

#define IS_IPHONEX (([[UIScreen mainScreen] bounds].size.height<812)?NO:YES)
#define SafeTop (([[UIScreen mainScreen] bounds].size.height<812) ? 20 : 44)
#define SafeBottom (([[UIScreen mainScreen] bounds].size.height<812) ? 0 : 34)
#define SafeBeautyBottom (([[UIScreen mainScreen] bounds].size.height<812) ? 0 : 12)
#define StatusBarHeight (([[UIScreen mainScreen] bounds].size.height<812) ? 20 : 44)
#define NoStatusBarSafeTop (IS_IPHONEX ? 44 : 0)

#define KquTabBarHeight  (IS_IPHONEX ? 100 : 0)

//#define SafeAreaTop \
//^double(){\
//    if (@available(iOS 11.0, *)) { \
//        return [UIApplication sharedApplication].keyWindow.safeAreaInsets.top; \
//    } else { \
//        return 20.0; \
//    } \
//}()\

#define SafeAreaBottom \
^double(){\
    if (@available(iOS 11.0, *)) { \
        return [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom; \
    } else { \
        return 0.0; \
    } \
}()\


#endif

//#ifdef DEBUG
//# define NSLog(fmt, ...) NSLog((@"\n[File:%s]\n" "[Function:%s]\n" "[Line:%d] \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
//#else
//# define NSLog(...);
//#endif

//去掉控制台输出
//#define NSLog(...)


// pushflow
#define AlivcScreenWidth  [UIScreen mainScreen].bounds.size.width
#define AlivcScreenHeight  [UIScreen mainScreen].bounds.size.height
#define AlivcSizeWidth(W) (W*(AlivcScreenWidth)/320)
#define AlivcSizeHeight(H) (H*(AlivcScreenHeight)/568)

/* 获取系统版本号 */
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

#define IOS_iOS10 IOS_VERSION >= 10.0 ? YES:NO

#define IOS_iOS9 IOS_VERSION >= 9.0 ? YES:NO

#define IOS_iOS8 IOS_VERSION >= 8.0 ? YES:NO

#define IPHONEX (([[UIScreen mainScreen] bounds].size.height<812)?NO:YES)

#define AlivcRGB(R,G,B)  [UIColor colorWithRed:(R * 1.0) / 255.0 green:(G * 1.0) / 255.0 blue:(B * 1.0) / 255.0 alpha:1.0]
#define AlivcRGBA(R,G,B,A)  [UIColor colorWithRed:(R * 1.0) / 255.0 green:(G * 1.0) / 255.0 blue:(B * 1.0) / 255.0 alpha:A]

#define AlivcOxRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define AlivcOxRGBA(rgbValue,A) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:A]


#define AlivcUserDefaultsIndentifierFirst @"AlivcUserDefaultsIndentifierFirst"

#define AlivcLocalResource  @"AlivcLocalResource"

//二维码界面模块
#define LBXScan_Define_UI
#define LBXScan_Define_Native


//不同设备的屏幕比例
#define SizeScale ((AlivcScreenHeight > 568) ? AlivcScreenHeight/568 : 1)
//字幕模块文字大小根据屏幕分辨率适配
#define PasterInputViewFontSize 18.0*SizeScale


//互动白板
#define kAppID @"sh-hrjbxns6"
#define kUserID @"wangxingge"


/* AlivcMacro_h */
