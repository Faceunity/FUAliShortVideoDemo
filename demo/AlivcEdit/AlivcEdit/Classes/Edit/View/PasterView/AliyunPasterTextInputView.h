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
#import <AliyunVideoSDKPro/AliyunVideoSDKPro.h>
#import "AliyunPasterTextStrokeView.h"

@protocol AliyunPasterTextInputViewDelegate <NSObject>

/**
 键盘frame变化的代理事件

 @param rect 变化后的frame
 @param duration 动画时长
 */
- (void)keyboardFrameChanged:(CGRect)rect animateDuration:(CGFloat)duration;


/**
 编辑将要完成的代理事件

 @param inputviewFrame 文字输入view的frame
 @param text 文字内容
 @param fontName 字体名字
 */
- (void)textInputViewTextDidChanged;

@end

/**
 字幕文字编辑状态下的输入view，它与AliyunPasterTextStrokeView共同组成文字输入view
 */
@interface AliyunPasterTextInputView : UIView

@property (nonatomic, weak) id<AliyunPasterTextInputViewDelegate> delegate;

@property (nonatomic, strong) AliyunPasterTextStrokeView *textView;//输入框

/**
 获取输入框文字

 @return 输入框文字
 */
- (NSString *)getText;


- (void)setText:(NSString *)text;

/**
 隐藏键盘
 */
- (void)shouldHiddenKeyboard;

/**
 显示键盘
 */
- (void)shouldAppearKeyboard;


//@property (nonatomic, weak) UIView *pasterView;

@end
