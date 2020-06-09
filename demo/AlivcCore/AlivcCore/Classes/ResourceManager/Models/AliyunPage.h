//
//  AliyunPages.h
//  AliyunVideoClient_Entrance
//
//  Created by sz on 2019/3/5.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AliyunPage : NSObject<NSCoding>
//当前页码
@property (nonatomic, assign) NSInteger currentPageNo;
//每页显示的数据个数
@property (nonatomic, assign) NSInteger pageSize;
//是否还有
@property (nonatomic, assign) BOOL hasMore;
//总数据
@property (nonatomic, assign) NSInteger totalRecords;

- (void)next;//下一页

@end

NS_ASSUME_NONNULL_END
