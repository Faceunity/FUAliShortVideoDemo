//
// UTICrashCaughtListener.h
// 
// UserTrack 
// 开发团队：数据通道团队 
// UT答疑群：11791581(钉钉) 
// UT埋点平台答疑群：11779226(钉钉) 
// 
// Copyright (c) 2014-2017 Taobao. All rights reserved. 
//

#import <Foundation/Foundation.h>

@protocol UTICrashCaughtListener <NSObject>

-(NSDictionary *) onCrashCaught:(NSString *) pCrashReason CallStack:(NSString *)callStack;

@end
