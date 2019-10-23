//
//  MotuReportAdapteHandler.h
//  TBCrashReporterAdapter
//
//  Created by qiulibin on 2017/3/28.
//  Copyright © 2017年 Taobao lnc. All rights reserved.
//

#ifndef MotuReportAdapteHandler_h
#define MotuReportAdapteHandler_h
#import <Foundation/Foundation.h>
#import "AdapterExceptionModule.h"

@interface MotuReportAdapteHandler : NSObject

- (void) adapterWithExceptionModule:(AdapterExceptionModule*)exceptionModule;

/**
 * 这是个同步接口，不要在主线程调
 * @return YES == 发送成功
 * @return NO  == 发送失败
 */
- (BOOL) adapterSyncWithExceptionModule:(AdapterExceptionModule*)exceptionModule;


@end


#endif /* MotuReportAdapteHandler_h */
