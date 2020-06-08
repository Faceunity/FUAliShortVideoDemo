//
//  UIButton+AliyunBlock.h
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2018/10/10.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef void (^OnClickBlock)(void);
@interface UIButton (AliyunBlock)

-(void)aliyunOnClickBlock:(OnClickBlock)action;

@end
