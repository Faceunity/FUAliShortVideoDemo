//
//  AlivcPlayContainerView.h
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/8/30.
//  Copyright © 2018年 Alibaba. All rights reserved.
//  播放容器视图

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AliyunVodPlayer;
@class AlivcVideoPlayListModel;

@interface AlivcPlayContainerView : UIView


/**
 Designed Inin

 @param vodPlayer 播放器实例
 @return 播放容器视图
 */
- (instancetype)initWithPlayer:(AliyunVodPlayer *)vodPlayer;

/**
 切换视频资源播放的时候，清空之前的界面
 */
- (void)clearData;


/**
 设置封面图片

 @param coverImage 封面图片
 */
- (void)setCoverImage:(UIImage *)coverImage;


/**
 设置之前的封面图片，当此容器中的播放器停止播放的时候
 */
- (void)setPreCoverImageWhenStop;

/**
 设置播放的数据源
 */
- (void)setVideoModel:(AlivcVideoPlayListModel *)model;


/**
 在本容器内的播放器的实例对象
 */
@property (strong, nonatomic, readonly) AliyunVodPlayer *vodPlayer;

/**
 在本容器内的播放器的资源
 */
@property (strong, nonatomic, readonly, nullable) AlivcVideoPlayListModel *videoModel;

/**
 容器的封面图片
 */
@property (strong, nonatomic, readonly) UIImageView *coverImageView;

@end

NS_ASSUME_NONNULL_END
