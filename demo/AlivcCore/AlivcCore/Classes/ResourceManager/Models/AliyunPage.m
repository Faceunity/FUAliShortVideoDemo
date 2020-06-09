//
//  AliyunPages.m
//  AliyunVideoClient_Entrance
//
//  Created by sz on 2019/3/5.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AliyunPage.h"
#import <objc/runtime.h>
#define kPageSize 20

@implementation AliyunPage

- (instancetype)init{
    self = [super init];
    if (self) {
        self.currentPageNo = 1;
        self.pageSize = kPageSize;
    }
    return self;
}

- (BOOL)hasMore {
    //第一页默认有数据的
    if (self.currentPageNo == 1) {
        return YES;
    }
    return self.pageSize * (self.currentPageNo -1) < self.totalRecords;
}




- (void)setCurrentPageNo:(NSInteger)currentPageNo{
    if (currentPageNo <= 0) {
        currentPageNo = 1;
    }else{
        _currentPageNo = currentPageNo;
    }
}
- (void)setPageSize:(NSInteger)pageSize{
    if (pageSize <= 0) {
        _pageSize = kPageSize;
    }else{
        _pageSize = pageSize;
    }
}

- (void)next{
    self.currentPageNo++;
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

@end
