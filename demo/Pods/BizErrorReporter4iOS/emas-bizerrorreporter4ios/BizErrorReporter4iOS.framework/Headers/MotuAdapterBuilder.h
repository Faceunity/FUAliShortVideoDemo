//
//  MotuAdapterBuilder.h
//  TBCrashReporterAdapter
//
//  Created by qiulibin on 2017/3/28.
//  Copyright © 2017年 Taobao lnc. All rights reserved.
//

#ifndef MotuAdapterBuilder_h
#define MotuAdapterBuilder_h

#import <Foundation/Foundation.h>
#import "AdapterSenderModule.h"
#import "AdapterExceptionModule.h"

@interface MotuAdapterBuilder : NSObject

/**
 * build 
 */
- (AdapterSenderModule*)buildWithAdapterExceptionModule:(AdapterExceptionModule*) module;

@end


#endif /* MotuAdapterBuilder_h */
