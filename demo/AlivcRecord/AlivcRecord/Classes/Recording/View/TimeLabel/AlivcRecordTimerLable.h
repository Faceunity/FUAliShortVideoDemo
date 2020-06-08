//
//  AlivcRecordTimerLable.h
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/4/8.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 倒计时录制功能，倒计时结束回调
 */
typedef void(^AlivcRecordTimerCompleteBlock)(void);

@interface AlivcRecordTimerLable : UILabel

@property(nonatomic, assign, readonly)BOOL isTiming;

/**
 开始倒计时录制

 @param complete 计时结束回调
 */
- (void)startTimerWithComplete:(AlivcRecordTimerCompleteBlock)complete;

/**
 停止倒计时
 */
- (void)stopTimer;

@end

NS_ASSUME_NONNULL_END
