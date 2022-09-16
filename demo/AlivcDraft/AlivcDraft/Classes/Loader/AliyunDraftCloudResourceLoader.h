//
//  AliyunDraftCloudResourceLoader.h
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/21.
//

#import "AliyunDraftLoaderUtils.h"

@interface AliyunDraftCloudResourceInfo : AliyunDraftResourceUrl
@property (nonatomic, copy, readonly) NSString *path;

+ (BOOL) IsCloudPath:(NSString *)path;
+ (BOOL) IsCloudUrl:(NSString *)url;

+ (AliyunDraftResourceType) PathToType:(NSString *)path;
+ (NSString *) RootPathWithType:(AliyunDraftResourceType)type;
@end


@interface AliyunDraftCloudResourceLoader : NSObject

+ (BOOL) LoadFromUrl:(NSString *)url completion:(void(^)(AliyunDraftCloudResourceInfo *info))completion;
+ (BOOL) LoadFromPath:(NSString *)path completion:(void(^)(AliyunDraftCloudResourceInfo *info))completion;

@end
