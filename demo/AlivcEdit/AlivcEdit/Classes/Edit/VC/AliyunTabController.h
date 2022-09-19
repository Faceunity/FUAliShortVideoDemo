//
//  AliyunTabController.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AliyunColor.h"
#import "AliyunSubtitleActionItem.h"
#import "AlivcTabbarView.h"
#import "AliyunPasterTextInputView.h"



@protocol AliyunTabControllerDelegate <NSObject>

/**
 完成回调
 */
- (void)tabControllerCompleteButtonClicked;

/**
 取消回调
 */
- (void)tabControllerCancelButtonClicked;

//切换非键盘tag
- (void)tabControllerCaptionSeletedTabChanged:(int)seletedTab;

//气泡
- (void)tabControllerCaptionBubbleViewDidSeleted:(NSString *)path fontId:(NSInteger)fontId;

//阴影
- (void)tabControllerShadowColor:(UIColor *)color offset:(UIOffset)offset;

//字体
- (void)tabControllerFontName:(NSString *)fontName faceType:(int)faceType;

//颜色&描边
- (void)tabControllerTextAndStrokeColor:(AliyunColor *)color;
- (void)tabControllerStrokeWidth:(CGFloat)width;

//排版
- (void)captionTextAlignmentSelected:(NSInteger)type;


//花字
- (void)tabControllerFlowerDidSeleted:(NSString *)path;


@end

/**
 字幕编辑页面
 */
@interface AliyunTabController : NSObject

@property (nonatomic, weak) id<AliyunTabControllerDelegate> delegate;

@property (nonatomic, strong) AliyunPasterTextInputView * textInputView;

@property (nonatomic, assign, readonly) TextActionType selectedActionType;//动画


/**
 显示一个字幕编辑页面到某个view上

 @param superView 想要添加字幕编辑页面的目标view
 @param height view的高度
 @param duration 动画时间
 @param tabItems tabbar上需要的功能项
 */
- (void)presentTabContainerViewInSuperView:(UIView *)superView height:(CGFloat)height duration:(CGFloat)duration tabItems:(NSArray *)tabItems;


/**
 移除字幕编辑页面
 */
- (void)dismissPresentTabContainerView;


/**
 设置默认字幕动画效果

 @param textEffectType 默认字幕动画效果
 */
-(void)setFontEffectDefault:(NSInteger)textEffectType;

-(void)alivcTabbarViewDidSelectedType:(TabBarItemType)type;

- (UIView *)containerView;

- (instancetype)initWithSuperView:(UIView *)superView needInputView:(BOOL)needInputView;

@end

