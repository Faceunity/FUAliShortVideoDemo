//
//  VODUploadSVideoModel.h
//  VODUpload
//
//  Created by Worthy on 2017/11/2.
//  Copyright © 2017年 Leigang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VodSVideoInfo : NSObject
//标题
@property (nonatomic, copy) NSString* title;
//标签
@property (nonatomic, copy) NSString* tags;
//描述
@property (nonatomic, copy) NSString* desc;
//分类id
@property (nonatomic, strong) NSNumber* cateId;

// 设置自定义数据
@property (nonatomic, copy) NSString* userData;

@property (nonatomic, assign) BOOL isProcess;
@property (nonatomic, assign) BOOL isShowWaterMark;
@property (nonatomic, strong) NSNumber* priority;
@property (nonatomic, copy) NSString* storageLocation;
@property (nonatomic, copy) NSString* templateGroupId;
@end

@interface VodSVideoUploadResult: NSObject
@property (nonatomic, copy) NSString* videoId;
@property (nonatomic, copy) NSString* imageUrl;
@property (nonatomic, copy) NSString* bucket;
@property (nonatomic, copy) NSString* endpoint;
@end
