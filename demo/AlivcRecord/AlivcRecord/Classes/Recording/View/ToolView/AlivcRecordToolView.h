//
//  AlivcRecordToolView.h
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/2/28.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 录制状态

 - AlivcRecordButtonTouchModeClick: 点击录制
 - AlivcRecordButtonTouchModeLongPress: 长按录制
 */
typedef NS_ENUM(NSInteger, AlivcRecordButtonTouchMode){
    AlivcRecordButtonTouchModeClick = 0,
    AlivcRecordButtonTouchModeLongPress
};

@protocol AlivcRecordToolViewDelegate <NSObject>

/**
 切换录制方式状态

 @param touchMode 录制方式
 */
- (void)alivcRecordToolViewSwitchTouchMode:(AlivcRecordButtonTouchMode)touchMode;

/**
 删除视频片段
 */
- (void)alivcRecordToolViewDeleteVideoPart;

@end

@interface AlivcRecordToolView : UIView

/**
 当前录制方式
 */
@property(nonatomic, assign)AlivcRecordButtonTouchMode touchMode;

@property(nonatomic, weak)id<AlivcRecordToolViewDelegate>delegate;

/**
 显示指示器
 */
@property(nonatomic, assign)BOOL showIndicator;

/**
 删除按钮是否显示

 @param show 是否显示
 */
- (void)showDeleteButton:(BOOL)show;

@end
NS_ASSUME_NONNULL_END
