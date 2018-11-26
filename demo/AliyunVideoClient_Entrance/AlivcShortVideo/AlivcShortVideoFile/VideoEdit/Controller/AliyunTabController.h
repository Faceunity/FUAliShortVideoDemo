//
//  AliyunTabController.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AliyunColor.h"
#import "AliyunSubtitleActionItem.h"
#import "AlivcTabbarView.h"



@protocol AliyunTabControllerDelegate <NSObject>

/**
 完成回调
 */
- (void)completeButtonClicked;

/**
 键盘隐藏前回调
 */
- (void)keyboardShouldHidden;

/**
 取消回调
 */
- (void)cancelButtonClicked;

/**
 键盘显示前回调
 */
- (void)keyboardShouldAppear;

/**
 字体颜色改变回调

 @param color AliyunColor
 */
- (void)textColorChanged:(AliyunColor *)color;

/**
 字体改变回调

 @param fontName 字体名称
 */
- (void)textFontChanged:(NSString *)fontName;

/**
 字体动效选择回调

 @param actionType 字体特效Type
 */
- (void)textActionType:(TextActionType)actionType;

/**
 字体边框清除回调
 */
- (void)textStrokeColorClear;

@end

/**
 字幕编辑页面
 */
@interface AliyunTabController : NSObject

@property (nonatomic, weak) id<AliyunTabControllerDelegate> delegate;

/**
 显示一个字幕编辑页面到某个view上

 @param superView 想要添加字幕编辑页面的目标view
 @param height view的高度
 @param duration 动画时间
 @param tabItems tabbar上需要的功能项
 */
- (void)presentTabContainerViewInSuperView:(UIView *)superView height:(CGFloat)height duration:(CGFloat)duration tabItems:(NSArray *)tabItems;


/**
 移除字幕编辑页面
 */
- (void)dismissPresentTabContainerView;

@end

