//
//  AliyunTimelineView.h
//  QPSDKCore
//
//  Created by Vienta on 2016/11/25.
//  Copyright © 2016年 lyle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunTimelineItem.h"
#import "AliyunTimelineMediaInfo.h"
#import "AliyunTimelineFilterItem.h"
#import "AliyunTimelineTimeFilterItem.h"

@protocol AliyunTimelineViewDelegate;

@interface AliyunTimelineView : UIView

/**
 代理
 */
@property (nonatomic, weak) id<AliyunTimelineViewDelegate> delegate;


/**
 区域编辑 - 左边的滑动块图片对应的名称
 */
@property (nonatomic, copy) NSString *leftPinchImageName;

/**
 区域编辑 - 右边的滑动块图片对应的名称
 */
@property (nonatomic, copy) NSString *rightPinchImageName;

/**
 区域编辑 - 背景图片
 */
@property (nonatomic, copy) NSString *pinchBgImageName;

/**
 中间指针的颜色
 */
@property (nonatomic, strong) UIColor *indicatorColor;

/**
 区域编辑 - 左右滑动拉出区域的背景颜色
 */
@property (nonatomic, strong) UIColor *pinchBgColor;


/**
 总的实际的时间
 */
@property (nonatomic, assign) CGFloat actualDuration;


/**
 第一帧图片
 */
@property (nonatomic, strong) UIImage *coverImage;
/**
 装载数据，用来显示

 @param clips 媒体片段
 @param segment 段长（指的是一个屏幕宽度的视频时长  单位：s）
 @param photos 一个段长上需要显示的图片个数 默认为8
 */
- (void)setMediaClips:(NSArray<AliyunTimelineMediaInfo *> *)clips segment:(CGFloat)segment photosPersegent:(NSInteger)photos;

/**
 获取当前时间指针所指向的时间

 @return 时间
 */
- (CGFloat)getCurrentTime;

/**
 视频播放过程中，传入当前播放的时间，导航条进行相应的展示

 @param time 当前播放时间
 */
- (void)seekToTime:(CGFloat)time;


/**
 取消当前控件行为 例如：在滑动时，调用此方法则不再滑动
 */
- (void)cancel;

/**
 添加显示元素 （例如加动图后，需要构建timelineItem对象，并且传入用来显示）

 @param timelineItem 显示元素
 */
- (void)addTimelineItem:(AliyunTimelineItem *)timelineItem;

/**
 删除显示元素

 @param timelineItem 显示元素
 */
- (void)removeTimelineItem:(AliyunTimelineItem *)timelineItem;

/**
 传入Timeline进入编辑

 @param timelineItem timelineItem
 */
- (void)editTimelineItem:(AliyunTimelineItem *)timelineItem;

/**
 timelineView编辑完成
 */
- (void)editTimelineComplete;

/**
 从vid获取AliyunTimelineItem对象

 @param obj obj
 @return AliyunTimelineItem
 */
- (AliyunTimelineItem *)getTimelineItemWithOjb:(id)obj;

/**
 动效滤镜的显示元素
 添加元素

 @param filterItem 动效滤镜元素
 */
- (void)addTimelineFilterItem:(AliyunTimelineFilterItem *)filterItem;

/**
 更新进度

 @param filterItem 动效滤镜
 */
- (void)updateTimelineFilterItems:(AliyunTimelineFilterItem *)filterItem;

/**
 删除动效滤镜显示元素

 @param filterItem 动效滤镜元素
 */
- (void)removeTimelineFilterItem:(AliyunTimelineFilterItem *)filterItem;

/**
 删除最后一个滤镜显示元素
 */
- (void)removeLastFilterItemFromTimeline;

/**
 删除所有的动效元素
 */
- (void)removeAllFilterItemFromTimeline;
/**
 时间特效的显示元素

 @param timeFilterItem 时间特效元素
 */
- (void)addTimelineTimeFilterItem:(AliyunTimelineTimeFilterItem *)timeFilterItem;

/**
 删除时间特效元素

 @param timeFilterItem 时间特效元素
 */
- (void)removeTimelineTimeFilterItem:(AliyunTimelineTimeFilterItem *)timeFilterItem;

- (void)removeAllTimelineTimeFilterItem;

/**
 更新透明度

 @param alpha 透明度
 */
- (void)updateTimelineViewAlpha:(CGFloat)alpha;


/**
 停止滑动
 */
- (void)stopSlid;

@end




@protocol AliyunTimelineViewDelegate <NSObject>
/**
 回调拖动的item对象（在手势结束时发生）

 @param item timeline对象
 */
- (void)timelineDraggingTimelineItem:(AliyunTimelineItem *)item;


/**
 回调timeline开始被手动滑动
 */
- (void)timelineBeginDragging;

- (void)timelineDraggingAtTime:(CGFloat)time;

- (void)timelineEndDraggingAndDecelerate:(CGFloat)time;

- (void)timelineCurrentTime:(CGFloat)time duration:(CGFloat)duration;

/**
 调节覆盖时长的拖动事件

 @param time 当前时间
 */
- (void)timelineEditDraggingAtTime:(CGFloat)time;



@end




