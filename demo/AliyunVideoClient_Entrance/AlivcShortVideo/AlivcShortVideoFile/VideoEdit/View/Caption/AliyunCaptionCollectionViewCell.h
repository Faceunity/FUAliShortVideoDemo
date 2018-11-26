//
//  AliyunCaptionCollectionViewCell.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/17.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AliyunCaptionCollectionViewCell : UICollectionViewCell

/**
 显示Icon的view
 */
@property (nonatomic, strong) UIImageView *showImageView;

/**
 是否是字幕展示view
 */
@property (nonatomic, assign) BOOL isFont;

/**
 是否是展示分组的view
 */
@property (nonatomic, assign) BOOL isGroup;


@end
