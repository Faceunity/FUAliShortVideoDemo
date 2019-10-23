//
//  TRDCmdService.h
//  TRemoteDebuggerDemo
//
//  Created by yingfang on 15/8/16.
//  Copyright © 2015年 yingfang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TRDConstDefine.h"
#import "TRDCacheService.h"
#import <AliHAProtocol/AliHAProtocol.h>

#define kTRDCmdServiceInstance [TRDManagerService shareInstance]

@interface TRDManagerService : NSObject <AliHAPluginProtocol>

@property (nonatomic, strong) id<AliHAContextProtocol> context;                         // aliha context
@property (nonatomic, strong) id<AliHARemoteDebugMessageProtocol> messageDelegate;      // message delegate
@property (nonatomic, strong) id<AliHAUploadProtocol> uploadDelegate;                   // upload delegate
@property (nonatomic, strong) TRDCacheService* cacheService;                            // file cache service

@property (nonatomic, copy) NSString *appId;

@property (nonatomic, copy) NSString *specialModule;                                    // special module tag, use to filter log, f**k

+ (TRDManagerService*) shareInstance;

/**
 * handle remote command
 */
- (void)handleRemoteCommand:(RemoteDebugRequest *)commandRequest;

/**
 * set message delegate
 */
- (void)setMessageDelegate:(id<AliHARemoteDebugMessageProtocol>)messageDelegate;

/**
 *
 */
- (void)registerCommand:(NSString*)className
             andCommand:(NSInteger)commadnId  __attribute__ ((deprecated));

/**
 * start tlog service
 */
- (void)startInit;

//逻辑日志接口
- (BOOL)log:(NSString*)module
   andLevel:(TLogLevel)level
andException:(NSString*)exception
 andContent:(NSString*)message, ...;


//逻辑日志接口
- (BOOL)log:(NSString*)module
   andLevel:(TLogLevel)level
andException:(NSString*)exception
  andFormat:(NSString*)format, ...;

/**
 * 用户日志接口
 */
- (BOOL)uLog:(NSString*)module
  andContent:(NSString*)data
     andArgs:(NSString*)args, ...;

/**
 * 用户日志接口
 */
- (BOOL)uLog:(NSString*)module
  andContent:(NSString*)data;


/**
 * 异常日志接口
 */
- (BOOL)eLog:(NSString*)module
  andContent:(NSString*)data
     andArgs:(NSString*)args, ...;

/**
 * ext log
 */
- (BOOL)extLog:(NSString*)module
  andException:(NSString*)exception
      andLevel:(TLogLevel)level
    andContent:(NSArray*)message
       andType:(TLogInterfaceLogType)logType;

@end
