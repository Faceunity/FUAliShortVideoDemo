//
//  Header.h
//  TRemoteDebuggerDemo
//
//  Created by yingfang on 15/8/19.
//  Copyright © 2015年 yingfang. All rights reserved.
//

#ifndef TRDConstDefine_h
#define TRDConstDefine_h


/** command keys */
#define kGodeyeKey_uploadId         @"uploadId"
#define kGodeyeKey_commandSet       @"commandSet"
#define kGodeyeKey_command          @"command"
#define kGodeyeKey_startJointPoint  @"start"
#define kGodeyeKey_stopJointPoint   @"stop"
#define kGodeyeKey_jointPointType   @"type"
#define kGodeyeKey_maxTrys          @"maxTrys"
#define kGodeyeKey_bufferSize       @"bufferSize"
#define kGodeyeKey_samplingInterval @"samplingInterval"
#define kGodeyeKey_useMmap          @"useMmap"
#define kGodeyeKey_numTrys          @"numTrys"
#define kGodeyeKey_filePath         @"filePath"
#define kGodeyeKey_progress         @"progress"

typedef NS_OPTIONS (NSInteger, TLogFlag) {
    TLogFlagOff         = 0,//(1 << 0), // 0...10000
    TLogFlagError       = 1,//(1 << 1), // 0...00001
    TLogFlagWarn        = 2,//(1 << 2), // 0...00010
    TLogFlagInfo        = 3,//(1 << 3), // 0...00100
    TLogFlagDebug       = 4,//(1 << 4), // 0...01000
    TLogFlagEnd
};

typedef NS_ENUM (NSInteger, TLogLevel) {
    TLogLevelOFF            = TLogFlagOff,
    TLogLevelError          = TLogFlagError,
    TLogLevelWarn           = TLogFlagWarn,
    TLogLevelInfo           = TLogFlagInfo,
    TLogLevelDebug          = TLogFlagDebug
};



typedef NS_ENUM (NSInteger, TLogInterfaceLogType) {
    TLogInterfaceLogTypeCustom,
    TLogInterfaceLogTypeAOP,
    TLogInterfaceLogTypeFormat
};

#endif /* TRDConstDefine_h */
