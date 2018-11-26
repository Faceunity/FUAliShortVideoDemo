//
//  AliyunColorPaletteItemCell.m
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/3.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AliyunColorPaletteItemCell.h"

@interface AliyunColorPaletteItemCell()
@property (strong, nonatomic)UIView *colorView;
@property (nonatomic, strong) CAShapeLayer *borderLayer;

@end

@implementation AliyunColorPaletteItemCell

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.colorView];
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setColor:(AliyunColor *)color
{
    _color = color;
    if (color.isStroke == NO) {
        [self.borderLayer removeFromSuperlayer];
        self.colorView.backgroundColor = [UIColor colorWithRed:self.color.tR /255 green:self.color.tG / 255 blue:self.color.tB / 255 alpha:1];;
    } else {
        [self.borderLayer removeFromSuperlayer];
        self.borderLayer = [CAShapeLayer layer];
        self.borderLayer.bounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        self.borderLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        self.borderLayer.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        self.borderLayer.lineWidth = 4;
        self.borderLayer.fillColor = [UIColor clearColor].CGColor;
//        self.borderLayer.fillColor = [UIColor colorWithRed:35 / 255.0 green:42 / 255.0 blue:66 / 255.0 alpha:1].CGColor;
        self.borderLayer.strokeColor = [UIColor colorWithRed:_color.sR / 255 green:_color.sG / 255 blue:_color.sB / 255 alpha:1].CGColor;
        [self.colorView.layer addSublayer:self.borderLayer];
        _colorView.backgroundColor = [UIColor clearColor];
    }
}

-(void)drawLine{
    CAShapeLayer *line = [CAShapeLayer layer];
    [line setFillColor:[[UIColor clearColor] CGColor]];
    [line setStrokeColor:[[UIColor colorWithRed:151.f/255 green:151.f/255 blue:151.f/255 alpha:1.0f] CGColor]];
    line.lineWidth = 2.0f ;
    UIBezierPath *path = [[UIBezierPath alloc]init];
    [path moveToPoint:CGPointMake(5, 5)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(self.colorView.bounds)-5,CGRectGetHeight(self.colorView.bounds)-5)];
    line.path = path.CGPath;
    [self.colorView.layer addSublayer:line];
}

-(UIView *)colorView{
    if (!_colorView) {
        _colorView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame))];
        _colorView.backgroundColor = [UIColor clearColor];
        _colorView.layer.cornerRadius = 3;
        _colorView.layer.masksToBounds = YES;
    }
    return _colorView;
}


@end
