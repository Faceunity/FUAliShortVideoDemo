//
//  AdapterExceptionModule.h
//  TBCrashReporterAdapter
//
//  Created by qiulibin on 2017/3/28.
//  Copyright © 2017年 Taobao lnc. All rights reserved.
//

#ifndef AdapterExceptionModule_h
#define AdapterExceptionModule_h

#import <Foundation/Foundation.h>
#import <mach/mach.h>
#import "AdapterBaseModule.h"

@interface AdapterExceptionModule : AdapterBaseModule

/**
 * 错误ID
 */
@property (nonatomic,readwrite) NSString* exceptionId;
/**
 * 错误code
 */
@property (nonatomic,readwrite) NSString* exceptionCode;
/**
 * 这里可以指定发生exception的业务版本
 */
@property (nonatomic,readwrite) NSString* exceptionVersion;
/**
 * 扩展字段1
 */
@property (nonatomic,readwrite) NSString* exceptionArg1;
/**
 * 扩展字段2
 */
@property (nonatomic,readwrite) NSString* exceptionArg2;
/**
 * 扩展字段3
 */
@property (nonatomic,readwrite) NSString* exceptionArg3;
/**
 * 自定义扩展字段args
 */
@property (nonatomic,readwrite) NSDictionary* exceptionArgs;

/**
 * 错误明细数据，无堆栈信息，那么填入错误信息也可
 */
@property (nonatomic,readwrite) NSString* exceptionDetail;
/**
 * 线程信息
 */
@property (nonatomic,readwrite) thread_t thread;
/**
 * 当前堆栈，这个值有的话，优先使用
 */
@property (nonatomic,readwrite) NSString* currentStack;


@end


#endif /* AdapterExceptionModule_h */
