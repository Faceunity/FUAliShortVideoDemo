//
//  AliyunToolView.m
//  AliyunVideoClient_Entrance
//
//  Created by 张璠 on 2018/7/6.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AliyunToolView.h"
@interface AliyunToolView()

/**
 被选中的按钮
 */
@property(nonatomic , weak) UIButton *selectButton;

/**
 分割线
 */
@property(nonatomic , weak) UIView *bottomLine;

/**
 按钮数组
 */
@property (nonatomic, strong) NSMutableArray *buttonArray;
@end

@implementation AliyunToolView

- (instancetype)initWithItems:(NSArray *)items imageArray:(NSArray *)imageArray frame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup:items imageArray:imageArray frame:frame];
        
    }
    return self;
}


/**
 设置子控件

 @param items 文字数组
 @param imageArray 图片数组
 @param frame frame值
 */
- (void)setup:(NSArray *)items imageArray:(NSArray *)imageArray frame:(CGRect)frame{
    self.buttonArray = [[NSMutableArray alloc]init];
    for (int i=0; i<items.count; i++) {
        UIButton *button = [[UIButton alloc] init];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        if (i==0) {
            self.selectButton = button;
            button.selected = YES;
            UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width/items.count-32)/2, self.bounds.size.height-3, 30, 2)];
            bottomLine.backgroundColor = AlivcOxRGB(0x00c1de);
            self.bottomLine = bottomLine;
            [self addSubview:bottomLine];
        }
        
        button.tag = i;
        [button setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 6)];
        [button setImage:[AlivcImage imageNamed:imageArray[i]] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:items[i] forState:UIControlStateNormal];
        CGFloat buttonW = frame.size.width/items.count;
        CGFloat buttonH = frame.size.height;
        CGFloat buttonX = i*buttonW;
        CGFloat buttonY = 0;
        button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        [self addSubview:button];
        [self.buttonArray addObject:button];
        if ((items.count == 2)&&(i==1)) {
            NSNotification *notification =[NSNotification notificationWithName:@"AliyunNotificationMVButton" object:button];
            
            //通过通知中心发送通知
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
    }
    UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-0.5, frame.size.width, 0.5)];
    separatorLine.backgroundColor = AlivcOxRGB(0xc3c5c6);
    separatorLine.alpha = 0.5;
    [self addSubview:separatorLine];
}

/**
 按钮点击事件

 @param button 被点击的按钮
 */
- (void)buttonClick:(UIButton *)button{
    [UIView animateWithDuration:0.2 animations:^{
        CGPoint point = self.bottomLine.center;
        point.x = button.center.x;
        self.bottomLine.center = point;
    }];
    
    self.selectButton.selected = NO;
    self.selectButton = button;
    if ([self.delegate respondsToSelector:@selector(AliyunToolView:didClickedButton:)]) {
        [self.delegate AliyunToolView:self didClickedButton:button.tag];
    }
}

- (void)clickTithTag:(NSInteger)tag{
    for (UIButton *button in self.buttonArray) {
        if (button.tag == tag) {
            [self buttonClick:button];
            break;
        }
    }
}
@end
