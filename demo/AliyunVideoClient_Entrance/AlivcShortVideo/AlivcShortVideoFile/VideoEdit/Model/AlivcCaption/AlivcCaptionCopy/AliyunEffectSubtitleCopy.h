//
//  AliyunEffectSubtitleCopy.h
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/14.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AliyunEffectSubtitle;

/**
 纯文字字幕信息深拷贝类
 */
@interface AliyunEffectSubtitleCopy : NSObject

/**
 文字内容
 */
@property (nonatomic, copy) NSString *text;

/**
 字体名称
 */
@property (nonatomic, copy) NSString *fontName;

/**
 字体颜色
 */
@property (nonatomic, strong) UIColor *textColor;

/**
 描边颜色
 */
@property (nonatomic, strong) UIColor *strokeColor;

/**
 是否描边
 */
@property (nonatomic, assign) BOOL isStroke;

@property (nonatomic, strong) UIColor *textLabelColor;
@property (nonatomic, assign) BOOL hasTextLabel;


/**
 拷贝一份AliyunEffectSubtitle
 
 @param effectSubtitle 需要copy的AliyunEffectSubtitle
 */
-(id)copyPropertysForAliyunEffectSubtitle:(AliyunEffectSubtitle *)effectSubtitle;

/**
 获取Copy的属性
 
 @param effectSubtitle 需要获取Copy属性的effectSubtitle
 */
-(void)setPropertysInAliyunEffectSubtitle:(AliyunEffectSubtitle *)effectSubtitle;

@end
