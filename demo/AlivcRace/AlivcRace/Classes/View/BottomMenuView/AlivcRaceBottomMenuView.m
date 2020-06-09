//
//  AlivcBottomMenuView.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/5/5.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcRaceBottomMenuView.h"

@implementation AlivcRaceBottomMenuView
{
    AlivcRaceBottomMenuHeaderView *headerView;
    NSArray<AlivcRaceBottomMenuHeaderViewItem *> *_items;
}

-(instancetype)initWithFrame:(CGRect)frame withItems:(NSArray<AlivcRaceBottomMenuHeaderViewItem *> *)items{
    self =[super initWithFrame:frame];
    if (self) {
        [self setupSubviewsWithItems:items];
    }
    return self;
}

-(void)setupSubviewsWithItems:(NSArray<AlivcRaceBottomMenuHeaderViewItem *> *)items{
    headerView =[[AlivcRaceBottomMenuHeaderView alloc]initWithItems:items];
    headerView.delegate = (id<AlivcBottomMenuHeaderViewDelegate>)self;
    headerView.showSelectedFlag = _showHeaderViewSelectedFlag;
    self.headerView = headerView;
}

-(void)didSelectHeaderViewWithIndex:(NSInteger)index{
    [headerView didSelectItemWithIndex:index];
}

-(void)setShowHeaderViewSelectedFlag:(BOOL)showHeaderViewSelectedFlag{
    _showHeaderViewSelectedFlag = showHeaderViewSelectedFlag;
    headerView.showSelectedFlag = _showHeaderViewSelectedFlag;
}

@end
