//
//  AlivcButton.h
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/4/28.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 按钮类型

 - AlivcButtonTypeTitleTop:     文字在图片上方
 - AlivcButtonTypeTitleBottom:  文字在图片下方
 - AlivcButtonTypeTitleLeft:    文字在图片左方
 - AlivcButtonTypeTitleRight:   文字在图片右方
 */
typedef NS_ENUM(NSInteger, AlivcButtonType){
    AlivcButtonTypeTitleTop,
    AlivcButtonTypeTitleBottom,
    AlivcButtonTypeTitleLeft,
    AlivcButtonTypeTitleRight
};

@interface AlivcButton : UIButton

/**
 初始化一个指定类型的按钮
 目前仅支持文字在图片下方，其它类型用到可以自行添加

 @param type 按钮类型
 @return 按钮实例
 */
-(instancetype)initWithButtonType:(AlivcButtonType)type;

@end

NS_ASSUME_NONNULL_END
