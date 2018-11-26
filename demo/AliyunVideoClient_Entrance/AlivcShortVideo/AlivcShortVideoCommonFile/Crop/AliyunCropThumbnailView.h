//
//  AliyunVideo
//
//  Created by dangshuai on 17/1/14.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunMediaConfig.h"

@class AVAsset;
@protocol AliyunCutThumbnailViewDelegate <NSObject>

- (void)cutBarDidMovedToTime:(CGFloat)time;

- (void)cutBarTouchesDidEnd;
@end

@interface AliyunCropThumbnailView : UIView

/**
 代理
 */
@property (nonatomic, weak) id<AliyunCutThumbnailViewDelegate> delegate;

@property (nonatomic, strong) AVAsset *avAsset;

/**
 初始化方法

 @param frame frame
 @param cutInfo 视频资源
 @return 实例化对象
 */
- (instancetype)initWithFrame:(CGRect)frame withCutInfo:(AliyunMediaConfig *)cutInfo;

/**
 加载缩略图资源
 */
- (void)loadThumbnailData;

/**
 更新进度

 @param progress 进度
 */
- (void)updateProgressViewWithProgress:(CGFloat)progress;
@end
