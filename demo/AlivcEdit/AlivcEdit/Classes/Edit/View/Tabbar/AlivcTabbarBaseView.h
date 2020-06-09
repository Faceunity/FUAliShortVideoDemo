//
//  AlivcTabbarBaseView.h
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/3.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 tab
 */
@interface AlivcTabbarBaseView : UIView

#define CPV_BootomView_Height   45  //底部View高度，调整底部高度后contentView高度自适应
#define CPV_LineView_Height     1   //分割线高度

@property(nonatomic, strong)UIView *topLine;        //上方分割线
@property(nonatomic, strong)UIView *contentView;    //中间内容View
@property(nonatomic, strong)UIView *bootomView;     //底部View
@property(nonatomic, strong)UIView *bootomLine;     //下方分割线

/**
 显示View到指定View上
 
 @param superView 目标View
 @param animation 是否以动画方式显示
 @param completion 动画完成后的回调
 */
-(void)showInView:(UIView *)superView animation:(BOOL)animation completion:(void (^ __nullable)(BOOL finished))completion;

/**
 隐藏View
 
 @param animation 是否以动画方式隐藏
 @param completion 动画完成后的回调
 */
-(void)hiddenAnimation:(BOOL)animation completion:(void (^ __nullable)(BOOL finished))completion;

@end
