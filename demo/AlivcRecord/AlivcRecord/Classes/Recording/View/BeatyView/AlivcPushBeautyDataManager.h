//
//  AlivcPushBeautyDataManager.h
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/8/6.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlivcPushBeautyParams.h"

NS_ASSUME_NONNULL_BEGIN
//基础美颜参数管理器key
extern NSString * const AlivcBeautyParamsTypeShortVideo_Base;
//高级美颜参数管理器key
extern NSString * const AlivcBeautyParamsTypeShortVideo_Advanced;
//美型参数管理器key
extern NSString * const AlivcBeautyParamsTypeShortVideo_BeautySkin;
//美型参数管理器key
extern NSString * const AlivcBeautyParamsTypeShortVideo_BeautyShape;

/**
 美颜美型业务上的分类
 - AlivcPushBeautyParamsTypeRace_ShortVideo:短视频Race的参数
 - AlivcPushBeautyParamsTypeFU_ShortVideo:短视频FU的参数
 - AlivcPushBeautyParamsTypeLive:互动直播的参数
 */
typedef NS_ENUM(NSInteger,AlivcBeautyParamsType) {
    AlivcBeautyParamsTypeRace_ShortVideo = 0,
    AlivcBeautyParamsTypeFU_ShortVideo,
    AlivcBeautyParamsTypeLive
};

/**
 FU的档位 - Race的脸型 - 同一个概念，形式不同

 - AlivcPushBeautyParamsLevel0: 0档
 - AlivcPushBeautyParamsLevel1: 1档
 - AlivcPushBeautyParamsLevel2: 2档
 - AlivcPushBeautyParamsLevel3: 3档
 - AlivcPushBeautyParamsLevel4: 4档
 - AlivcPushBeautyParamsLevel5: 5档
 
 - AlivcPushBeautyShapeTypeCustom: 自定义
 - AlivcPushBeautyShapeTypeDGrace: 优雅
 - AlivcPushBeautyShapeTypeDelicate: 精致
 - AlivcPushBeautyShapeTypeInternet: 网红
 - AlivcPushBeautyShapeTypeLovely: 可爱
 - AlivcPushBeautyShapeTypeBaby: 婴儿
 - AlivcPushBeautyShapeTypeNature: 自然
 - AlivcPushBeautyShapeTypeSquare: 方脸
 - AlivcPushBeautyShapeTypeCircle: 圆脸
 - AlivcPushBeautyShapeTypeLong: 长脸
 - AlivcPushBeautyShapeTypePear: 梨形
 */
typedef NS_ENUM(NSInteger,AlivcPushBeautyParamsLevel) {
    AlivcPushBeautyParamsLevel0 = 0,
    AlivcPushBeautyParamsLevel1,
    AlivcPushBeautyParamsLevel2,
    AlivcPushBeautyParamsLevel3,
    AlivcPushBeautyParamsLevel4,
    AlivcPushBeautyParamsLevel5,
    AlivcPushBeautyShapeTypeCustom,
    AlivcPushBeautyShapeTypeDGrace,
    AlivcPushBeautyShapeTypeDelicate,
    AlivcPushBeautyShapeTypeInternet,
    AlivcPushBeautyShapeTypeLovely,
    AlivcPushBeautyShapeTypeBaby,
    AlivcPushBeautyShapeTypeNature,
    AlivcPushBeautyShapeTypeSquare,
    AlivcPushBeautyShapeTypeCircle,
    AlivcPushBeautyShapeTypeLong,
    AlivcPushBeautyShapeTypePear,
};


@interface AlivcPushBeautyDataManager : NSObject

/**
 美颜美型数据管理器 - 对应界面上每一个档位选择或者美型选择

 @param type 美颜参数类型
 @param customSaveString 自定义存储字符串，一个字符串对应一个本地的美颜参数存储，为空:默认的本地存储器，不为空：每个值对应一个存储器，别和默认存储的字符串值一样，那就是一个新的存储器，用于工程里有多个美颜美型界面，但是彼此间数据又想保持独立的需求
 @return 实例化对象
 */
- (instancetype)initWithType:(AlivcBeautyParamsType)type customSaveString:(NSString *__nullable)customSaveString;

/**
 default beauty AlivcBeautyParamsLevel
 
 @return AlivcBeautyParamsLevel
 */
- (AlivcPushBeautyParamsLevel)defaultBeautyLevel;

/**
 default beauty params
 
 @param level AlivcBeautyParamsLevel
 @return AlivcBeautyParams
 */
- (AlivcPushBeautyParams *)defaultBeautyParamsWithLevel:(AlivcPushBeautyParamsLevel)level;

/**
 获取当前的美颜等级
 
 @return 当前的美颜等级
 */
- (AlivcPushBeautyParamsLevel)getBeautyLevel;

/**
 获取美颜等级对应的各美颜参数model
 
 @param level 美颜等级
 @return 美颜参数model
 */
- (AlivcPushBeautyParams *)getBeautyParamsOfLevel:(AlivcPushBeautyParamsLevel)level;

/**
 存储当前的美颜等级
 
 @param level 当前的美颜等级
 */
- (void)saveBeautyLevel:(AlivcPushBeautyParamsLevel)level;


/**
 存储美颜参数
 
 @param beautyParams 美颜参数
 @param level 存储的美颜参数对应的美颜等级
 */
- (void)saveBeautyParams:(AlivcPushBeautyParams *)beautyParams level:(AlivcPushBeautyParamsLevel)level;


/**
 存储单个美颜项目的数值
 
 @param count 美颜的数值
 @param identifer 标记美颜项目的值
 @param level 美颜等级
 */
- (void)saveParam:(NSInteger)count identifer:(NSString *)identifer level:(AlivcPushBeautyParamsLevel)level;

/**
 存储美颜参数 - 当美颜某个值具体改变的时候
 
 @param info AlivcLiveBeautifySettingsViewControllerDelegate 回调里的info
 */
- (void)saveParamWithInfo:(NSDictionary *)info;




#pragma mark - 用于生成界面的各个参数的字典，供开发者随意生成，自由组合

- (NSDictionary *)dicWithBeautyParamEnum:(AlivcBeautyParamsEnum)enumItem;


@end
NS_ASSUME_NONNULL_END
