//
//  AliyunRecordBeautyView.h
//  AliyunVideoClient_Entrance
//
//  Created by 张璠 on 2018/7/6.
//  Copyright © 2018年 Alibaba. All rights reserved.
//  点击录制按钮旁边左右两个按钮弹出的view

#import <UIKit/UIKit.h>

// 美颜类型,分为高级美颜和普通美颜
typedef enum : NSUInteger {
    AliyunBeautyTypeAdvanced = 0,
    AliyunBeautyTypeBase
} AliyunBeautyType;

@class AliyunEffectFilterInfo,AliyunEffectMvGroup,AliyunRecordBeautyView;

@protocol AliyunRecordBeautyViewDelegate <NSObject>
@optional

/**
 选中某个滤镜

 @param filter 滤镜数据模型
 */
- (void)didSelectEffectFilter:(AliyunEffectFilterInfo *)filter;

/**
 基础美颜的美颜值改变

 @param beautyValue 美颜值（1-100）
 */
- (void)didChangeBeautyValue:(CGFloat)beautyValue;

/**
 高级美颜的美白值改变

 @param beautyWhiteValue 高级美颜：美白参数值
 */
- (void)didChangeAdvancedBeautyWhiteValue:(CGFloat)beautyWhiteValue;

/**
 高级美颜的磨皮值改变

 @param blurValue 高级美颜：磨皮参数值
 */
- (void)didChangeAdvancedBlurValue:(CGFloat)blurValue;

/**
 高级美颜的红润值改变

 @param buddyValue 高级美颜：红润参数值
 */
- (void)didChangeAdvancedBuddy:(CGFloat)buddyValue;

/**
 美肌的大眼值改变

 @param bigEyeValue 美肌：大眼参数值
 */
- (void)didChangeAdvancedBigEye:(CGFloat)bigEyeValue;

/**
 美肌的瘦脸值改变

 @param slimFaceValue 美肌：瘦脸参数值
 */
- (void)didChangeAdvancedSlimFace:(CGFloat)slimFaceValue;


/**
 选中某个人脸动图

 @param index 序号
 @param cell cell对象
 */
- (void)focusItemIndex:(NSInteger)index cell:(UICollectionViewCell *)cell;

/**
 选中某个MV

 @param mvGroup MV数据模型
 */
- (void)didSelectEffectMV:(AliyunEffectMvGroup *)mvGroup;

/**
 选中某个MV

 @param mvGroup MV数据模型
 @param index 序号
 */
- (void)didSelectEffectMV:(AliyunEffectMvGroup *)mvGroup itemIndex:(NSInteger)index;

/**
 切换高级美颜
 */
- (void)didChangeAdvancedMode;

/**
 切换普通美颜
 */
- (void)didChangeCommonMode;

/**
 退出此类的view

 @param view 此类的view
 @param button 退出按钮
 */
- (void)recordBeautyView:(AliyunRecordBeautyView *)view dismissButtonTouched:(UIButton *)button;
@end

@interface AliyunRecordBeautyView : UIView

/**
 初始化方法

 @param frame frame值
 @param titleArray 文字数组
 @param imageArray 图片数组
 @return self对象
 */
-(instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray *)titleArray imageArray:(NSArray *)imageArray;

/**
 此类的代理
 */
@property (nonatomic, weak) id<AliyunRecordBeautyViewDelegate> delegate;


/**
 设置动图选中哪个

 @param selectedIndex 选中的序号
 */
- (void)setGifSelectedIndex:(NSInteger)selectedIndex;


/**
 根据新的动图数组刷新ui

 @param effectItems 新的动图数组
 */
- (void)refreshUIWithGifItems:(NSArray *)effectItems;


/**
 根据新的mv数组刷新ui

 @param mvItems 新的mv数组
 */
- (void)refreshUIWithMVItems:(NSArray *)mvItems;

/**
 动图实际应用时候调用此方法刷新UI选中状态
 */
- (void)refreshUIWhenThePasterInfoApplyedWithIndex:(NSInteger)applyedIndex;


@end
