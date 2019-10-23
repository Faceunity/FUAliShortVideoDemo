//
//  TBDevice2.h
//
//
//  Created by Alvin on 4/21/13.
//
//  设备信息的分装类

#ifndef TBRestDevice_h
#define TBRestDevice_h

#import <sys/socket.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "TBRestDeviceInfo.h"


@interface TBRestDevice : NSObject

// 获取设备信息：部分信息的变化性，因此这里需要提供一个 持久配置模块，用于支持这类数据
+ (TBRestDeviceInfo *) getDevice;

// 获取Mac地址
+(NSString *) macAddress;

@end

#endif
