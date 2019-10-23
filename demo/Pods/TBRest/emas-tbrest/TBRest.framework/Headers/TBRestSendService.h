//
//  TBRestSendService.h
//  TBRest
//
//  Created by qiulibin on 16/11/12.
//  Copyright © 2016年 Taobao lnc. All rights reserved.
//

#ifndef TBRestSendService_h
#define TBRestSendService_h

#import <Foundation/Foundation.h>
#import "TBRestConfiguration.h"

@interface TBRestSendService : NSObject

+(TBRestSendService*) shareInstance;

/**
 * 配置初始化，该接口支持更新配置
 * 》》》》》》》》》》》》》》》》提醒：只有调用接口比TBCrashReporter的业务才需要进行配置，比如安全模式 》》》》》》
 * @param config 配置对象,参数存储在对象中
 * @return 配置初始化是否成功，如appkey是必填参数，不可缺少
 */
- (BOOL)configBasicParamWithTBConfiguration:(TBRestConfiguration*)config;

/**
 * 获取配置参数
 * @return 已经配置过了，返回配置的结果，否则返回nil
 */
- (TBRestConfiguration*)obtainConfiguration;

/**
 * 同步接口，注意数据大小不能超过30K
 */
-(BOOL)sendLogSync:(NSObject *)aPageName eventId:(int) aEventId arg1:(NSString *) aArg1 arg2:(NSString *) aArg2 arg3:(NSString *) aArg3 args:(NSDictionary *) aArgs;

/**
 * 异步接口，注意数据大小不能超过30K
 */
-(void)sendLogAsync:(NSObject *)aPageName eventId:(int) aEventId arg1:(NSString *) aArg1 arg2:(NSString *) aArg2 arg3:(NSString *) aArg3 args:(NSDictionary *) aArgs;

@end


#endif /* TBRestSendService_h */
