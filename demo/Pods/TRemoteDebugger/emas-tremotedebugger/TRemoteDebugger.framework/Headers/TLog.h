//
//  TLog.h
//  TRemoteDebugger
//
//  Created by 洋大 on 15/2/3.
//  Copyright (c) 2015年 Taobao.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AliHAProtocol/AliHAProtocol.h>

#import "TRDConstDefine.h"
//!  TLOG_DEBUG < TLOG_INFO < TLOG_WARN < TLOG_ERROR < TLOG_OFF

@interface TLog : NSObject

+ (void)trace:(NSDictionary *)content category:(NSString *)category __attribute__((deprecated));

+ (void)debug:(NSString *)message;

+ (void)debug:(NSString *)message exception:(NSException *)exception;

+ (void)info:(NSString *)message;

+ (void)info:(NSString *)message exception:(NSException *)exception;

+ (void)warn:(NSString *)message;

+ (void)warn:(NSString *)message exception:(NSException *)exception;

+ (void)error:(NSString *)message;

+ (void)error:(NSString *)message exception:(NSException *)exception;

+ (void)log:(TLogLevel)level exception:(NSException*)exception content:(NSString*)message, ...;

+ (TLogLevel)logLevel;

@end
