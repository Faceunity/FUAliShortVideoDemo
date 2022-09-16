//
//  AliyunCloudDraftModel.m
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/30.
//

#import "AliyunCloudDraftModel+Private.h"
#import "AliyunDraftInfo+Private.h"

@implementation AliyunCloudDraftModel

static NSString * s_formatBackupTime(NSTimeInterval time) {
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    dateFormat.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    return [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
}

- (instancetype) init {
    return [super initWithState:AliyunDraftState_Cloud];
}

- (instancetype) initWithDict:(NSDictionary *)dict {
    self = [self init];
    if (self) {
        self.projectId = [dict objectForKey:@"id"];
        self.title = [dict objectForKey:@"name"];
        self.modifiedTime = [dict objectForKey:@"modified_time"];
        self.duration = [[dict objectForKey:@"duration"] doubleValue];
        self.size = (size_t)[[dict objectForKey:@"file_size"] longLongValue];
        self.cover = [AEPSource SourceWithType:AEPSourceType_Image sourceId:nil url:[dict objectForKey:@"cover_url"] path:nil];
        _projectUrl = [dict objectForKey:@"project_url"];
        
        _innerBackupTime = [[dict objectForKey:@"backup_time"] doubleValue];
        _backupTime = s_formatBackupTime(_innerBackupTime);
    }
    return self;
}

- (instancetype) initWithLocal:(AliyunLocalDraftModel *)model projectUrl:(NSString *)projectUrl {
    self = [self init];
    if (self) {
        self.projectId = model.projectId;
        self.title = model.title;
        self.modifiedTime = model.modifiedTime;
        self.duration = model.duration;
        self.size = model.size;
        AEPSource *tmp = model.cover;
        self.cover = [AEPSource SourceWithType:tmp.type sourceId:tmp.sourceId url:tmp.URL path:tmp.path];
        _projectUrl = projectUrl;
        
        _innerBackupTime = [NSDate.date timeIntervalSince1970];
        _backupTime = s_formatBackupTime(_innerBackupTime);
    }
    return self;
}

- (void) onConnect {
    self.state = AliyunDraftState_Synced;
}
- (void) onDisconnect {
    self.state = AliyunDraftState_Cloud;
}

@end
