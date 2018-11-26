//
//  UIButton+AliyunBlock.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2018/10/10.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "UIButton+AliyunBlock.h"
#import <objc/runtime.h>
static char overviewKey;
@implementation UIButton (AliyunBlock)
-(void)aliyunOnClickBlock:(OnClickBlock)action{
    objc_setAssociatedObject(self, &overviewKey, action, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(callActionBlock:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)callActionBlock:(id)sender {
    OnClickBlock block = (OnClickBlock)objc_getAssociatedObject(self, &overviewKey);
    if (block) {block();}
}

@end
