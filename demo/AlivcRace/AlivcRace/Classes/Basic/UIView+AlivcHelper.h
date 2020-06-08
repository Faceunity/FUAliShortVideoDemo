//
//  UIView+AlivcHelper.h
//  MaoBoli
//
//  Created by Zejian Cai on 2018/7/19.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AlivcHelper)
/**
 为当前的view添加模糊效果
 */
- (void)addVisualEffect;


/**
 为当前的view添加模糊效果

 @param frame 需要增加的区域
 */
- (void)addVisualEffectWithFrame:(CGRect)frame;

/**
 移除当前view的毛玻璃效果
 */
-(void)removeVisualEffectView;

@end
