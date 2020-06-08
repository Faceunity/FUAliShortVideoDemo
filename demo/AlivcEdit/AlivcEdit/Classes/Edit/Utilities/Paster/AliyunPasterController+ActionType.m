//
//  AliyunPasterController+ActionType.m
//  AliyunVideoClient_Entrance
//
//  Created by 孙震 on 2019/5/25.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AliyunPasterController+ActionType.h"
#import "objc/runtime.h"

static const char AlivcActionTypeKey = '\0';
static const char AlivcTempActionTypeKey = '\1';

@implementation AliyunPasterController (ActionType)

- (void)setActionType:(TextActionType)actionType{
    objc_setAssociatedObject(self, &AlivcActionTypeKey, @(actionType), OBJC_ASSOCIATION_ASSIGN);
}
- (TextActionType)actionType{
    return [objc_getAssociatedObject(self, &AlivcActionTypeKey) integerValue];
}

- (void)setTempActionType:(TextActionType)tempActionType{
    objc_setAssociatedObject(self, &AlivcTempActionTypeKey, @(tempActionType), OBJC_ASSOCIATION_ASSIGN);
}

- (TextActionType)tempActionType{
    return [objc_getAssociatedObject(self, &AlivcTempActionTypeKey) integerValue];
}

@end
