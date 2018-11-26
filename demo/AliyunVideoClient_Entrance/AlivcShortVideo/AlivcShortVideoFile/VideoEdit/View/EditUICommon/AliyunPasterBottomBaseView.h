//
//  AliyunPasterBottomBaseView.h
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/1.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AliyunPasterCollectionViewCell.h"
#import "AliyunPasterGroupCollectionViewCell.h"
#import "AliyunTimelineView.h"
#import "AlivcEditBottomHeaderView.h"

@class AliyunEffectPasterInfo;
@class AliyunEffectPasterGroup;
@class AliyunPasterBottomBaseView;




@protocol AliyunPasterBottomBaseViewDelegate <NSObject>

@required
/**
 添加一个动图的代理方法
 
 @param bottomView 当前的BottomView
 @param pasterInfo 所添加的动图信息
 */
- (void)pasterBottomView:(AliyunPasterBottomBaseView *)bottomView didSelectedPasterModel:(AliyunEffectPasterInfo *)pasterInfo;

/**
 确认按钮代理事件
 
 @param bottomView 当前的BottomView
 */
- (void)pasterBottomViewApply:(AliyunPasterBottomBaseView *)bottomView;

/**
 更多按钮代理事件
 
 @param bottomView 当前的BottomView
 */
- (void)pasterBottomViewMore:(AliyunPasterBottomBaseView *)bottomView;

/**
 取消按钮代理事件
 
 @param bottomView 当前的BottomView
 */
- (void)pasterBottomViewCancel:(AliyunPasterBottomBaseView *)bottomView;

@optional

/**
 自定义headerView高度

 @param bottomView 当前的BottomView
 @return 返回高度
 */
- (CGFloat)pasterBottomViewForHeaderViewHeight:(AliyunPasterBottomBaseView *)bottomView;

/**
 自定义BottomView底部tabBar高度
 
 @param bottomView 当前的BottomView
 @return 返回高度
 */
- (CGFloat)pasterBottomViewForBottomTabbarHeight:(AliyunPasterBottomBaseView *)bottomView;

/**
 自定义timeLineView的大小
 
 @param bottomView 当前的BottomView
 @return 返回timeLineView的大小
 */
- (CGSize)pasterBottomViewForTimeLineViewSize:(AliyunPasterBottomBaseView *)bottomView;

@end

/**
 贴图BottomView基类，所有贴图类（动图||纯字幕||字幕动画）BottomView继承此类
 
 */
@interface AliyunPasterBottomBaseView : UIView

@property (nonatomic, weak)   id<AliyunPasterBottomBaseViewDelegate> delegate;//delegate
@property (nonatomic, strong) UICollectionView *tabbarCollectionView;//底部tabbarCollectionView
@property (nonatomic, strong) AliyunPasterCollectionViewCell *lastPasterCollectionCell;//上一次选中的cell
@property (nonatomic, strong) AliyunPasterGroupCollectionViewCell *lastGroupCollectionCell;//上一次选中的cell
@property (nonatomic, assign) NSInteger selectIndex;//tabbar选中索引

/**
 上次被tabbar的title
 记录此值是为了实现“进入更多页面下载一个资源如果不选中此资源直接返回，则tabbar还是默认上次选中的tabbar，如果在下载页面选中了一个资源，则tabbar选中下载页面选中的资源，而且每次下载的资源要在动图或字幕页面显示在最前面”这样一个业务逻辑，由于每下载一个资源都会插在最前边、导致选中的索引一直在变所以记录title简单粗暴有效
 
 */
@property (nonatomic, strong) NSString *selectTitle;//tabbar倒序选中索引
@property (nonatomic, strong) UICollectionView *pasterCollectionView;//中间展示区pasterCollectionView
@property (nonatomic, strong) AlivcEditBottomHeaderView *headerView;//顶部headerView
@property (nonatomic, strong) AliyunTimelineView *timeLineView;



/**
 初始化UI布局
 */
- (void)setupSubViews;

///**
// 复位UI状态
// */
//-(void)reset;

/**
 是否是上次选中的title

 @param title 本次title
 @return 是否是上次选中的title
 */
-(BOOL)isEqualSelectedTitle:(NSString *)title;


@end
