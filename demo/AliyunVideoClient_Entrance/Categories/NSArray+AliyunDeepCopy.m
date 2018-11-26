//
//  NSArray+AliyunDeepCopy.m
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/5.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "NSArray+AliyunDeepCopy.h"

@implementation NSArray (AliyunDeepCopy)

-(instancetype)aliyunDeepCopy{
    if ([self isKindOfClass:[NSArray class]]) {
        NSArray *arr =(NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
        return arr;
    }else{
        return self;
    }
}

@end
