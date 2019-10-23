//
//  AliHARetainCycleMonitor.h
//  AliHAMemoryMonitorCore
//
//  Created by junzhan on 2017/7/31.
//  Copyright © 2017年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AliHAProtocol/AliHAProtocol.h>

@interface AliHARetainCycleMonitor : NSObject<AliHAPluginProtocol>

@end


@interface TestCycleRootObject : NSObject

@end


#ifdef DEBUG

#define  TestObjectClass(x) \
@interface TestObject##x : TestCycleRootObject \
@property (nonatomic, strong) id object;\
@property (nonatomic, strong) id secondObject;\
@end\
@implementation TestObject##x\
@end\

#endif
