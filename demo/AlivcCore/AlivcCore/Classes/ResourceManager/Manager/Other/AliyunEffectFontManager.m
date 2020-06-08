//
//  AliyunEffectFontManager.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/15.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectFontManager.h"
#import <CoreText/CoreText.h>

@implementation AliyunEffectFontManager

static AliyunEffectFontManager *manager = nil;
+ (instancetype)manager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AliyunEffectFontManager alloc] init];
    });
    return manager;
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
    
    return fontName;
}

@end
