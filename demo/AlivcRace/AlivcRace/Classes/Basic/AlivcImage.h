//
//  AlivcImage.h
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/10/10.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlivcImage: NSObject

/**
 更改默认的bundle名称，默认为各模块Alivc+XXX+Image
 请谨慎使用，确保你传入的参数，工程中有这个资源，保持bundle中的图片命名一致
 @param bundleName 要变更的bundle名称
 */
//+ (void)setImageBundleName:(NSString *)bundleName;

/**
 根据名称返回图片
 
 @param imageName 图片的名称
 @return 返回一个图片名称对应的图片实例
 */
+ (UIImage *__nullable)imageNamed:(NSString *)imageName;

/**
 根据名称返回图片路径
 
 @param imageName 图片的名称
 @return 返回一个图片名称对应的图片路径
 */
+ (NSString *__nullable)pathOfImageName:(NSString *)imageName;
@end
NS_ASSUME_NONNULL_END
