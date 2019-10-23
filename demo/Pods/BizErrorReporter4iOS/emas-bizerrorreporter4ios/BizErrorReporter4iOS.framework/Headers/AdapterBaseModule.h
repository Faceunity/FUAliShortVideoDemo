//
//  AdapterBaseModule.h
//  TBCrashReporterAdapter
//
//  Created by qiulibin on 2017/3/28.
//  Copyright © 2017年 Taobao lnc. All rights reserved.
//

#ifndef AdapterBaseModule_h
#define AdapterBaseModule_h

#import <Foundation/Foundation.h>

typedef enum : NSUInteger{
    ADAPTER_STACK=0,  //("按堆栈聚合，传入堆栈对象throwable"),
    ADAPTER_CONTENT=1 //("根据内容聚合，无堆栈的错误就根据内容聚合");
} ADAPTER_AGGREGATION_TYPE;


typedef enum : NSUInteger{
    ADAPTER_WEEX_ERROR=0,     //("weex js error"),
    ADAPTER_WINDVANE_ERROR=1, //("windvane error"),
    ADAPTER_IMAGE_ERROR=2    //("图片库错误")
} ADAPTER_BUSINESS_TYPE;


@interface AdapterBaseModule : NSObject

/**
 * 业务类型
 */
@property (nonatomic, readwrite) ADAPTER_BUSINESS_TYPE businessType DEPRECATED_ATTRIBUTE;

/**
 * 自定义业务类型， 和crash平台配置的保持一致
 */
@property (nonatomic,readwrite) NSString* customizeBusinessType;

/**
 * 聚合类型
 */
@property (nonatomic, readwrite) ADAPTER_AGGREGATION_TYPE aggregationType;


-(NSString *) NSStringFromAggregationType;
-(NSString *) NSStringFromBusinessType;

@end

#endif /* AdapterBaseModule_h */

