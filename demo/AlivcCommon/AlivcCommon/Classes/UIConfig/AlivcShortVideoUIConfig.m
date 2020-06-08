//
//  AlivcShortVideoUIConfig.m
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/10/9.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcShortVideoUIConfig.h"
#import "AlivcImage.h"

@implementation AlivcShortVideoUIConfig

- (instancetype)init{
    self = [super init];
    if(self){
        [self p_setDefaultValue];
    }
    return self;
}

- (void)p_setDefaultValue{
    
    self.backgroundColor = [UIColor blackColor];
    self.backImage = [AlivcImage imageNamed:@"avcBackIcon"];

}

@end
