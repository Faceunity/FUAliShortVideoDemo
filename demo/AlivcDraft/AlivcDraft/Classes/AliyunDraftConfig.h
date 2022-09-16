//
//  AliyunDraftConfig.h
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/9.
//

#import <Foundation/Foundation.h>
#import "AliyunDraftLoader.h"
#import "AliyunLocalDraftManager.h"
#import "AliyunCloudDraftManager.h"

@interface AliyunDraftConfig : NSObject
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *serverUrl;
@property (nonatomic, assign, readonly) BOOL hasService;
@property (nonatomic, strong, readonly) AliyunDraftLoader *loader;
@property (nonatomic, strong, readonly) AliyunLocalDraftManager *localManager;
@property (nonatomic, strong, readonly) AliyunLocalDraftManager *templateManager;
@property (nonatomic, strong, readonly) AliyunCloudDraftManager *cloudManager;

+ (AliyunDraftConfig *) Shared;
@end
