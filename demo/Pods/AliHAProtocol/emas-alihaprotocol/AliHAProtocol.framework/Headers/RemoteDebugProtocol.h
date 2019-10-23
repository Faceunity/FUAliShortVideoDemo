//
//  RemoteDebug.h
//  AliHAProtocol
//
//  Created by hansong.lhs on 2017/12/18.
//  Copyright © 2017年 alibaba. All rights reserved.
//

#ifndef RemoteDebug_h
#define RemoteDebug_h

#import <Foundation/Foundation.h>
#import <TBJSONModel/TBJSONModel.h>

#pragma messages type
extern NSString * const MESSAGE_TYPE_REQUEST;
extern NSString * const MESSAGE_TYPE_REPLY;
extern NSString * const MESSAGE_TYPE_NOTIFY;

#pragma opcode
extern NSString * const OPCODE_ACK;
extern NSString * const OPCODE_STARTUP;
extern NSString * const OPCODE_APPLY_UPLOAD_TOKEN;                  // 主动上报（适用于有upload_id的情况）
extern NSString * const OPCODE_APPLY_UPLOAD_TOKEN_REPLY;
extern NSString * const OPCODE_APPLY_UPLOAD;                        // 主动上报（适用于无upload_id的情况）
extern NSString * const OPCODE_APPLY_UPLOAD_REPLY;
extern NSString * const OPCODE_APPLY_UPLOAD_COMPLETE;
extern NSString * const OPCODE_APPLY_UPLOAD_COMPLETE_REPLY;
extern NSString * const OPCODE_LOG_CONFIGURE;
extern NSString * const OPCODE_LOG_CONFIGURE_REPLY;
extern NSString * const OPCODE_LOG_UPLOAD;
extern NSString * const OPCODE_LOG_UPLOAD_REPLY;
extern NSString * const OPCODE_METHOD_TRACE_DUMP;
extern NSString * const OPCODE_METHOD_TRACE_DUMP_REPLY;
extern NSString * const OPCODE_HEAP_DUMP;
extern NSString * const OPCODE_HEAP_DUMP_REPLY;
extern NSString * const OPCODE_PACKET_PULL;                         // pull packet on receive command

#pragma debug type
extern NSString * const DEBUG_TYPE_UNKOWN;
extern NSString * const DEBUG_TYPE_TLOG;
extern NSString * const DEBUG_TYPE_METHOD_TRACE;
extern NSString * const DEBUG_TYPE_HEAP_DUMP;

#pragma biz type
extern NSString * const BIZ_TYPE_UNKOWN;
extern NSString * const BIZ_TYPE_FEEDBACK;
extern NSString * const BIZ_TYPE_CRASH;

#pragma AliHA remote debug message protocol

/**
 * message base
 */
@interface RemoteDebugMessagePacket : NSObject

// protocol root
@property (nonatomic, copy) NSString *type;                 // request or response
@property (nonatomic, copy) NSString *version;              // remote debug protocol version


// protocol header
@property (nonatomic, strong) NSMutableDictionary *headers; // headers
@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) NSString *requestId;
@property (nonatomic, copy) NSString *opCode;               // operation code
@property (nonatomic, copy) NSString *platform;             // platform

// protocol body
@property (nonatomic, strong) NSMutableDictionary *data;    // body data
@property (nonatomic, copy) NSString *bizType;              // biz type
@property (nonatomic, copy) NSString *debugType;            // debug type
@property (nonatomic, copy) NSString *tokenType;            // token type
@property (nonatomic, copy) NSDictionary *tokenInfo;        // token info
@property (nonatomic, copy) NSString *uploadId;             // upload id
@property (nonatomic, copy) NSDictionary *forward;          // forward params
@property (nonatomic, copy) NSDictionary *extraInfo;        // extra info

- (instancetype)init;

- (instancetype)initWithJson:(NSDictionary *)json;

- (NSString *)serializeToJSONString;

@end

/**
 * abstraction of server response
 */
@interface RemoteDebugResponse : RemoteDebugMessagePacket

@property (nonatomic, copy) NSString *replyId;
@property (nonatomic, copy) NSString *replyCode;
@property (nonatomic, copy) NSString *replyMessage;

@end

/**
 * abstraction of client request
 */
@interface RemoteDebugRequest : RemoteDebugMessagePacket

@end

/**
 * local file item(for upload)
 */
@interface RemoteDebugLocalFileItem : TBJSONModel

@property (nonatomic, copy) NSString *absolutePath;
@property (nonatomic, copy) NSString *contentEncoding;
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, assign) NSUInteger contentLength;
@property (nonatomic, copy) NSString *contentMD5;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, assign) NSTimeInterval lastModified;

@end

/**
 * remote file item(for upload complete)
 */
@interface RemoteDebugRemoteFileItem : RemoteDebugLocalFileItem

@property (nonatomic, copy) NSString *storageType;
@property (nonatomic, copy) NSDictionary *storageInfo;  // storage info

@end

/**
 * upload file request
 */
@interface RemoteDebugUploadFileReqeust : RemoteDebugRequest

@property (nonatomic, copy) NSArray<RemoteDebugLocalFileItem *> *fileInfos;

@end

/**
 * upload file request
 */
@interface RemoteDebugUploadFileCompleteResponse : RemoteDebugResponse

@property (nonatomic, copy) NSArray<RemoteDebugLocalFileItem *> *remoteFileInfos;

@end

/**
 * message channel protocol
 */
@protocol AliHARemoteDebugMessageProtocol <NSObject>

/**
 * send startup message
 */
- (void)sendStartupMessage:(RemoteDebugRequest *)request resultsBlock:(void(^)(NSError *error, RemoteDebugResponse *response))resultsBlock;

/**
 * send data(up-going)
 */
- (void)sendData:(RemoteDebugMessagePacket *)request resultsBlock:(void(^)(NSError *error, RemoteDebugResponse *response))resultsBlock;

/**
 * pull data
 */
- (void)pullData:(NSString *)appKey deviceId:(NSString *)deviceId resultsBlock:(void (^)(NSError *, RemoteDebugResponse *))resultsBlock;

@end


#pragma remote deubug command handler protocol

/**
 * abstraction of remote debug biz(log upload, log configuration, method trace, heap dump)
 */
@protocol RemoteDebugCommandHandler

/**
 * opocode that can be handled
 */
- (NSString *)targetOpCode;

/**
 * handle command
 * @return command is handled successfully or not
 */
- (BOOL)handleCommand:(RemoteDebugMessagePacket *)packet;

@end


#pragma upload protocol

typedef void (^UploadResultBlock)(RemoteDebugUploadFileCompleteResponse* uploadFileCompleteResponse);
typedef void (^UploadFailureBlock)(NSString* errorMsg);

typedef NS_ENUM(NSInteger, AliHAUploadReasonType) {
    AliHAUploadReasonInvalid = 0,
    AliHAUploadReasonLog,
    AliHAUploadReasonMethodTrace,
    AliHAUploadReasonMemoryDump
};


#pragma file upload protocl

@protocol AliHAUploadProtocol <NSObject>

/**
 * upload file async
 * we want to make the upload process clean and simple, serveral steps will be required to upload a file:
 * 1) request upload token(if we have already get upload-id)
 * 2) direct upload file
 */
- (void)uploadFileAsync:(RemoteDebugUploadFileReqeust *)request
        successCallback:(UploadResultBlock)succssCallback
        failureCallback:(UploadFailureBlock)failureCallback;

@end

#endif /* RemoteDebug_h */
