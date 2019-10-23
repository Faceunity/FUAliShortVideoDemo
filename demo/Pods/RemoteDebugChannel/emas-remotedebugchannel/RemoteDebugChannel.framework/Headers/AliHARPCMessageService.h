//
//  AliHARPCMessageService.h
//  AliHACore
//
//  Created by hansong.lhs on 2017/12/21.
//

#import <Foundation/Foundation.h>
#import <AliHAProtocol/AliHAProtocol.h>

@interface AliHARPCMessageService : NSObject <AliHARemoteDebugMessageProtocol>

+ (AliHARPCMessageService *)sharedInstance;

/**
 * @param scheme http schema, http | https
 */
- (void)initWithRPCHost:(NSString *)rpcHost scheme:(NSString *)scheme;

@end
