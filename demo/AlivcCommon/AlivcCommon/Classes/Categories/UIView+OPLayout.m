//
//  UIView+OPLayout.m
//  Maying
//
//  Created by mengyehao on 2019/8/20.
//  
//

#import "UIView+OPLayout.h"

@implementation UIView (OPLayout)


- (CGFloat)op_left
{
    return self.frame.origin.x;
}

- (CGFloat)op_right
{
    return CGRectGetMaxX(self.frame);
}

- (CGFloat)op_top
{
    return self.frame.origin.y;
}

- (CGFloat)op_bottom;
{
    return CGRectGetMaxY(self.frame);
}


- (CGFloat)op_width
{
    return CGRectGetWidth(self.frame);
}

- (CGFloat)op_height
{
    return CGRectGetHeight(self.frame);
}

- (void)setOp_left:(CGFloat)op_left
{
    CGRect frame = self.frame;
    frame.origin.x = op_left;
    self.frame = frame;
}

- (void)setOp_right:(CGFloat)op_right
{
    [self setOp_left:op_right - self.op_width];
}

- (void)setOp_top:(CGFloat)op_top
{
    CGRect frame = self.frame;
    frame.origin.y = op_top;
    self.frame = frame;
}

- (void)setOp_bottom:(CGFloat)op_bottom
{
    [self setOp_top:op_bottom - self.op_height];
}

- (void)setOp_width:(CGFloat)op_width
{
    CGRect frame = self.frame;
    frame.size.width = op_width;
    self.frame = frame;
}

- (void)setOp_height:(CGFloat)op_height
{
    CGRect frame = self.frame;
    frame.size.height = op_height;
    self.frame = frame;
}

@end
