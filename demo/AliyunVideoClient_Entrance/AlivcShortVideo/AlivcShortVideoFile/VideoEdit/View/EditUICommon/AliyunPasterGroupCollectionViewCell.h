//
//  QUPackageCollectionViewCell.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AliyunEffectPasterGroup;

/**
 动图分组cell
 */
@interface AliyunPasterGroupCollectionViewCell : UICollectionViewCell

/**
 分组Icon View
 */
@property (nonatomic, strong) UIImageView *iconImageView;

/**
 当前cell分组模型
 */
@property (nonatomic, strong) AliyunEffectPasterGroup *group;

@end
