//
//  AliyunDraftAppResourceLoader.h
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/20.
//

#import "AliyunDraftLoaderUtils.h"

@interface AliyunDraftAppResourceInfo : AliyunDraftResourceUrl
@property (nonatomic, copy, readonly) NSString *path;

+ (AliyunDraftAppResourceInfo *) InfoFromPath:(NSString *)path;
+ (AliyunDraftAppResourceInfo *) InfoFromUrl:(NSString *)url;

+ (AliyunDraftResourceType) PathToType:(NSString *)path;
+ (NSString *) RootPathWithType:(AliyunDraftResourceType)type;

+ (BOOL) IsAppPath:(NSString *)path;
+ (BOOL) IsAppUrl:(NSString *)url;

@end
