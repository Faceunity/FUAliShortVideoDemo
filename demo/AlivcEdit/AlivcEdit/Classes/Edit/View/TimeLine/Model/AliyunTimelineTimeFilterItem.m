//
//  AliyunTimelineTimeFilterItem.m
//  qusdk
//
//  Created by Vienta on 2018/2/26.
//  Copyright © 2018年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunTimelineTimeFilterItem.h"
#import "UIColor+AlivcHelper.h"

@implementation AliyunTimelineTimeFilterItem
- (instancetype)init
{
    self = [super init];
    if (self) {
        _displayColor = [UIColor colorWithHexString:@"0x3CF2FF" alpha:0.7];
        
    }
    return self;
}
@end
