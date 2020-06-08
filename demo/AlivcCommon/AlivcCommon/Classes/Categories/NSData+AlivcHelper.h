//
//  NSData+AlivcHelper.h
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2019/1/11.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (AlivcHelper)

+ (NSData *)dataWithObject:(id <NSSecureCoding>)object;

+ (nullable id<NSSecureCoding>)customInstanceFromData:(NSData *)data forClassType:(Class)classType;

@end

NS_ASSUME_NONNULL_END
