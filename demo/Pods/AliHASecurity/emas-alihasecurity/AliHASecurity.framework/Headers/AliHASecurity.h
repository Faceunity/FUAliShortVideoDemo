//
//  AliHASecurity.h
//
//
//  Created by hansong.lhs on 2017/12/13.
//  Copyright © 2017年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AliHASecurity : NSObject

// rsa public key
@property (nonatomic, copy, readonly) NSString *rsaPublicKey;

/**
 * instance method
 */
+ (instancetype)sharedInstance;

/**
 * init security util with RSA public key
 */
- (void)initWithRSAPublicKey:(NSString *)key;

/**
 * encrypt string with rsa
 */
- (NSString *)RSADecryptString:(NSString *)string;

/**
 * decrypt string with rsa
 */
- (NSString *)RSAEncryptString:(NSString *)string;

@end
