//
//  AliyunTransitionCoverCell.h
//  qusdk
//
//  Created by Vienta on 2018/6/6.
//  Copyright © 2018年 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunTransitionCover.h"


/**
 被选中转场效果展示Cell
 */
@interface AliyunTransitionCoverCell : UITableViewCell

//@property (nonatomic, strong) UIImageView *coverImageView;


/**
 设置选中转场效果Icon

 @param cover 选中转场效果信息
 */
- (void)setTransitionCover:(AliyunTransitionCover *)cover;

@end
