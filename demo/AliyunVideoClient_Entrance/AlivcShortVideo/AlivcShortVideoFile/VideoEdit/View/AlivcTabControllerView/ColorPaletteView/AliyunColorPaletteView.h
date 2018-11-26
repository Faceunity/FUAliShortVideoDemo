//
//  AliyunColorPaletteVIew.h
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/3.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunColor.h"
#import "AlivcTabbarBaseView.h"



@protocol AliyunColorPaletteViewDelegate<NSObject>

/**
 颜色改变代理方法

 @param color 选择的颜色
 */
- (void)textColorChanged:(AliyunColor *)color;

/**
 清除边框颜色
 */
- (void)clearStrokeColor;

@end

/**
 颜色view
 */
@interface AliyunColorPaletteView : AlivcTabbarBaseView;

@property(nonatomic, weak)id<AliyunColorPaletteViewDelegate>delegate;


@end
