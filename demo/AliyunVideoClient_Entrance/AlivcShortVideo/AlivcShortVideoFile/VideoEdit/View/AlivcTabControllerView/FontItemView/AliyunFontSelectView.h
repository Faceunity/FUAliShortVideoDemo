//
//  AliyunFontSelectView.h
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/4.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcTabbarBaseView.h"

@class AliyunEffectFontInfo;

@protocol AliyunFontSelectViewDelegate <NSObject>


/**
 字体选择代理方法

 @param fontInfo 选择的字体信息
 */
- (void)onSelectFontWithFontInfo:(AliyunEffectFontInfo *)fontInfo;

@end

/**
 字体view
 */
@interface AliyunFontSelectView : AlivcTabbarBaseView

@property(nonatomic, weak)id<AliyunFontSelectViewDelegate> delegate;

@end
