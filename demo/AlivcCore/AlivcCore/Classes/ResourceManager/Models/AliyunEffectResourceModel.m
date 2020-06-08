//
//  AliyunEffectResourceModel.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectResourceModel.h"
#import "AliyunPathManager.h"
#import "NSString+AlivcHelper.h"

static NSString *localeLanguageCode = nil;

@implementation AliyunEffectResourceModel



+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    
    return YES;
}

+ (JSONKeyMapper *)keyMapper {
    
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"eid":@"id",
                                                                  @"edescription":@"description",
                                                                  @"mvList":@"aspectList"}];
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

/**
 重写名称的get方法

 @return 返回国际化的名称
 */
- (NSString *)name{
    if (![self isChineseEnv] && [_nameEn isNotEmpty]) {
        return _nameEn;
    }
    return _name;
}

/**
 重写名称的get方法
 
 @return 返回国际化的描述
 */
- (NSString *)edescription{
    if (![self isChineseEnv] && [_descriptionEn isNotEmpty]) {
        return _descriptionEn;
    }
    return _edescription;
}


- (NSString *)storageFullPath {
    NSString *fullPath = [NSHomeDirectory() stringByAppendingPathComponent:[self storageDirectory]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return fullPath;
}

//将特效iconurl字段映射为icon字段
- (NSString *)icon{
    if (!_icon && _iconUrl) {
        _icon = _iconUrl;
    }
    return _icon;
}

-(NSString *)storageDirectory {
    
    return [[self class] storageDirectoryWithEffectType:self.effectType];
}

+ (NSString *)storageDirectoryWithEffectType:(AliyunEffectType)type {
    
    NSString *path = @"pasterRes";
    switch (type) {
        case AliyunEffectTypeMV:
            path = @"mvRes";
            break;
        case AliyunEffectTypeFilter:
            path = @"filterRes";
            break;
        case AliyunEffectTypeMusic:
            path = @"musicRes";
            break;
        case AliyunEffectTypeFont:
            path = @"fontRes";
            break;
        case AliyunEffectTypePaster:
            path = @"pasterRes";
            break;
        case AliyunEffectTypeCaption:
            path = @"subtitleRes";
            break;
        case AliyunEffectTypeSpecialFilter:
            path = @"specialFilterRes";
            break;
        case AliyunEffectTypeTransition:
            path = @"transitionRes";
            break;
        default:
            break;
    }
    return [[AliyunPathManager resourceRelativeDir] stringByAppendingPathComponent:path];
}

+ (NSString *)effectNameByPath:(NSString *)path
{
    NSRange range = [path rangeOfString:@"-"];
    if (range.length <= 0) {
        return nil;
    }
    
    NSString *effectName = [path substringFromIndex:NSMaxRange(range)];
    return effectName;
}

+ (id)effectIdByPath:(NSString *)path
{
    NSArray *components = [path componentsSeparatedByString:@"-"];
    if (components.count <= 1) {
        NSError *err = [[NSError alloc] initWithDomain:@"Resource Err" code:-9090 userInfo:nil];
        return err;
    }
    return [components firstObject];
}

@end
