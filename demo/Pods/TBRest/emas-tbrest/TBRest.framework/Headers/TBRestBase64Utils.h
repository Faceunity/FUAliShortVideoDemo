//
//  TBRestBase64Utils.h
//  TBRest
//
//  Created by hansong.lhs on 2017/11/23.
//  Copyright © 2017年 Taobao lnc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBRestBase64Utils : NSObject

+ (NSString *)base64forData:(NSData *)theData;

@end
