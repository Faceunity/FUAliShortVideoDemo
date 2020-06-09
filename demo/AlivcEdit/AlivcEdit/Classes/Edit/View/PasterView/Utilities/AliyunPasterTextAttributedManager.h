//
//  AliyunPasterTextAttributedManager.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/9.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 富文本合成类
 */
@interface AliyunPasterTextAttributedManager : NSObject

/**
 根据给定的文字信息合成富文本

 @param text 文本内容
 @param fontSize 字体大小
 @param fontName 字体名字
 @param textColor 文字颜色
 @return 生成的富文本
 */
- (NSAttributedString *)attributeString:(NSString *)text fontSize:(CGFloat)fontSize fontName:(NSString *)fontName textColor:(UIColor *)textColor;

/**
 根据给定的文字信息合成带描边的富文本
 
 @param text 文本内容
 @param fontSize 字体大小
 @param fontName 字体名字
 @param textColor 文字颜色
 @return 生成的富文本
 */
- (NSAttributedString *)strokeAttributeString:(NSString *)text fontSize:(CGFloat)fontSize fontName:(NSString *)fontName textColor:(UIColor *)textColor;

/**
 计算富文本的高度

 @param attributedString 富文本
 @param textLength 文本长度
 @param width 给定宽度
 @return 富文本高度
 */
- (CGSize)sizeWithCoreText:(NSAttributedString *)attributedString length:(NSUInteger)textLength width:(CGFloat)width;

@end
