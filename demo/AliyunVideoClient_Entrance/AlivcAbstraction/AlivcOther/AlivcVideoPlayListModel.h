//
//  AlivcVideoPlayListModel.h
//  AliyunVideoClient_Entrance
//
//  Created by 王凯 on 2018/5/23.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "JSONModel.h"

@interface AlivcVideoPlayListModel : JSONModel
@property (nonatomic, copy) NSString *status;
@property (nonatomic, assign) double duration;
@property (nonatomic, copy) NSString *creationTime;
@property (nonatomic, strong) NSDictionary *snapshots;
@property (nonatomic, copy) NSString *modifyTime;
@property (nonatomic, assign) long size;
@property (nonatomic, copy) NSString *coverURL;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, copy) NSString * stsAccessKeyId;
@property (nonatomic, copy) NSString * stsAccessSecret;
@property (nonatomic, copy) NSString * stsSecurityToken;

@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *des;
@property (nonatomic, copy) NSString *durationStr;


//@property (nonatomic, assign) AliyunOlympicPlayStyle playStyle;

@end



