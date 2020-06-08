//
//  AlivcPushBeautyDataManager.m
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/8/6.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcPushBeautyDataManager.h"
#import "NSString+AlivcHelper.h"

static const int AlivcBeautyWhiteDefault = 70;
static const int AlivcBeautyBuffingDefault = 40;
static const int AlivcBeautyRuddyDefault = 40;
static const int AlivcBeautyCheekPinkDefault = 15;
static const int AlivcBeautyThinFaceDefault = 40;
static const int AlivcBeautyShortenFaceDefault = 50;
static const int AlivcBeautyBigEyeDefault = 30;

NSString * const AlivcBeautyParamsTypeShortVideo_Base = @"AlivcPushBeautyParamsTypeShortVideo_Base";
NSString * const AlivcBeautyParamsTypeShortVideo_Advanced = @"AlivcPushBeautyParamsTypeShortVideo_Advanced";
NSString * const AlivcBeautyParamsTypeShortVideo_BeautySkin = @"AlivcBeautyParamsTypeShortVideo_BeautySkin";
NSString * const AlivcBeautyParamsTypeShortVideo_BeautyShape = @"AlivcBeautyParamsTypeShortVideo_BeautyShape";


@interface AlivcPushBeautyDataManager()

@property (assign, nonatomic) AlivcBeautyParamsType type;

@property (strong, nonatomic) NSString *levelKey;

@property (strong, nonatomic) NSString *customSaveString;

@property (assign, nonatomic) BOOL haveSavedDefaultValue; //存储过默认值

@end


@implementation AlivcPushBeautyDataManager

- (instancetype)initWithType:(AlivcBeautyParamsType)type customSaveString:(NSString * _Nullable)customSaveString{
    self = [super init];
    if (self) {
        _type = type;
        switch (_type) {
            case AlivcBeautyParamsTypeLive:
                _customSaveString = @"AlivcBeautyParamsTypeLive";
                break;
            case AlivcBeautyParamsTypeFU_ShortVideo:
                _customSaveString = @"AlivcBeautyParamsTypeFU_ShortVideo";
                break;
            case AlivcBeautyParamsTypeRace_ShortVideo:
                _customSaveString = @"AlivcBeautyParamsTypeRace_ShortVideo";
                break;
            default:
                break;
        }
        if (customSaveString) {
            _customSaveString = customSaveString;
        }
        _levelKey = [NSString stringWithFormat:@"levelKey_%@",_customSaveString];
        [self saveDefaultParams];
    }
    return self;
}

/// 存储默认参数
- (void)saveDefaultParams{
    _haveSavedDefaultValue = [[NSUserDefaults standardUserDefaults]boolForKey:_customSaveString];
    if (!_haveSavedDefaultValue) {
        int maxValue = AlivcPushBeautyShapeTypePear + 1;
        for(int i = 0;i < maxValue;i ++){
            AlivcPushBeautyParams *params = [self defaultBeautyParamsWithLevel:i];
            [self saveBeautyParams:params level:i];
        }
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:_customSaveString];
    }
   

}

#pragma mark - 默认值获取
/// 默认等级或者美型类型
- (AlivcPushBeautyParamsLevel)defaultBeautyLevel{
    switch (self.type) {
        case AlivcBeautyParamsTypeLive:
            return AlivcPushBeautyParamsLevel4;
            break;
        case AlivcBeautyParamsTypeFU_ShortVideo:
            return AlivcPushBeautyParamsLevel3;
            break;
        case AlivcBeautyParamsTypeRace_ShortVideo:
            return AlivcPushBeautyShapeTypeCustom;
        default:
            break;
    }
    return AlivcPushBeautyParamsLevel3;
}

/// 默认的参数
/// @param level 响应的等级与美型类型
- (AlivcPushBeautyParams *)defaultBeautyParamsWithLevel:(AlivcPushBeautyParamsLevel)level{
    
    switch (self.type) {
        case AlivcBeautyParamsTypeLive:{
            return [self defaultLiveParamsWithLevel:level];
        }
            break;
            
        case AlivcBeautyParamsTypeFU_ShortVideo:{
            return [self defaultFuShortVideoParamsWithLevel:level];
        }
            break;
        case AlivcBeautyParamsTypeRace_ShortVideo:{
            return [self defaultRaceShortVideoParamsWithlevel:level];
        }
            break;
        default:
            break;
    }
    return [[AlivcPushBeautyParams alloc] init];
    
}

/// 互动直播的默认美颜参数
/// @param level 美颜等级
- (AlivcPushBeautyParams *)defaultLiveParamsWithLevel:(AlivcPushBeautyParamsLevel)level{
    AlivcPushBeautyParams *params = [[AlivcPushBeautyParams alloc] init];
    CGFloat scale = 1;
    if (level == AlivcPushBeautyParamsLevel0) {
        scale = 0;
    }else if(level == AlivcPushBeautyParamsLevel1){
        scale = 0.3;
    }else if(level == AlivcPushBeautyParamsLevel2){
        scale = 0.6;
    }else if(level == AlivcPushBeautyParamsLevel3){
        scale = 1;
    }else if(level == AlivcPushBeautyParamsLevel4){
        scale = 1.2;
    }else if(level == AlivcPushBeautyParamsLevel5){
        scale = 1.5;
    }
    params.beautyWhite = AlivcBeautyWhiteDefault * scale > 100 ? 100 : AlivcBeautyWhiteDefault * scale;
    params.beautyBuffing = AlivcBeautyBuffingDefault * scale > 100 ? 100 : AlivcBeautyBuffingDefault * scale;
    params.beautyRuddy = AlivcBeautyRuddyDefault * scale > 100 ? 100 : AlivcBeautyRuddyDefault * scale;
    params.beautyCheekPink = AlivcBeautyCheekPinkDefault * scale > 100 ? 100 : AlivcBeautyCheekPinkDefault * scale;
    params.beautySlimFace = AlivcBeautyThinFaceDefault * scale > 100 ? 100 : AlivcBeautyThinFaceDefault * scale;
    params.beautyShortenFace = AlivcBeautyShortenFaceDefault * scale > 100 ?  100 : AlivcBeautyShortenFaceDefault * scale;
    params.beautyBigEye = AlivcBeautyBigEyeDefault * scale > 100 ? 100 : AlivcBeautyBigEyeDefault * scale;
    return params;
}


///  默认的FU在短视频的默认参数
/// @param level 美颜等级
- (AlivcPushBeautyParams *)defaultFuShortVideoParamsWithLevel:(AlivcPushBeautyParamsLevel)level{
    AlivcPushBeautyParams *params = [[AlivcPushBeautyParams alloc] init];
    //短视频的参数没有规律可言，这里统一定死赋值吧，清晰明了
    switch (level) {
        case 0:
        {
            params.beautyWhite = 0;
            params.beautyBuffing = 0;
            params.beautyRuddy = 0;
            params.beautyCheekPink = 0;
            params.beautySlimFace = 0;
            params.beautyShortenFace = 0;
            params.beautyBigEye = 0;
        }
            break;
        case 1:
        {
            params.beautyWhite = 20;
            params.beautyBuffing = 10;
            params.beautyRuddy = 20;
            params.beautyCheekPink = 20;
            params.beautySlimFace = 20;
            params.beautyShortenFace = 20;
            params.beautyBigEye = 20;
        }
            break;
        case 2:
        {
            params.beautyWhite = 40;
            params.beautyBuffing = 30;
            params.beautyRuddy = 40;
            params.beautyCheekPink = 40;
            params.beautySlimFace = 40;
            params.beautyShortenFace = 40;
            params.beautyBigEye = 40;
        }
            break;
        case 3:
        {
            params.beautyWhite = 60;
            params.beautyBuffing = 60;
            params.beautyRuddy = 60;
            params.beautyCheekPink = 60;
            params.beautySlimFace = 60;
            params.beautyShortenFace = 60;
            params.beautyBigEye = 60;
        }
            break;
        case 4:
        {
            params.beautyWhite = 80;
            params.beautyBuffing = 85;
            params.beautyRuddy = 80;
            params.beautyCheekPink = 80;
            params.beautySlimFace = 80;
            params.beautyShortenFace = 80;
            params.beautyBigEye = 80;
        }
            break;
        case 5:
        {
            params.beautyWhite = 100;
            params.beautyBuffing = 100;
            params.beautyRuddy = 100;
            params.beautyCheekPink = 100;
            params.beautySlimFace = 100;
            params.beautyShortenFace = 100;
            params.beautyBigEye = 100;
        }
            break;
        default:
            break;
    }
    return params;
}

- (AlivcPushBeautyParams *)defaultRaceShortVideoParamsWithlevel:(AlivcPushBeautyParamsLevel)shapeType{
    
    NSArray *valueArray = [[NSArray alloc]init];
    switch (shapeType) {
        case AlivcPushBeautyShapeTypeCustom:
            valueArray = [self customArray];
            break;
        case AlivcPushBeautyShapeTypeDGrace:
            valueArray = [self dGraceArray];
            break;
        case AlivcPushBeautyShapeTypeDelicate:
            valueArray = [self delicateArray];
            break;
        case AlivcPushBeautyShapeTypeInternet:
            valueArray = [self internetArray];
            break;
        case AlivcPushBeautyShapeTypeLovely:
            valueArray = [self lovelyArray];
            break;
        case AlivcPushBeautyShapeTypeBaby:
            valueArray = [self babyArray];
            break;
        case AlivcPushBeautyShapeTypeNature:
            valueArray = [self natureArray];
            break;
        case AlivcPushBeautyShapeTypeSquare:
            valueArray = [self squareArray];
            break;
        case AlivcPushBeautyShapeTypeCircle:
            valueArray = [self cicleArray];
            break;
        case AlivcPushBeautyShapeTypeLong:
            valueArray = [self longFaceArray];
            break;
        case AlivcPushBeautyShapeTypePear:
            valueArray = [self pearArray];
            break;
            
        default:
            break;
    }
    return [self paramsWithValueArray:valueArray];
}


/// 根据默认的美型各个值设置
/// @param valueArray 数字数组
- (AlivcPushBeautyParams *)paramsWithValueArray:(NSArray <NSNumber *>*)valueArray{
    AlivcPushBeautyParams *params = [[AlivcPushBeautyParams alloc] init];
    if (valueArray.count == 9) {
        params.beautyBigEye = valueArray[0].intValue/3;
        params.longFace = valueArray[1].intValue/3;
        params.cutFace = valueArray[2].intValue/3;
        params.beautySlimFace = valueArray[3].intValue/3;
        params.lowerJaw = valueArray[4].intValue/3;
        params.mouthWidth = valueArray[5].intValue/3;
        params.thinNose = valueArray[6].intValue/3;
        params.thinMandible = valueArray[7].intValue/3;
        params.cutCheek = valueArray[8].intValue/3;
    }
    return params;
}

#pragma mark - 美型各个脸型的参数配置
/*
 默认顺序为
 /// @param  bigEyeValue 大眼
 /// @param longFaceValue 脸长
 /// @param cutFaceValue 削脸
 /// @param thinFaceValue 瘦脸
 /// @param lowerJawValue 下巴
 /// @param mouthWidthValue 唇宽
 /// @param thinNoseValue 瘦鼻
 /// @param thinMandibleValue 下颌
 /// @param cutCheekValue 颧骨
 **/

/// 自定义脸型
- (NSArray *)customArray{
    return @[@12,@11,@27,@23,@50,@61,@0,@0,@0];
}
/// 优雅
- (NSArray *)dGraceArray{
    return @[@100,@50,@100,@100,@20,@54,@0,@0,@0];
}
/// 精致
- (NSArray *)delicateArray{
    return @[@0,@31,@17,@100,@99,@0,@0,@0,@0];
}
/// 网红
- (NSArray *)internetArray{
    return @[@48,@6,@100,@22,@7,@35,@0,@0,@0];
}
/// 可爱
- (NSArray *)lovelyArray{
    return @[@100,@49,@52,@100,@-8,@-24,@0,@0,@0];
}
/// 婴儿
- (NSArray *)babyArray{
    return @[@48,@80,@44,@28,@-29,@-24,@0,@0,@0];
}
/// 自然
- (NSArray *)natureArray{
    return @[@50,@0,@50,@50,@0,@0,@0,@0,@0];
}
/// 方脸
- (NSArray *)squareArray{
    return @[@50,@0,@50,@30,@0,@0,@0,@80,@0];
}
/// 圆脸
- (NSArray *)cicleArray{
    return @[@30,@0,@60,@30,@0,@0,@0,@0,@0];
}
/// 长脸
- (NSArray *)longFaceArray{
    return @[@50,@0,@70,@50,@0,@0,@0,@0,@0];
}
/// 梨形
- (NSArray *)pearArray{
    return @[@50,@0,@50,@50,@50,@0,@0,@60,@60];
}

#pragma mark - 当前数值返回


/// 当前等级
- (AlivcPushBeautyParamsLevel)getBeautyLevel{
    
    NSString *beautyLevelString = [[NSUserDefaults standardUserDefaults] objectForKey:_levelKey];
    if(beautyLevelString){
        AlivcPushBeautyParamsLevel level = [beautyLevelString integerValue];
        return level;
    }
    return [self defaultBeautyLevel];
}

- (void)saveBeautyLevel:(AlivcPushBeautyParamsLevel)level{
    
    [[NSUserDefaults standardUserDefaults] setObject:@(level).stringValue forKey:_levelKey];
}


/// 获取对应等级的参数
/// @param level 对应等级
- (AlivcPushBeautyParams *)getBeautyParamsOfLevel:(AlivcPushBeautyParamsLevel)level{
    AlivcPushBeautyParams *parames = [[AlivcPushBeautyParams alloc]init];
    
    NSString *beautyWhiteStr = [[NSUserDefaults standardUserDefaults]objectForKey:[self keyStringForBeautyParamValueWithParam:AlivcBeautyParamsEnum_beautyWhite level:level]];
    
    if (!beautyWhiteStr) { //说明还没有存储过，取默认值
        parames = [self defaultBeautyParamsWithLevel:level];
        [self saveBeautyParams:parames level:level]; // 做一次存储
        return parames;
    }
    int max = AlivcBeautyParamsEnum_cutCheek + 1;
    for (int i = 0; i < max; i++) {
        NSString *valueString = [[NSUserDefaults standardUserDefaults]objectForKey:[self keyStringForBeautyParamValueWithParam:i level:level]];
        int value = [valueString intValue];
        [parames setParamValue:value WithParamEnum:i];
    }
    return parames;
}


/// 存储参数与等级
/// @param beautyParams 参数
/// @param level 等级
- (void)saveBeautyParams:(AlivcPushBeautyParams *)beautyParams level:(AlivcPushBeautyParamsLevel)level{
    
    int max = AlivcBeautyParamsEnum_cutCheek + 1;
    for (int i = 0;i < max; i++) {
        AlivcBeautyParamsEnum enumParam = (AlivcBeautyParamsEnum)i;
        int paramValue = [beautyParams paramValueWithParamEnum:enumParam];
        NSString *valueString = [NSString stringWithFormat:@"%d",paramValue];
        [[NSUserDefaults standardUserDefaults]setObject:valueString forKey:[self keyStringForBeautyParamValueWithParam:enumParam level:level]];
    }
}


- (void)saveParamValue:(NSInteger)value identifer:(NSString *)identifer level:(AlivcPushBeautyParamsLevel)level{
    int enumValue = identifer.intValue;
    [[NSUserDefaults standardUserDefaults]setObject:@(value).stringValue forKey:[self keyStringForBeautyParamValueWithParam:enumValue level:level]];
}

- (void)saveParamWithInfo:(NSDictionary *)info{
    [self saveParamValue:[info[@"value"] integerValue] identifer:info[@"identifier"] level:[self getBeautyLevel]];
    //都存储一遍
    
}



#pragma mark - 用于生成界面的各个参数的字典，供开发者自由组合

- (NSDictionary *)dicWithBeautyParamEnum:(AlivcBeautyParamsEnum)enumItem{
    AlivcPushBeautyParamsLevel level = [self getBeautyLevel];
    AlivcPushBeautyParams *params = [self getBeautyParamsOfLevel:level];
    AlivcPushBeautyParams *defaultParams = [self defaultBeautyParamsWithLevel:level];
    NSString *title = [self titleWithBeautyParamEnum:enumItem];
    NSString *identifier = [NSString stringWithFormat:@"%ld",(long)enumItem];
    NSString *iconName = [self iconNameWithBeautyParamEnum:enumItem];
    int parameEnumValue = [params paramValueWithParamEnum:enumItem];
    int defaultParameEnumValue = [defaultParams paramValueWithParamEnum:enumItem];
    int minValue = 0;
    if (level > 5) {
        minValue = -100;//美型的最小值为-100
        //美型中大眼与瘦脸的调节范围为0-100
        if (enumItem == AlivcBeautyParamsEnum_beautyBigEye || enumItem == AlivcBeautyParamsEnum_beautySlimFace) {
            minValue = 0;
        }
    }
    return  @{
              @"title":title,
              @"identifier":identifier,
              @"icon_name":iconName,
              @"value":@(parameEnumValue),
              @"originalValue":@(defaultParameEnumValue),
              @"minimumValue":@(minValue),
              @"maximumValue":@(100),
              };
}

/// 配置不同美颜选项的标题
/// @param enumItem 美颜选项
- (NSString *)titleWithBeautyParamEnum:(AlivcBeautyParamsEnum)enumItem{
     switch (enumItem) {
           case AlivcBeautyParamsEnum_beautyWhite:
               return [@"Skin Whitening" localString];
               break;
           case AlivcBeautyParamsEnum_beautyBuffing:
               return [@"Skin Polishing" localString];
               break;
           case AlivcBeautyParamsEnum_beautyRuddy:{
               NSString *title = [@"锐化" localString];
               NSString *beautyType = [[NSUserDefaults standardUserDefaults] objectForKey:@"AlivcBeautyType_cell"];
               if ([beautyType isEqualToString:@"FaceUnity"]) {
                    title = [@"Skin Shining" localString];
               }
               return title;
          }
               break;
           case AlivcBeautyParamsEnum_beautyBigEye:
               return [@"Eye Widening" localString];
               break;
           case AlivcBeautyParamsEnum_beautySlimFace:
               return [@"Face Slimming" localString];
               break;
           case AlivcBeautyParamsEnum_longFace:
               return [@"脸长" localString];
               break;
           case AlivcBeautyParamsEnum_cutFace:
               return [@"削脸" localString];
               break;
           case AlivcBeautyParamsEnum_lowerJaw:
               return [@"下巴" localString];
               break;
           case AlivcBeautyParamsEnum_mouthWidth:
               return [@"唇宽" localString];
               break;
           case AlivcBeautyParamsEnum_thinNose:
               return [@"瘦鼻" localString];
               break;
           case AlivcBeautyParamsEnum_thinMandible:
               return [@"下颌" localString];
               break;
           case AlivcBeautyParamsEnum_cutCheek:
               return [@"颧骨" localString];
               break;
               
           default:
               break;
       }
       return @"Default Title";
}

/// 配置不同美颜选项的图片名称
/// @param enumItem 美颜选项
- (NSString *)iconNameWithBeautyParamEnum:(AlivcBeautyParamsEnum)enumItem{
    switch (enumItem) {
        case AlivcBeautyParamsEnum_beautyWhite:
            return @"ic_beauty_white";
            break;
        case AlivcBeautyParamsEnum_beautyBuffing:
            return @"ic_buffing";
            break;
        case AlivcBeautyParamsEnum_beautyRuddy:
            return @"ic_Ruddy";
            break;
        case AlivcBeautyParamsEnum_beautyBigEye:
            return @"ic_bigeye";
            break;
        case AlivcBeautyParamsEnum_beautySlimFace:
            return @"ic_slimface";
            break;
        case AlivcBeautyParamsEnum_longFace:
            return @"ic_face_height";
            break;
        case AlivcBeautyParamsEnum_cutFace:
            return @"ic_face_width";
            break;
        case AlivcBeautyParamsEnum_lowerJaw:
            return @"ic_chin";
            break;
        case AlivcBeautyParamsEnum_mouthWidth:
            return @"ic_lips_width";
            break;
        case AlivcBeautyParamsEnum_thinNose:
            return @"ic_thin_nose";
            break;
        case AlivcBeautyParamsEnum_thinMandible:
            return @"ic_jaw";
            break;
        case AlivcBeautyParamsEnum_cutCheek:
            return @"ic_ cheekbone";
            break;
            
        default:
            break;
    }
    return @"ic_slimface";
}

/// 根据美颜等级，美颜项生成一个存储key字符串
/// @param paramEnum 美颜项
/// @param level 美颜等级或m美型模板
- (NSString *)keyStringForBeautyParamValueWithParam:(AlivcBeautyParamsEnum)paramEnum level:(AlivcPushBeautyParamsLevel)level {
    NSString *levelString = @(level).stringValue;
    NSString *paramString = [AlivcPushBeautyParams keyStringWithParamEnum:paramEnum];
    NSString *keyString = [NSString stringWithFormat:@"%@_%@_%@",paramString,levelString,self.customSaveString];
    return keyString;
}
@end
