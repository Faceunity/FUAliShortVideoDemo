//
//  TLogBiz.h
//  TRemoteDebugger
//
//  Created by 洋大 on 15/4/1.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TRDConstDefine.h"

@interface TLogBiz : NSObject

- (instancetype)initWithModuleName:(NSString*)moduleName;

- (void)debug:(NSString *)message;

- (void)debug:(NSString *)message exception:(NSException *)exception;

- (void)info:(NSString *)message;

- (void)info:(NSString *)message exception:(NSException *)exception;

- (void)warn:(NSString *)message;

- (void)warn:(NSString *)message exception:(NSException *)exception;

- (void)error:(NSString *)message;

- (void)error:(NSString *)message exception:(NSException *)exception;

- (void)log:(TLogLevel)level exception:(NSException*)exception content:(NSString*)message, ...;

@end
