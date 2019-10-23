//
//  AliHAPerformanceMonitor.h
//  AliHAPerformanceMonitor
//
//  Created by hansong.lhs on 2017/8/1.
//  Copyright © 2017年 alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AliHAProtocol/AliHAProtocol.h>

#ifndef kAliHAStartupEndNotification
#define kAliHAStartupEndNotification        @"AliHAStartupEnd"
#endif

typedef void(^PerformanceDataOutputBlock)(NSString*pageName, NSInteger interval, NSDictionary *extraInfos);

@interface AliHAPerformanceMonitor : NSObject <AliHAPluginProtocol>

+ (void)setPerfomanceDataHandler:(PerformanceDataOutputBlock)performanceDataHandler;

@end
