//
//  OSSUploadService.h
//  RemoteDebugChannel
//
//  Created by hansong.lhs on 2017/12/16.
//  Copyright © 2017年 alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AliHAProtocol/AliHAProtocol.h>
#import <TBJSONModel/TBJSONModel.h>

/**
 * oss upload service impl
 */
@interface AliHAOSSUploadService : NSObject <AliHAUploadProtocol>

+ (AliHAOSSUploadService *)sharedInstance;

@property (nonatomic, copy) NSString *ossBucketName;

@end
