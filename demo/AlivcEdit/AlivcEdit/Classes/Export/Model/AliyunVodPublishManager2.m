//
//  AliyunVodPublishManager2.m
//  AliyunVideoSDKPro
//
//  Created by Worthy Zhang on 2018/12/28.
//  Copyright © 2018 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunVodPublishManager2.h"
#import <AliyunVideoSDKPro/AliyunErrorCode.h>
#import <VODUpload/VODUploadClient.h>

@interface AliyunVodPublishManager2 () <AliyunIPlayerCallback, AliyunIExporterCallback, AliyunIStreamExporterCallback, AliyunIRenderCallback>
@property(nonatomic, strong) VODUploadClient *uploader;
@property(nonatomic, strong) AliyunEditor *editor;

@property(nonatomic, copy) NSString *imageAuth;
@property(nonatomic, copy) NSString *imageAddress;

@property(nonatomic, copy) NSString *videoAuth;
@property(nonatomic, copy) NSString *videoAddress;

@property(atomic, strong) UploadStreamFileInfo *streamFileInfo;

@end

@implementation AliyunVodPublishManager2

- (instancetype)init {
    self = [super init];
    if (self) {
        _uploadPartSize = 1024 * 1024;
        [self setup];
    }
    return self;
}

#define MIN_PART_SIZE 100*1024 // 100KB
- (void) setUploadPartSize:(NSUInteger)uploadPartSize {
    _uploadPartSize = MAX(MIN_PART_SIZE, uploadPartSize);
}

- (void)dealloc {
    [self.editor stopEdit];
    [self.uploader clearFiles];
}

- (void)setup {

    // uploader
    self.uploader = [VODUploadClient new];
    _reportEnabled = YES;

    // weak items
    __weak typeof(self) weakSelf = self;

    // callback functions and listener
    OnUploadFinishedListener testFinishCallbackFunc = ^(UploadFileInfo *fileInfo, VodUploadResult *result) { [weakSelf.uploadCallback publishManagerUploadSuccess:weakSelf]; };

    OnUploadFailedListener testFailedCallbackFunc = ^(UploadFileInfo *fileInfo, NSString *code, NSString *message) { [weakSelf.uploadCallback publishManager:weakSelf uploadFailedWithCode:code message:message]; };

    OnUploadProgressListener testProgressCallbackFunc = ^(UploadFileInfo *fileInfo, long uploadedSize, long totalSize) { [weakSelf.uploadCallback publishManager:weakSelf uploadProgressWithUploadedSize:uploadedSize totalSize:totalSize]; };

    OnUploadTokenExpiredListener testTokenExpiredCallbackFunc = ^{ [weakSelf.uploadCallback publishManagerUploadTokenExpired:weakSelf]; };

    OnUploadRertyListener testRetryCallbackFunc = ^{ [weakSelf.uploadCallback publishManagerUploadRetry:weakSelf]; };

    OnUploadRertyResumeListener testRetryResumeCallbackFunc = ^{ [weakSelf.uploadCallback publishManagerUploadRetryResume:weakSelf]; };

    OnUploadStartedListener testUploadStartedCallbackFunc = ^(UploadFileInfo *fileInfo) {
        if (weakSelf.uploadState == AliyunVodUploadImage) {
            [weakSelf.uploader setUploadAuthAndAddress:fileInfo uploadAuth:weakSelf.imageAuth uploadAddress:weakSelf.imageAddress];
        } else {
            [weakSelf.uploader setUploadAuthAndAddress:fileInfo uploadAuth:weakSelf.videoAuth uploadAddress:weakSelf.videoAddress];
        }
    };

    VODUploadListener *listener = [[VODUploadListener alloc] init];
    listener.finish = testFinishCallbackFunc;
    listener.failure = testFailedCallbackFunc;
    listener.progress = testProgressCallbackFunc;
    listener.expire = testTokenExpiredCallbackFunc;
    listener.retry = testRetryCallbackFunc;
    listener.retryResume = testRetryResumeCallbackFunc;
    listener.started = testUploadStartedCallbackFunc;
    // 点播上传。每次上传都是独立的鉴权，所以初始化时，不需要设置鉴权
    [self.uploader init:listener];
}

- (void)setCustomRenderCallback:(id<AliyunIRenderCallback>)customRenderCallback {
    _customRenderCallback = customRenderCallback;
    self.editor.renderCallback = customRenderCallback;
}

- (void)setReportEnabled:(BOOL)reportEnabled {
    _reportEnabled = reportEnabled;
    [_uploader setReportEnabled:reportEnabled];
}

- (int)exportWithTaskPath:(NSString *)taskPath outputPath:(NSString *)outputPath {
    return [self exportWithTaskPath:taskPath outputPath:outputPath uploadAddress:nil uploadAuth:nil];
}

- (UploadStreamFileInfo *) createDefaultStreamWithFileName:(NSString *)fileName {
    return [[UploadStreamFileInfo alloc] initWithFileName:fileName
                                                 partSize:_uploadPartSize
                                    optimizeFirstPartSize:MIN_PART_SIZE];
}

- (int)exportWithTaskPath:(NSString *)taskPath outputPath:(NSString *)outputPath
            uploadAddress:(NSString *)vodUploadAddress uploadAuth:(NSString *)vodUploadAuth {
    UploadStreamFileInfo *fileInfo = nil;
    if (vodUploadAddress.length > 0 && vodUploadAuth.length > 0) {
        fileInfo = [self createDefaultStreamWithFileName:outputPath.lastPathComponent];
    }

    int ret = [self exportWithTaskPath:taskPath outputPath:outputPath streamFile:fileInfo];
    if (ret) {
        return ret;
    }
    
    if (fileInfo) {
        [self uploadStreamFile:fileInfo uploadAddress:vodUploadAddress uploadAuth:vodUploadAuth];
    }
    return ret;
}

- (int)exportWithTaskPath:(NSString *)taskPath outputPath:(NSString *)outputPath streamFile:(UploadStreamFileInfo *)streamFile {
    self.videotPath = outputPath;
    self.editor = [[AliyunEditor alloc] initWithPath:taskPath preview:nil];
    self.editor.delegate = self;
    self.editor.renderCallback = self.customRenderCallback;
    
    if (streamFile) {
        self.editor.streamExporterCallback = self;
        self.streamFileInfo = streamFile;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [_editor performSelector:@selector(startEditForExport)];
#pragma clang diagnostic pop
    
    int ret = [[self.editor getExporter] startExport:outputPath];
    if (ret) {
        return ret;
    }
    return ret;
}

- (int)uploadStreamFile:(UploadStreamFileInfo *)streamFile
          uploadAddress:(NSString *)vodUploadAddress
             uploadAuth:(NSString *)uploadAuth {
    _videoAuth = uploadAuth;
    _videoAddress = vodUploadAddress;
    [self.uploader addStreamFile:streamFile];
    self.uploadState = AliyunVodUploadVideo;
    BOOL flag = [self.uploader start];
    if (!flag) {
        return ALIVC_SVIDEO_ERROR_UPLOAD_FAILED;
    }
    return 0;
}

- (UploadStreamFileInfo *)exportToStreamFileWithTaskPath:(NSString *)taskPath
                                              outputPath:(NSString *)outputPath
                                                   error:(NSError **)error {
    NSString *fileName = outputPath.lastPathComponent;
    UploadStreamFileInfo *streamFileInfo = [[UploadStreamFileInfo alloc] initWithFileName:fileName
                                                                                 partSize:_uploadPartSize
                                                                    optimizeFirstPartSize:MIN_PART_SIZE];
    int ret = [self exportWithTaskPath:taskPath outputPath:outputPath streamFile:streamFileInfo];
    if (ret) {
        if (error) {
            *error = [NSError errorWithDomain:@"com.aliyun.svideo.export" code:ret userInfo:nil];
        }
        return nil;
    }
    return streamFileInfo;
}

- (int)pauseExport {
    return [[self.editor getExporter] pauseExport];
}

- (int)resumeExport {
    return [[self.editor getExporter] resumeExport];
}

- (int)cancelExport {
    return [[self.editor getExporter] cancelExport];
}

#pragma mark - upload

- (int)uploadImageWithPath:(NSString *)imagePath uploadAddress:(NSString *)uploadAddress uploadAuth:(NSString *)uploadAuth {
    _imageAuth = uploadAuth;
    _imageAddress = uploadAddress;
    [self.uploader addFile:imagePath vodInfo:nil];
    self.uploadState = AliyunVodUploadImage;
    BOOL flag = [self.uploader start];
    if (!flag) {
        return ALIVC_SVIDEO_ERROR_UPLOAD_FAILED;
    }
    return 0;
}

- (int)uploadVideoWithPath:(NSString *)videoPath uploadAddress:(NSString *)uploadAddress uploadAuth:(NSString *)uploadAuth {
    _videoAuth = uploadAuth;
    _videoAddress = uploadAddress;
    [self.uploader addFile:videoPath vodInfo:nil];
    self.uploadState = AliyunVodUploadVideo;
    BOOL flag = [self.uploader start];
    if (!flag) {
        return ALIVC_SVIDEO_ERROR_UPLOAD_FAILED;
    }
    return 0;
}

- (int)pauseUpload {
    BOOL flag = [self.uploader pause];
    if (!flag) {
        return ALIVC_SVIDEO_ERROR_UPLOAD_FAILED;
    }
    return 0;
}

- (int)resumeUpload {
    BOOL flag = [self.uploader resume];
    if (!flag) {
        return ALIVC_SVIDEO_ERROR_UPLOAD_FAILED;
    }
    return 0;
}

- (int)refreshWithUploadAuth:(NSString *)uploadAuth {
    if (self.uploadState == AliyunVodUploadImage) {
        self.imageAuth = uploadAuth;
    } else {
        self.videoAuth = uploadAuth;
    }
    BOOL flag = [_uploader resumeWithAuth:uploadAuth];
    if (!flag) {
        return ALIVC_SVIDEO_ERROR_UPLOAD_FAILED;
    }
    return 0;
}

- (int)cancelUpload {
    [self deleteStreamInfoIfNeed];
    BOOL flag = [_uploader clearFiles];
    if (!flag) {
        return ALIVC_SVIDEO_ERROR_UPLOAD_FAILED;
    }
    return 0;
}

#pragma mark - export delegate

- (void)exporterDidStart {
    if ([self.exportCallback respondsToSelector:@selector(exporterDidStart)]) {
        [self.exportCallback exporterDidStart];
    }
}

- (void)exporterDidEnd:(NSString *)outputPath {
    [self.editor stopEdit];
    self.editor = nil;
    if ([self.exportCallback respondsToSelector:@selector(exporterDidEnd)]) {
        [self.exportCallback exporterDidEnd];
    }
    if ([self.exportCallback respondsToSelector:@selector(exporterDidEnd:)]) {
        [self.exportCallback exporterDidEnd:outputPath];
    }
    [self.streamFileInfo fileComplete];
    self.streamFileInfo = nil;
}

- (void) deleteStreamInfoIfNeed {
    if (!self.streamFileInfo) {
        return;
    }
    
    NSArray *files = self.uploader.listFiles;
    NSUInteger index = [files indexOfObject:self.streamFileInfo];
    [self.uploader deleteFile:index];
    self.streamFileInfo = nil;
}

- (void)exporterDidCancel {
    [self.editor stopEdit];
    self.editor = nil;
    [self.exportCallback exporterDidCancel];
    [self deleteStreamInfoIfNeed];
}

- (void)exportProgress:(float)progress {
    [self.exportCallback exportProgress:progress];
}

- (void)exportError:(int)errorCode {
    [self.exportCallback exportError:errorCode];
    [self deleteStreamInfoIfNeed];
}

// MARK: - AliyunIStreamExporterCallback
- (void) onStreamExporterSeek:(size_t)offset {
    if (!self.streamFileInfo) {
        return;
    }
    
    __weak AliyunVodPublishManager2 *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.streamFileInfo seek:offset];
    });
}

- (void) onStreamExporterWritePacket:(uint8_t *)buffer bufSize:(size_t)bufSize {
    if (!self.streamFileInfo) {
        return;
    }
    
    __weak AliyunVodPublishManager2 *weakSelf = self;
    NSData *data = [NSData dataWithBytes:buffer length:bufSize];
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.streamFileInfo appendBuffer:data];
    });
}

#pragma mark - play delegate

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

@end
