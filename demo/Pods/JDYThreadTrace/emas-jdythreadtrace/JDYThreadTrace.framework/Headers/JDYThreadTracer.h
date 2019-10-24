//
//  JDYThreadTracer.h
//  JitterDetector
//
//  Created by Jason Lee on 15/10/20.
//  Copyright © 2015年 Jason Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach/mach_types.h>
#import "JDYThreadScene.h"

typedef enum : NSUInteger {
    JDYThreadTraceReportDeviceInfo      = 1UL << 0,
    JDYThreadTraceReportCpuAndMem       = 1UL << 1,
    JDYThreadTraceReportMainThread      = 1UL << 2,
    JDYThreadTraceReportOtherThread     = 1UL << 3,
    JDYThreadTraceReportRegisters       = 1UL << 4, // 目前该标志位无作用
    JDYThreadTraceReportBinaryImages    = 1UL << 5,
    
    JDYThreadTraceReportMain            = 0x27U,    // 不包含OtherThread和Registers标志位
    JDYThreadTraceReportAll             = 0xFFU
} JDYThreadTraceReportMask;

@interface JDYThreadTracer : NSObject

+ (NSString *)generateTraceReport:(JDYThreadTraceReportMask)reportMask;

/**
 * 传入指定的thread，dump指定线程的堆栈数据，如果要获取当前线程，内部会调用 generateTraceReportForCurrentThread 方法
 */
+ (NSString *)generateTraceReportWithThread:(thread_t)thread;

/**
 * dump当前线程的堆栈数据
 */
+ (NSString *)generateTraceReportForCurrentThread;

/**
 * needSymbolicated 标识是否需要开启本地符号化
 */
+ (NSString *)generateTraceReport:(JDYThreadTraceReportMask)reportMask needSymbolicated:(BOOL)needSymbolicated;

/**
 * 很多应用真实的version不等于bundle version，这个时候需要应用自己传入version
 */
+ (NSString *)generateTraceReportWithAppVersion:(NSString*) appVersion ReportMask:(JDYThreadTraceReportMask)reportMask;

/**
 * 获取主线程的堆栈，单纯的堆栈
 */
+ (NSString *)getMainStackTrace;

/**
 * 获取crash时内存信息
 */
+ (NSString *)getCurrentMemoryInfo;

/**
 * 从线程场景中生成可上传的报告，reason可用来区分报告
 */
+ (NSString *)generateTraceReportForThreadScenes:(NSArray *)scenes needSymbolicated:(BOOL)sym reason:(NSString *)reason;

@end
