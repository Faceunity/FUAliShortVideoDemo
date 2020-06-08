//
//  AlivcBottomMenuView.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/5/5.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcBottomMenuView.h"

@implementation AlivcBottomMenuView
{
    AlivcBottomMenuHeaderView *headerView;
    NSArray<AlivcBottomMenuHeaderViewItem *> *_items;
}

-(instancetype)initWithFrame:(CGRect)frame withItems:(NSArray<AlivcBottomMenuHeaderViewItem *> *)items{
    self =[super initWithFrame:frame];
    if (self) {
        [self setupSubviewsWithItems:items];
    }
    return self;
}

-(void)setupSubviewsWithItems:(NSArray<AlivcBottomMenuHeaderViewItem *> *)items{
    headerView =[[AlivcBottomMenuHeaderView alloc]initWithItems:items];
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
