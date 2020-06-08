//
//  AliyunPaintingWidthView.h
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/3.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AliyunPaintingWidthView;

typedef void(^ChangeWidthHandle)(NSInteger width);

@interface AliyunPaintingWidthView : UIView

/**
 改变画笔宽度的回调
 */
@property(nonatomic, strong)ChangeWidthHandle changeWidthHandle;

/**
 当前被选中的button
 */
@property(nonatomic, strong)UIButton *currentTagBtn;

/**
 当前选中颜色
 */
@property(nonatomic, strong)UIColor *widthtTagColor;


@end
