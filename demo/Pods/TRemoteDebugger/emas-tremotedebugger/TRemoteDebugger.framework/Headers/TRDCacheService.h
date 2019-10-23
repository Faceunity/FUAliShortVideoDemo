//
//  TRDCacheService.h
//  TRemoteDebuggerDemo
//
//  Created by yingfang on 15/8/18.
//  Copyright © 2015年 yingfang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AliHAProtocol/AliHAProtocol.h>
#import "TRDConstDefine.h"


#pragma log object
@interface LogObject : NSObject

@property (nonatomic, assign) TLogLevel logLevel;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *module;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, copy) NSString *curTimeString;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *exception;

@end


@interface TRDCacheService : NSObject

/**
 * init cache service
 */
- (id)init;

/**
 * write log
 */
- (void)cache:(LogObject *)logObject;

/**
 * sync cache to file
 */
- (void)syncCacheToFile;

/**
 * clean all log files
 */
- (void)cleanCacheLogFiles;

/**
 * get log logs of recent days
 */
- (NSArray<RemoteDebugLocalFileItem *> *)getRecentLogsByDay:(NSInteger)numDays;

@end
