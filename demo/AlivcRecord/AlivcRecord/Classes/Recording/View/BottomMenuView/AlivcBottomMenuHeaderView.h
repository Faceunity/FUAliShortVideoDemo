//
//  AlivcBottomMenuHeaderView.h
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/4/29.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlivcBottomMenuHeaderViewItem : NSObject
@property(nonatomic, copy)NSString *title;
@property(nonatomic, copy)UIColor *titleColor;
@property(nonatomic, copy)UIImage *icon;
@property(nonatomic, assign)NSInteger tag;


+(instancetype)createItemWithTitle:(NSString *)title icon:(UIImage *)icon tag:(NSInteger)tag;
@end

@protocol AlivcBottomMenuHeaderViewDelegate <NSObject>

-(void)alivcBottomMenuHeaderViewAction:(UIButton *)button;

@end

@interface AlivcBottomMenuHeaderView : UIView

/**
 显示选中下标
 YES:显示  NO:不显示  默认为NO:不显示
 */
@property(nonatomic, assign)BOOL showSelectedFlag;

@property(nonatomic, weak)id<AlivcBottomMenuHeaderViewDelegate>delegate;

-(instancetype)initWithItems:(NSArray <AlivcBottomMenuHeaderViewItem *>*)items;

-(void)didSelectItemWithIndex:(NSInteger )index;

@end

NS_ASSUME_NONNULL_END
