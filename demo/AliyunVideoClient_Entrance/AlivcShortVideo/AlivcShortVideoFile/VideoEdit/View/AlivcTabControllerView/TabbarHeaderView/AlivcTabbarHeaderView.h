//
//  AlivcTabbarHeaderView.h
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2018/10/10.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlivcTabbarView.h"
#import "UIButton+AliyunBlock.h"

/**
 AlivcTabbar的顶部底层view，它与AlivcTabbarView共同组成AlivcTabbar的顶部view
 */
@interface AlivcTabbarHeaderView : UIView

/**
 tabbar
 */
@property(nonatomic, strong)AlivcTabbarView *tabbar;

/**
 绑定响应事件
 
 @param applyOnClick 确认按钮事件
 @param cancelOnClick 取消按钮事件
 */
-(void)bindingApplyOnClick:(OnClickBlock)applyOnClick cancelOnClick:(OnClickBlock)cancelOnClick;

@end
