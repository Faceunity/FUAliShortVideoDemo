//
//  AliyunTransitionPreviewCell.h
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/8/30.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunTransitionCover.h"

/**
 转场片段预览Cell
 */
@interface AliyunTransitionPreviewCell : UITableViewCell

/**
 预览imageView
 */
@property (nonatomic, strong) UIImageView *preview;


/**
 设置转场片段动画数据

 @param cover 转场片段动画数据模型
 */
- (void)setTransitionCover:(AliyunTransitionCover *)cover;

@end
