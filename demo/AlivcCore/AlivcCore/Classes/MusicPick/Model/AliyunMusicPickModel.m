//
//  AliyunMusicPickModel.m
//  qusdk
//
//  Created by Worthy on 2017/6/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunMusicPickModel.h"
#import <objc/runtime.h>
@implementation AliyunMusicPickModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        //musicId
        self.musicId = dictionary[@"musicId"];
        //获取keyId
        self.keyId = [[self.musicId substringFromIndex:self.musicId.length - 3] intValue];
//        self.keyId = dictionary[@"musicId"];
        //title
        self.name = dictionary[@"title"];
        //artistName
        self.artist = dictionary[@"artistName"];
        //duration
        self.duration = [dictionary[@"duration"] floatValue];
        //playPath
        self.path = dictionary[@"playPath"];
        //expireTime
        self.image = dictionary[@"image"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    //利用runtime 遍历所有的key
    unsigned int count = 0;
    objc_property_t *list = class_copyPropertyList([self class], &count);
    for(int i = 0;i < count; i++) {
        objc_property_t property = list[i];
        NSString *key = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
    free(list);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    //利用runtime 遍历所有的key
    if (self = [super init]) {
        unsigned int count = 0;
        objc_property_t *list = class_copyPropertyList([self class], &count);
        for(int i = 0;i < count; i++) {
            objc_property_t property = list[i];
            NSString *key = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
        free(list);
    } 
    return self;
}


- (id)copyWithZone:(NSZone *)zone {
    AliyunMusicPickModel *musicPickModel = [[AliyunMusicPickModel allocWithZone:zone] init];
    unsigned int count = 0;
    objc_property_t *list = class_copyPropertyList([self class], &count);
    for(int i = 0;i < count; i++) {
        objc_property_t property = list[i];
        NSString *key = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        id value = [self valueForKey:key];
        [musicPickModel setValue:value forKey:key]; 
    }
    free(list);
    return musicPickModel;
}
@end
