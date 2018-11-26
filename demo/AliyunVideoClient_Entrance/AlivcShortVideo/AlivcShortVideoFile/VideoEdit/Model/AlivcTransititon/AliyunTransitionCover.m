//
//  AliyunTransitionCover.m
//  qusdk
//
//  Created by Vienta on 2018/6/6.
//  Copyright © 2018年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunTransitionCover.h"

@implementation AliyunTransitionCover

- (id)copyWithZone:(NSZone *)zone{
    AliyunTransitionCover *newOne = [[AliyunTransitionCover allocWithZone:zone]init];
    newOne.image = self.image;
    newOne.image_Nor = self.image_Nor;
    newOne.transitionImage = self.transitionImage;
    newOne.transitionImage_Nor = self.transitionImage_Nor;
    newOne.isTransitionIdx = self.isTransitionIdx;
    newOne.isSelect = self.isSelect;
    newOne.transitionIdx = self.transitionIdx;
    newOne.type = self.type;
    return newOne;
}


@end
