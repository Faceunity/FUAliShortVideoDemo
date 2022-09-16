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
#import "UIDevice+AlivcInfo.h"

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
        [AliyunPathManager makeDirExist:recordDir];
        //生成这次的存储路径
        NSString *taskPath = [recordDir stringByAppendingPathComponent:[AliyunPathManager randomString]];
        //视频存储路径
        NSString *videoSavePath = [[taskPath stringByAppendingPathComponent:[AliyunPathManager randomString]] stringByAppendingPathExtension:@"mp4"];
        CGSize outputSize = self.quVideo.outputSize;
        
        
        UIView *outputSizeView = [[UIView alloc] initWithFrame:CGRectMake(0, NoStatusBarSafeTop+44+20, ScreenWidth, 8 * ScreenWidth / 9)];
        [self.view addSubview:outputSizeView];
        
        
        AliyunMixMediaInfoParam *mixMediaInfo = [[AliyunMixMediaInfoParam alloc] init];
        mixMediaInfo.mixVideoFilePath = self.quVideo.sourcePath;
        
        if (self.quVideo.hasVideoBorder || self.quVideo.isMixVideoTopLayer) {
            //如果设置了视频边框 则调整合拍样本视频的窗口大小 和 合拍摄像头采集窗口的大小 以便于展示效果
            CGFloat resolutionRatio = 9.0 / 16.0;
            if (self.quVideo.isMixVideoTopLayer) {
                CGSize videoResoultion = self.quVideo.originalMediaSize;
                resolutionRatio = videoResoultion.width / videoResoultion.height;
            }
            
            CGFloat height = outputSizeView.bounds.size.height * 0.4;
            CGRect frontViewFrame = CGRectMake(20.0, 0, height * resolutionRatio, height);
            frontViewFrame.origin.y = (outputSizeView.bounds.size.height - frontViewFrame.size.height) * 0.5;
            
            AliyunMixMediaVideoInfo *bgInfo;
            AliyunMixMediaVideoInfo *frontInfo;
            
            if (self.quVideo.isMixVideoTopLayer) {
                bgInfo = mixMediaInfo.recordVideoInfo;
                frontInfo = mixMediaInfo.mixVideoInfo;
            } else {
                bgInfo = mixMediaInfo.mixVideoInfo;
                frontInfo = mixMediaInfo.recordVideoInfo;
            }
            
            bgInfo.layerLevel = 1;
            bgInfo.frame = outputSizeView.bounds;
            
            frontInfo.layerLevel = 2;
            frontInfo.frame = frontViewFrame;
            
            CGSize resolution = mixMediaInfo.recordVideoInfo.frame.size;
            mixMediaInfo.recordVideoInfo.resolution = CGSizeMake(resolution.width * 2.0, resolution.height * 2.0);
            
            if (self.quVideo.hasVideoBorder) {
                frontInfo.borderInfo.width = 2.0;
                frontInfo.borderInfo.cornerRadius = 10.0;
                frontInfo.borderInfo.color = UIColor.whiteColor;
            }
            
        }else if (self.quVideo.mixbgImgType>0 || self.quVideo.mixbgColorType>0) {
            //如果设置了合拍背景颜色或合拍背景图片 则调整合拍样本视频的窗口大小 和 合拍摄像头采集窗口的大小 以便于展示效果
            CGFloat preViewWidth = (CGRectGetWidth(outputSizeView.bounds)/2)*0.75;
            CGFloat preViewheight = CGRectGetWidth(outputSizeView.bounds)*0.75;
            
            CGFloat preViewOffsetX = (CGRectGetWidth(outputSizeView.bounds)/2 - preViewWidth)/2;
            
            mixMediaInfo.mixVideoViewFrame = CGRectMake(preViewWidth + 2*preViewOffsetX, 0, preViewWidth, preViewheight);
            
            mixMediaInfo.previewViewFrame = CGRectMake(preViewOffsetX, 0, preViewWidth, preViewheight);
            mixMediaInfo.previewVideoSize = CGSizeMake(outputSize.width * 0.5, outputSize.height);
        }else{
            mixMediaInfo.mixVideoViewFrame = CGRectMake(CGRectGetWidth(outputSizeView.bounds) / 2, 0, CGRectGetWidth(outputSizeView.bounds) / 2, CGRectGetHeight(outputSizeView.bounds));
            
            mixMediaInfo.previewViewFrame = CGRectMake(0, 0, CGRectGetWidth(outputSizeView.bounds) / 2, CGRectGetHeight(outputSizeView.bounds));
            mixMediaInfo.previewVideoSize = CGSizeMake(outputSize.width * 0.5, outputSize.height);
        }
        
        mixMediaInfo.outputSizeView = outputSizeView;
        
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
        _recorder.frontCameraSupportVideoZoomFactor = YES;
        //录制片段设置
        
        [_recorder setRecordMaxDuration:self.quVideo.maxDuration];
        [_recorder setRecordMinDuration:self.quVideo.minDuration];
        
        //设置合成视频使用录制音轨
        [_recorder setMixAudioSource:self.quVideo.mixAudioType];
        
        //设置合拍颜色
        if(self.quVideo.mixbgColorType>0){
            if (self.quVideo.mixbgColorType==1) {
                [_recorder setBackgroundColor:0xff0000];
            }else if (self.quVideo.mixbgColorType==2) {
                [_recorder setBackgroundColor:0x00ff00];
            }
        }
        if (self.quVideo.mixbgImgType>0) {

            NSString *suff = [NSString stringWithFormat:@"mixbgimg%d.png",self.quVideo.mixbgImgType];
            NSString *imgPath = [[NSBundle mainBundle] pathForResource:suff ofType:nil];
            [_recorder setBackgroundImageFilePath:imgPath imageDisplayMode:self.quVideo.mixbgImgScaleType];
        }
        
        //设置硬件回声消除效果
        _recorder.recorderAECType = self.quVideo.mixAECType;
        
    }
    return _recorder;
}


- (BOOL)isBelowIphone_8 {
    int code = [UIDevice iphoneDeviceCode];
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
