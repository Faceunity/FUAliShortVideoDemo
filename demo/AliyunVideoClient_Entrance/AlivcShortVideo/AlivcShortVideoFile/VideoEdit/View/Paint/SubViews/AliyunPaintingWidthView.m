//
//  AliyunPaintingWidthView.m
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/3.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AliyunPaintingWidthView.h"

#define kPaintButtonTag 2005
#define kPaintButtonHeight 35

@interface AliyunPaintingWidthView()
@property(nonatomic, assign)BOOL animateIsOver;//切换选中圈圈动画是否结束

@end

@implementation AliyunPaintingWidthView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews{
    int buttonIndex = 3;
    UIButton *lastButton;
    for (int index = 0; index < buttonIndex; index++) {
        CGFloat width =15+7*index;
        UIButton *sizeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, width, width)];
        sizeButton.tag = kPaintButtonTag + index;
        sizeButton.layer.borderWidth = 2;
        sizeButton.layer.cornerRadius = width/2;
        sizeButton.layer.borderColor = AlivcOxRGB(0x979797).CGColor;
        [sizeButton addTarget:self action:@selector(changeWidthButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [self addSubview:sizeButton];
        CGFloat pointX = index == 0?(width/2+5):index == 1?CGRectGetMidX(self.frame)-width/2:(CGRectGetWidth(self.frame)-width/2-5);
        sizeButton.center = CGPointMake(pointX, CGRectGetHeight(self.frame)/2);
        if (index == 0) {
            _currentTagBtn = sizeButton;
            self.widthtTagColor = [UIColor whiteColor];
        }
        if (index > 0 && lastButton) {
            CGFloat afterWidth = CGRectGetWidth(self.frame)-CGRectGetMinX(sizeButton.frame);
            CGFloat lineWidth =CGRectGetWidth(self.frame)-CGRectGetMaxX(lastButton.frame)-afterWidth;
            CAShapeLayer *line = [CAShapeLayer layer];
            [line setFillColor:[AlivcOxRGB(0xD7D8D9)CGColor]];
            [line setStrokeColor:[AlivcOxRGB(0xD7D8D9)CGColor]];
            line.lineWidth = 1.0f;
            UIBezierPath *path = [[UIBezierPath alloc]init];
            [path moveToPoint:CGPointMake(CGRectGetMaxX(lastButton.frame), CGRectGetMidY(lastButton.frame))];
            [path addLineToPoint:CGPointMake(CGRectGetMaxX(lastButton.frame)+lineWidth,CGRectGetMidY(lastButton.frame))];
            line.path = path.CGPath;
            [self.layer addSublayer:line];
        }
        lastButton = sizeButton;
    } 
}

-(void)changeWidthButtonAction:(UIButton *)btn{
    if (_currentTagBtn == btn) {
        return;
    }
    NSInteger index = btn.tag - kPaintButtonTag;
    NSInteger width =   SizeWidth(5.0) + 5 * index;
    if (self.changeWidthHandle) {
        self.changeWidthHandle(width);
    }
    _currentTagBtn.backgroundColor = [UIColor clearColor];
    __block UIButton *cursorBtn = [[UIButton alloc]initWithFrame:_currentTagBtn.frame];
    cursorBtn.backgroundColor = _widthtTagColor;
    cursorBtn.layer.masksToBounds = YES;
    cursorBtn.layer.cornerRadius = _currentTagBtn.layer.cornerRadius;
    [self addSubview:cursorBtn];
    
    _currentTagBtn = btn;
    [UIView animateWithDuration:0.25 animations:^{
        cursorBtn.frame = btn.frame;
        cursorBtn.layer.cornerRadius = btn.layer.cornerRadius;
    } completion:^(BOOL finished) {
        [cursorBtn removeFromSuperview];
        cursorBtn = nil;
        _currentTagBtn = btn;
        btn.backgroundColor = _widthtTagColor;
    }];
}

-(void)setWidthtTagColor:(UIColor *)widthtTagColor{
    _widthtTagColor = widthtTagColor;
    if (_currentTagBtn) {
        _currentTagBtn.backgroundColor = widthtTagColor;
    }
}



@end
