//
//  AliyunToolView.h
//  AliyunVideoClient_Entrance
//
//  Created by 张璠 on 2018/7/6.
//  Copyright © 2018年 Alibaba. All rights reserved.
//  选择控件，AliyunRecordBeautyView的顶部控件

#import <UIKit/UIKit.h>
@class AliyunToolView;

@protocol AliyunToolViewDelegate <NSObject>
@optional

/**
 点击此类按钮之后的代理方法

 @param toolView 本类的对象
 @param buttonTag 按钮序号
 */
- (void)AliyunToolView:(AliyunToolView *)toolView didClickedButton:(NSInteger)buttonTag;
@end

@interface AliyunToolView : UIView

/**
 此类的代理属性
 */
@property (weak, nonatomic) id<AliyunToolViewDelegate> delegate;

/**
 初始化方法

 @param items 文字数组
 @param imageArray 图片数组
 @param frame frame值
 @return 创建好的对象self
 */
-(instancetype)initWithItems:(NSArray *)items imageArray:(NSArray *)imageArray frame:(CGRect)frame;

/**
 供外界调用，相当于按钮响应

 @param tag tag
 */
-(void)clickTithTag:(NSInteger)tag;
@end
