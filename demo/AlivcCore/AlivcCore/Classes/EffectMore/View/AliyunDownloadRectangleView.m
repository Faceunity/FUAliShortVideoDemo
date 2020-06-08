//
//  AliyunDownloadRectangleView.m
//  AliyunVideoClient_Entrance
//
//  Created by 张璠 on 2018/9/6.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AliyunDownloadRectangleView.h"

@implementation AliyunDownloadRectangleView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}


/**
 设置文字和圆角
 */
- (void)setupSubViews{
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:self.bounds];
    textLabel.text = NSLocalizedString(@"下载中" , nil);
    textLabel.textColor = [UIColor whiteColor];
    textLabel.font = [UIFont systemFontOfSize:12];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:textLabel];
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 1;
}
/**
 绘制进度条

 @param rect 绘制的frame值
 */
- (void)drawRect:(CGRect)rect {
    // 绘制背景
    CGContextRef ctx2 = UIGraphicsGetCurrentContext();
    CGContextAddRect(ctx2, rect);
    CGContextSetFillColor(ctx2, CGColorGetComponents([rgba(97, 89, 86, 1) CGColor]));
    CGContextFillPath(ctx2);
    // 绘制进度
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddRect(ctx, CGRectMake(0, 0, rect.size.width*_percentage, rect.size.height));
    CGContextSetFillColor(ctx, CGColorGetComponents([AlivcOxRGB(0x00c1de) CGColor]));
    CGContextFillPath(ctx);
    
}


/**
 刷新进度条百分比

 @param percentage 百分比
 */
- (void)setPercentage:(CGFloat)percentage{
    _percentage = percentage;
    [self setNeedsDisplay];
    
}
@end
