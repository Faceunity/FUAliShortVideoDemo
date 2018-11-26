//
//  QUPasterSelectView.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunPasterBottomBaseView.h"

/**
 动图view
 */
@interface AliyunPasterShowView : AliyunPasterBottomBaseView

/**
 刷新分组动图

 @param group 动图分组模型
 */
- (void)fetchPasterGroupDataWithCurrentShowGroup:(AliyunEffectPasterGroup *)group;

@end
