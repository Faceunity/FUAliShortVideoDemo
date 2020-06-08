//
//  AliyunPasterTextView.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/7.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <AliyunVideoSDKPro/AliyunPasterBaseView.h>


/**
 调整字幕大小、位置大小状态下的文字显示框
 */
@interface AliyunPasterTextView : AliyunPasterBaseView

/**
 文字
 */
@property (nonatomic, copy) NSString *text;

/**
 字体名称
 */
@property (nonatomic, copy) NSString *fontName;

/**
 是否描边
 */
@property (nonatomic, assign) BOOL isStroke;

/**
 文字颜色
 */
@property (nonatomic, strong) UIColor *textColor;

/**
 描边颜色
 */
@property (nonatomic, strong) UIColor *strokeColor;

/**
 获取当前输入框文字图片

 @param nativeSize nativeSize
 @param outputSize 输出Size
 @return 字幕文字图片
 */
- (UIImage *)captureImage:(CGSize)nativeSize outputSize:(CGSize)outputSize;

@end
