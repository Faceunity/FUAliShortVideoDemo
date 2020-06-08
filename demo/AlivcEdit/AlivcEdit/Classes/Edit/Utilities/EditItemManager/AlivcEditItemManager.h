//
//  AlivcEditItemManager.h
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/12/26.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AlivcEditItemModel;
@class AlivcEditUIConfig;

NS_ASSUME_NONNULL_BEGIN

@interface AlivcEditItemManager : NSObject

+ (NSArray <AlivcEditItemModel*>*)defaultModelsWithUIConfig:(AlivcEditUIConfig *)uiConfig;

@end

NS_ASSUME_NONNULL_END
