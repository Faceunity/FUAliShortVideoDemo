//
//  MagicCameraScrollView.m
//  AliyunVideo
//
//  Created by Vienta on 2017/1/5.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//



#import "MagicCameraPressCircleView.h"

@implementation MagicCameraPressCircleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setBackgroundImage:[AlivcImage imageNamed:@"shortVideo_recordBtn_singleClick"] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.backgroundColor = [UIColor clearColor];

        
    }
    return self;
}



@end













