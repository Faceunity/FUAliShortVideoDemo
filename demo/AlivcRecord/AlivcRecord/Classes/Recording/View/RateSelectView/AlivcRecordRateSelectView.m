//
//  AlivcRecordRateSelectView.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/4/22.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcRecordRateSelectView.h"

@implementation AlivcRecordRateSelectView
{
    UIView *_tagView;
    UIButton *_lastBtn;
    int _selectedIndex;
    AlivcRecordDidSelectRateBlock _rateBlock;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self =[super initWithFrame:frame];
    if (self) {
        self.backgroundColor =[UIColor colorWithWhite:0 alpha:0.5];
        self.layer.cornerRadius =4;
        self.layer.masksToBounds =YES;
        _selectedIndex =2;
    }
    return self;
}

- (void)setupViewsWithItems:(NSArray *)items selectedRateBlock:(nonnull AlivcRecordDidSelectRateBlock)rateBlock{
//    NSArray *texts =@[@"极慢",@"慢",@"标准",@"快",@"极快"];
    _rateBlock = rateBlock;
    CGFloat width =CGRectGetWidth(self.frame)/items.count;
    if (!_tagView) {
        _tagView =[[UIView alloc]initWithFrame:CGRectMake(width * _selectedIndex, 0, width, CGRectGetHeight(self.frame))];
        _tagView.backgroundColor =[UIColor whiteColor];
        _tagView.layer.cornerRadius =4;
        [self insertSubview:_tagView atIndex:1];
    }
    for (int i =0; i<items.count; i++) {
        UIButton *btn =[[UIButton alloc]initWithFrame:CGRectMake(width*i, 0, width, CGRectGetHeight(self.frame))];
        btn.backgroundColor =[UIColor clearColor];
        btn.titleLabel.font =[UIFont boldSystemFontOfSize:14];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.textAlignment =NSTextAlignmentCenter;
        [btn setTitle:items[i] forState:UIControlStateNormal];
        btn.showsTouchWhenHighlighted =YES;
        btn.tag =i;
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        if (i == _selectedIndex) {
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            _lastBtn = btn;
        }
        [self insertSubview:btn atIndex:2];
    }
}

- (void)btnAction:(UIButton *)sBtn{
    if (sBtn == _lastBtn) {return;}//防止重复点击
    [UIView animateWithDuration:0.2 animations:^{
        _tagView.frame = sBtn.frame;
    }];
    [_lastBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    CGFloat rate = 1.0f;
    if (_rateBlock) {
        switch (sBtn.tag) {
            case 0:rate = 0.5f; break;
            case 1:rate = 0.75f; break;
            case 2:rate = 1.0f; break;
            case 3:rate = 1.5f; break;
            case 4:rate = 2.0f; break;
            default:break;
        }
        _rateBlock(rate);
    }
    _lastBtn =sBtn;
}

@end
