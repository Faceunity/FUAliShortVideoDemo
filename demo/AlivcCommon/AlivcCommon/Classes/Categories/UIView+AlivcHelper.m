//
//  UIView+AlivcHelper.m
//  MaoBoli
//
//  Created by Zejian Cai on 2018/7/19.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "UIView+AlivcHelper.h"

@implementation UIView (AlivcHelper)

- (void)addVisualEffect{
    self.backgroundColor = [UIColor clearColor];
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    visualEffectView.frame =CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:visualEffectView];
    [self sendSubviewToBack:visualEffectView];
}

-(void)addVisualEffectWithFrame:(CGRect)frame{
    self.backgroundColor = [UIColor clearColor];
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    visualEffectView.frame =frame;
    [self addSubview:visualEffectView];
    [self sendSubviewToBack:visualEffectView];
}

-(void)removeVisualEffectView{
    for (id effectView in self.subviews) {
        if ([effectView isKindOfClass:[UIVisualEffectView class]]) {
            [effectView removeFromSuperview];
        }
    }
}

- (UIViewController *)getCurrentVC {
    //通过响应者链，取得此视图所在的视图控制器
    UIResponder *next = self.nextResponder;
    do {
        
        //判断响应者对象是否是视图控制器类型
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        
        next = next.nextResponder;
        
    }while(next != nil);
    
    return nil;
}

@end
