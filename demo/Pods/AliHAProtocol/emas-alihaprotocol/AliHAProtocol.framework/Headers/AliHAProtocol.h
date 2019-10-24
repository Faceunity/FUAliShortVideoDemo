//
//  AliHAProtocol.h
//  AliHAProtocol
//
//  Created by hansong.lhs on 2017/7/29.
//  Copyright © 2017年 alibaba. All rights reserved.
//

#ifndef AliHAProtocol_h
#define AliHAProtocol_h

#import <Foundation/Foundation.h>

#import "AliHADefine.h"
#import "RemoteDebugProtocol.h"

#define NOW_TIME_STAMP [[NSDate date] timeIntervalSince1970] * 1000

// app lifecycle events
extern const uint16_t kTraceTypeStartupBegin;
extern const uint16_t kTraceTypeForeground;
extern const uint16_t kTraceTypeBackground;
extern const uint16_t kTraceTypeBecomeActive;
extern const uint16_t kTraceTypeResignActive;
extern const uint16_t kTraceTypeMemoryWarning;
extern const uint16_t kTraceTypeAppTerminate;
extern const uint16_t kTraceTypeApplicationOpenFromUrl;

// vc lifecycle events
extern const uint16_t kTraceTypeVCViewDidLoad;
extern const uint16_t kTraceTypeVCViewWillAppear;
extern const uint16_t kTraceTypeVCViewDidAppear;
extern const uint16_t kTraceTypeVCViewWillDisappear;
extern const uint16_t kTraceTypeVCViewDidDisappear;
extern const uint16_t kTraceTypeVCViewDidLayoutSubviews;
extern const uint16_t kTraceTypePageRenderFinished;
extern const uint16_t kTraceTypeMainThreadHeartbeat;

// user interaction
extern const uint16_t kTraceTypeTapEvent;
extern const uint16_t kTraceTypeSwipeEvent;

// performance data
extern const uint16_t kTraceTypeStartupEnd;
extern const uint16_t kTraceTypeOpenPage;
extern const uint16_t kTraceTypeOpenPageEnd;
extern const uint16_t kTraceTypeMemoryUsage;
extern const uint16_t kTraceTypeCPUUsage;
extern const uint16_t kTraceTypeFPS;

// important components
extern const uint16_t kTraceTypeLoadWebView;

// memory event
extern const uint16_t kTraceTypeBigMalloc;
extern const uint16_t kTraceTypeMemoryLeakRetainCycle;
extern const uint16_t kTraceTypeMemoryLeakAliveObject;

// jank event
extern const uint16_t kTraceTypeJankEvent;

// crash event
extern const uint16_t kTraceTypeCrashEvent;

// runtime tasks
extern const uint16_t kTraceTypeRuntimeTaskBegin;
extern const uint16_t kTraceTypeRuntimeTaskEnd;

// custom event
extern const uint16_t kTraceTypeCustomEvent;

#pragma logger protocol
@protocol AliHALoggerProtocol <NSObject>

- (void)append:(uint16_t)type time:(uint64_t)time;

- (void)append:(uint16_t)type time:(uint64_t)time params:(float[]) params paramSize:(uint16_t)paramSize;

- (void)append:(uint16_t)type time:(uint64_t)time data:(NSString *)data;

- (void)append:(uint16_t)type time:(uint64_t)time data:(NSString *)data params:(float[])params paramSize:(uint16_t)paramSize;

- (void)append:(uint16_t)type time:(uint64_t)time data:(NSString *)data desc:(NSString *)desc;

- (void)append:(uint16_t)type time:(uint64_t)time data:(NSString *)data desc:(NSString *)desc params:(float[])params paramSize:(uint16_t)paramSize;

@end

#pragma config protocol
@protocol AliHAConfigProtocol <NSObject>

/**
 * get all configs
 */
- (NSDictionary *)getConfigs;

@end

#pragma app lifecycle call back protocol
@protocol AliHAAppLifeProtocol <NSObject>

@required

/**
 * application enter foreground callback
 */
- (void)onApplicationEnterForeground;

/**
 * application enter background callback
 */
- (void)onApplicationEnterBackground;

/**
 * application become active callback
 */
- (void)onApplicationBecomeActive;

/**
 * application resign active callback
 */
- (void)onApplicationResignActive;

@optional

/**
 * open application from external url callback
 */
- (void)onApplicationOpenFromURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

/**
 * application receive memory warning
 */
- (void)onReceiveMemoryWarning;

/**
 * application terminate callback
 */
- (void)onApplicationTerminate;

@end

/**
 * page change type
 */
typedef NS_ENUM(NSInteger, PageChangeType) {
    PageChangeTypePush = 0,
    PageChangeTypePop,
    PageChangeTypeTab,
};

#pragma HA vc lifecycle protocol
@protocol AliHAVCLifeProtocol <NSObject>

@required

/**
 * page change callback
 */
- (void)onPageChange:(PageChangeType)pageChangeType
              fromVC:(UIViewController*)fromVC
                toVC:(UIViewController*)toVC
                args:(NSDictionary*)args;




/**
 * viewDidAppear callback
 */
- (void)onViewDidAppear:(BOOL)animated viewController:(UIViewController*)viewController;

/**
 * viewDidLayoutSubviews callback
 */
- (void)onViewDidLayoutSubviews:(UIViewController*)viewController;

/**
 * viewDidDisappear callback
 */
- (void)onViewDidDisappear:(BOOL)animated viewController:(UIViewController*)viewController;

@optional

- (void)onViewDidLoad:(UIViewController *)viewController;
- (void)onViewWillExit:(UIViewController*)viewController;
- (void)onViewWillAppear:(BOOL)animated viewController:(UIViewController*)viewController;
- (void)onViewWillDisappear:(BOOL)animated viewController:(UIViewController*)viewController;


/**
 * NavigationDidEndTransitionFromView callback
 */
- (void)onNavigationDidEndTransitionFromView:(UIView*)view toView:(UIView*)toView;

/**
 * container view(UITableViewCellContentView, UITableViewCell, UITableView) layout subview callback
 */
- (void)onUIViewLayoutSubviews;

@end

/**
 * user event protocol
 */
@protocol AliHAUserEventProtocol <NSObject>

/**
 * on general user event
 */
- (void)onUserEvent;

/**
 * on user tap event
 */
- (void)onUserTap;

/**
 * on user swipe event
 */
- (void)onUserSwipe;

@end

#pragma AliHA runtime task protocol
@protocol AliHARuntimeTaskProtocol <NSObject>

/**
 * on customized task begin
 */
- (void)onTaskBegin:(NSString *)taskName thread:(NSString *)thread;

/**
 * on customized task end
 */
- (void)onTaskEnd:(NSString *)taskName;

@end

#pragma HA util protocol
@protocol AliHAPageResolverProtocol <NSObject>

/**
 * 获取VC真实的地址，webview -> url, weex - > url
 */
- (NSString*)getRealPageNameByVC:(UIViewController*)toVC;

/**
 * get page params from vc, such as product id, shop id .etc
 * @return page params kv pair
 */
- (NSDictionary*)getPageParamsByVC:(UIViewController *)toVC;

/**
 * 排除UITabBarController、UINavigationController等类型
 */
- (BOOL)isVaildViewController:(UIViewController*)viewController;

/**
 * 排除UITabBarController、UINavigationController等类型
 */
- (UIViewController*)getRealUIViewController:(UIViewController*)viewController;

@end

#pragma HA context protocol
@protocol AliHAContextProtocol <NSObject>

/**
 * register app lifecycle listener
 */
- (void)registerAppLifeListener:(id<AliHAAppLifeProtocol>)listener;

/**
 * register vc lifecycle listener
 */
- (void)registerVCLifeListener:(id<AliHAVCLifeProtocol>)listener;

/**
 * register user event listener
 */
- (void)registerUserEventListener:(id<AliHAUserEventProtocol>)listener;

/**
 * register customized task listener
 */
- (void)registerCustomizedTaskListener:(id<AliHARuntimeTaskProtocol>)listener;

/**
 * @return configuration delegate
 */
- (id<AliHAConfigProtocol>)getConfigDelegate;

/**
 * @return logger delegate
 */
- (id<AliHALoggerProtocol>)getLogger;

/**
 * @return page resolver delegate
 */
- (id<AliHAPageResolverProtocol>)getPageResolver;

/**
 * get appKey
 */
- (NSString *)appKey;

/**
 * get appVersion
 */
- (NSString *)appVersion;

/**
 * get channel
 */
- (NSString *)channel;

/**
 * get nick
 */
- (NSString *)nick;

/**
 * get utdid
 */
- (NSString *)utdid;

/**
 * is app first launch
 */
- (BOOL)isAppFirstLaunch;

/**
 * is release version or beta version
 */
- (BOOL)isReleaseVersion;

/**
 * get app startup timestamp
 */
- (uint64_t)getAppStartupTimestamp;

/**
 * get current page name
 */
- (NSString *)curPageName;

/**
 * get current VC
 */
- (UIViewController *)curViewController;

/**
 * get current session identifier(a unique session will be generated once app launched)
 */
- (NSString *)getAliHASession;

/**
 * get last tracing file path by session
 */
- (NSString *)getAliHAFileBySession:(NSString *)session;

@end

#pragma HA plugin protocol
@protocol AliHAPluginProtocol <NSObject>

/**
 * plugin init callback, and plugin context can be retrieved
 */
- (void)onPluginInit:(id<AliHAContextProtocol>)context;

/**
 * plugin destory callback
 */
- (void)onPluginDestory;

@end

@interface AliHAProtocol : NSObject

/**
 * @return meta type descriptors
 */
+ (NSDictionary *)getTypeDescriptors;

@end

#endif /* AliHAProtocol_h */
