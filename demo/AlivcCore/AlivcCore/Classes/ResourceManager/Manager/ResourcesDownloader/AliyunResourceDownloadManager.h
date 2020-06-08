//
//  AliyunResourceDownloadManager.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/8.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class AliyunEffectResourceModel;


@interface AliyunResourceDownloadTask : NSObject 

@property(nonatomic, copy) void (^progressBlock)(CGFloat progress);
@property(nonatomic, copy) void (^completionHandler)(AliyunEffectResourceModel *newModel, NSError *error);
@property(nonatomic, readonly) AliyunEffectResourceModel *resourceModel;

- (id)initWithModel:(AliyunEffectResourceModel *)resourceModel;

@end



@interface AliyunResourceDownloadManager : NSObject


- (void)addDownloadTask:(AliyunResourceDownloadTask *)task __deprecated_msg("素材分发服务为官方demo演示使用，无法达到商业化使用程度。请自行搭建相关的服务");


- (void)addDownloadTask:(AliyunResourceDownloadTask *)task
               progress:(void (^)(CGFloat progress))progressBlock
      completionHandler:(void (^)(AliyunEffectResourceModel *newModel, NSError *error))completionHandler __deprecated_msg("素材分发服务为官方demo演示使用，无法达到商业化使用程度。请自行搭建相关的服务");


@end
