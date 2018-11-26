//
//  AliyunFontPickerViewCell.h
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/4.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AliyunFontPickerViewCell : UIView

/**
 是否选中
 */
@property(nonatomic ,assign)BOOL isSelected;

/**
 设置text

 @param text text可传nil
 */
-(void)setText:(NSString *)text;
@end
