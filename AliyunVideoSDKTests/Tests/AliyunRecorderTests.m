//
//  AliyunRecorderTests.m
//  qusdk
//
//  Created by Vienta on 2017/5/31.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AliyunVideoSDKPro/AliyunIRecorder.h>

@interface AliyunRecorderTests : XCTestCase

@end

@implementation AliyunRecorderTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testVersion {
    XCTAssertEqualObjects(@"3.1.2", [AliyunIRecorder version]);
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
