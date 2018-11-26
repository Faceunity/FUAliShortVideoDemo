//
//  AlivcVideoPlayListModel.m
//  AliyunVideoClient_Entrance
//
//  Created by 王凯 on 2018/5/23.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcVideoPlayListModel.h"

@implementation AlivcVideoPlayListModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

+ (JSONKeyMapper *)keyMapper {
    
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:
  @{@"status":@"Status",
    @"duration":@"Duration",
    @"creationTime" : @"CreationTime",
    @"modifyTime" : @"ModifyTime",
    @"size" : @"Size",
    @"coverURL" : @"CoverURL",
    @"title" : @"Title",
    @"createTime" : @"CreateTime",
    @"videoId" : @"VideoId",
    @"snapshots" : @"Snapshots"
    }];
}

@end

