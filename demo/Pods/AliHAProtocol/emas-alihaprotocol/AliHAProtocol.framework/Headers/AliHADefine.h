//
//  AliPerformanceDefine.h
//  AliPerformanceCore
//
//  Created by yingfang on 17/2/15.
//  Copyright © 2017年 alibaba. All rights reserved.
//

#ifndef AliPerformanceDefine_h
#define AliPerformanceDefine_h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Orange配置 组件开关
#define kAliHAIsTraceFileEnabled                          @"isTraceFileEnabled" // 是否打开trace file
#define kAliHAIsPerformanceMonitorEnabled                 @"isPerformanceMonitorEnabled" // 是否打开性能监控
#define kAliHAIsRetainCycleDetectorEnabled                @"isRetainCycleDetectorEnabled" // 是否打开循环引用监控
#define kAliHAIsBigMallocDetectorEnabled                  @"isBigMallocDetectorEnabled" // 大内存申请监控是否打开
#define kAliHAIsTraceFileUploadEnabled                    @"isTraceFileUploadEnabled" // 是否打开trace文件上传功能
#define kAliHAIsMemoryMonitorEnabled                      @"isMemoryMonitorEnabled" // 是否打开内存轮训检测
#define kAliHAIsSmartRecoveryEnabled                      @"isSmartRecoveryEnabled" // 是否开启智能容灾
#define kAliHAIsSmartRecoveryImageMemoryManagerEnabled                      @"isSmartRecoveryImageMemoryManagerEnabled" // 是否开启智能容灾的图片智能回收


// UI更新监控开关
#define kAliHAMonitorVCDidAppear                          @"isMonitorVCDidAppear" // 是否监听vcDidAppear事件更新启动时间
#define kAliHAMonitorVCLayoutSubview                      @"isMonitorVCLayoutSubview" // 是否监听VCLayoutSubview事件
#define kAliHAMonitorUIViewLayoutSubview                  @"isMonitorUIViewLayoutSubview" // 是否监听UIView layoutSubview事件
#define kAliHAMonitorTransitionFromView                   @"isMonitorTransitionFromView" // 是否监听TransitionFromView

//Orange配置 无痕页面埋点控制开关
#define kAliPerformanceConfigDisableFPS                @"fpsSampleDisable"          //帧率收集开关配置key
#define kAliPerformanceConfigDisableNet                @"netSampleDisable"
//Orange配置 页面加载功能开关
#define kAliPerformanceConfigDisablePageLoad           @"pageLoadSampleDisable"

//对外出值的key
#define kAliPerformanceCurPageName                    @"pageName"          //内存收集开关配置key
#define kAliPerformanceVaildPageChange                @"vaildPageChange"
#define kAliPerformanceCurRealVC                      @"curRealVC"

static NSString * const AliPerformancePageNameKey = @"AliPPageNameKey";

#endif /* AliPerformanceDefine_h */
