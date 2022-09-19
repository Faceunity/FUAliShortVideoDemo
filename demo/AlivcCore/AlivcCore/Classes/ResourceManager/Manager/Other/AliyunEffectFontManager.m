//
//  AliyunEffectFontManager.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/15.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectFontManager.h"
#import <CoreText/CoreText.h>

@interface AliyunEffectFontManager()
@property (nonatomic, strong) NSMutableDictionary *fontPathInfos;
@end

@implementation AliyunEffectFontManager

static AliyunEffectFontManager *manager = nil;
+ (instancetype)manager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AliyunEffectFontManager alloc] init];
    });
    return manager;
}

static NSString * s_documentPath()
{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
}

static NSString * s_infoPlistPath()
{
    return [s_documentPath() stringByAppendingPathComponent:@"font_info.plist"];
}

static NSMutableDictionary * s_readFromFile()
{
    NSString *path = s_infoPlistPath();
    if ([NSFileManager.defaultManager fileExistsAtPath:path]) {
        return [NSDictionary dictionaryWithContentsOfFile:s_infoPlistPath()].mutableCopy;
    }
    return @{}.mutableCopy;
}

static void s_saveToFile(NSDictionary *dict)
{
    [dict writeToFile:s_infoPlistPath() atomically:YES];
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _fontPathInfos = s_readFromFile();
    }
    return self;
}

#define HOME_ALIST @"$HOME"
static NSString * s_homePath()
{
    return [s_documentPath() stringByDeletingLastPathComponent];
}

- (void) addFont:(NSString *)fontName withPath:(NSString *)path
{
    path = [path stringByReplacingOccurrencesOfString:s_homePath() withString:HOME_ALIST];
    _fontPathInfos[fontName] = path;
    s_saveToFile(_fontPathInfos);
}

- (NSString *) findFontPathWithName:(NSString *)fontName
{
    NSString *path = [_fontPathInfos objectForKey:fontName];
    if (!path) {
        return nil;
    }
    
    return [path stringByReplacingOccurrencesOfString:HOME_ALIST withString:s_homePath()];
}

- (NSString *)registerFontWithFontPath:(NSString *)fontPath {
    NSString *fontPathFormat = [NSString stringWithFormat:@"%@",fontPath];
    NSData *dynamicFontData;
    dynamicFontData = [NSData dataWithContentsOfFile:fontPathFormat];
    if (!dynamicFontData) {
        fontPathFormat = [fontPathFormat stringByReplacingOccurrencesOfString:@".ttf" withString:@".TTF"];
        dynamicFontData = [NSData dataWithContentsOfFile:fontPathFormat];
        NSLog(@"font path rename befor:%@",fontPath);
        NSLog(@"font path renamed:%@",fontPathFormat);
    }
    if (!dynamicFontData) {
        NSLog(@"font data read error:%@", fontPath);
        return nil;
    }
    NSURL *fontUrl = [NSURL fileURLWithPath:fontPathFormat];
    CFErrorRef error;
    CGDataProviderRef providerRef = CGDataProviderCreateWithCFData((__bridge CFDataRef)dynamicFontData);
    CGFontRef font = CGFontCreateWithDataProvider(providerRef);
    CFStringRef cfFontName = CGFontCopyPostScriptName(font);
    NSString *fontName = (__bridge NSString *)cfFontName;
//    @try {
//        CTFontManagerRegisterGraphicsFont(font, &error);
//    } @catch (NSException *exception) {
//        
//    }
    
    if (CTFontManagerRegisterFontsForURL((__bridge CFURLRef)fontUrl,kCTFontManagerScopeProcess,&error)) {
        UIFont *keepFontRegister = [UIFont fontWithName:fontName size:10];
        if (!keepFontRegister) {
            NSLog(@"font register not success: can not get font call [UIFont fontWithName:size:]");
            CFRelease(font);
            CFRelease(cfFontName);
            CFRelease(providerRef);
            return nil;
        }
    }else{
        
        NSInteger errorCode = CFErrorGetCode(error);//105 表示已经注册过
            NSLog(@"errorcode == %zd",errorCode);
        if (errorCode == kCTFontManagerErrorAlreadyRegistered) {
            
        }else{
            CFRelease(font);
            CFRelease(cfFontName);
            CFRelease(providerRef);
            return nil;
        }
    }
    
    NSLog(@"font:%@ register success", fontName);
    CFRelease(font);
    CFRelease(cfFontName);
    CFRelease(providerRef);
    
    [self addFont:fontName withPath:fontPath];
    return fontName;
}

- (NSString *)registerFontWithFontName:(NSString *)fontName
{
    NSString *path = [self findFontPathWithName:fontName];
    if (!path) {
        return nil;
    }
    [self registerFontWithFontPath:path];
    return path;
}

@end
