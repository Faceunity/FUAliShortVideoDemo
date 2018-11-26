//
//  AliyunTabBarCell.h
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/1.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>



/**
 字幕编辑tabBarController顶部Cell
 
 */
@interface AliyunTabBarCell : UICollectionViewCell

/**
 cell按钮
 */
@property(nonatomic ,strong )UIButton *itemBtn;

/**
 设置标题和Icon

 @param title 标题
 @param icon Icon
 */
-(void)setTitle:(NSString *)title icon:(UIImage *)icon;

@end
