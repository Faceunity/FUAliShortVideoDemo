//
//  AliyunCycleProgressView.h
//  qusdk
//
//  Created by TripleL on 17/5/9.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AliyunCycleProgressView : UIView

/**
 背景颜色
 */
@property (nonatomic, strong) UIColor *progressBackgroundColor;

/**
 选中颜色
 */
@property (nonatomic, strong) UIColor *progressColor;

/**
 选中的区域
 */
@property (nonatomic, assign) CGFloat progress;

@end
