//
//  AliyunEffectInfo.m
//  AliyunVideo
//
//  Created by dangshuai on 17/3/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectInfo.h"
#import "AliyunEffectResourceModel.h"
#import "NSString+AlivcHelper.h"

static NSString *localeLanguageCode = nil;

@implementation AliyunEffectInfo

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

- (NSString *)localFilterIconPath {
    return nil;
}

- (NSString *)localFilterResourcePath {
    return nil;
}

- (NSString *)filterTypeName{
    NSString *typeName = @"";
    switch (_filterType) {
        case AliyunFilterTypNone:
            typeName = @"";
            break;
        case AliyunFilterTypeFace:
            typeName = NSLocalizedString(@"人物类" , nil);
            break;
        case AliyunFilterTypeFood:
            typeName = NSLocalizedString(@"食物类" , nil);
            break;
        case AliyunFilterTypeScenery:
            typeName = NSLocalizedString(@"风景类" , nil);
            break;
        case AliyunFilterTypePet:
            typeName = NSLocalizedString(@"宠物类" , nil);
            break;
        case AliyunFilterTypeSpecialStyle:
            typeName = NSLocalizedString(@"特殊风格类" , nil);
            break;
        default:
            break;
    }
    return typeName;
}

/**
 重写名称的get方法

 @return 返回国际化的名称
 */
- (NSString *)name{
    if(!_isCustomLocaleLanguage) return _name;
    if ([self isChineseEnv] && [_name isNotEmpty]) {
        return _name;
    }
    return _nameEn;
}

/**
 避免频繁获取语言编码

 @return 语言编码
 */
- (BOOL)isChineseEnv{
    if (!localeLanguageCode) {
        localeLanguageCode =  [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    }
    if ([localeLanguageCode isEqualToString:@"zh"]) {
        return YES;
    }
    return NO;
}

@end
