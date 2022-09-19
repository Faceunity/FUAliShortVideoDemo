//
//  AlivcTemplateResourceManager.h
//  AFNetworking
//
//  Created by Bingo on 2021/11/22.
//

#import <Foundation/Foundation.h>
#import <AliyunVideoSDKPro/AliyunVideoSDKPro.h>

@interface AlivcTemplateResourceManager : NSObject

+ (NSString *)hardcodeTemplatePath;
+ (NSString *)localTemplatePath;
+ (NSString *)builtTemplatePath;
+ (NSString *)exportTemplatePath;
+ (NSString *)projectTemplatePath;
+ (NSString *)applyTemplatePath;
+ (NSString *)resourceDownloadPath;

+ (AliyunResourceImport *)templateResourceImport:(NSString *)taskPath reset:(BOOL)reset;
+ (AliyunResourceImport *)projectResourceImport:(NSString *)taskPath reset:(BOOL)reset shouldDownload:(BOOL)shouldDownload;

+ (AliyunResourceExport *)templateResourceExport:(NSString *)taskPath;
+ (AliyunResourceExport *)projectResourceExport:(NSString *)taskPath;

@end
