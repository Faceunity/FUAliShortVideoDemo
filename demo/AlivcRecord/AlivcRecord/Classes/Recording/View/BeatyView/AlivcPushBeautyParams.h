//
//  AlivcPushBeautyParams.h
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/6/20.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 美颜参数的种类枚举
 */
typedef NS_ENUM(NSInteger,AlivcBeautyParamsEnum) {
    AlivcBeautyParamsEnum_beautyWhite = 0,
    AlivcBeautyParamsEnum_beautyBuffing,
    AlivcBeautyParamsEnum_beautyRuddy,
    
    AlivcBeautyParamsEnum_beautyBigEye,
    AlivcBeautyParamsEnum_beautySlimFace,
    AlivcBeautyParamsEnum_longFace,
    AlivcBeautyParamsEnum_cutFace,
    AlivcBeautyParamsEnum_lowerJaw,
    AlivcBeautyParamsEnum_mouthWidth,
    AlivcBeautyParamsEnum_thinNose,
    AlivcBeautyParamsEnum_thinMandible,
    AlivcBeautyParamsEnum_cutCheek, //确保此项在最后一项，新增属性加在上面
};


@interface AlivcPushBeautyParams : NSObject

#pragma mark -  美肤
/**
 white
 美白
 default : 70
 value range : [0,100]
 */
@property (nonatomic, assign) int beautyWhite;

/**
 buffing
 磨皮
 default : 40
 value range : [0,100]
 */
@property (nonatomic, assign) int beautyBuffing;

/**
 ruddy
 红润/锐化
 default : 70
 value range : [0,100]
 */
@property (nonatomic, assign) int beautyRuddy;

/**
 pink
 
 default : 15
 value range : [0,100]
 */
@property (nonatomic, assign) int beautyCheekPink;

#pragma mark -  美型

/**
 big eye
 大眼
 default : 30
 value range : [0,100]
 */

@property (nonatomic, assign) int beautyBigEye;

/**
 slim face
 瘦脸
 default : 40
 value range : [0,100]
 */
@property (nonatomic, assign) int beautySlimFace;

/**
 longFace
 脸长
 default : 50
 value range : [0,100]
 */
@property (nonatomic, assign) int longFace;

/**
 cutFace
 削脸
 default : 50
 value range : [0,100]
 */
@property (nonatomic, assign) int cutFace;

/**
 lowerJaw
 下巴
 default : 50
 value range : [0,100]
 */
@property (nonatomic, assign) int lowerJaw;

/**
 mouthWidth
 唇宽
 default : 50
 value range : [0,100]
 */
@property (nonatomic, assign) int mouthWidth;

/**
 thinNose
 瘦鼻
 default : 50
 value range : [0,100]
 */
@property (nonatomic, assign) int thinNose;


/**
 thinMandible
 下颌
 default : 50
 value range : [0,100]
 */
@property (nonatomic, assign) int thinMandible;

/**
 cutCheek
 颧骨
 default : 50
 value range : [0,100]
 */
@property (nonatomic, assign) int cutCheek;

/**
 shorten face
 
 default : 50
 value range : [0,100]
 */
@property (nonatomic, assign) int beautyShortenFace;


/**
 init
 
 @return AlivcBeautyParams
 */
- (instancetype)init;


/// 根据美颜选项返回对应的数值
/// @param enumType 美颜选项
- (int)paramValueWithParamEnum:(AlivcBeautyParamsEnum)enumType;



/// 设置值到对应的美颜选项
/// @param value 值
/// @param enumType 美颜选项
- (void)setParamValue:(int)value WithParamEnum:(AlivcBeautyParamsEnum)enumType;

/// 根据美颜选项反馈不同的字符串
/// @param enumType 美颜选项
+ (NSString *)keyStringWithParamEnum:(AlivcBeautyParamsEnum)enumType;
@end
