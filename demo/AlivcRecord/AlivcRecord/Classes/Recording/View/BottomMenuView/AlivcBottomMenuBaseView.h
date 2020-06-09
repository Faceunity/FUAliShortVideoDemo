//
//  AlivcBottomMenuBaseView.h
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/4/29.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlivcBottomMenuBaseView : UIView

/**
 头部view
 */
@property(nonatomic, copy)UIView *headerView;

/**
 内容view
 */
@property(nonatomic, strong)UIView *contentView;


@property(nonatomic, assign)CGFloat safeTop;

/**
 显示view
 */
-(void)show;

/**
 隐藏view
 */
-(void)hide;


@end

NS_ASSUME_NONNULL_END
