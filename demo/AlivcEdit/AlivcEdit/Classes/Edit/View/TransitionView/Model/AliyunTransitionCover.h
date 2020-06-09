//
//  AliyunTransitionCover.h
//  qusdk
//
//  Created by Vienta on 2018/6/6.
//  Copyright © 2018年 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 转场片段动画数据模型
 */
@interface AliyunTransitionCover : NSObject<NSCopying>

/**
 未选择转场效果时默认显示的Icon
 */
@property (nonatomic, strong) UIImage *image;

/**
 未选择转场效果时被选中的icon
 */
@property (nonatomic, strong) UIImage *image_Nor;

/**
 选择了转场效果时被选中的icon
 */
@property (nonatomic, strong) UIImage *transitionImage;

/**
 选择了转场效果时未被选中的icon
 */
@property (nonatomic, strong) UIImage *transitionImage_Nor;

/**
 是否是转场效果
 */
@property (nonatomic, assign) BOOL isTransitionIdx;

/**
 是否被选中
 */
@property (nonatomic, assign) BOOL isSelect;

/**
 转场动画效果索引
 */
@property (nonatomic, assign) int transitionIdx;

/**
 转场效果type
 */
@property (nonatomic, assign) int type;

/**
 因添加了自定义类型   type字段不再唯一，故使用name字段
 */
@property (nonatomic,copy) NSString *name;

//转场特效路径
@property(nonatomic,copy) NSString *transitionPath;

//记录path 提供给删除资源包时比对重置特效cell状态
@property(nonatomic,copy) NSString *resourcePath;

@property(nonatomic,copy) NSString *paramsJsonString;

@end
