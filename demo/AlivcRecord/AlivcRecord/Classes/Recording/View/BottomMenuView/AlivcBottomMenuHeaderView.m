//
//  AlivcBottomMenuHeaderView.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/4/29.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcBottomMenuHeaderView.h"
#import "AlivcButton.h"
#import "UIView+AlivcHelper.h"
#import "UIColor+AlivcHelper.h"

//高度
static CGFloat AlivcBottomMenuHeaderViewHeight = 45;

@implementation AlivcBottomMenuHeaderViewItem
-(instancetype)init{
    self =[super init];
    if (self) {
        _title =@"";
        _titleColor =[UIColor whiteColor];
    }
    return self;
}
+(instancetype)createItemWithTitle:(NSString *)title icon:(UIImage *)icon tag:(NSInteger)tag{
    AlivcBottomMenuHeaderViewItem *item =[AlivcBottomMenuHeaderViewItem new];
    item.title = title;
    item.icon = icon;
    item.tag = tag;
    return item;
}

@end

@implementation AlivcBottomMenuHeaderView
{
    UIView *_flagView;
}

-(instancetype)initWithItems:(NSArray<AlivcBottomMenuHeaderViewItem *> *)items{
    self = [super initWithFrame:CGRectMake(0, 0, ScreenWidth, AlivcBottomMenuHeaderViewHeight)];
    if (self) {
        self.backgroundColor =[UIColor clearColor];
        [self setupSubviewsItems:items];
        
    }
    return self;
}

-(void)setupSubviewsItems:(NSArray<AlivcBottomMenuHeaderViewItem *> *)items{
    CGFloat btnSize = ScreenWidth/items.count;
    for (int i =0; i<items.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(btnSize*i, 0, btnSize, CGRectGetHeight(self.frame));
        btn.tag = items[i].tag;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.backgroundColor = [UIColor clearColor];
        [self addSubview:btn];
        if (i == 0) {
            _flagView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 2)];
            _flagView.hidden = !_showSelectedFlag;
            [self addSubview:_flagView];
            _flagView.backgroundColor =[UIColor colorWithHexString:@"#00C1DE"];
            _flagView.center = CGPointMake(btn.center.x, CGRectGetHeight(self.frame)-CGRectGetHeight(_flagView.frame)/2);
        }
        btn.titleLabel.font =[UIFont systemFontOfSize:14];
        [btn setTitle:items[i].title forState:UIControlStateNormal];
        [btn setTintColor:items[i].titleColor];
        [btn setImage:items[i].icon forState:UIControlStateNormal];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
        [btn addTarget:self action:@selector(btnAciton:) forControlEvents:UIControlEventTouchUpInside];
    }
}
-(void)setShowSelectedFlag:(BOOL)showSelectedFlag{
    _showSelectedFlag = showSelectedFlag;
    _flagView.hidden = !showSelectedFlag;
}

-(void)btnAciton:(UIButton *)sBtn{
    if (CGPointEqualToPoint(_flagView.center, CGPointMake(sBtn.center.x, _flagView.center.y))) {//处理重复点击
        return;
    }
    [UIView animateWithDuration:0.2 animations:^{
        _flagView.center = CGPointMake(sBtn.center.x, _flagView.center.y);
    }];
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcBottomMenuHeaderViewAction:)]) {
        [self.delegate alivcBottomMenuHeaderViewAction:sBtn];
    }
}

-(void)didSelectItemWithIndex:(NSInteger)index{
    UIButton *btn = [self viewWithTag:index];
    if (btn) {
        [self btnAciton:btn];
    }
}



@end
