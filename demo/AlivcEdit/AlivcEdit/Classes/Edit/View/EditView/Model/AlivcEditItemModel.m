//
//  AlivcEditItemModel.m
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/12/26.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcEditItemModel.h"

@implementation AlivcEditItemModel

- (instancetype)initWithType:(AliyunEditSouceClickType)itemType{
    self = [super init];
    if (self) {
        _itemType = itemType;
    }
    return self;
}


@end
