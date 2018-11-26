//
//  AlivcImage.m
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/10/10.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcImage.h"

static NSString *theBundleName = @"Null";

@implementation AlivcImage

+ (void)setImageBundleName:(NSString *)bundleName{
    theBundleName = bundleName;
}

+ (UIImage *)imageNamed:(NSString *)imageName{
    NSString *path = [NSString stringWithFormat:@"%@.bundle/%@",theBundleName,imageName];
    UIImage *image = [UIImage imageNamed:path];
    return image;
}

@end
