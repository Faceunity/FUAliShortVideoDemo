//
//  AliyunPublishManager.m
//  QUSDK
//
//  Created by Worthy on 2017/10/27.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPublishManager.h"
#import <VODUpload/VODUploadSVideoClient.h>

@implementation AliyunUploadSVideoInfo

- (instancetype)init {
    self = [super init];
    if (self) {
        _isProcess = YES;
        _priority = @(6);
    }
    return self;
}

@end

@interface AliyunPublishManager () <VODUploadSVideoClientDelegate, AliyunIPlayerCallback, AliyunIExporterCallback, AliyunIRenderCallback>
@property(nonatomic, strong) AliyunEditor *editor;
@property(nonatomic, strong) VODUploadSVideoClient *client;

@property(nonatomic, assign) BOOL isExporting;
@property(nonatomic, assign) BOOL isUploading;

@property(nonatomic, strong) UIImage *image;
@property(nonatomic, assign) CGRect frame;
@property(nonatomic, assign) CGFloat duration;

@property(nonatomic, copy) NSString *address;
@property(nonatomic, copy) NSString *auth;

@property(nonatomic, copy) NSString *requestId;
@property(nonatomic, strong) AliyunEffectImage *watermark;
@property(nonatomic, strong) AliyunEffectImage *tailWatermark;
@property(nonatomic, assign) BOOL cancelExportInResignActive;
@end

@implementation AliyunPublishManager

#pragma mark - init

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)dealloc {
    [self removeNotifications];
}

- (void)setup {
    _client = [[VODUploadSVideoClient alloc] init];
    _reportEnabled = YES;
    _client.delegate = self;
    _maxRetryCount = 2;
    _timeoutIntervalForRequest = 30;
    // todo:待确定是否修改默认接口行为
    _cancelExportInResignActive = NO;
    [self addNotifications];
}

- (void)setReportEnabled:(BOOL)reportEnabled {
    _reportEnabled = reportEnabled;
    [_client setReportEnabled:reportEnabled];
}

- (int)setWaterMark:(AliyunEffectImage *)waterMark {
    _watermark = waterMark;
    return 0;
}

- (int)setTailWaterMark:(AliyunEffectImage *)waterMark {
    _tailWatermark = waterMark;
    return 0;
}

- (void)setCancelExportInResignActive:(BOOL)flag {
    _cancelExportInResignActive = flag;
}

#pragma mark - notification

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillResignActive {
    if (_cancelExportInResignActive) {
        _isExporting = NO;
        [[_editor getExporter] cancelExport];
        [_editor stopEdit];
    }
}

#pragma mark - setting

static NSString * s_tailWaterMarkPath() {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(
                                                                  NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *basePath =
    [documentPath stringByAppendingPathComponent:@"com.duanqu.sdk"];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if (![fileMgr fileExistsAtPath:basePath]) {
        [fileMgr createDirectoryAtPath:basePath
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];
    };
    return [basePath stringByAppendingPathComponent:@"tail.png"];
}

- (void)setTailWaterMark:(UIImage *)image frame:(CGRect)frame duration:(CGFloat)duration {
    _image = image;
    _frame = frame;
    _duration = duration;
    [UIImagePNGRepresentation(image) writeToFile:s_tailWaterMarkPath() atomically:YES];
    _tailWatermark = [[AliyunEffectImage alloc] initWithFile:s_tailWaterMarkPath()];
    _tailWatermark.frame = frame;
    _tailWatermark.endTime = _duration;
}

- (void)setMaxRetryCount:(uint32_t)maxRetryCount {
    _maxRetryCount = maxRetryCount;
    _client.maxRetryCount = maxRetryCount;
}

- (void)setTimeoutIntervalForRequest:(NSTimeInterval)timeoutIntervalForRequest {
    _timeoutIntervalForRequest = timeoutIntervalForRequest;
    _client.timeoutIntervalForRequest = timeoutIntervalForRequest;
}

- (void)setTranscode:(BOOL)transcode {
    _transcode = transcode;
    _client.transcode = transcode;
}

#pragma mark - export

- (BOOL)exportWithTaskPath:(NSString *)taskPath outputPath:(NSString *)outputPath {
    if (![self checkCanExport]) {
        return NO;
    }

    _outputPath = outputPath;
    _editor = [[AliyunEditor alloc] initWithPath:taskPath preview:nil];
    _editor.delegate = self;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [_editor performSelector:@selector(startEditForExport)];
#pragma clang diagnostic pop
    if (_watermark) {
        [_editor setWaterMark:_watermark];
    }
    if (_tailWatermark) {
        [_editor setTailWaterMark:_tailWatermark];
    }
    _requestId = [_editor getRequestId];
    [[_editor getExporter] setCancelExportInResignActive:_cancelExportInResignActive];
    int ret = [[_editor getExporter] startExport:_outputPath];
    if (ret) {
        return NO;
    }
    _isExporting = YES;
    return YES;
}

- (void)cancelExport {
    [[_editor getExporter] cancelExport];
}

- (BOOL)checkCanExport {
    if (!_isExporting && !_isUploading) {
        return YES;
    }
    if (_isExporting) {
        NSLog(@"正在合成视频，无法导出或上传！");
    }
    if (_isUploading) {
        NSLog(@"正在合成视频，无法导出或上传！");
    }
    return NO;
}

#pragma mark - upload

- (BOOL)uploadWithImagePath:(NSString *)imagePath svideoInfo:(AliyunUploadSVideoInfo *)svideoInfo accessKeyId:(NSString *)accessKeyId accessKeySecret:(NSString *)accessKeySecret accessToken:(NSString *)accessToken {
    if (!_outputPath) {
        NSLog(@"合成视频路径不存在，请先合成视频，再上传！");
        return NO;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:_outputPath]) {
        NSLog(@"合成视频文件不存在！");
        return NO;
    }
    if (_requestId) {
        if ([_client respondsToSelector:@selector(setRequestId:)]) {
            [_client performSelector:@selector(setRequestId:) withObject:_requestId];
        }
    }
    VodSVideoInfo *info = [VodSVideoInfo new];
    info.tags = svideoInfo.tags;
    info.title = svideoInfo.title;
    info.desc = svideoInfo.desc;
    info.cateId = svideoInfo.cateId;
    info.isProcess = svideoInfo.isProcess;
    info.isShowWaterMark = svideoInfo.isShowWaterMark;
    info.priority = svideoInfo.priority;
    info.storageLocation = svideoInfo.storageLocation;
    info.templateGroupId = svideoInfo.templateGroupId;

    return [_client uploadWithVideoPath:_outputPath imagePath:imagePath svideoInfo:info accessKeyId:accessKeyId accessKeySecret:accessKeySecret accessToken:accessToken];
}

- (void)refreshWithAccessKeyId:(NSString *)accessKeyId accessKeySecret:(NSString *)accessKeySecret accessToken:(NSString *)accessToken expireTime:(NSString *)expireTime {
    [_client refreshWithAccessKeyId:accessKeyId accessKeySecret:accessKeySecret accessToken:accessToken expireTime:expireTime];
}

- (void)cancelUpload {
    [_client cancel];
}

#pragma mark - export callback

- (void)exportError:(int)errorCode {
    _isExporting = NO;
    [_editor stopEdit];
    _editor = nil;
    [_exportCallback exportError:errorCode];
}
//#define EXPORTTEST
- (void)exporterDidEnd:(NSString *)outputPath {
    // did end
//    NSLog(@"TestLog, %@:%@", @"log_compose_endtime_time", @([NSDate
//    date].timeIntervalSince1970));
#ifdef EXPORTTEST
    double now = [NSDate date].timeIntervalSince1970;
    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:outputPath error:nil] fileSize];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"result" message:[NSString stringWithFormat:@"compose_total_time:%lf  filesize:%lld", (now - publish_start_time), fileSize] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
#endif
    _isExporting = NO;
    [_editor stopEdit];
    _editor = nil;
    if ([_exportCallback respondsToSelector:@selector(exporterDidEnd)]) {
        [_exportCallback exporterDidEnd];
    }
    if ([_exportCallback respondsToSelector:@selector(exporterDidEnd:)]) {
        [_exportCallback exporterDidEnd:outputPath];
    }
}

static double publish_start_time = 0.0;

- (void)exporterDidStart {
    if ([_exportCallback respondsToSelector:@selector(exporterDidStart)]) {
        [_exportCallback exporterDidStart];
    }
}

- (void)exporterDidCancel {
    _isExporting = NO;
    [_editor stopEdit];
    _editor = nil;
    [_exportCallback exporterDidCancel];
}

- (void)exportProgress:(float)progress {
    [_exportCallback exportProgress:progress];
}

#pragma mark - upload callback

- (void)uploadFailedWithCode:(NSString *)code message:(NSString *)message {
    [_uploadCallback uploadFailedWithCode:code message:message];
}

//-(void)uploadSuccessWithVid:(NSString *)vid imageUrl:(NSString *)imageUrl {
//    [_uploadCallback uploadSuccessWithVid:vid imageUrl:imageUrl];
//}

- (void)uploadSuccessWithResult:(VodSVideoUploadResult *)result {
    [_uploadCallback uploadSuccessWithVid:result.videoId imageUrl:result.imageUrl];
}

- (void)uploadTokenExpired {
    [_uploadCallback uploadTokenExpired];
}

- (void)uploadProgressWithUploadedSize:(long long)uploadedSize totalSize:(long long)totalSize {
    [_uploadCallback uploadProgressWithUploadedSize:uploadedSize totalSize:totalSize];
}

- (void)uploadRetry {
    [_uploadCallback uploadRetry];
}

- (void)uploadRetryResume {
    [_uploadCallback uploadRetryResume];
}

#pragma mark - callbacks

- (void)playerDidEnd {
}

- (void)playerDidStart {
}

- (void)playError:(int)errorCode {
}

- (void)seekDidEnd {
}

- (void)playProgress:(double)playSec streamProgress:(double)streamSec {
}

- (int)customRender:(int)srcTexture size:(CGSize)size {
    return srcTexture;
}

@end
