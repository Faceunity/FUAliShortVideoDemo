//
//  AdapterSenderModule.h
//  TBCrashReporterAdapter
//
//  Created by qiulibin on 2017/3/28.
//  Copyright © 2017年 Taobao lnc. All rights reserved.
//

#ifndef AdapterSenderModule_h
#define AdapterSenderModule_h
#import <Foundation/Foundation.h>

@interface AdapterSenderModule : NSObject

/**
 * 发送的内容
 */
@property(nonatomic,readwrite) NSDictionary* sendContent;
/**
 * 业务类型
 */
@property(nonatomic,readwrite) NSString* businessType;
/**
 * 聚合类型
 */
@property(nonatomic,readwrite) NSString* aggregationType;
/**
 * event id
 */
@property(nonatomic,readwrite) int eventId;
/**
 * 发送标记
 */
@property(nonatomic,readwrite) NSString* sendFlag;
/**
 * 当前线程堆栈
 */
@property(nonatomic,readwrite) NSString* currentStack;

@end

#endif /* AdapterSenderModule_h */
