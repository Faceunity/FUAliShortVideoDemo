//
//  AliyunTransitionIcon.m
//  qusdk
//
//  Created by Vienta on 2018/6/6.
//  Copyright © 2018年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunTransitionIcon.h"
#import "NSString+AlivcHelper.h"

static NSString *localeLanguageCode = nil;

@implementation AliyunTransitionIcon

- (id)copyWithZone:(NSZone *)zone{
    AliyunTransitionIcon *newOne = [[AliyunTransitionIcon allocWithZone:zone]init];
    newOne.image = self.image;
    newOne.imageSel = self.imageSel;
    newOne.coverIcon = self.coverIcon;
    newOne.text = [self.text copy];
    newOne.textEn = [self.textEn copy];
    newOne.isSelect = self.isSelect;
    newOne.type = self.type;
    newOne.isCustomLocaleLanguage = self.isCustomLocaleLanguage;
    newOne.resoucePath = self.resoucePath;
    return newOne;
}

/**
 重写名称的get方法

 @return 返回国际化的名称
 */
- (NSString *)text{
    if(!_isCustomLocaleLanguage) return _text;
    if ([self isChineseEnv] && [_text isNotEmpty]) {
        return _text;
    }
    return _textEn;
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
