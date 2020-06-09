//
//  AlivcEditBottomHeaderView.h
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2018/10/11.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+AliyunBlock.h"

@interface AlivcEditBottomHeaderView : UIView

/**
 设置headerView信息

 @param icon 中间icon
 @param titile 标题
 */
-(void)setTitle:(NSString *)titile icon:(UIImage *)icon;

/**
 隐藏两侧按钮
 */
-(void)hiddenButton;

/**
 绑定响应事件

 @param applyOnClick 确认按钮事件
 @param cancelOnClick 取消按钮事件
 */
-(void)bindingApplyOnClick:(OnClickBlock)applyOnClick cancelOnClick:(OnClickBlock)cancelOnClick;

@end
