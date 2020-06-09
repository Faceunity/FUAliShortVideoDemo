//
//  AlivcCoverImageSelectedView.h
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/12/26.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AliyunTimelineView;
@class AlivcCoverImageSelectedView;

@protocol AlivcCoverImageSelectedViewDelegate <NSObject>

- (void)cancelCoverImageSelectedView:(AlivcCoverImageSelectedView *)view;

- (void)applyCoverImageSelectedView:(AlivcCoverImageSelectedView *)view;

@end

NS_ASSUME_NONNULL_BEGIN

@interface AlivcCoverImageSelectedView : UIView

/**
 设置缩略图。frame自适应，不用设置frame
 */
@property (nonatomic, strong) AliyunTimelineView *timelineView;

@property (nonatomic, weak) id <AlivcCoverImageSelectedViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
