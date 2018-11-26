//
//  AliyunTransitionIcon.m
//  qusdk
//
//  Created by Vienta on 2018/6/6.
//  Copyright © 2018年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunTransitionIcon.h"

@implementation AliyunTransitionIcon

- (id)copyWithZone:(NSZone *)zone{
    AliyunTransitionIcon *newOne = [[AliyunTransitionIcon allocWithZone:zone]init];
    newOne.image = self.image;
    newOne.imageSel = self.imageSel;
    newOne.coverIcon = self.coverIcon;
    newOne.text = [self.text copy];
    newOne.isSelect = self.isSelect;
    newOne.type = self.type;
    return newOne;
}

@end
