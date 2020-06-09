//
//  AlivcShortVideoTempSave.m
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2019/5/23.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcShortVideoTempSave.h"

@interface AlivcShortVideoTempSave ()
//在相册选择里导入的资源，这里要存储下，避免被销毁导致合成失败
@property(strong, nonatomic) NSArray *assets;
    
@end

static AlivcShortVideoTempSave *_instance = nil;

@implementation AlivcShortVideoTempSave
+ (instancetype)shared{
    
    return [[self alloc]init];
}
    
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance) {
            _instance = [super allocWithZone:zone];
        }
        
    });
    return _instance;
}
    // 为了严谨，也要重写copyWithZone 和 mutableCopyWithZone
-(id)copyWithZone:(NSZone *)zone
    {
        return _instance;
    }
-(id)mutableCopyWithZone:(NSZone *)zone
    {
        return _instance;
    }
- (void)saveResources:(id)asset{
    if ([asset isKindOfClass:[NSArray class]]) {
        self.assets = asset;
    }
}

@end
