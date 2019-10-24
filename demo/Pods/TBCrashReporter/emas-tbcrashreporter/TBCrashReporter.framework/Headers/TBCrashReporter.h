//
//  TBCrashReporter.h
//  CrashReporterDemo
//
//  Created by 贾复 on 15/3/16.
//  Copyright (c) 2015年 Taobao lnc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach_types.h>
#import <CrashReporter/CrashReporter.h>

#import <AliHAProtocol/AliHAProtocol.h>

void TBCrashReporterSetPreHandler(BOOL(*handler)(uintptr_t));

@protocol TBCrashReporterDelegate <NSObject>
@optional
/**
 *  完整crashreport上传接口
 *  @param plCrashReport 完整crash
 */
- (void)uploadPLCrashReport:(NSString *)plCrashReport;
/**
 *  crash堆栈和原因上传接口
 *  @param backTrace crash堆栈
 *  @param reason    crash原因
 */
- (void)uploadCrashBackTrace:(NSString *)backTrace withReason:(NSString *)reason;
/**
 *  主线程死锁堆栈上报接口
 *  @param backtrace 死锁堆栈
 */
- (void)uploadMainThreadDeadlockWithBacktrace:(NSString *)backtrace;
@end
//--------------------------------------------------------------------------------------------------------------
@protocol TBCrashReporterRunLoopDelegate <NSObject>
@optional
/**
 *  发生卡顿时的回调
 */
- (void)mainRunLoopStuckCallBack:(NSString *)report ExtData:(NSDictionary*)extData;
@end

//--------------------------------------------------------------------------------------------------------------
@interface TBCrashReporter : NSObject <AliHAPluginProtocol>

@property (nonatomic, strong) id<AliHAContextProtocol> aliHAContext;
@property (nonatomic, assign) id<TBCrashReporterDelegate> delegate;
@property (nonatomic, assign) id<TBCrashReporterRunLoopDelegate> runLoopDelegate  __attribute__((deprecated));

+ (instancetype)sharedReporter;

- (PLCrashReporter *) getPLCrashReport;

/**
 *  TBCrashReporter 初始化
 */
- (void)initCrashSDK:(NSString*)appKey AppVersion:(NSString*)appVersion Channel:(NSString*)channel Usernick:(NSString*)usernick;

/**
 * 卡顿检测，欢迎使用
 * initCrashSDK 接口调用后调用 || 不调用也可，因为默认会帮你开启，默认检测卡顿间隔时间为5s,默认正式版本会采样（千分之一）
 * 调用该接口时默认的检测时间为5s
 */
- (void) startMainRunLoopObserver;

/**
 * 卡顿检测，欢迎使用
 * initCrashSDK 接口调用后调用 || 不调用也可，因为默认会帮你开启，默认检测卡顿间隔时间为5s,默认正式版本会采样（千分之一）
 * 调用该接口时传入检测间隔时间，blockTime的单位为秒，如设置检测间隔时间为1秒，那么传入1.0，如果设置检测间隔300毫秒，那么传入0.3.
 */
- (void) startMainRunLoopObserverWithBaseBlockTime:(float)blockTime;

/**
 * 卡顿检测，欢迎使用
 * initCrashSDK 接口调用后调用 || 不调用也可，因为默认会帮你开启，默认检测卡顿间隔时间为5s,默认正式版本会采样（千分之一）
 * 调用该接口时传入检测间隔时间，blockTime的单位为秒，如设置检测间隔时间为1秒，那么传入1.0，如果设置检测间隔300毫秒，那么传入0.3.
 * isCloseSampling表示是否关闭采样，关闭-YES，开启-NO，关闭后不分正式和灰度，全量检测卡顿。
 */
- (void) startMainRunLoopObserverWithBaseBlockTime:(float)blockTime isCloseSampling:(BOOL)isClose;

/**
 * 卡顿检测，欢迎使用
 * 注册发生卡顿时的回调
 */
- (void)registMainRunLoopCallBack:(id<TBCrashReporterRunLoopDelegate>)mainRunLoop;

/**
 * 卡顿检测，欢迎使用
 * 关闭卡顿检测的接口
 */
- (void) turnOffMainRunLoopObserver;

/**
 *  当用户更换帐号登录时，重新传递一次usernick
 */
- (void)setWhenChangeUserNick:(NSString*)usernick;

/**
 *  当用户更换appVersion的时候，重新设置appVersion
 */
- (void)setWhenChangeAppVersion:(NSString*)appVersion;

/**
 *  是否合并重复的crash文件，如果需要请设置为YES
 */
- (void)setMergeCrashReport:(BOOL)isMerge;

/**
 *  使用方调用该接口检查是否有crash文件，有的话则会实现上传，调用时机可由使用方自己决定
 * （建议不要在启动时调用，可在其他时机调用，如应用切后台时调用等）
 */
- (void)checkAndUploadCrashReporter;

/**
 * 单独发送使用方捕获的crashreport，手淘用
 */
- (void)sendCatchedCrashReportWithContent:(NSString*)content  __attribute__((deprecated));

/**
 * 单独发送使用方捕获的crashreport，分类型，手淘用
 */
- (void)sendCatchedCrashReportWithType:(NSString*)type SubType:(NSString*)subType Content:(NSString*)content __attribute__((deprecated));

/**
 * 生成crashreport， 手淘用
 */
- (NSString*) generateLiveReportWithThread:(thread_t)thread;

/**
 * 单独发送使用方捕获的crashreport，增加上传额外信息.手淘用
 */
- (void)sendCatchedCrashReportWithContent:(NSString *)content ExtInfo:(NSDictionary *)extInfo;

/**
 * 单独发送使用方捕获的crashreport，增加上传额外信息.分类型，手淘用
 */
- (void)sendCatchedCrashReportWithType:(NSString*)type SubType:(NSString*)subType Content:(NSString*)content ExtInfo:(NSDictionary *)extInfo;

/**
 * 如果在crashreporter初始化前需要进行发送，那么先调用该接口进行初始化
 */
-(void) beforeSendInitArgsWithAppkey:(NSString*)appKey Channel:(NSString*)channel UserNick:(NSString*)usernick AppVersion:(NSString*) appVersion __attribute__((deprecated));

/**
 * 数据发送接口，同步接口，手淘用，注意数据大小不能超过30K
 * 调用前请确认：initCrashSDK已调用 || beforeSendInitArgsWithAppkey已调用
 */
-(BOOL) sendLogSync:(NSObject *)aPageName eventId:(int) aEventId arg1:(NSString *) aArg1 arg2:(NSString *) aArg2 arg3:(NSString *) aArg3 args:(NSDictionary *) aArgs __attribute__((deprecated));

/**
 * 数据发送接口，异步接口，手淘用，注意数据大小不能超过30K
 * 调用前请确认：initCrashSDK已调用 || beforeSendInitArgsWithAppkey已调用
 */
-(void) sendLogAsync:(NSObject *)aPageName eventId:(int) aEventId arg1:(NSString *) aArg1 arg2:(NSString *) aArg2 arg3:(NSString *) aArg3 args:(NSDictionary *) aArgs __attribute__((deprecated));

/**
 * 设置TBCrashReporter的捕获方式为mach exception，输入参数设置为YES,该接口调用需在initCrashSDK之前。
 * 该模式能一定程度的增加crash的捕获率，如死锁等，但对于ios平台仍然不太完善，接入方慎用该模式。
 */
- (void)setCrashReporterModuleToMachException:(BOOL)isMachException __attribute__((deprecated));

/**
 *  开始主线程死锁监控, 需要在initCrashSDK之后调用
 */
- (void)turnOnMainThreadDeadlockMonitor __attribute__((deprecated));

/**
 *  开启主线程监控并设置死锁时间周期, 需要在initCrashSDK之后调用
 *
 *  @param deadlockInterval 死锁时间周期（PS：这个值设小了会把有些正常人物误认为死锁，设大了在检测到死锁时用户可能强退导致不能上报数据，默认为5s）
 */
- (void)turnOnMainThreadDeadlockMonitorWithDealockInterval:(NSTimeInterval)deadlockInterval __attribute__((deprecated));

/**
 *  关闭
 */
- (void)turnOffMainThreadDeadlockMonitor __attribute__((deprecated));

@end
