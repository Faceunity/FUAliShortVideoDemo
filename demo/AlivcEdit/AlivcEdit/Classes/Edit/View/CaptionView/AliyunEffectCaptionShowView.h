//
//  AliyunEffectCaptionShowView.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/16.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunPasterBottomBaseView.h"

@class AliyunEffectFontInfo;
@class AliyunEffectCaptionGroup;

@protocol AliyunEffectCaptionShowViewDelegate <NSObject>

/**
 纯字幕点击代理事件

 @param font 字幕信息
 */
- (void)onClickFontWithFontInfo:(AliyunEffectFontInfo *)font;

@end

@interface AliyunEffectCaptionShowView : AliyunPasterBottomBaseView


/**
 纯字幕贴图，因为此类就是特殊处理纯字幕所单独出来的类，所以纯字幕相关操作单独一个代理比较好，最好不要混入上一级贴图代理
 
 */
@property (nonatomic, weak) id<AliyunEffectCaptionShowViewDelegate> fontDelegate;


/**
 刷新展示区UI

 @param group tabbar选中分组的数据
 */
- (void)fetchCaptionGroupDataWithCurrentShowGroup:(AliyunEffectCaptionGroup *)group;

@end
