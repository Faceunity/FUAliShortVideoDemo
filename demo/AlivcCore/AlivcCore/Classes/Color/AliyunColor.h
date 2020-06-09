//
//  AliyunColor.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/7.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

/**
 包含字体颜色、边框颜色、是否有边框信息的Color类
 */
@interface AliyunColor : NSObject

@property (nonatomic, assign) CGFloat tR;//color R
@property (nonatomic, assign) CGFloat tG;//color G
@property (nonatomic, assign) CGFloat tB;//color B
@property (nonatomic, assign) CGFloat sR;//边框color R
@property (nonatomic, assign) CGFloat sG;//边框color G
@property (nonatomic, assign) CGFloat sB;//边框color B
@property (nonatomic, assign) BOOL isStroke;//是否有边框

/**
 初始化一个AliyunColor从一个dic

 @param dict 用来初始化的dic
 @return AliyunColor实例
 */
- (id)initWithDict:(NSDictionary *)dict;

/**
 初始化一个AliyunColor

 @param color 颜色
 @param strokeColor 边框颜色
 @param stroke 是否有边框
 @return AliyunColor实例
 */
- (id)initWithColor:(UIColor *)color strokeColor:(UIColor *)strokeColor stoke:(BOOL)stroke;

@end
