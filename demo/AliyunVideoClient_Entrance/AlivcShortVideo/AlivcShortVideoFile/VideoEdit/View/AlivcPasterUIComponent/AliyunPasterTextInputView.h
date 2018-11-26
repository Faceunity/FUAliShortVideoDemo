//
//  AliyunPasterTextInputView.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/10.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunColor.h"
#import "AliyunSubtitleActionItem.h"

@protocol AliyunPasterTextInputViewDelegate <NSObject>

/**
 键盘frame变化的代理事件

 @param rect 变化后的frame
 @param duration 动画时长
 */
- (void)keyboardFrameChanged:(CGRect)rect animateDuration:(CGFloat)duration;

/**
 键盘将要隐藏的代理事件
 */
- (void)keyboardWillHide;

/**
 编辑将要完成的代理事件

 @param inputviewFrame 文字输入view的frame
 @param text 文字内容
 @param fontName 字体名字
 */
- (void)editWillFinish:(CGRect)inputviewFrame text:(NSString *)text fontName:(NSString *)fontName;

@end

/**
 字幕文字编辑状态下的输入view，它与AliyunPasterTextStrokeView共同组成文字输入view
 */
@interface AliyunPasterTextInputView : UIView

@property (nonatomic, weak) id<AliyunPasterTextInputViewDelegate> delegate;

/**
 最大可输入的字符个数  如果为0，则不显示字符个数
 */
@property (nonatomic, assign) int maxCharacterCount;

/**
 最大换行宽度
 */
@property (nonatomic, assign) CGFloat maxWidth;


/**
 创建一个paster文字输入view

 @return AliyunPasterTextInputView实例
 */
+ (id)createPasterTextInputView;

/**
 创建一个paster文字输入view，并指定初始化属性

 @param text 文字内容
 @param textColor 文字颜色
 @param fontName 字体
 @param maxCount 最大输入文字数量
 @return AliyunPasterTextInputView实例
 */
+ (id)createPasterTextInputViewWithText:(NSString *)text
                              textColor:(AliyunColor *)textColor
                               fontName:(NSString *)fontName
                           maxCharacterCount:(int)maxCount;

/**
 获取输入框文字

 @return 输入框文字
 */
- (NSString *)getText;

/**
 隐藏键盘
 */
- (void)shouldHiddenKeyboard;

/**
 显示键盘
 */
- (void)shouldAppearKeyboard;


/**
 设置文字颜色信息

 @param color 文字颜色信息
 */
- (void)setFilterTextColor:(AliyunColor *)color;


/**
 适配input换行
 */
- (void)viewFit;


/**
 移除边框颜色
 */
- (void)removeStrokeColor;

/**
 获取颜色信息

 @return 颜色信息
 */
- (AliyunColor *)getTextColor;

/**
 设置文字字体

 @param fontName 文字字体
 */
- (void)setFontName:(NSString *)fontName;

/**
 获取文字字体

 @return 文字字体
 */
- (NSString *)fontName;

/**
 设置文字特效

 @param type 特效Type
 */
- (void)setTextAnimationType:(TextActionType)type;

/**
 获取文字特效

 @return 特效Type
 */
- (TextActionType)actionType;

@end
