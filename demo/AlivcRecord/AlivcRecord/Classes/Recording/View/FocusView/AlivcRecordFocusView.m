//
//  AlivcRecordFocusView.m
//  AlivcVideoClient_Entrance
//
//  Created by wanghao on 2019/3/18.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcRecordFocusView.h"
#import "UIColor+AlivcHelper.h"

@interface AlivcRecordFocusView()
@property (nonatomic,assign) NSTimeInterval lastTime;
@end

@implementation AlivcRecordFocusView


- (instancetype)initWithFrame:(CGRect)frame{
    self =[super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled =NO;
    }
    return self;
}

- (void)hiddenAction{
    self.hidden = YES;
}

- (void)setCenter:(CGPoint)center{
     __weak typeof(self) weakSelf = self;
    [super setCenter:center];
    self.lastTime =  CFAbsoluteTimeGetCurrent();
    [self.superview bringSubviewToFront:self];
    self.hidden =NO;
    if (self.animation) {
        self.transform = CGAffineTransformIdentity;
        self.layer.anchorPoint = CGPointMake(0.35, 0.28);
        [UIView animateWithDuration:0.3 animations:^{
            self.transform = CGAffineTransformMakeScale(0.75, 0.75);
        }];
        
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (CFAbsoluteTimeGetCurrent() - weakSelf.lastTime > 1) {
             [weakSelf hiddenAction];
        }
    });
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    CGFloat size =CGRectGetWidth(self.frame)-4;
    CGFloat lineLenth = 5;
    UIBezierPath *path =[UIBezierPath bezierPath];
    path.lineWidth = 1.0;

    CGFloat center_x = size/2;
    CGFloat center_y = size/2;
    CGFloat start_x =2;
    CGFloat start_y =2;
    
    [path moveToPoint:CGPointMake(start_x,start_y)];
    [path addLineToPoint:CGPointMake(center_x,start_y)];
    [path addLineToPoint:CGPointMake(center_x,start_y+lineLenth)];

    [path moveToPoint:CGPointMake(center_x,start_y)];
    [path addLineToPoint:CGPointMake(start_x+size,start_y)];
    [path addLineToPoint:CGPointMake(start_x+size,center_y)];
    [path addLineToPoint:CGPointMake(start_x+size-lineLenth,center_y)];

    [path moveToPoint:CGPointMake(start_x+size,center_y)];
    [path addLineToPoint:CGPointMake(start_x+size,start_y+size)];
    [path addLineToPoint:CGPointMake(center_x,start_y+size)];
    [path addLineToPoint:CGPointMake(center_x,start_y+size-lineLenth)];

    [path moveToPoint:CGPointMake(center_x,start_y+size)];
    [path addLineToPoint:CGPointMake(start_x,start_y+size)];
    [path addLineToPoint:CGPointMake(start_x,center_y)];
    [path addLineToPoint:CGPointMake(start_x+lineLenth,center_y)];

    [path moveToPoint:CGPointMake(start_x,center_y)];
    [path addLineToPoint:CGPointMake(start_x, start_y)];
    [path closePath];
    UIColor *lineColor = [UIColor colorWithHexString:@"#FECB2F"];
    [lineColor set];
    [path stroke];
}

- (void)dealloc{
    NSLog(@"AlivcRecordFocusView dealloc");
  
}

@end
