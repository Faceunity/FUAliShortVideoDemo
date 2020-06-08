//
//  AliyunPasterTextStrokeView.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 字幕文字编辑状态下的输入textview，它与AliyunPasterTextInputView共同组成文字输入view
 */
@interface AliyunPasterTextStrokeView : UITextView

/**
 文字颜色
 */
@property (nonatomic, strong) UIColor *mTextColor;

/**
 文字描边颜色
 */
@property (nonatomic, strong) UIColor *mTextStrokeColor;

/**
 文字字体名字
 */
@property (nonatomic, copy) NSString *mfontName;

/**
 文字大小
 */
@property (nonatomic, assign) CGFloat mfontSize;

/**
 文字是否描边
 */
@property (nonatomic, assign) BOOL isStroke;

@end
