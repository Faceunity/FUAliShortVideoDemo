//
//  AliyunEffectFilterCell.h
//  AliyunVideo
//
//  Created by dangshuai on 17/3/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//  滤镜、特效、MV模块用到的cell

#import <UIKit/UIKit.h>
#import "AliyunEffectInfo.h"
@interface AliyunEffectFilterCell : UICollectionViewCell

/**
 下载的view
 */
@property (weak, nonatomic) IBOutlet UIImageView *downloadImageView;

/**
 名称Label
 */
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

/**
 图片显示的view
 */
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

/**
 被选中的按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *selectedButton;

/**
 是否是音效
 */
@property (assign, nonatomic) BOOL isAudioEffect;

/**
 给cell数据

 @param effectInfo 数据模型
 */
- (void)cellModel:(AliyunEffectInfo *)effectInfo;

/**
 是否应该显示下载的view

 @param flag 是否显示
 */
- (void)shouldDownload:(BOOL)flag;

/**
 刷新进度的方法

 @param progress 进度（0-1）
 */
- (void)downloadProgress:(CGFloat)progress;

@end
