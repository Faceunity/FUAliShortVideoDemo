//
//  AlivcTabbarView.h
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2018/10/10.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 tabBar上边可滑动的item枚举
 
 - TabBarItemTypeKeboard: 键盘
 - TabBarItemTypeColor: 颜色
 - TabBarItemTypeFont: 字体
 - TabBarItemTypeAnimation: 特效
 */
typedef NS_ENUM(NSInteger, TabBarItemType){
    TabBarItemTypeKeboard  = 0,
    TabBarItemTypeColor,
    TabBarItemTypeFont,
    TabBarItemTypeAnimation
};

@protocol AlivcTabbarViewDelegate <NSObject>

/**
 tabbar选中代理事件
 */
-(void)alivcTabbarViewDidSelectedType:(TabBarItemType)type;

@end

/**
 AlivcTabbarHeaderView的TabbarView
 */
@interface AlivcTabbarView : UIView

/**
 选择展示的功能
 例：@[@(TabBarItemTypeKeboard),@(TabBarItemTypeColor)]
 */
@property (nonatomic, copy)NSArray *tabItems;


@property (nonatomic, weak)id<AlivcTabbarViewDelegate>delegate;


@end
