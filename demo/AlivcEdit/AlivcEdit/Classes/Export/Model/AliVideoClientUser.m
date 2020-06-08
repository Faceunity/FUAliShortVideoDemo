//
//  AlivcUser.m
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2019/1/10.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AliVideoClientUser.h"

static AliVideoClientUser *_instance = nil;

@implementation AliVideoClientUser
#pragma mark - 单例

+ (instancetype)shared {
    if (_instance == nil) {
        
        _instance = [[AliVideoClientUser alloc] init];
    }
    
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    if (_instance == nil) {
        
        _instance = [super allocWithZone:zone];
    }
    
    return _instance;
}

- (id)copy {
    
    return self;
}

- (id)mutableCopy {
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    
    return self;
}


#pragma mark - Method
- (void)setValueWithInfo:(NSDictionary *)dic{
    NSString *avatarString = dic[@"avatarUrl"];
    if (avatarString) {
        _avatarUrlString = avatarString;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSURL *url = [NSURL URLWithString:avatarString];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            self->_avatarImage = image;
        });
    }
    
    _token = dic[@"token"];
    
    _nickName = dic[@"nickName"];
    
    _userID = dic[@"userId"];
}

- (void)setNickName:(NSString *)nickName{
    _nickName = nickName;
}

- (void)setLocalUser:(AliVideoClientUser *)localUser{
    _instance = localUser;
    if (_instance.avatarUrlString) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSURL *url = [NSURL URLWithString:_instance.avatarUrlString];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            _instance.avatarImage = image;
        });
    }
}

#pragma mark - NSSecureCoding

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_avatarUrlString forKey:@"avatarUrlString"];
    [aCoder encodeObject:_token forKey:@"token"];
    [aCoder encodeObject:_nickName forKey:@"nickName"];
    [aCoder encodeObject:_userID forKey:@"userID"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        _avatarUrlString = (NSString *)[aDecoder decodeObjectForKey:@"avatarUrlString"];
        _token = (NSString *)[aDecoder decodeObjectForKey:@"token"];
        _nickName = (NSString *)[aDecoder decodeObjectForKey:@"nickName"];
        _userID = (NSString *)[aDecoder decodeObjectForKey:@"userID"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding{
    return YES;
}


@end
