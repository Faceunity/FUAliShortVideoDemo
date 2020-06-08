//
//  AlivcRecordButton.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/4/22.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcRecordButton.h"
#import "UIColor+AlivcHelper.h"

@implementation AlivcRecordButton
{
    AlivcRecordButtonStatus _status;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.backgroundColor =[UIColor clearColor];
        self.titleLabel.font =[UIFont systemFontOfSize:12];
    }
    return self;
}

- (void)changeRecordButtonStatus:(AlivcRecordButtonStatus)status{
    _status = status;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGFloat lineWidth =ceilf(CGRectGetWidth(rect)*0.14/2);
    CGFloat circleRadius = ceilf(CGRectGetWidth(rect)*0.72/2);
    CGFloat circleBorderRadius = ceilf(CGRectGetWidth(rect)/2);
    if (_status == AlivcRecordButtonStatusHighlight){
        [self drawShakeCircleBorderWithRadius:circleBorderRadius-ceilf((lineWidth)/2) withRect:rect lineWidth:lineWidth lineColor:[UIColor colorWithHexString:@"0xFC4448"]];
    }else if (_status == AlivcRecordButtonStatusSelected){
        [self drawShakeCircleBorderWithRadius:circleBorderRadius-ceilf((lineWidth)/2) withRect:rect lineWidth:lineWidth lineColor:[UIColor colorWithHexString:@"0xFC4448"]];
        [self drawShakeSquareWithRadius:5 withRect:CGRectMake(20, 20, CGRectGetWidth(rect)-40, CGRectGetWidth(rect)-40)];
    }else{
        [self drawShakeCircleBorderWithRadius:circleBorderRadius-ceilf((lineWidth)/2) withRect:rect lineWidth:lineWidth lineColor:[UIColor whiteColor]];
        [self drawShakeCircleWithRadius:circleRadius withRect:rect];
    }
}

// 绘制圆形
- (void)drawShakeCircleWithRadius:(CGFloat)radius withRect:(CGRect)rect;
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor colorWithHexString:@"0xFC4448"].CGColor);
    CGContextAddArc(context, CGRectGetWidth(rect)/2, CGRectGetHeight(rect)/2, radius, 0, 2*M_PI, 0);
    CGContextDrawPath(context, kCGPathFill);
}
// 绘制圆圈
- (void)drawShakeCircleBorderWithRadius:(CGFloat)radius withRect:(CGRect)rect lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextAddArc(context, CGRectGetWidth(rect)/2, CGRectGetHeight(rect)/2, radius, 0, 2*M_PI, 0);
    CGContextDrawPath(context, kCGPathStroke);
}
// 绘制方形
- (void)drawShakeSquareWithRadius:(CGFloat)radius withRect:(CGRect)rect{
    UIBezierPath *path =[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    [[UIColor colorWithHexString:@"0xFC4448"] set];
    [path fill];
}


@end
