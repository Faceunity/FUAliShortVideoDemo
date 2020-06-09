//
//  AliyunColorPaletteItemCell.h
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/3.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunColor.h"

/**
 颜色选择cell
 */
@interface AliyunColorPaletteItemCell : UICollectionViewCell

/**
 当前cell的颜色信息
 */
@property (nonatomic, strong) AliyunColor *color;

/**
 调用此方法会在cell中间画一条斜线，一般用在第一个cell表示清除效果
 */
-(void)drawLine;

@end
