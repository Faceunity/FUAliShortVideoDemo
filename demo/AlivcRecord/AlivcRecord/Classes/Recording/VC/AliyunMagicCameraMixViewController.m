//
//  AliyunMagicCameraMixViewController.m
//  AliyunVideoClient_Entrance
//
//  Created by 孙震 on 2019/5/21.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AliyunMagicCameraMixViewController.h"
//合拍
#import <AliyunVideoSDKPro/AliyunMixRecorder.h> 
#import "AliyunPathManager.h"
#import "MBProgressHUD+AlivcHelper.h"
#import <sys/utsname.h> 

@interface AliyunMagicCameraMixViewController ()<AliyunMixRecorderDelegate>

@property(nonatomic, strong) AliyunMixRecorder *recorder;

@end

@implementation AliyunMagicCameraMixViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isMixedViedo = YES;
    //禁用音乐和切换画幅按钮
    [self hiddenSideBarButtons];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.recorder stopPreview];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated]; 

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}
- (CGFloat)finishButtonEnabledMinDuration {
    return self.quVideo.maxDuration;
}
- (void)mixRecorderComposerDidStart {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}
- (void)mixRecorderComposerOnProgress:(CGFloat)progress {
    NSLog(@"----progress --- %f",progress);
}
- (void)mixRecorderComposerDidError:(int)errorCode{
    NSLog(@"----error --- %d",errorCode);
}
- (void)mixRecorderComposerDidComplete {
    NSLog(@"----完成录制");
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    if ([self respondsToSelector:@selector(recorderDidFinishRecording)]) {
        [self performSelector:@selector(recorderDidFinishRecording)]; 
    }
}

- (NSInteger)partCount {
    return [self.recorder partCount];
}

- (CGFloat)duration {
    return [self.recorder recordDuration];
}

- (void)deletePart {
    [_recorder deleteLastMediaClip];
    
}

- (void)recorder:(AliyunIRecorder *)recorder setMaxDuration:(CGFloat)maxDuration {
    recorder.clipManager.maxDuration = maxDuration;
}
- (CGFloat)maxDuration {
    return [self.recorder recordMaxDuration];
}

- (void)recorder:(AliyunIRecorder *)recorder setMinDuration:(CGFloat)minDuration {
    recorder.clipManager.minDuration = minDuration;
}
- (void)startRetainCameraRotate  {
    
}

- (AliyunMixRecorder *)recorder {
    if (!_recorder) {
        //清除之前生成的录制路径
        NSString *recordDir = [AliyunPathManager createRecrodDir];
        [AliyunPathManager clearDir:recordDir];
        //生成这次的存储路径
        NSString *taskPath = [recordDir stringByAppendingPathComponent:[AliyunPathManager randomString]];
        //视频存储路径
        NSString *videoSavePath = [[taskPath stringByAppendingPathComponent:[AliyunPathManager randomString]] stringByAppendingPathExtension:@"mp4"];
        CGSize outputSize = self.quVideo.outputSize;
        
        
        UIView *outputSizeView = [[UIView alloc] initWithFrame:CGRectMake(0, NoStatusBarSafeTop+44+20, ScreenWidth, 8 * ScreenWidth / 9)];
        [self.view addSubview:outputSizeView];
        
        
        AliyunMixMediaInfoParam *mixMediaInfo = [[AliyunMixMediaInfoParam alloc] init];
        mixMediaInfo.mixVideoFilePath = self.quVideo.sourcePath;
        mixMediaInfo.mixVideoViewFrame = CGRectMake(CGRectGetWidth(outputSizeView.bounds) / 2, 0, CGRectGetWidth(outputSizeView.bounds) / 2, CGRectGetHeight(outputSizeView.bounds));
        
        mixMediaInfo.outputSizeView = outputSizeView;
        
        mixMediaInfo.previewViewFrame = CGRectMake(0, 0, CGRectGetWidth(outputSizeView.bounds) / 2, CGRectGetHeight(outputSizeView.bounds));
        mixMediaInfo.previewVideoSize = CGSizeMake(outputSize.width * 0.5, outputSize.height);
        
        _recorder = [[AliyunMixRecorder alloc] initWithMediaInfo:mixMediaInfo outputSize:self.quVideo.outputSize];
        
         
        _recorder.delegate = self; 
        _recorder.outputType = AliyunIRecorderVideoOutputPixelFormatType420f;//SDK自带人脸识别只支持YUV格式
        _recorder.useFaceDetect = YES;
        _recorder.faceDetectCount = 2;
        _recorder.faceDectectSync = NO;
        if ([self isBelowIphone_8]) {
             _recorder.frontCaptureSessionPreset = AVCaptureSessionPreset640x480;
        } else {
            _recorder.frontCaptureSessionPreset = AVCaptureSessionPreset1280x720;
        }
        _recorder.encodeMode = (self.quVideo.encodeMode == AliyunEncodeModeSoftFFmpeg)?0:1;
        NSLog(@"录制编码方式：%d",_recorder.encodeMode);
        _recorder.GOP = self.quVideo.gop;
        _recorder.videoQuality = (AliyunVideoQuality)self.quVideo.videoQuality;
        _recorder.recordFps = self.quVideo.fps;
        _recorder.outputPath = self.quVideo.outputPath?self.quVideo.outputPath:videoSavePath;
        _recorder.cameraRotate = 0;
        self.quVideo.outputPath = _recorder.outputPath;
        _recorder.beautifyStatus = YES;
        //录制片段设置
        
        [_recorder setRecordMaxDuration:self.quVideo.maxDuration];
        [_recorder setRecordMinDuration:self.quVideo.minDuration];
    }
    return _recorder;
}


- (BOOL)isBelowIphone_8 {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *phoneType = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    NSRange range = [phoneType rangeOfString:@","];
    NSRange range1 = NSMakeRange(6, range.location - 6);
    NSString *subStr = [phoneType substringWithRange:range1];
    int code = [subStr intValue];
    return code <=9;
}

- (void)dealloc
{
    NSLog(@"~~~~~~%s delloc", __PRETTY_FUNCTION__);
    [_recorder stopPreview];
    [_recorder destroyRecorder];
    _recorder = nil; 
}


@end
