//
//  AlivcRecordPasterView.h
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/5/5.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcBottomMenuView.h"
@class AliyunPasterInfo;

NS_ASSUME_NONNULL_BEGIN

@protocol AlivcRecordPasterViewDelegate <NSObject>
@optional
/**
 选中动图的代理方法

 @param pasterInfo 被选中的动图信息
 @param cell 被选中的cell
 */
- (void)alivcRecordPasterViewDidSelectedPasterInfo:(AliyunPasterInfo *)pasterInfo cell:(UICollectionViewCell *)cell;

@end

@interface AlivcRecordPasterView : AlivcBottomMenuView

@property (nonatomic, weak)id<AlivcRecordPasterViewDelegate>delegate;

/**
 设置动图选中哪个
 
 @param selectedIndex 选中的序号
 */
- (void)setGifSelectedIndex:(NSInteger)selectedIndex;

/**
 根据新的动图数组刷新ui
 
 @param pasterInfos 新的动图数组
 */
- (void)refreshUIWithGifItems:(NSArray *)pasterInfos;

///**
// 根据pasterInfo获取paster所在cell的索引
//
// @param pasterInfo 目标pasterInfo
// @return paster所在cell的索引
// */
//- (NSInteger)getIndexForPasterInfo:(AliyunPasterInfo *)pasterInfo;

/**
 动图应用上去之后更新UI状态
 */
- (void)refreshUIWhenThePasterInfoApplyedWithPasterInfo:(nonnull AliyunPasterInfo *)pasterInfo;


@end

NS_ASSUME_NONNULL_END
