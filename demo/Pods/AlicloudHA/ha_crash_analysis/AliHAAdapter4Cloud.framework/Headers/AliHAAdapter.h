//
//  AliHATBAdapter.h
//  AliHATBAdapter
//
//  Created by hansong.lhs on 2017/7/31.
//  Copyright © 2017年 alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AliHAProtocol/AliHAProtocol.h>

@interface AliHAAdapter : NSObject

+ (void)initWithAppKey:(NSString *)appKey
                secret:(NSString *)secret
            appVersion:(NSString *)appVersion
               channel:(NSString *)channel
               plugins:(NSArray<id<AliHAPluginProtocol>> *) plugins
                  nick:(NSString *)nick;

/**
 * initialize AliHA
 * @param plugins custom plugins, and default plugins(crash, performance) will be registered if plugins is nil
 */
+ (void)initWithAppKey:(NSString *)appKey
            appVersion:(NSString *)appVersion
               channel:(NSString *)channel
               plugins:(NSArray<id<AliHAPluginProtocol>> *) plugins
                  nick:(NSString *)nick;


@end
