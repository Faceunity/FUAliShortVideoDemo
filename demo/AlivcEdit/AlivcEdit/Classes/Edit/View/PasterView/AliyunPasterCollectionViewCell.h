//
//  AliyunPasterCollectionViewCell.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 动图展示cell
 */
@interface AliyunPasterCollectionViewCell : UICollectionViewCell

/**
 icon展示view
 */
@property (nonatomic, strong) UIImageView *showImageView;

@property (nonatomic, assign) BOOL isSelected;

@end
