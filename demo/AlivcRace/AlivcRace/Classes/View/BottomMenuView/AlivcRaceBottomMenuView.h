//
//  AlivcBottomMenuView.h
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/5/5.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcRaceBottomMenuBaseView.h"
#import "AlivcRaceBottomMenuHeaderView.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlivcRaceBottomMenuView : AlivcRaceBottomMenuBaseView

/**
 是否显示选中下标
 */
@property(nonatomic, assign)BOOL showHeaderViewSelectedFlag;

-(instancetype)initWithFrame:(CGRect)frame withItems:(NSArray <AlivcRaceBottomMenuHeaderViewItem *>*)items;

-(void)didSelectHeaderViewWithIndex:(NSInteger )index;

@end

NS_ASSUME_NONNULL_END
