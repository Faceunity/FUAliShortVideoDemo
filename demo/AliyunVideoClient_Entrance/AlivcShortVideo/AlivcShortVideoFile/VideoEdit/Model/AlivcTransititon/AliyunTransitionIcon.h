//
//  AliyunTransitionIcon.h
//  qusdk
//
//  Created by Vienta on 2018/6/6.
//  Copyright © 2018年 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 转场动画数据模型
 
 */
@interface AliyunTransitionIcon : NSObject <NSCopying>

/**
 默认显示Icon
 */
@property (nonatomic, strong) UIImage *image;

/**
 选中的Icon
 */
@property (nonatomic, strong) UIImage *imageSel;

/**
 选中后上边片段之间应该显示的icon
 */
@property (nonatomic, strong) UIImage *coverIcon;

/**
 转场效果名字
 */
@property (nonatomic, strong) NSString *text;

/**
 是否被选中
 */
@property (nonatomic, assign) BOOL isSelect;

/**
 此转场效果的type
 */
@property (nonatomic, assign) int type;


@end
