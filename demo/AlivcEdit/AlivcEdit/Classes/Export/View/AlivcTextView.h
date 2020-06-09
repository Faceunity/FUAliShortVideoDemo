//
//  AlivcTextView.h
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2019/1/10.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlivcTextView : UIView

/**
 用于定制化显示字体 - 只能用于显示
 */
@property (strong, nonatomic, readonly) UITextField *textField;

/**
 显示的字符
 */
@property (strong, nonatomic, readwrite) NSString *showText;


/**
 设置最大字数

 @param maxCount 最大字符 > 0;
 */
- (void)setMaxCount:(NSInteger )maxCount;

@end

NS_ASSUME_NONNULL_END
