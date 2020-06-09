//
//  NSData+AlivcHelper.m
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2019/1/11.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "NSData+AlivcHelper.h"

@implementation NSData (AlivcHelper)

+ (NSData *)dataWithObject:(id<NSSecureCoding>)object{
    NSMutableData *data = [[NSMutableData alloc]init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver setRequiresSecureCoding:YES];
    [archiver encodeObject:object forKey:NSKeyedArchiveRootObjectKey];
    [archiver finishEncoding];
    return data;
}

+ (nullable id<NSSecureCoding>)customInstanceFromData:(NSData *)data forClassType:(Class)classType {
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    [unarchiver setRequiresSecureCoding:YES];
    id object = [unarchiver decodeObjectOfClass:[classType class] forKey:NSKeyedArchiveRootObjectKey];
    return object;
}


@end
