//
//  AlivcUser.h
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2019/1/10.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AliVideoClientUser : NSObject <NSSecureCoding>

#pragma mark - 类方法 - 先放这里

/**
 单例

 @return 实例化的对象
 */
+ (instancetype)shared;

/**
 设置值

 @param dic 字典信息
 */
- (void)setValueWithInfo:(NSDictionary *)dic;

/**
 设置昵称

 @param nickName 昵称
 */
- (void)setNickName:(NSString *)nickName;

/**
 更新本地存储的值进单例

 @param localUser 本地存储的值
 */
- (void)setLocalUser:(AliVideoClientUser *)localUser;

/**
 token
 */
@property (strong, nonatomic, readonly) NSString *token;

/**
 昵称
 */
@property (strong, nonatomic, readonly) NSString *nickName;

/**
 头像
 */
@property (strong, nonatomic, nullable) UIImage *avatarImage;

/**
 头像URL字符串 -- 用于本地化存储，存图片暂用空间大
 */
@property (strong, nonatomic, readonly) NSString *avatarUrlString;

/**
 用户ID
 */
@property (strong, nonatomic, readonly) NSString *userID;




@end

NS_ASSUME_NONNULL_END
