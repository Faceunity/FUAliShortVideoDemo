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
    
    UIImage *image = [UIImage imageNamed:imageName];
    if (!image) {
      NSString *fullPath =  [AlivcImage pathOfImageName:imageName];
      image = [UIImage imageWithContentsOfFile:fullPath];
    }
    return image;
}

+ (NSString *__nullable)pathOfImageName:(NSString *)imageName {
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
     NSString *imagePath = [NSString stringWithFormat:@"AlivcCore.bundle/%@",imageName];
     NSString *fullPath = [[currentBundle resourcePath] stringByAppendingPathComponent:imagePath];
    return fullPath;
}

+ (UIImage *__nullable)imageInSmartVideoNamed:(NSString *)imageName {
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    NSString *imagePath = [NSString stringWithFormat:@"AlivcSmartVideo.bundle/%@",imageName];
    NSString *fullPath = [[currentBundle resourcePath] stringByAppendingPathComponent:imagePath];
    return [UIImage imageWithContentsOfFile:fullPath];
}
    
+ (UIImage *__nullable)imageName:(NSString *)imageName inBundle:(NSString *)bundle{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png" inDirectory:bundle];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}

+ (UIImage *__nullable)imageInBasicVideoNamed:(NSString *)imageName {
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    NSString *imagePath = [NSString stringWithFormat:@"AlivcBasicVideo.bundle/%@",imageName];
    NSString *fullPath = [[currentBundle resourcePath] stringByAppendingPathComponent:imagePath];
    return [UIImage imageWithContentsOfFile:fullPath];
}

@end
