//
//  AliyunDraftLoaderUtils.h
//  Pods
//
//  Created by coder.pi on 2021/7/21.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AliyunDraftResourceType) {
    AliyunDraftResourceType_AnimationEffect = 0,
    AliyunDraftResourceType_Bubble,
    AliyunDraftResourceType_Filter,
    AliyunDraftResourceType_MV,
    AliyunDraftResourceType_Sticker,
    AliyunDraftResourceType_Font,
    AliyunDraftResourceType_Music,
    AliyunDraftResourceType_Transition,
    AliyunDraftResourceType_Caption,
    AliyunDraftResourceType_LutFilter,
    AliyunDraftResourceType_Unknown,
    
};

@interface AliyunDraftLoaderUtils : NSObject
+ (NSString *) TypeToString:(AliyunDraftResourceType)type;
+ (AliyunDraftResourceType) StringToType:(NSString *)str;
@end

@interface AliyunDraftResourceUrl : NSObject
@property (nonatomic, class, readonly) NSString *Scheme;
@property (nonatomic, class, readonly) NSString *AppHost;
@property (nonatomic, class, readonly) NSString *CloudHost;
@property (nonatomic, class, readonly) NSString *AppUrl;
@property (nonatomic, class, readonly) NSString *CloudUrl;

@property (nonatomic, copy, readonly) NSString *url;

@property (nonatomic, assign, readonly) BOOL isInApp;
@property (nonatomic, assign, readonly) AliyunDraftResourceType type;
@property (nonatomic, copy, readonly) NSString *gid;
@property (nonatomic, copy, readonly) NSString *eid;
@property (nonatomic, copy, readonly) NSString *name;

- (instancetype) initWithUrl:(NSString *)url;
- (instancetype) initWithType:(AliyunDraftResourceType)type
                      isInApp:(BOOL)isInApp
                          gid:(NSString *)gid
                          eid:(NSString *)eid
                         name:(NSString *)name;
@end

@interface AliyunDraftResourceId : NSObject
@property (nonatomic, copy) NSString *gid;
@property (nonatomic, copy) NSString *eid;
@property (nonatomic, copy) NSString *name;
@end
