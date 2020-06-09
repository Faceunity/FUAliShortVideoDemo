//
//  AlivcButton.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/4/28.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcButton.h"

@implementation AlivcButton
{
    AlivcButtonType _type;
}

-(instancetype)initWithButtonType:(AlivcButtonType)type{
    self =[super init];
    if (self) {
        _type = type;
        switch (_type) {
            case AlivcButtonTypeTitleTop:
            case AlivcButtonTypeTitleBottom:
                self.titleLabel.textAlignment =NSTextAlignmentCenter;
                break;
            case AlivcButtonTypeTitleLeft:
                self.titleLabel.textAlignment =NSTextAlignmentLeft;
                break;
            case AlivcButtonTypeTitleRight:
                self.titleLabel.textAlignment =NSTextAlignmentRight;
            default:
                break;
        }
    }
    return self;
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGFloat image_w = 0.0f;
    CGFloat image_h = 0.0f;
    CGFloat image_x = 0.0f;
    CGFloat image_y = 0.0f;
    switch (_type) {
        case AlivcButtonTypeTitleTop:;
        case AlivcButtonTypeTitleBottom:
        {
            image_w = CGRectGetHeight(self.bounds)*0.55;
            image_h = image_w;
            image_x = (CGRectGetWidth(self.bounds)-image_w)/2;
            image_y = CGRectGetHeight(self.bounds)*0.04;
        }
            break;
        case AlivcButtonTypeTitleLeft:;
        {
            image_w = CGRectGetHeight(self.bounds)*0.6;
            image_h = image_w;
            image_x = CGRectGetWidth(self.bounds)-image_w;
            image_y = (CGRectGetHeight(self.bounds)-image_h)/2;
        }
            break;
        case AlivcButtonTypeTitleRight:
        {
            return [super imageRectForContentRect:contentRect];
//            image_w = CGRectGetHeight(self.bounds)*0.6;
//            image_h = image_w;
//            image_x = CGRectGetWidth(self.bounds)-image_w;
//            image_y = (CGRectGetHeight(self.bounds)-image_h)/2;
        }
            break;
        default:
            return [super imageRectForContentRect:contentRect];
            break;
    }
    return CGRectMake(image_x, image_y, image_w, image_h);
}
-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGFloat image_w = 0.0f;
    CGFloat image_h = 0.0f;
    CGFloat image_x = 0.0f;
    CGFloat image_y = 0.0f;
    switch (_type) {
        case AlivcButtonTypeTitleTop:;
        case AlivcButtonTypeTitleBottom:
        {
            image_w = CGRectGetWidth(contentRect);
            image_h = CGRectGetHeight(self.bounds)*0.35;
            image_x = CGRectGetMinX(contentRect);
            image_y = CGRectGetHeight(self.bounds)-CGRectGetHeight(self.bounds)*0.35-CGRectGetHeight(self.bounds)*0.05;
        }
            break;
        case AlivcButtonTypeTitleLeft:
        {
            image_w = CGRectGetWidth(self.bounds)*0.36;
            image_h = CGRectGetHeight(self.bounds);
            image_x = 0;
            image_y = (CGRectGetHeight(self.bounds)-image_h)/2;
        }
            break;
        case AlivcButtonTypeTitleRight:
        {
//            image_h = CGRectGetHeight(self.bounds);
//            image_w = CGRectGetWidth(self.bounds)*0.36;
//            image_x = 0;
//            image_y = (CGRectGetHeight(self.bounds)-image_h)/2;
            return [super imageRectForContentRect:contentRect];
            break;
        };
        default:
            return [super imageRectForContentRect:contentRect];
            break;
    }
    return CGRectMake(image_x, image_y, image_w, image_h);
}

-(CGFloat)getXAtImageWidth:(CGFloat)imagew withContentRect:(CGRect)contentRect{
    CGSize size = [self.currentTitle sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, CGRectGetHeight(contentRect))];
    //    CGSize size = [self sizeThatFits:CGSizeMake(CGRectGetWidth(self.bounds), MAXFLOAT)];
    CGFloat contentW = imagew+size.width;
    CGFloat imageX = (CGRectGetWidth(self.bounds)-contentW)/2;
    return imageX;
}

@end
