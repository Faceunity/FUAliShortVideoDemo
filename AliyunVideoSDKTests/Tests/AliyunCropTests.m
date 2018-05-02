//
//  AliyunCropTests.m
//  qusdk
//
//  Created by Vienta on 2017/5/16.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AliyunVideoSDKPro/AliyunCrop.h>
#import <AVFoundation/AVFoundation.h>

@interface AliyunCropTests : XCTestCase

@property (nonatomic, strong) AliyunCrop *crop;
@property (nonatomic, strong) XCTestExpectation *cropExpectation;
@property (nonatomic, strong) NSString *unitTestsFolder;

@end

@implementation AliyunCropTests {
    NSDictionary *_configJsonCache;
}


- (NSString *)unitTestsFolder {
    if (!_unitTestsFolder) {
        NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *unitTests = [document stringByAppendingPathComponent:@"unitTests"];
        _unitTestsFolder = unitTests;

        NSFileManager *fm = [NSFileManager defaultManager];
        
        BOOL fileExist = [fm fileExistsAtPath:unitTests];
        if (!fileExist) {
            [fm createDirectoryAtPath:_unitTestsFolder withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    
    return _unitTestsFolder;
}

- (AliyunCrop *)cropWithJsonConfig:(NSString *)configName {
    
    if (!_configJsonCache) {
        NSString *configJsonPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test" ofType:@"json"];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:configJsonPath] options:NSJSONReadingAllowFragments error:nil];
        _configJsonCache =  dict;
    }
    
    NSDictionary *cropDict = [_configJsonCache objectForKey:configName];
    AliyunCrop *crop = [[AliyunCrop alloc] init];
    crop.outputSize = CGSizeFromString([cropDict objectForKey:@"output"]);
    crop.startTime = [[cropDict objectForKey:@"startTime"] floatValue];
    crop.endTime = [[cropDict objectForKey:@"endTime"] floatValue];
    crop.cropMode = [[cropDict objectForKey:@"cropMode"] integerValue];
    crop.videoQuality = [[cropDict objectForKey:@"videoQuality"] integerValue];
    crop.fps = [[cropDict objectForKey:@"fps"] intValue];
    crop.gop = [[cropDict objectForKey:@"gop"] intValue];
    crop.encodeMode = [[cropDict objectForKey:@"encodeMode"] intValue];
    crop.rect = CGRectFromString([cropDict objectForKey:@"rect"]);
    
    return crop;
}

- (NSString *)cropQuality:(AliyunVideoQuality)quality {
    switch (quality) {
        case AliyunVideoQualityLow:
            return @"AliyunVideoQualityLow";
            break;
        case AliyunVideoQualityPoor:
            return @"AliyunVideoQualityPoor";
            break;
        case AliyunVideoQualityExtraPoor:
            return @"AliyunVideoQualityExtraPoor";
            break;
        case AliyunVideoQualityHight:
            return @"AliyunVideoQualityHight";
            break;
        case AliyunVideoQualityMedium:
            return @"AliyunVideoQualityMedium";
            break;
        case AliyunVideoQualityVeryHight:
            return @"AliyunVideoQualityVeryHight";
            break;
            
        default:
            return @"";
            break;
    }
}

- (NSString *)fileNameWithCrop:(AliyunCrop *)crop {
    NSString *fileName = [NSString stringWithFormat:@"%@_%@_起_%@_止_%@_裁剪模式_%@_质量_%@_编码模式_%@_fps_%@_gop_%@.mp4",
                          @(crop.outputSize.width),
                          @(crop.outputSize.height),
                          @(crop.startTime),
                          @(crop.endTime),
                          (crop.cropMode == 0 ? @"填充" : @"裁剪"),
                          [self cropQuality:crop.videoQuality],
                          (crop.encodeMode == 0 ? @"软编" : @"硬编"),
                          @(crop.fps),
                          @(crop.gop)];
    
    return fileName;
}

- (void)transCrop:(AliyunCrop *)tmpCrop caseName:(NSString *)caseName {
    self.crop.outputSize = tmpCrop.outputSize;
    self.crop.startTime = tmpCrop.startTime;
    self.crop.endTime = tmpCrop.endTime;
    self.crop.cropMode = tmpCrop.cropMode;
    self.crop.videoQuality = tmpCrop.videoQuality;
    self.crop.fps = tmpCrop.fps;
    self.crop.gop = tmpCrop.gop;
    self.crop.encodeMode = tmpCrop.encodeMode;
    self.crop.rect = tmpCrop.rect;
    NSString *fileName = [self fileNameWithCrop:self.crop];
    NSString *newFileName = [NSString stringWithFormat:@"%@_%@", caseName, fileName];
    NSString *filePath = [self.unitTestsFolder stringByAppendingPathComponent:newFileName];
    self.crop.outputPath = filePath;
}

- (void)checksumMediaInfo {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:self.crop.outputPath] options:nil];
    XCTAssertNotNil(asset);
    
    Float64 duration = CMTimeGetSeconds([asset duration]);
    XCTAssertEqualWithAccuracy(duration, self.crop.endTime - self.crop.startTime, 0.1);
    
    AVAssetTrack *videoTrack = nil;
    NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if ([videoTracks count] > 0) {
        videoTrack = [videoTracks objectAtIndex:0];
    }
    CGSize trackDimensions = {
        .width = 0.0,
        .height = 0.0,
    };
    trackDimensions = [videoTrack naturalSize];
    XCTAssertEqual((int)trackDimensions.width, (int)self.crop.outputSize.width);
    XCTAssertEqual((int)trackDimensions.height, (int)self.crop.outputSize.height);
    
    XCTAssertEqualWithAccuracy([videoTrack nominalFrameRate], self.crop.fps, 2);
}

- (void)checksumCanceledMediaInfo {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:self.crop.outputPath] options:nil];
    XCTAssertNotNil(asset);
    
    Float64 duration = CMTimeGetSeconds([asset duration]);
    XCTAssertLessThan(duration, self.crop.endTime - self.crop.startTime);
    
    AVAssetTrack *videoTrack = nil;
    NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if ([videoTracks count] > 0) {
        videoTrack = [videoTracks objectAtIndex:0];
    }
    CGSize trackDimensions = {
        .width = 0.0,
        .height = 0.0,
    };
    trackDimensions = [videoTrack naturalSize];
    XCTAssertEqual((int)trackDimensions.width, (int)self.crop.outputSize.width);
    XCTAssertEqual((int)trackDimensions.height, (int)self.crop.outputSize.height);
    
    XCTAssertEqualWithAccuracy([videoTrack nominalFrameRate], self.crop.fps, 2);
}


- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *testMp4path = [bundle pathForResource:@"test" ofType:@"mp4"];//10s的视频
    
    self.crop = [[AliyunCrop alloc] initWithDelegate:(id)self];
    self.crop.videoPath = testMp4path;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testNormalCrop {
    _cropExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    AliyunCrop *tmpCrop = [self cropWithJsonConfig:@"normalCrop"];
    [self transCrop:tmpCrop caseName:@"normalCrop"];
    
    [self.crop startCrop];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {    //60s内裁完 否则失败
        XCTAssertNil(error);
    }];
}


- (void)testCropCancel {
    _cropExpectation = [self expectationWithDescription: NSStringFromSelector(_cmd)];

    AliyunCrop *tmpCrop = [self cropWithJsonConfig:@"cancelCrop"];
    [self transCrop:tmpCrop caseName:@"cancelCrop"];
    
    [self.crop startCrop];
    
    [self waitForExpectationsWithTimeout:6 handler:^(NSError * _Nullable error) {
        
        sleep(3);
        [self checksumCanceledMediaInfo];
    }];
}

- (void)testCropMode1Crop {
    _cropExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    AliyunCrop *tmpCrop = [self cropWithJsonConfig:@"cropMode1Crop"];
    [self transCrop:tmpCrop caseName:@"cropMode1Crop"];
    
    [self.crop startCrop];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)testCropMode0Crop {
    _cropExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    AliyunCrop *tmpCrop = [self cropWithJsonConfig:@"cropMode0Crop"];
    [self transCrop:tmpCrop caseName:@"cropMode0Crop"];
    
    [self.crop startCrop];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)testVeryHightCrop {
    _cropExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    AliyunCrop *tmpCrop = [self cropWithJsonConfig:@"veryHightCrop"];
    [self transCrop:tmpCrop caseName:@"veryHightCrop"];
    
    [self.crop startCrop];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)testHightCrop {
    _cropExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    AliyunCrop *tmpCrop = [self cropWithJsonConfig:@"hightCrop"];
    [self transCrop:tmpCrop caseName:@"hightCrop"];
    
    [self.crop startCrop];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)testMediumCrop {
    _cropExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    AliyunCrop *tmpCrop = [self cropWithJsonConfig:@"mediumCrop"];
    [self transCrop:tmpCrop caseName:@"mediumCrop"];
    
    [self.crop startCrop];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)testLowCrop {
    _cropExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    AliyunCrop *tmpCrop = [self cropWithJsonConfig:@"lowCrop"];
    [self transCrop:tmpCrop caseName:@"lowCrop"];
    
    [self.crop startCrop];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)testPoorCrop {
    _cropExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    AliyunCrop *tmpCrop = [self cropWithJsonConfig:@"poorCrop"];
    [self transCrop:tmpCrop caseName:@"poorCrop"];
    
    [self.crop startCrop];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)testExtraPoorCrop {
    _cropExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    AliyunCrop *tmpCrop = [self cropWithJsonConfig:@"extraPoorCrop"];
    [self transCrop:tmpCrop caseName:@"extraPoorCrop"];
    
    [self.crop startCrop];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

#pragma mark - AliyunCropDelegate


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

- (void)cropOnError:(int)error {
    NSLog(@"cropOnError: %d", error);
    XCTAssertFalse(error);
}

- (void)cropTaskOnProgress:(float)progress {
    NSLog(@"qucrop task onprogress: %lf", progress);
    if (progress > 0.5) {
        if (_cropExpectation && [[_cropExpectation expectationDescription] isEqualToString:NSStringFromSelector(@selector(testCropCancel))]) {
            [_cropExpectation fulfill];
            _cropExpectation = nil;
            [self.crop cancel];
        }
    }
}

- (void)cropTaskOnComplete {
    NSLog(@"crop task on Complete");
    if (_cropExpectation) {
        [_cropExpectation fulfill];
        _cropExpectation = nil;
        [self checksumMediaInfo];
    }
}

@end
