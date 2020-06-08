//
//  AlivcEditIconButton.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2018/10/12.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcEditIconButton.h"

@implementation AlivcEditIconButton

-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    
    CGFloat imageW = 23;
    
    CGFloat imageH = 23;
    
    CGFloat imageX = [self getXAtImageWidth:imageW withContentRect:contentRect]-4;
    
    CGFloat imageY = (CGRectGetHeight(contentRect)-imageH)/2;
    
    return CGRectMake(imageX, imageY, imageW, imageH);
}
-(CGFloat)getXAtImageWidth:(CGFloat)imagew withContentRect:(CGRect)contentRect{
    CGSize size = [self.currentTitle sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, CGRectGetHeight(contentRect))];
//    CGSize size = [self sizeThatFits:CGSizeMake(CGRectGetWidth(self.bounds), MAXFLOAT)];
    CGFloat contentW = imagew+size.width;
    CGFloat imageX = (CGRectGetWidth(self.bounds)-contentW)/2;
    return imageX;
}
@end
