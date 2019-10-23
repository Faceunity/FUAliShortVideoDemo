//
//  RemoteDebugChannel.h
//  RemoteDebugChannel
//
//  Created by hansong.lhs on 2017/12/20.
//  Copyright © 2017年 alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AliHAProtocol/AliHAProtocol.h>
#import "AliHARPCMessageService.h"
#import "AliHAOSSUploadService.h"
#import "AliHACephUploadService.h"

@interface RemoteDebugChannel : NSObject

@property (nonatomic, weak) id<AliHARemoteDebugMessageProtocol> defaultMessageDelegate;  // default message delegate
@property (nonatomic, weak) id<AliHAUploadProtocol> defaultUploadDelegate;  // default upload delegate

/**
 * instance method
 */
+ (RemoteDebugChannel*)sharedInstance;

/**
 * prepare for remote command
 */
- (void)prepareForRemoteCommand:(void(^)(RemoteDebugRequest *request))commandHandler __attribute__((deprecated));

@end
