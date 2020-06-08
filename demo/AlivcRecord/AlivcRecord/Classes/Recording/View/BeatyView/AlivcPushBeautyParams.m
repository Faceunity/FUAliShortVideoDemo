
//
//  AlivcPushBeautyParams.m
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/6/20.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcPushBeautyParams.h"


@implementation AlivcPushBeautyParams

- (instancetype)init {
    self = [super init];
    if(self) {
        //美肤
        self.beautyWhite = 70;
        self.beautyBuffing = 40;
        self.beautyRuddy = 40;
        self.beautyCheekPink = 15;
        //美型
        self.beautyBigEye = 30;
        self.beautySlimFace = 40;
        self.longFace = 50;
        self.cutFace = 50;
        self.lowerJaw = 50;
        self.mouthWidth = 50;
        self.thinNose = 50;
        self.thinMandible = 50;
        self.cutCheek = 50;
        
        self.beautyShortenFace = 50;
        
    }
    return self;
}
/**
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
 AlivcBeautyParamsEnum_cutCheek
 */
- (int)paramValueWithParamEnum:(AlivcBeautyParamsEnum)enumType{
    switch (enumType) {
        case AlivcBeautyParamsEnum_beautyWhite:
            return self.beautyWhite;
            break;
        case AlivcBeautyParamsEnum_beautyBuffing:
            return self.beautyBuffing;
            break;
        case AlivcBeautyParamsEnum_beautyRuddy:
            return self.beautyRuddy;
            break;
        case AlivcBeautyParamsEnum_beautyBigEye:
            return self.beautyBigEye;
            break;
        case AlivcBeautyParamsEnum_beautySlimFace:
            return self.beautySlimFace;
            break;
        case AlivcBeautyParamsEnum_longFace:
            return self.longFace;
            break;
        case AlivcBeautyParamsEnum_cutFace:
            return self.cutFace;
            break;
        case AlivcBeautyParamsEnum_lowerJaw:
            return self.lowerJaw;
            break;
        case AlivcBeautyParamsEnum_mouthWidth:
            return self.mouthWidth;
            break;
        case AlivcBeautyParamsEnum_thinNose:
            return self.thinNose;
            break;
        case AlivcBeautyParamsEnum_thinMandible:
            return self.thinMandible;
            break;
        case AlivcBeautyParamsEnum_cutCheek:
            return self.cutCheek;
            break;
            
        default:
            break;
    }
    return 0;
}

- (void)setParamValue:(int)value WithParamEnum:(AlivcBeautyParamsEnum)enumType{
    switch (enumType) {
          case AlivcBeautyParamsEnum_beautyWhite:
              self.beautyWhite = value;
              break;
          case AlivcBeautyParamsEnum_beautyBuffing:
              self.beautyBuffing = value;
              break;
          case AlivcBeautyParamsEnum_beautyRuddy:
              self.beautyRuddy = value;
              break;
          case AlivcBeautyParamsEnum_beautyBigEye:
              self.beautyBigEye = value;
              break;
          case AlivcBeautyParamsEnum_beautySlimFace:
              self.beautySlimFace = value;
              break;
          case AlivcBeautyParamsEnum_longFace:
              self.longFace = value;
              break;
          case AlivcBeautyParamsEnum_cutFace:
              self.cutFace = value;
              break;
          case AlivcBeautyParamsEnum_lowerJaw:
              self.lowerJaw = value;
              break;
          case AlivcBeautyParamsEnum_mouthWidth:
              self.mouthWidth = value;
              break;
          case AlivcBeautyParamsEnum_thinNose:
              self.thinNose = value;
              break;
          case AlivcBeautyParamsEnum_thinMandible:
              self.thinMandible = value;
              break;
          case AlivcBeautyParamsEnum_cutCheek:
              self.cutCheek = value;
              break;
              
          default:
              break;
      }
}

+ (NSString *)keyStringWithParamEnum:(AlivcBeautyParamsEnum)enumType{
    NSString *beautyParamsEnumString = [NSString stringWithFormat:@"%@%d",@"key_AlivcBeautyParamsEnum",enumType];
    return beautyParamsEnumString;
}
@end
