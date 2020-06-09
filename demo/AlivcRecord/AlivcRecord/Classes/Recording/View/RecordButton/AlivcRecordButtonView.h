//
//  AlivcRecordButtonView.h
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/4/9.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlivcRecordButton.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AlivcRecordButtonViewDelegate <NSObject>
@optional
/**
 录制按钮抬起
 */
- (void)alivcRecordButtonTouchUp;

/**
 录制按钮按下
 */
- (void)alivcRecordButtonTouchDown;

/**
 录制按钮touch点移出按钮区域
 */
- (void)alivcRecordButtonTouchUpDragOutside;

@end

@interface AlivcRecordButtonView : UIView
@property(nonatomic, weak)id <AlivcRecordButtonViewDelegate>delegate;

@property(nonatomic, strong)AlivcRecordButton *recordBtn;//录制按钮

/**
 更新录制按钮状态

 @param isRecording 是否正在录制
 @param type 录制类型：长按、点击
 */
- (void)setRecordStatus:(BOOL)isRecording withRecordType:(NSInteger)type;

/**
 长按录制按钮提示

 @param isShow 是否显示提示
 */
- (void)switchShowRecordButtonTip:(BOOL)isShow;

/**
 刷新录制时长显示

 @param percent 录制时长
 */
- (void)refreshRecordingTime:(CGFloat)percent;

@end

NS_ASSUME_NONNULL_END
