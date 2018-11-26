//
//  AliyunPaintingEditView.h
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/3.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AliyunPaintingEditViewDelegate <NSObject>

/**
 完成涂鸦
 
 */
- (void)onClickPaintFinishButton;

/**
 改变画笔宽度
 
 @param width 画笔宽度
 */
- (void)onClickChangePaintWidth:(NSInteger)width;

/**
 改变画笔颜色
 
 @param color 画笔颜色
 */
- (void)onClickChangePaintColor:(UIColor *)color;

/**
 撤销一步
 
 */
- (void)onClickPaintUndoPaintButton;


/**
 反向撤销一步
 
 */
- (void)onClickPaintRedoPaintButton;

@optional

/**
 取消
 
 */
- (void)onClickPaintCancelButton;



@end

@interface AliyunPaintingEditView : UIView
@property (nonatomic, weak) id<AliyunPaintingEditViewDelegate> delegate;

/**
 显示View到指定View上
 
 @param superView 目标View
 @param animation 是否以动画方式显示
 */
-(void)showInView:(UIView *)superView animation:(BOOL)animation;

/**
 隐藏View
 
 @param animation 是否以动画方式隐藏
 */
-(void)hiddenAnimation:(BOOL)animation;

@end
