//
//  AliyunRateSelectView.m
//  qusdk
//
//  Created by Worthy on 2017/6/19.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunRateSelectView.h"

@implementation AliyunRateSelectView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(instancetype)initWithItems:(NSArray *)items {
    self = [super initWithItems:items];
    if (self) {
        [self setup];
    }
    return self;
}

/**
 设置一些属性
 */
- (void)setup {
    self.backgroundColor = rgba(255,255,255,0.5);
    [self setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}
                           forState:UIControlStateNormal];
    [self setBackgroundImage:[self imageWithBgColor:rgba(23,31,33,0.8)]
                    forState:UIControlStateNormal
                  barMetrics:UIBarMetricsDefault];
    
    [self setTitleTextAttributes:@{NSForegroundColorAttributeName:AlivcOxRGB(0x333333)}
                        forState:UIControlStateSelected];
    [self setBackgroundImage:[self imageWithBgColor:AlivcOxRGB(0xf8f8f8)]
                    forState:UIControlStateSelected
                  barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:[self imageWithBgColor:AlivcOxRGB(0xf8f8f8)]
                    forState:UIControlStateHighlighted
                  barMetrics:UIBarMetricsDefault];
    
    [self setDividerImage:[self imageWithBgColor:rgba(23,31,33,0.8)] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

}


/**
 通过颜色生成一个背景图片

 @param color 颜色
 @return 生成的图片对象
 */
- (UIImage *)imageWithBgColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}


@end
