//
//  MagicCameraEffectCell.h
//  AliyunVideo
//
//  Created by Vienta on 2017/1/9.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//  录制中动图的cell

#import <UIKit/UIKit.h>

@interface AliyunMagicCameraEffectCell : UICollectionViewCell

/**
 图片显示控件
 */
@property (nonatomic, strong) UIImageView *imageView;

/**
 下载图标显示控件
 */
@property (nonatomic, strong) UIImageView *downloadImageView;

/**
 
 是否正在下载
 */
@property (nonatomic, assign) BOOL isLoading;

/**
  是否隐藏选中框

 @param isHidden 是否隐藏
 */
- (void)borderHidden:(BOOL)isHidden;

/**
 是否显示下载图标

 @param flag 是否显示
 */
- (void)shouldDownload:(BOOL)flag;

/**
 刷新下载进度

 @param progress 下载进度
 */
- (void)downloadProgress:(CGFloat)progress;


/**
 当前cell的动图是否在应用中

 @param Applyed 动图是否在应用中
 */
- (void)setApplyed:(BOOL)Applyed;

@end
