//
//  AlivcEditItemModel.h
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/12/26.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//编辑底部事件类型定义
typedef NS_ENUM(NSInteger,AliyunEditSouceClickType){
    AliyunEditSouceClickTypeFilter = 0,
    AliyunEditSouceClickTypeMusic,
    AliyunEditSouceClickTypePaster,
    AliyunEditSouceClickTypeCaption,
    AliyunEditSouceClickTypeMV,
    AliyunEditSouceClickTypeEffectSound,
    AliyunEditSouceClickTypeEffect,
    AliyunEditSouceClickTypeTimeFilter,
    AliyunEditSouceClickTypeTranslation,
    AliyunEditSouceClickTypePaint,
    AliyunEditSouceClickTypeCover
};

@interface AlivcEditItemModel : NSObject

- (instancetype)initWithType:(AliyunEditSouceClickType)itemType;

@property (strong, nonatomic) NSString *title;

@property (strong, nonatomic) NSString *selString;

@property (strong, nonatomic, nullable) UIImage *showImage;

@property (assign, nonatomic, readonly) AliyunEditSouceClickType itemType;

@end

NS_ASSUME_NONNULL_END
