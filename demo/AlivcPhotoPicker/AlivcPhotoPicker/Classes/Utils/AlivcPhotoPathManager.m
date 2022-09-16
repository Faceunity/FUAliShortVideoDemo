//
//  AlivcPhotoPathManager.m
//  AlivcPhotoPicker
//
//  Created by mengyehao on 2021/11/11.
//

#import "AlivcPhotoPathManager.h"

@implementation AlivcPhotoPathManager

+ (NSString *)quCachePath {
    return [[self cachePath] stringByAppendingPathComponent:@"com.duanqu.demo"];
}

+ (NSString *)compositionRootDir {
    return [[self quCachePath] stringByAppendingPathComponent:@"composition"];
}

+ (NSString*)randomString {
    CFUUIDRef puuid = CFUUIDCreate(nil);
    CFStringRef uuidString = CFUUIDCreateString(nil, puuid);
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

#pragma mark - Private

+ (NSString *)rootPath {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
}

+ (NSString *)cachePath {
    return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
}

@end
