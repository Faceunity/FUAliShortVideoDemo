//
//  AlivcShortVideoUploadManager.m
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/11/9.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcShortVideoUploadManager.h"
#import "AliyunMediaConfig.h"
#import "AliyunPublishService.h"
#import "AliyunSVideoApi.h"
#import "AliVideoClientUser.h"
#import <sys/utsname.h>

@interface AlivcShortVideoUploadManager () <AliyunIVodUploadCallback>

@property(nonatomic, copy) NSString *coverImagePath; //封面图路径
@property(nonatomic, copy) NSString *videoPath;  //视频所在路径
@property(nonatomic, copy) AliyunUploadSVideoInfo *videoInfo; //视频信息
@property(nonatomic, assign) AlivcUploadStatus newStatus; //上传状态

@property(nonatomic, copy) NSString *coverImageUrl;  //封面图的URL
@property(nonatomic, copy) NSString *videoId; //视频上传成功之后得到视频id

@end

static AlivcShortVideoUploadManager *_instance = nil;
static AliyunVodPublishManager *_uploadManager = nil;

@implementation AlivcShortVideoUploadManager

#pragma mark - 单例

+ (instancetype)shared {
    if (_instance == nil) {
        
        _instance = [[AlivcShortVideoUploadManager alloc]init];
        _uploadManager = [[AliyunVodPublishManager alloc]init];
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

#pragma mark - 上传

- (void)setCoverImagePath:(NSString *)imagePath videoInfo:(AliyunUploadSVideoInfo *)videoInfo videoPath:(NSString *)videoPath{
    _coverImagePath = imagePath;
    _videoInfo = videoInfo;
    _videoPath = videoPath;
}

- (BOOL)haveUploadSource {
    if (_coverImagePath && _videoInfo) {
        return YES;
    }
    return NO;
}

/**
 开始上传

 */
- (void)startUpload {

    if (![self haveUploadSource]) {
        [self handleUploadFailed];
        return;
    }
    
    _uploadManager.uploadCallback = self;
    if (self.coverImageUrl) {
        //上传视频
        [self startUploadVideo];
    }else{
        //上传图片
        [self startUploadImage];
    }
    _newStatus = AlivcUploadStatusUploading;
    if (_managerDelegate &&
        [_managerDelegate respondsToSelector:@selector(uploadManager:
                                                       uploadStatusChangedTo:)]) {
        [_managerDelegate uploadManager:self
                  uploadStatusChangedTo:AlivcUploadStatusUploading];
    }

}

/**
 对于上传失败的处理 - 代理回调
 */
- (void)handleUploadFailed{
    _newStatus = AlivcUploadStatusFailure;
    if (_managerDelegate && [_managerDelegate respondsToSelector:@selector(uploadManager:uploadStatusChangedTo:)]) {
        [_managerDelegate uploadManager:self uploadStatusChangedTo:AlivcUploadStatusFailure];
    }
}

- (void)cancelUpload {
    _newStatus = AlivcUploadStatusCancel;
    [_uploadManager cancelUpload];
    if (_managerDelegate && [_managerDelegate respondsToSelector:@selector(uploadManager:uploadStatusChangedTo:)]) {
        [_managerDelegate uploadManager:self uploadStatusChangedTo:AlivcUploadStatusCancel];
    }
}

- (AlivcUploadStatus)currentStatus {
    return _newStatus;
}
- (NSString *)coverImagePath {
    return _coverImagePath;
}
- (int)pauseUpload{
    if (self.currentStatus != AlivcUploadStatusUploading) {
        return 0;
    }
    int result =[_uploadManager pauseUpload];
    if (result == 0) {
        _newStatus = AlivcUploadStatusPause;
    }
    return result;
}
- (int)resumeUpload{
    if (self.currentStatus != AlivcUploadStatusPause) {
        return 0;
    }
    int result =[_uploadManager resumeUpload];
    if (result == 0) {
        _newStatus = AlivcUploadStatusUploading;
    }
    return result;
}


#pragma mark - Private Method
/**
 上传封面图
 */
- (void)startUploadImage{
    [AliyunSVideoApi getImageUploadAuthWithToken:[AliVideoClientUser shared].token title:@"DefaultTitle" filePath:self.coverImagePath tags:@"DefaultTags" handler:^(NSString * _Nullable uploadAddress, NSString * _Nullable uploadAuth, NSString * _Nullable imageURL, NSString * _Nullable imageId, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error获取封面凭证:%@", error.description);
            [self handleUploadFailed];
            return;
        }
        self.coverImageUrl = imageURL;
        [_uploadManager uploadImageWithPath:self.coverImagePath uploadAddress:uploadAddress uploadAuth:uploadAuth];
    }];
}

/**
 上传视频
 */
- (void)startUploadVideo{
    _newStatus = AlivcUploadStatusUploading;
    __weak typeof(self)weakSelf = self;
    [AliyunSVideoApi getVideoUploadAuthWithWithToken:[AliVideoClientUser shared].token title:_videoInfo.title filePath:self.videoPath coverURL:self.coverImageUrl desc:_videoInfo.desc tags:_videoInfo.tags handler:^(NSString * _Nullable uploadAddress, NSString * _Nullable uploadAuth, NSString * _Nullable videoId, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error:获取视频凭证%@", error.description);
            weakSelf.newStatus = AlivcUploadStatusFailure;
            [self handleUploadFailed];
            return;
        }
        self.videoId = videoId;
        [_uploadManager uploadVideoWithPath:self.videoPath uploadAddress:uploadAddress uploadAuth:uploadAuth];
    }];
}


- (void)refreshVideo{
    [AliyunSVideoApi refreshVideoUploadAuthWithToken:[AliVideoClientUser shared].token videoId:self.videoId handler:^(NSString * _Nullable uploadAddress, NSString * _Nullable uploadAuth, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error:%@", error.description);
            [self handleUploadFailed];
            return;
        }
        [_uploadManager refreshWithUploadAuth:uploadAuth];
    }];
}



- (NSString *)getDeviceId {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

- (NSString *)getDeviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine
                                                encoding:NSUTF8StringEncoding];
    return deviceString;
}


#pragma mark - AliyunIVodUploadCallback

- (void)publishManagerUploadSuccess:(AliyunVodPublishManager *)manager {
    NSLog(@"upload success");
    if (manager.uploadState == AliyunVodUploadImage) {
        [self startUploadVideo];
    }else {
        NSLog(@"upload success vid:%@, imageurl:%@", self.videoId, self.coverImageUrl);
        _newStatus = AlivcUploadStatusSuccess;
        if (_managerDelegate &&
            [_managerDelegate respondsToSelector:@selector(uploadManager:
                                                           uploadStatusChangedTo:)]) {
            [_managerDelegate uploadManager:self
                      uploadStatusChangedTo:AlivcUploadStatusSuccess];
        }
        if (_managerDelegate && [_managerDelegate respondsToSelector:@selector(uploadManager:succesWithVid:coverImageUrl:)]) {
            [_managerDelegate uploadManager:self succesWithVid:self.videoId coverImageUrl:self.coverImageUrl];
        }
        _videoInfo = nil;
        _coverImagePath = nil;
        _managerDelegate = nil;
        _coverImageUrl = nil;
    }
}

- (void)publishManager:(AliyunVodPublishManager *)manager uploadFailedWithCode:(NSString *)code message:(NSString *)message {
    NSLog(@"upload failed code:%@, message:%@", code, message);
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_newStatus = AlivcUploadStatusFailure;
        if (self->_managerDelegate &&
            [self->_managerDelegate respondsToSelector:@selector(uploadManager:
                                                           uploadStatusChangedTo:)]) {
            [self->_managerDelegate uploadManager:self
                      uploadStatusChangedTo:AlivcUploadStatusFailure];
        }
    });
}

- (void)publishManager:(AliyunVodPublishManager *)manager uploadProgressWithUploadedSize:(long long)uploadedSize totalSize:(long long)totalSize {
    if (manager.uploadState == AliyunVodUploadVideo) {
        if (totalSize) {
            if (_managerDelegate &&
                [_managerDelegate respondsToSelector:@selector(uploadManager:
                                                               updateProgress:)]) {
                CGFloat progressValue = uploadedSize / (double)totalSize;
                [_managerDelegate uploadManager:self updateProgress:progressValue];
            }
        }
    }
}

- (void)publishManagerUploadTokenExpired:(AliyunVodPublishManager *)manager {
    if (manager.uploadState == AliyunVodUploadImage) {
        [self startUploadImage];
    } else {
        if (self.videoId) {
            [self refreshVideo];
        }else{
            [self startUploadVideo];
        }
        
    }
}

- (void)publishManagerUploadRetry:(AliyunVodPublishManager *)manager {
    NSLog(@"上传重试");
}

- (void)publishManagerUploadRetryResume:(AliyunVodPublishManager *)manager {
    NSLog(@"上传继续重试");
}


@end
