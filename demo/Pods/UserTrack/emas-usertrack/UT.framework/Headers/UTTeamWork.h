//
// UTTeamWork.h
// 
// UserTrack 
// 开发团队：数据通道团队 
// UT答疑群：11791581(钉钉) 
// UT埋点平台答疑群：11779226(钉钉) 
// 
// Copyright (c) 2014-2017 Taobao. All rights reserved. 
//

#import <Foundation/Foundation.h>
#import "UTExposureViewProtocol.h"

@interface UTTeamWork : NSObject

+(void) turnOnRealTimeDebug:(NSDictionary *) pDict;

+(void) trunOffRealTimeDebug;



+ (void)setConfigMgr:(NSDictionary *) pDict withNameSpace: (NSString *) pName isUpdate:(BOOL) isUpdate;

+ (void)setHasOrange;

//UT内部已经可以判断是二方的安全黑匣子还是三方的安全黑匣子
//该接口已经被空实现，无需调用了
+ (void)appIsOpenSet __deprecated;

+ (void)registerExposureViewHandler:(id<UTExposureViewProtocol>)handler;

+ (id<UTExposureViewProtocol>)utExposureViewHandler;

+ (void)unregisterExposureViewHandler:(id<UTExposureViewProtocol>)handler;

@end
