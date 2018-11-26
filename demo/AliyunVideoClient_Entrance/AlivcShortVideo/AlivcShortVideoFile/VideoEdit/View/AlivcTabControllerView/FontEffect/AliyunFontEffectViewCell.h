//
//  AliyunFontEffectViewCell.h
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/4.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunSubtitleActionItem.h"

/**
 字体特效cell
 */
@interface AliyunFontEffectViewCell : UICollectionViewCell

/**
 设置字体特效信息

 @param actionItem 字体特效信息model
 */
- (void)setSubtitleActionItem:(AliyunSubtitleActionItem *)actionItem;

@end
