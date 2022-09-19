//
//  AliyunVideoConfig.h
//  AliyunVideoClient_Entrance
//
//  Created by coder.pi on 2022/2/24.
//  Copyright © 2022 Aliyun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AliyunVideoConfig : NSObject
@property (nonatomic, class, readonly) BOOL IsSetupFinish;
+ (void) Setup;
+ (BOOL) CheckLicense:(NSString **)errMsg;
+ (void) RefreshLicense:(void(^)(BOOL isSuccess, NSString *errMsg))callback;
@end

NS_ASSUME_NONNULL_END
