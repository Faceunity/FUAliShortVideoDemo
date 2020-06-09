//
//  AliyunTransitionIconCell.h
//  qusdk
//
//  Created by Vienta on 2018/6/6.
//  Copyright © 2018年 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunTransitionIcon.h"

/**
 转场效果Icon展示Cell
 */
@interface AliyunTransitionIconCell : UITableViewCell


/**
 设置转场效果的Icon数据

 @param icon 转场效果数据模型
 */
- (void)setTransitionIcon:(AliyunTransitionIcon *)icon;

@end
