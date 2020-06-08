//
//  AlivcRecordRateSelectView.h
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/4/22.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^AlivcRecordDidSelectRateBlock)(CGFloat rate);

@interface AlivcRecordRateSelectView : UIView

/**
 根据传入的items进行view布局

 @param items item数组
 @param rateBlock 速度改变事件回调
 */
- (void)setupViewsWithItems:(NSArray *)items selectedRateBlock:(AlivcRecordDidSelectRateBlock)rateBlock;

@end

NS_ASSUME_NONNULL_END
