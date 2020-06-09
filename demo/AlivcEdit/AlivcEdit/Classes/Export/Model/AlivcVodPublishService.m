//
//  AlivcVodPublishService.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/5/22.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcVodPublishService.h"
#import "AliyunSVideoApi.h"
#import "AliVideoClientUser.h"

@interface AlivcVodPublishService()<AliyunIVodUploadCallback>
@property(nonatomic, strong) AliyunVodPublishManager *manager;
@property(nonatomic, copy) NSString *videoId;

@end


@implementation AlivcVodPublishService

+ (AlivcVodPublishService *)service{
    static dispatch_once_t onceToken;
    static AlivcVodPublishService *_service = NULL;
    dispatch_once(&onceToken, ^{
        _service = [[AlivcVodPublishService alloc] init];
    });
    return _service;
}

- (AliyunVodPublishManager *)manager{
    if (!_manager) {
        _manager = [AliyunVodPublishManager new];
        _manager.uploadCallback = self;
    }
    return _manager;
}

-(void)setExportCallback:(id<AliyunIExporterCallback>)exportCallback{
    self.manager.exportCallback = exportCallback;
}

- (BOOL)exportWithTaskPath:(NSString *)taskPath outputPath:(NSString *)outputPath{
    return [self.manager exportWithTaskPath:taskPath outputPath:outputPath];
}

- (int)pauseExport{
    return [self.manager pauseExport];
}

- (int)cancelExport{
    return [self.manager cancelExport];
}

- (int)resumeExport{
    return [self.manager resumeExport];
}

- (void)uploadWithImagePath:(NSString *)imagePath withResult:(nullable void (^)(BOOL))result{
    __weak typeof(self)weakSelf = self;
    [AliyunSVideoApi getImageUploadAuthWithToken:[AliVideoClientUser shared].token title:@"DefaultTitle" filePath:imagePath tags:@"DefaultTags" handler:^(NSString * _Nullable uploadAddress, NSString * _Nullable uploadAuth, NSString * _Nullable imageURL, NSString * _Nullable imageId, NSError * _Nullable error) {
       BOOL res = [weakSelf.manager uploadImageWithPath:imagePath uploadAddress:uploadAddress uploadAuth:uploadAuth];
        if (result) {
            result(res);
        }
    }];
}
//目前仅支持单个视频上传
- (void)uploadVideoWithPath:(NSString *)videoPath withCoverImagePath:(NSString *)imagePath withDesc:(NSString *)desc withTag:(NSString *)tag withResultCode:(nullable void (^)(int))result{
    __weak typeof(self)weakSelf = self;
    [AliyunSVideoApi getVideoUploadAuthWithWithToken:[AliVideoClientUser shared].token title:@"DefaultTitle" filePath:videoPath coverURL:imagePath desc:desc tags:tag handler:^(NSString * _Nullable uploadAddress, NSString * _Nullable uploadAuth, NSString * _Nullable videoId, NSError * _Nullable error) {
        weakSelf.videoId = videoId;
        int res = [weakSelf.manager uploadVideoWithPath:videoPath uploadAddress:uploadAddress uploadAuth:uploadAuth];
        if (res == 0) {
            weakSelf.uploadStatus = AlivcVodServiceUploadStatusUploading;
        }
        if (result) {
            result(res);
        }
    }];
}
- (int)pauseUpload{
    if (self.uploadStatus != AlivcVodServiceUploadStatusUploading) {
        return 0;
    }
    int result =[self.manager pauseUpload];
    if (result == 0) {
        self.uploadStatus = AlivcVodServiceUploadStatusPause;
    }
    return result;
}
- (int)cancelUpload{
    if (self.uploadStatus != AlivcVodServiceUploadStatusUploading) {
        return 0;
    }
    int result =[self.manager cancelUpload];
    if (result == 0) {
        self.uploadStatus = AlivcVodServiceUploadStatusDefault;
    }
    return result;
}
- (int)resumeUpload{
    if (self.uploadStatus != AlivcVodServiceUploadStatusPause) {
        return 0;
    }
    int result =[self.manager resumeUpload];
    if (result == 0) {
        self.uploadStatus = AlivcVodServiceUploadStatusUploading;
    }
    return result;
}

-(void)publishManagerUploadTokenExpired:(AliyunVodPublishManager *)manager{
    self.uploadStatus = AlivcVodServiceUploadStatusExpired;
    __weak typeof(self)weakSelf = self;
    [AliyunSVideoApi refreshVideoUploadAuthWithToken:[AliVideoClientUser shared].token videoId:self.videoId handler:^(NSString * _Nullable uploadAddress, NSString * _Nullable uploadAuth, NSError * _Nullable error) {
        int result =[manager refreshWithUploadAuth:uploadAuth];
        if (result == 0) {
            weakSelf.uploadStatus = AlivcVodServiceUploadStatusUploading;
        }
    }];
}

-(void)publishManagerUploadSuccess:(AliyunVodPublishManager *)manager{
    self.uploadStatus = AlivcVodServiceUploadStatusDefault;
    if (self.delegate && [self.delegate respondsToSelector:@selector(uploadSuccessWithUploadType:)]) {
        [self.delegate uploadSuccessWithUploadType:self.uploadType];
    }
}

- (void)publishManager:(AliyunVodPublishManager *)manager uploadFailedWithCode:(NSString *)code message:(NSString *)message{
    self.uploadStatus = AlivcVodServiceUploadStatusDefault;
    if (self.delegate && [self.delegate respondsToSelector:@selector(uploadFailedWithUploadType:withErrorCode:message:)]) {
        [self.delegate uploadFailedWithUploadType:self.uploadType withErrorCode:code message:message];
    }
}

- (void)publishManager:(AliyunVodPublishManager *)manager uploadProgressWithUploadedSize:(long long)uploadedSize totalSize:(long long)totalSize{
    if (self.delegate && [self.delegate respondsToSelector:@selector(uploadProgressWithUploadType:withUploadedSize:totalSize:)]) {
        [self.delegate uploadProgressWithUploadType:self.uploadType withUploadedSize:uploadedSize totalSize:totalSize];
    }
}

@end
