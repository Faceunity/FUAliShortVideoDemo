//
//  AliyunEffectCaptionCopy.h
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/14.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AliyunVideoSDKPro/AliyunEffectCaption.h>

@class AliyunEffectPasterTimeItemCopy;
@class AliyunEffectPasterFrameItemCopy;

/**
 气泡字幕参数深拷贝类
 */
@interface AliyunEffectCaptionCopy : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *captionFontName;//用户后台配置的字体名称
@property (nonatomic, assign) NSInteger captionFontId;//用户后台配置的字体id
@property (nonatomic, assign) CGFloat textRelativeToBeginTime;//文字开始出现的时间 相对于动图本身坐标系
@property (nonatomic, assign) CGFloat textRelativeToEndTime;//文字消失的时间 相对于动图本身坐标系
@property (nonatomic, assign) CGRect textFrame;//文字的位置大小 相对于动图本身坐标
@property (nonatomic, assign) CGPoint textCenter;//文字的中心点位置 相对于动图本身坐标
@property (nonatomic, assign) CGSize textSize;//文字的大小 相对于动图本身坐标
@property (nonatomic, strong) UIImage *kernelImage;//关键帧图片
@property (nonatomic, assign) BOOL textStroke;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *textStrokeColor;
@property (nonatomic, strong) UIColor *textLabelColor;
@property (nonatomic, copy) NSString *fontName;//字体名称

@property (nonatomic, copy) NSArray<AliyunEffectPasterTimeItemCopy *> *timeItems;
@property (nonatomic, copy) NSArray<AliyunEffectPasterFrameItemCopy *> *frameItems;
@property (nonatomic, assign) CGFloat originDuration;//原始时长
@property (nonatomic, assign) CGFloat originTextDuration;//文字原始时长
@property (nonatomic, assign) CGFloat originTextBeginTime;//文字原始开始时间 相对于动图


/**
 拷贝一份AliyunEffectCaption
 
 @param effectCaption 需要copy的AliyunEffectCaption
 */
-(id)copyPropertysForAliyunEffectCaption:(AliyunEffectCaption *)effectCaption;

/**
 获取Copy的属性
 
 @param effectCaption 需要获取Copy属性的AliyunEffectCaption
 */
-(void)setPropertysInAliyunEffectCaption:(AliyunEffectCaption *)effectCaption;

@end
