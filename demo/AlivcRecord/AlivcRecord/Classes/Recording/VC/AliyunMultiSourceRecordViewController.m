//
//  AliyunMultiSourceRecordViewController.m
//  AlivcRecord
//
//  Created by coder.pi on 2021/5/17.
//

#import "AliyunMultiSourceRecordViewController.h"
#import <AliyunVideoSDKPro/AliyunRecorder.h>
#import <AliyunVideoSDKPro/AliyunVideoSDKInfo.h>
#import <CoreMotion/CoreMotion.h>
// Helper
#import "AlivcDefine.h"
#import "MBProgressHUD+AlivcHelper.h"
#import "AliyunReachability.h"
#import "AliyunResourceManager.h"
#import "AliyunDownloadManager.h"
#import "AliyunPathManager.h"
//view
#import "AlivcRecordNavigationBar.h"
#import "QUProgressView.h"
#import "AlivcRecordBottomView.h"
#import "AlivcRecordTimerLable.h"
#import "AlivcRecordFocusView.h"
#import "AliyunMusicPickViewController.h"
#import "AlivcRecordSliderButtonsView.h"
#import "AlivcRecordDrawView.h"
//美颜
#if SDK_VERSION == SDK_VERSION_CUSTOM
#import "FUDemoManager.h"
#import "AlivcShortVideoRaceManager.h"
#endif
#import "AlivcRecordBeautyView.h"
#import "AlivcWebViewController.h"
//动图
#import <AliyunVideoSDKPro/AliyunHttpClient.h>
#import "AlivcRecordPasterView.h"
#import "AliyunMagicCameraEffectCell.h"
//滤镜
#import "AlivcBottomMenuFilterView.h"
#import "NSString+AlivcHelper.h"

#import "AlivcBottomMenuSpecialFilterView.h"
#import "AliyunEffectMoreViewController.h"
#import "AlivcRegulatorView.h"
#import "AlivcButton.h"
#import "AVAsset+VideoInfo.h"
#import "AlivcImage.h"
#import "AliyunRecordAudioEffectView.h"

@interface AliyunMultiSourceRecordViewController () <
AliyunRecorderDelegate, AliyunRecorderCustomRender,
AlivcRecordNavigationBarDelegate,
AlivcRecordSliderButtonsViewDelegate,
AliyunMusicPickViewControllerDelegate,
AlivcRecordBottomViewDelegate,
AlivcRecordBeautyViewDelegate,
AlivcRecordPasterViewDelegate,
AliyunRecordAudioEffectViewDelegate>
@property (nonatomic, strong) id<AliyunCameraRecordController> cameraController;
@property (nonatomic, strong) id<AliyunViewRecordController> viewRecordController;
@property (nonatomic, strong) id<AliyunAVFileRecordController> mixPlayerController;
@property (nonatomic, strong) AliyunRecorder *recorder;
// helper
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) CMMotionManager *motionManager;   //陀螺仪
//view
@property (nonatomic, strong) UIView *preview;
@property (nonatomic, strong) UIView *previewBgView;
@property (nonatomic, strong) UIView *cameraPreview;
@property (nonatomic, strong) UIView *mixPlayerView;
@property (nonatomic, strong) AlivcRecordDrawView *recordTargetView;
@property (nonatomic, strong) QUProgressView *progressView;                 //进度条
@property (nonatomic, strong) AlivcRecordNavigationBar *navigationBar;      //顶部导航栏
@property (nonatomic, strong) AlivcRecordSliderButtonsView *sliderButtonsView;  //侧边菜单栏
@property (nonatomic, strong) AlivcRecordBottomView *bottomView;        //底部view
@property (nonatomic, strong) UIView *micBottomView;
@property (nonatomic, strong) AlivcRecordTimerLable *timerCountLab;     //倒计时lab
@property (nonatomic, strong) AlivcRecordPasterView *pasterView;        //动图view
@property (nonatomic, strong) AlivcRecordBeautyView *beautyView;        //美颜View
@property (nonatomic, strong) AlivcBottomMenuFilterView *filterView;    //滤镜view
@property (nonatomic, strong) AliyunRecordAudioEffectView *audioEffectView; // 音效view
@property (nonatomic, strong) AlivcBottomMenuSpecialFilterView *specialFilterView;
@property (nonatomic, strong) AlivcRecordFocusView *focusView;          //聚焦框
//data
@property (nonatomic, strong) AliyunDownloadManager *downloadManager;   //下载管理（动图）
@property (nonatomic, strong) AliyunResourceManager *resourceManager;   //资源管理（动图）
@property (nonatomic, strong) NSMutableArray *allPasterInfoArray;       //所有动图资源
@property (nonatomic, strong) AliyunReachability *reachability;         //网络监听
//ViewModel
@property (nonatomic, strong) AliyunRecorderBackgroundInfo *bgInfo;
@property (nonatomic, strong) AliyunRecorderImageSticker *waterMark;
@property (nonatomic, assign) CGSize outputResolution;
@property (nonatomic, assign) CGFloat outputRotation;
@property (nonatomic, readonly) CGRect previewFrame;
@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;
@property (nonatomic, assign) AlivcRecordTorchMode torchMode;
@property (nonatomic, readonly) BOOL hasBgMusic;
@property (nonatomic, assign) NSInteger lastSelectedMusicType;
@property (nonatomic, strong) AliyunMusicPickModel *lastSelectedMusic;
@property (nonatomic, readonly) NSInteger partCount;
@property (nonatomic, readonly) CGFloat duration;
@property (nonatomic, readonly) CGFloat maxDuration;
@property (nonatomic, readonly) CGFloat minDuration;
@property (nonatomic, readonly) BOOL isRecordIdle;
@property (nonatomic, assign) CGFloat pinBeginVideoZoomFactor;
@property (nonatomic, assign) BOOL shouldStartPreviewWhenActive;    //跳转其他页面停止预览，返回开始预览，退后台进入前台则一直在预览。这2种情况通过此变量区别。
@property (nonatomic, assign) BOOL shouldStartPreviewForSetup;
@end

@implementation AliyunMultiSourceRecordViewController

- (void) dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

static CGSize s_fitSizeForVideo(AVAsset *video, CGSize containerSize) {
    CGSize result = containerSize;
    
    CGSize videoSize = video.avAssetNaturalSize;
    CGFloat videoFactor = videoSize.width / videoSize.height;
    CGFloat containerFactor = containerSize.width / containerSize.height;
    
    if (videoFactor < containerFactor) {
        result.width = result.height * videoFactor;
    } else {
        result.height = result.width / videoFactor;
    }
    return result;
}

- (AliyunRecorder *) recorder {
    if (_recorder) {
        return _recorder;
    }
    
    // 输出参数配置
    AliyunRecorderVideoConfig *vConfig = [AliyunRecorderVideoConfig new];
    vConfig.encodeMode = (self.quVideo.encodeMode == AliyunEncodeModeSoftFFmpeg ? AliyunRecorderEncodeMode_SoftCoding : AliyunRecorderEncodeMode_HardCoding);
    vConfig.resolution = _quVideo.outputSize;
    vConfig.videoQuality = (AliyunVideoQuality)_quVideo.videoQuality;
    vConfig.gop = _quVideo.gop;
    vConfig.fps = _quVideo.fps;
    
    self.quVideo.outputPath = self.randomOutputPath;
    
    AliyunRecorderConfig *config = [[AliyunRecorderConfig alloc] initWithVideoConfig:vConfig outputPath:self.quVideo.outputPath usingAEC:self.quVideo.mixAECType];
    config.bgInfo = self.bgInfo;
    [config addWaterMark:self.waterMark];
    
    // 摄像头位置
    AliyunVideoRecordLayoutParam *cameraLayout = [[AliyunVideoRecordLayoutParam alloc] initWithRenderMode:AliyunRenderMode_ResizeAspectFill];
    cameraLayout.size = CGSizeMake(vConfig.resolution.width/3.0, vConfig.resolution.height/4.0);
    cameraLayout.center = CGPointMake(cameraLayout.size.width * 0.75, cameraLayout.size.height * 0.75);
    cameraLayout.zPosition = 2;
    cameraLayout.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    _cameraController = [config addCamera:cameraLayout];
    _cameraController.preview = _cameraPreview;
    _cameraController.isVideoMirror = _quVideo.videoFlipH;
    _cameraController.faceDectectSync = NO;
    if (_quVideo.hasVideoBorder) {
        // 摄像头边框
        AliyunVideoRecordBorderInfo *cameraBorder = [AliyunVideoRecordBorderInfo new];
        cameraBorder.color = UIColor.yellowColor;
        cameraBorder.width = 3.0;
        cameraBorder.cornerRadius = 10.0;
        _cameraController.borderInfo = cameraBorder;
    }
    
    // 合拍视频
    if (_quVideo.needMixVideo) {
        AVAsset *mixAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:self.quVideo.sourcePath]];
        AliyunVideoRecordLayoutParam *mixVideoLayout = [[AliyunVideoRecordLayoutParam alloc] initWithRenderMode:AliyunRenderMode_ResizeAspect];
        CGSize mixVideoContainerSize = cameraLayout.size;
        mixVideoLayout.size = s_fitSizeForVideo(mixAsset, mixVideoContainerSize);
        mixVideoLayout.center = CGPointMake(vConfig.resolution.width - mixVideoContainerSize.width * 0.75, mixVideoContainerSize.height * 0.75);
        mixVideoLayout.zPosition = 2;
        mixVideoLayout.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        AliyunFileRecordSource *avFileSource = [[AliyunFileRecordSource alloc] initWithAVFilePath:self.quVideo.sourcePath
                                                                                        startTime:0
                                                                                         duration:_quVideo.maxDuration];
        _mixPlayerController = [config addAVFileSource:avFileSource layout:mixVideoLayout];
        _mixPlayerController.preview = _mixPlayerView;
//        _mixPlayerController.volume = 10;
        if (_quVideo.hasVideoBorder) {
            // 合拍视频边框
            AliyunVideoRecordBorderInfo *mixBorder = [AliyunVideoRecordBorderInfo new];
            mixBorder.color = UIColor.redColor;
            mixBorder.width = 3.0;
            mixBorder.cornerRadius = 10.0;
            _mixPlayerController.borderInfo = mixBorder;
        }
    }

    // 录制内容配置
    AliyunVideoRecordLayoutParam *viewRecordLayout = [[AliyunVideoRecordLayoutParam alloc] initWithRenderMode:AliyunRenderMode_ResizeAspect];
    if (self.bgInfo) {
        viewRecordLayout.size = CGSizeMake(0.7*vConfig.resolution.width, 0.7*vConfig.resolution.height); // 有背景图的时候留一点边距以展示
    } else {
        viewRecordLayout.size = vConfig.resolution;
    }
    viewRecordLayout.center = CGPointMake(0.5*vConfig.resolution.width, 0.5*vConfig.resolution.height);
    viewRecordLayout.zPosition = 1;
    AliyunViewRecordSource *viewSource = [[AliyunViewRecordSource alloc] initWithTargetView:_recordTargetView fps:vConfig.fps];
    viewSource.captureInBackground = YES;
    _viewRecordController = [config addViewSource:viewSource layout:viewRecordLayout];
    if (self.bgInfo && _quVideo.hasVideoBorder) { // 有背景图时view录制也带上边框以展示
        AliyunVideoRecordBorderInfo *viewBorder = [AliyunVideoRecordBorderInfo new];
        viewBorder.color = UIColor.blueColor;
        viewBorder.width = 5.0;
        viewBorder.cornerRadius = 10.0;
        _viewRecordController.borderInfo = viewBorder;
    }
    
    _recorder = [[AliyunRecorder alloc] initWithConfig:config];
    _recorder.clipManager.minDuration = _quVideo.minDuration;
    _recorder.clipManager.maxDuration = _quVideo.maxDuration;
    _recorder.clipManager.deleteVideoClipsOnExit = _quVideo.deleteVideoClipOnExit;
    _recorder.delegate = self;
    _recorder.customRender = self;
    
    [self updatePreviewFrame];
    return _recorder;
}

// MARK: - AliyunRecorderCustomRender
- (CVPixelBufferRef) onAliyunRecorderCustomRenderToPixelBuffer:(AliyunRecorder *)recorder
                                              withSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    if (self.beautyView.currentBeautyType == AlivcBeautySettingViewStyle_ShortVideo_BeautyFace_Base) {
        return nil;
    }
    
    //queen 高级美颜
    if ([[AlivcShortVideoRoute shared] currentBeautyType] == AlivcBeautyTypeRace) {
        
        //注意这里美颜美型的参数是分开的beautyParams和beautySkinParams
        //美颜参数设置(这里用的是beautyParams)
        CGFloat beautyBuffing = self.beautyView.beautyParams.beautyBuffing/100.0f;
        CGFloat beautyWhite = self.beautyView.beautyParams.beautyWhite/100.0f;
        CGFloat beautySharpen = self.beautyView.beautyParams.beautyRuddy/100.0f; //race中，这个是锐化
        //美型参数设置(这里用的是beautySkinParams)
        CGFloat beautyBigEye = self.beautyView.beautySkinParams.beautyBigEye/100.0f;
        CGFloat beautyThinFace = self.beautyView.beautySkinParams.beautySlimFace/100.0f;
        CGFloat longFace = self.beautyView.beautySkinParams.longFace/100.0f;
        CGFloat cutFace = self.beautyView.beautySkinParams.cutFace/100.0f;
        CGFloat lowerJaw = self.beautyView.beautySkinParams.lowerJaw/100.0f;
        CGFloat mouthWidth = self.beautyView.beautySkinParams.mouthWidth/100.0f;
        CGFloat thinNose = self.beautyView.beautySkinParams.thinNose/100.0f;
        CGFloat thinMandible = self.beautyView.beautySkinParams.thinMandible/100.0f;
        CGFloat cutCheek = self.beautyView.beautySkinParams.cutCheek/100.0f;
        CVPixelBufferRef buf = [[AlivcShortVideoRaceManager shareManager] customRenderWithBuffer:sampleBuffer rotate:0  skinBuffing:beautyBuffing skinWhitening:beautyWhite sharpen:beautySharpen bigEye:beautyBigEye longFace:longFace cutFace:cutFace thinFace:beautyThinFace lowerJaw:lowerJaw mouthWidth:mouthWidth thinNose:thinNose thinMandible:thinMandible cutCheek:cutCheek];
        
        return buf;
        
    } else {
        
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        [[FUDemoManager shared] checkAITrackedResult];
        if ([FUDemoManager shared].shouldRender) {
            [[FUTestRecorder shareRecorder] processFrameWithLog];
            [FUDemoManager updateBeautyBlurEffect];
            FURenderInput *input = [[FURenderInput alloc] init];
            input.renderConfig.imageOrientation = FUImageOrientationUP;
            input.pixelBuffer = pixelBuffer;
            //开启重力感应，内部会自动计算正确方向，设置fuSetDefaultRotationMode，无须外面设置
            input.renderConfig.gravityEnable = YES;
            FURenderOutput *output = [[FURenderKit shareRenderKit] renderWithInput:input];
            if (output) {
                return output.pixelBuffer;
            }
        } else {
            return pixelBuffer;
        }
        
        return pixelBuffer;

    }
 
}


- (void) onAliyunRecorderDidDestory:(AliyunRecorder *)recorder
{
    if ([[AlivcShortVideoRoute shared] currentBeautyType] == AlivcBeautyTypeRace) {
        [[AlivcShortVideoRaceManager shareManager] clear];
    }else {
        [FUDemoManager destory];
    }
}

// MARK: - AliyunRecorderDelegate
- (void) onAliyunRecorder:(AliyunRecorder *)recorder stateDidChange:(AliyunRecorderState)state
{
    if (state == AliyunRecorderState_Recording)
    {
        _quVideo.videoRotate = self.recorder.config.videoConfig.rotate;
    }
    
    [self updatePartCount];
    [self.bottomView updateRecorderUI];
    [self updateForLoading];
    [self.sliderButtonsView setMusicButtonEnabled:self.isRecordIdle];
}

- (void) onAliyunRecorder:(AliyunRecorder *)recorder previewStateDidChange:(BOOL)isPreviewing
{
}

- (void) onAliyunRecorder:(AliyunRecorder *)recorder progressWithDuration:(CGFloat)duration
{
    [self updatePartCount];
    [self.progressView updateProgress:duration];
    [self.bottomView refreshRecorderVideoDuration:duration];
    [self.navigationBar setFinishButtonEnabled:duration > self.minDuration];
    [self.navigationBar setTimerButtonEnabled:duration < self.maxDuration];
}

- (void) onAliyunRecorder:(AliyunRecorder *)recorder occursError:(NSError *)error
{
    NSAssert(NO, @"发生错误了！");
}

// MARK: - Data
- (NSMutableArray *)allPasterInfoArray{
    if (!_allPasterInfoArray) {
        _allPasterInfoArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _allPasterInfoArray;
}
- (AliyunDownloadManager *)downloadManager{
    if (!_downloadManager) {
        _downloadManager = [[AliyunDownloadManager alloc] init];
    }
    return _downloadManager;
}
- (AliyunResourceManager *)resourceManager{
    if (!_resourceManager) {
        _resourceManager = [[AliyunResourceManager alloc] init];
    }
    return _resourceManager;
}

- (void)fetchData
{
    [self.allPasterInfoArray removeAllObjects];
    AliyunHttpClient *httpClient = [[AliyunHttpClient alloc] initWithBaseUrl:kAlivcQuUrlString];
    NSDictionary *param = @{@"type":@(1)};
    __weak typeof(self)weakSelf = self;
    [httpClient GET:@"resource/getFrontPasterList" parameters:param completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        AliyunMultiSourceRecordViewController *strongSelf = weakSelf;
        if (error) {
            NSArray *groups = [strongSelf loadLocalData];
            if (strongSelf.allPasterInfoArray.count>0) {
                [strongSelf.allPasterInfoArray removeAllObjects];
            }
            if (groups.count > 0) {
                for (AliyunPasterInfoGroup *pasterInfoGroup in groups) {
                    [strongSelf.allPasterInfoArray addObjectsFromArray:pasterInfoGroup.pasterList];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.pasterView refreshUIWithGifItems:weakSelf.allPasterInfoArray];
            });
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *pastList = responseObject[@"data"];
            for (NSDictionary *dict in pastList) {
                AliyunPasterInfo *info = [[AliyunPasterInfo alloc] initWithDict:dict];
                [strongSelf.allPasterInfoArray addObject:info];
            }
            [strongSelf.pasterView refreshUIWithGifItems:weakSelf.allPasterInfoArray];
        });
    }];
}
//本地的动图资源
- (NSArray *)loadLocalData
{
    return [self.resourceManager loadLocalFacePasters];
}

// 下载
- (void)startNetworkReachability{
    //网络状态判定
    _reachability = [AliyunReachability reachabilityForInternetConnection];
    [_reachability startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged)
                                                 name:AliyunSVReachabilityChangedNotification
                                               object:nil];
}

//网络状态判定
- (void)reachabilityChanged{
    AliyunSVNetworkStatus status = [self.reachability currentReachabilityStatus];
    if (status != AliyunSVNetworkStatusNotReachable && self.allPasterInfoArray.count == 0) {
        [self fetchData];
    }
}

// MARK: - Actions
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    [MBProgressHUD showMessage:NSLocalizedString(@"已保存到手机相册", nil) inView:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void) finishRecordForEdit
{
    MBProgressHUD *loading = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
    //停止预览
    [self.recorder stopPreview];
    self.shouldStartPreviewWhenActive = YES;
    
    __weak typeof(self) weakSelf = self;
    [self.recorder finishRecordForEdit:^(NSString *taskPath, NSError *error) {
        [loading hideAnimated:YES];
        
        AliyunMultiSourceRecordViewController *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"转换到编辑错误：%@", error.description];
            [MBProgressHUD showMessage:msg inView:strongSelf.view];
            return;
        }
        
        [AlivcShortVideoRoute.shared registerEditVideoPath:nil];
        [AlivcShortVideoRoute.shared registerEditMediasPath:taskPath];
        [AlivcShortVideoRoute.shared registerMediaConfig:strongSelf.quVideo];
        
        [AlivcShortVideoRoute.shared registerHasRecordMusic:strongSelf.hasBgMusic];
        
        UIViewController *editVC = [[AlivcShortVideoRoute shared]alivcViewControllerWithType:AlivcViewControlEdit];
        if (editVC) {
            // 先退到主页
//            [self.navigationController popToRootViewControllerAnimated:YES];
            // 再添加editVC
            [self.navigationController pushViewController:editVC animated:YES];
        }
    }];
}

- (void) finishRecord
{
    MBProgressHUD *loading = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //停止预览
    [self.recorder stopPreview];
    self.shouldStartPreviewWhenActive = YES;
    
    __weak typeof(self) weakSelf = self;
    [self.recorder finishRecord:^(NSString *outputPath, NSError *error) {
        [loading hideAnimated:YES];
        
        AliyunMultiSourceRecordViewController *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        if (error) {
            NSString *msg = [NSString stringWithFormat:@"保存错误：%@", error.description];
            [MBProgressHUD showMessage:msg inView:strongSelf.view];
            return;
        }
        
        if (strongSelf.finishBlock) {
            strongSelf.finishBlock(outputPath);
        } else {
            if (isRace) {
                UISaveVideoAtPathToSavedPhotosAlbum(outputPath, strongSelf, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                return;
            }
            
            [AlivcShortVideoRoute.shared registerEditVideoPath:outputPath];
            [AlivcShortVideoRoute.shared registerEditMediasPath:nil];
            [AlivcShortVideoRoute.shared registerMediaConfig:strongSelf.quVideo];
            
            [AlivcShortVideoRoute.shared registerHasRecordMusic:strongSelf.hasBgMusic];
            
            UIViewController *editVC = [[AlivcShortVideoRoute shared]alivcViewControllerWithType:AlivcViewControlEdit];
            if (editVC) {
                // 先退到主页
//                [self.navigationController popToRootViewControllerAnimated:NO];
                // 再添加editVC
                [self.navigationController pushViewController:editVC animated:YES];
            }else{
                UISaveVideoAtPathToSavedPhotosAlbum(outputPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            }
        }
    }];
}

// 拍照
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [MBProgressHUD showMessage:@"图片已保存到相册中" inView:self.view];
}

- (void) takePhoto
{
    __weak typeof(self) weakSelf = self;
    [_cameraController takePhoto:^(UIImage *image, UIImage *rawImage) {
        AliyunMultiSourceRecordViewController *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        if (!image && !rawImage) {
            [MBProgressHUD showMessage:@"拍照失败" inView:strongSelf.view];
            return;
        }

        if (image) {
            UIImageWriteToSavedPhotosAlbum(image, strongSelf, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)strongSelf);
        } else {
            [MBProgressHUD showMessage:@"获取渲染结果失败" inView:strongSelf.view];
        }

        if (rawImage) {
            UIImageWriteToSavedPhotosAlbum(rawImage, strongSelf, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)strongSelf);
        } else {
            [MBProgressHUD showMessage:@"获取原始图片失败" inView:strongSelf.view];
        }
    }];
}

// 切画幅
- (void)switchRatio
{
    [self.sliderButtonsView setSwitchRationButtonEnabled:NO];
    CGSize resolution = self.outputResolution;
    
    switch (_quVideo.mediaRatio) {
        case AliyunMediaRatio9To16: // switch to AliyunMediaRatio3To4
            self.outputResolution = CGSizeMake(resolution.width, resolution.width * 4.0 / 3.0);
            break;
        case AliyunMediaRatio3To4: // switch to AliyunMediaRatio1To1
            self.outputResolution = CGSizeMake(resolution.width, resolution.width);
            break;
        case AliyunMediaRatio1To1: // switch to AliyunMediaRatio9To16
            self.outputResolution = CGSizeMake(resolution.width, resolution.width * 16.0 / 9.0);
            break;
        default:break;
    }
    
    [self.recorder cancel];
    [self.recorder startPreview];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self updatePreviewFrame];
    } completion:^(BOOL finished) {
        [self.sliderButtonsView setSwitchRationButtonEnabled:self.isRecordIdle];
    }];
}

// 背景音乐
- (void) pickBgMusic
{
    AliyunMusicPickViewController *vc = [[AliyunMusicPickViewController alloc] init];
    vc.delegate = self;
    vc.duration = _quVideo.maxDuration;
    [vc setSelectedMusic:_lastSelectedMusic type:_lastSelectedMusicType];
    [self.recorder stopPreview];
    self.shouldStartPreviewWhenActive = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

// 人脸贴图
- (void) deleteCurrentEffectPaster
{
    [_cameraController deleteFaceSticker];
}

- (void) addEffectWithPasterInfo:(AliyunPasterInfo *)info path:(NSString *)path
{
    if(self.recorder.isRecording){
        NSLog(@"动图测试:添加动图：录制中，不添加");
        return;
    }
    
    if (![NSFileManager.defaultManager fileExistsAtPath:path]) {
        NSLog(@"动图测试：动图不存在！");
        return;
    }
    
    [self deleteCurrentEffectPaster];
    [_cameraController applyFaceSticker:path];
    [_pasterView refreshUIWhenThePasterInfoApplyedWithPasterInfo:info];
    
    //如果不存在icon 自行拉取icon图片
    if (![NSFileManager.defaultManager fileExistsAtPath:[path stringByAppendingPathComponent:@"icon.png"]]) {
        [self saveImage:info.icon path:path];
    }
}

// 手势
- (void)addGesture
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToFocusPoint:)];
    [_cameraPreview addGestureRecognizer:tapGesture];
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [_cameraPreview addGestureRecognizer:pinchGesture];
    
    if (_mixPlayerView) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToFocusPoint:)];
        [_mixPlayerView addGestureRecognizer:tapGesture];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        [_mixPlayerView addGestureRecognizer:panGesture];
    }
}
//点按手势的触发方法
- (void)tapToFocusPoint:(UITapGestureRecognizer *)tapGesture {
    UIView *tapView = tapGesture.view;
    if (tapView == _cameraPreview) {
        CGPoint point = [tapGesture locationInView:tapView];
        self.focusView.center = point;
        CGSize viewSize = tapView.bounds.size;
        CGPoint normalizedPoint = CGPointMake(point.x / viewSize.width, point.y / viewSize.height);
        [_cameraController.camera adjustForceWithNormalizedPoint:normalizedPoint];
        [_cameraPreview bringSubviewToFront:self.focusView];
    } else if (tapView == _mixPlayerView) {
        if (_mixPlayerController.isRunning) {
            [_mixPlayerController stop];
        } else {
            [_mixPlayerController start];
        }
    }
}
- (void) panGesture:(UIPanGestureRecognizer *)panGesture {
    CGPoint translatedPoint = [panGesture translationInView:_mixPlayerView];
    _mixPlayerController.volume -= translatedPoint.y;
    [panGesture setTranslation:CGPointZero inView:_mixPlayerView];
    
    UILabel *volumeLabel = [_mixPlayerView viewWithTag:666];
    if (!volumeLabel) {
        volumeLabel = [[UILabel alloc] initWithFrame:_mixPlayerView.bounds];
        volumeLabel.tag = 666;
        volumeLabel.font = [UIFont systemFontOfSize:30];
        volumeLabel.textAlignment = NSTextAlignmentCenter;
        volumeLabel.textColor = UIColor.whiteColor;
        [_mixPlayerView addSubview:volumeLabel];
    }
    volumeLabel.text = @(_mixPlayerController.volume).stringValue;
    volumeLabel.alpha = 1.0;
    [UIView animateWithDuration:0.5 animations:^{
        volumeLabel.alpha = 0.0;
    }];
}
//捏合手势的触发方法
- (void)pinchGesture:(UIPinchGestureRecognizer *)pinchGesture {
    if (isnan(pinchGesture.velocity) || pinchGesture.numberOfTouches != 2) {
        return;
    }
    
    if (pinchGesture.state == UIGestureRecognizerStateBegan) {
        _pinBeginVideoZoomFactor = _cameraController.camera.videoZoomFactor;
    }
    _cameraController.camera.videoZoomFactor = _pinBeginVideoZoomFactor * pinchGesture.scale;
}

// MARK: - ViewModel
- (AliyunRecorderBackgroundInfo *) bgInfo
{
    if (_quVideo.mixbgColorType == 0 && _quVideo.mixbgImgType == 0) {
        return nil;
    }
    
    if (!_bgInfo) {
        _bgInfo = [AliyunRecorderBackgroundInfo new];
        if (_quVideo.mixbgColorType == 1) {
            _bgInfo.color = UIColor.redColor;
        } else if (_quVideo.mixbgColorType == 2) {
            _bgInfo.color = UIColor.greenColor;
        }
        
        if (_quVideo.mixbgImgType > 0) {
            NSString *imgName = [NSString stringWithFormat:@"mixbgimg%d.png",self.quVideo.mixbgImgType];
            _bgInfo.image = [UIImage imageNamed:imgName];
            if (_quVideo.mixbgImgScaleType == AliyunMixVideoBackgroundImageModeScaleAspectFill) {
                _bgInfo.renderMode = AliyunRenderMode_ResizeAspectFill;
            } else if (_quVideo.mixbgImgScaleType == AliyunMixVideoBackgroundImageModeScaleAspectFit) {
                _bgInfo.renderMode = AliyunRenderMode_ResizeAspect;
            } else if (_quVideo.mixbgImgScaleType == AliyunMixVideoBackgroundImageModeScaleToFill) {
                _bgInfo.renderMode = AliyunRenderMode_Resize;
            }
        }
    }
    return _bgInfo;
}

- (AliyunRecorderImageSticker *) waterMark
{
    if (!_waterMark) {
        NSString *watermarkPath = [AlivcImage pathOfImageName:@"watermark.png"];
        _waterMark = [[AliyunRecorderImageSticker alloc] initWithImagePath:watermarkPath];
        _waterMark.size = CGSizeMake(42, 30);
        _waterMark.center = CGPointMake(_waterMark.size.width * 0.5 + 4, _waterMark.size.height * 0.5 + 4);
        _waterMark.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    return _waterMark;
}

- (CGFloat) outputRotation { return _recorder.config.videoConfig.rotate; }
- (void) setOutputRotation:(CGFloat)outputRotation
{
    if (!self.isRecordIdle) {
        return;
    }
    
    _recorder.config.videoConfig.rotate = outputRotation;
}

- (CGSize) outputResolution
{
    if (_recorder) {
        return _recorder.config.videoConfig.resolution;
    }
    return _quVideo.outputSize;
}
- (void) setOutputResolution:(CGSize)outputResolution
{
    if (!self.isRecordIdle) {
        return;
    }
    
    if (CGSizeEqualToSize(outputResolution, self.outputResolution)) {
        return;
    }

    _quVideo.outputSize = outputResolution;
    _recorder.config.videoConfig.resolution = outputResolution;
}

- (CGRect) previewFrame
{
    CGSize resolution = self.outputResolution;
    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    CGRect frame = UIScreen.mainScreen.bounds;

    CGFloat targetRatio = resolution.width / resolution.height;
    CGFloat screenRatio = screenSize.width / screenSize.height;
    if (targetRatio < screenRatio) {
        frame.size.width = frame.size.height * targetRatio;
        frame.origin.x = (screenSize.width - frame.size.width) * 0.5;
    } else {
        frame.size.height = frame.size.width / targetRatio;
        frame.origin.y = (screenSize.height - frame.size.height) * 0.5;
        const CGFloat kTopSpace = NoStatusBarSafeTop + 44 + 10;
        if (frame.origin.y * 2 > kTopSpace) {
            frame.origin.y = kTopSpace;
        }
    }
    return frame;
}

- (void) setTorchMode:(AlivcRecordTorchMode)torchMode
{
    if (_torchMode == torchMode) {
        return;
    }
    _torchMode = torchMode;
    [self.navigationBar setTorchButtonImageWithMode:torchMode];
    if (torchMode == AlivcRecordTorchModeOn) {
        _cameraController.camera.torchMode = AVCaptureTorchModeOn;
    } else if (torchMode == AlivcRecordTorchModeOff) {
        _cameraController.camera.torchMode = AVCaptureTorchModeOff;
    } else if (torchMode == AlivcRecordTorchModeAuto) {
        _cameraController.camera.torchMode = AVCaptureTorchModeAuto;
    }
}

- (void) setCameraPosition:(AVCaptureDevicePosition)cameraPosition
{
    if (_cameraPosition == cameraPosition) {
        return;
    }
    
    _cameraPosition = cameraPosition;
    _cameraController.camera.position = cameraPosition;
    if (cameraPosition == AVCaptureDevicePositionFront) {
        self.torchMode = AlivcRecordTorchModeDisabled;
    } else {
        self.torchMode = AlivcRecordTorchModeAuto;
    }
}

- (BOOL) hasBgMusic { return self.lastSelectedMusic && [self.lastSelectedMusic.name isEqualToString:NSLocalizedString(@"无音乐" , nil)]; }
- (NSInteger) partCount { return self.recorder.clipManager.partCount; }
- (CGFloat) duration { return self.recorder.clipManager.duration; }
- (CGFloat) maxDuration { return self.recorder.clipManager.maxDuration; }
- (CGFloat) minDuration { return self.recorder.clipManager.minDuration; }
- (BOOL) isRecordIdle { return self.recorder.state == AliyunRecorderState_Idle; }

// MARK: - View update
- (void) updatePreviewFrame
{
    self.preview.frame = self.previewFrame;
    self.previewBgView.frame = self.preview.bounds;
    
    CGSize size = self.preview.bounds.size;
    CGSize resolution = self.recorder.config.videoConfig.resolution;
    CGSize scale = CGSizeMake(size.width/resolution.width, size.height/resolution.height);

    CGSize layoutSize = CGSizeZero;
    CGPoint layoutCenter = CGPointZero;
    CGRect frame = CGRectZero;
    layoutSize = _cameraController.layoutParam.size;
    layoutCenter = _cameraController.layoutParam.center;
    frame.size = CGSizeMake(layoutSize.width * scale.width, layoutSize.height * scale.height);
    _cameraPreview.frame = frame;
    _cameraPreview.center = CGPointMake(layoutCenter.x * scale.width, layoutCenter.y * scale.height);
    
    if (_quVideo.needMixVideo) {
        layoutSize = _mixPlayerController.layoutParam.size;
        layoutCenter = _mixPlayerController.layoutParam.center;
        frame.size = CGSizeMake(layoutSize.width * scale.width, layoutSize.height * scale.height);
        _mixPlayerView.frame = frame;
        _mixPlayerView.center = CGPointMake(layoutCenter.x * scale.width, layoutCenter.y * scale.height);
    }
    

    layoutSize = _viewRecordController.layoutParam.size;
    layoutCenter = _viewRecordController.layoutParam.center;
    frame.size = CGSizeMake(layoutSize.width * scale.width, layoutSize.height * scale.height);
    _recordTargetView.frame = frame;
    _recordTargetView.center = CGPointMake(layoutCenter.x * scale.width, layoutCenter.y * scale.height);
}

- (void) updatePartCount
{
    self.progressView.videoCount = self.partCount;
    [self.bottomView updateViewsWithVideoPartCount:self.partCount];
}

- (void) updateForLoading
{
    BOOL isLoading = (self.recorder.isRecording || self.timerCountLab.isTiming);
    
    _navigationBar.hidden = isLoading;
    _sliderButtonsView.hidden = isLoading;
    _bottomView.hidden = self.timerCountLab.isTiming;
    _micBottomView.hidden = isLoading;
}

// MARK: - View
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //VC布局
    [self setupSubviews];
    //开始预览
    self.shouldStartPreviewForSetup = YES;
    self.shouldStartPreviewWhenActive = NO;
    //设置默认美颜状态
    [self alivcRecordBeautyDidChangeBeautyType:self.beautyView.currentBeautyType];
    //添加手势
    [self addGesture];
    //开启网络监听
    [self startNetworkReachability];
    //默认值设置
    self.torchMode = AlivcRecordTorchModeOff;
    self.cameraPosition = AVCaptureDevicePositionFront;
    
//    [AliyunVideoSDKInfo setLogLevel:AlivcLogDebug];
}


- (void) setupPreview
{
    _preview = [[UIView alloc] initWithFrame:self.previewFrame];
    _preview.backgroundColor = UIColor.clearColor;
    [self.view addSubview:_preview];
    
    AliyunRecorderBackgroundInfo *bgInfo = self.bgInfo;
    if (bgInfo) {
        _previewBgView = [[UIView alloc] initWithFrame:_preview.bounds];
        [_preview addSubview:_previewBgView];
        
        if (bgInfo.color) {
            _previewBgView.backgroundColor = bgInfo.color;
        } else {
            _previewBgView.backgroundColor = UIColor.blackColor;
        }
        if (bgInfo.image) {
            _previewBgView.layer.contents = (__bridge id)bgInfo.image.CGImage;
            if (bgInfo.renderMode == AliyunRenderMode_ResizeAspect) {
                _previewBgView.layer.contentsGravity = kCAGravityResizeAspect;
            } else if (bgInfo.renderMode == AliyunRenderMode_ResizeAspectFill) {
                _previewBgView.layer.contentsGravity = kCAGravityResizeAspectFill;
            } else if (bgInfo.renderMode == AliyunRenderMode_Resize) {
                _previewBgView.layer.contentsGravity = kCAGravityResize;
            }
        }
    }
    
    _recordTargetView = [[AlivcRecordDrawView alloc] initWithFrame:_preview.bounds];
    [_preview addSubview:_recordTargetView];

    _cameraPreview = [[UIView alloc] initWithFrame:_preview.bounds];
    [_preview addSubview:_cameraPreview];
    
    if (_quVideo.needMixVideo) {
        _mixPlayerView = [[UIView alloc] initWithFrame:_preview.bounds];
        _mixPlayerView.backgroundColor = UIColor.clearColor;
        [_preview addSubview:_mixPlayerView];
    }
}

- (void) setupSubviews
{
    if (!_uiConfig) {
        _uiConfig =[[AlivcRecordUIConfig alloc]init];
    }
    
    self.view.backgroundColor = _uiConfig.backgroundColor;
    //添加倒计时lab
    [self.view addSubview:self.timerCountLab];
    //添加预览view
    [self setupPreview];
    //添加顶部录制进度条
    [self.view addSubview:self.progressView];
    //添加顶部导航条
    _navigationBar =[[AlivcRecordNavigationBar alloc] initWithUIConfig:_uiConfig];
    _navigationBar.delegate =self;
    [self.view addSubview:_navigationBar];
    //添加右侧菜单栏
    [self.view addSubview:self.sliderButtonsView];
    //添加底部view
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.micBottomView];

    //提前加载好美颜view，防止在异步线程里惰性加载view
    [self beautyView];
}

- (QUProgressView *)progressView{
    if (!_progressView) {
        _progressView =[[QUProgressView alloc] initWithFrame:CGRectMake(8, NoStatusBarSafeTop+4, ScreenWidth-16, 4)];
        _progressView.showBlink = NO;
        _progressView.showNoticePoint = YES;
        _progressView.layer.cornerRadius = CGRectGetHeight(_progressView.frame)/2;
        _progressView.layer.masksToBounds =YES;
        _progressView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.34];
        _progressView.colorProgress = [UIColor colorWithHexString:@"0xFC4448"];
        _progressView.maxDuration = self.maxDuration;
        _progressView.minDuration = self.minDuration;
    }
    return _progressView;
}
- (AlivcRecordBottomView *)bottomView{
    if (!_bottomView) {
        _bottomView =[[AlivcRecordBottomView alloc] initWithFrame:CGRectMake(0, ScreenHeight-185-SafeBottom, ScreenWidth, 200) withUIConfig:self.uiConfig];
        _bottomView.delegate =self;
    }
    return _bottomView;
}
- (AlivcRecordSliderButtonsView *)sliderButtonsView{
    if (!_sliderButtonsView) {
        _sliderButtonsView =[[AlivcRecordSliderButtonsView alloc] initWithFrame:CGRectMake(ScreenWidth - 52 -10, CGRectGetMaxY(self.navigationBar.frame)+40, 52, 350)];
        _sliderButtonsView.delegate = self;
    }
    return _sliderButtonsView;
}
- (UILabel *)timerCountLab{
    if (!_timerCountLab) {
        _timerCountLab =[[AlivcRecordTimerLable alloc]initWithFrame:self.view.bounds];
    }
    return _timerCountLab;
}
- (AlivcRecordBeautyView *)beautyView{
    if (!_beautyView) {
        AlivcBottomMenuHeaderViewItem *item1 =[AlivcBottomMenuHeaderViewItem createItemWithTitle:[@"美颜" localString] icon:[AlivcImage imageNamed:@"AlivcIconBeauty"] tag:1];
        AlivcBottomMenuHeaderViewItem *item2 =[AlivcBottomMenuHeaderViewItem createItemWithTitle:[@"美型" localString] icon:[AlivcImage imageNamed:@"shortVideo_beautySkin"] tag:2]; //fu的美型
        
        AlivcBottomMenuHeaderViewItem *item3 =[AlivcBottomMenuHeaderViewItem createItemWithTitle:[@"美型" localString] icon:[AlivcImage imageNamed:@"shortVideo_beautySkin"] tag:3];  //race的美型
        NSArray *items;
        if ([[AlivcShortVideoRoute shared] currentBeautyType] == AlivcBeautyTypeFaceUnity) {
            items =@[item1,item2];
        }else {
            items =@[item1,item3];
        }
        CGFloat safeTop = 78;
        _beautyView =[[AlivcRecordBeautyView alloc]initWithFrame:CGRectMake(0, ScreenHeight-200-safeTop, ScreenWidth, 200+safeTop) withItems:items];
        _beautyView.safeTop = safeTop;
        _beautyView.showHeaderViewSelectedFlag = YES;
        _beautyView.delegate = self;
        if ([[AlivcShortVideoRoute shared] currentBeautyType] == AlivcBeautyTypeFaceUnity) {
            [_beautyView setLevelViewTitle:@"faceunity"];
        }else {
            [_beautyView setLevelViewTitle:@"race"];
        }
        [self.view addSubview:_beautyView];
    }
    return _beautyView;
}
- (AlivcRecordPasterView *)pasterView{
    if (!_pasterView) {
        AlivcBottomMenuHeaderViewItem *item1 =[AlivcBottomMenuHeaderViewItem createItemWithTitle:[@"人脸贴纸" localString] icon:[AlivcImage imageNamed:@"shortVideo_paster_gif"] tag:1];
        _pasterView = [[AlivcRecordPasterView alloc]initWithFrame:CGRectMake(0, ScreenHeight-200, ScreenWidth, 200) withItems:@[item1]];
        _pasterView.delegate = self;
        [self.view addSubview:_pasterView];
        [self fetchData];
    }
    return _pasterView;
}


- (AlivcBottomMenuFilterView *)filterView{
    if (!_filterView) {
        AlivcBottomMenuHeaderViewItem *item1 =[AlivcBottomMenuHeaderViewItem createItemWithTitle:[@"滤镜" localString] icon:[AlivcImage imageNamed:@"alivc_svEdit_filter"] tag:1];
        _filterView = [[AlivcBottomMenuFilterView alloc]initWithFrame:CGRectMake(0, ScreenHeight-200, ScreenWidth, 200) withItems:@[item1]];
        [self.view addSubview:_filterView];
        __weak typeof(self)weakSelf = self;
        [_filterView registerDidSelectEffectFilterBlock:^(AliyunEffectFilterInfo *filterInfo) {
            NSString *path = filterInfo.localFilterResourcePath;
            if (path.length == 0 || ![NSFileManager.defaultManager fileExistsAtPath:path]) {
                [weakSelf.cameraController deleteFilter];
            } else {
                AliyunEffectFilter *filter = [[AliyunEffectFilter alloc] initWithFile:path];
                [weakSelf.cameraController applyFilter:filter];
            }
        }];
    }
    return _filterView;
}

//特效
- (AlivcBottomMenuSpecialFilterView *)specialFilterView {
    if (!_specialFilterView) {
        AlivcBottomMenuHeaderViewItem *item1 =[AlivcBottomMenuHeaderViewItem createItemWithTitle:[@"特效滤镜" localString] icon:[AlivcImage imageNamed:@"shortVideo_effectFilter"] tag:1];
        _specialFilterView = [[AlivcBottomMenuSpecialFilterView alloc]initWithFrame:CGRectMake(0, ScreenHeight-200, ScreenWidth, 244+SafeBottom) withItems:@[item1]];
        [self.view addSubview:_specialFilterView];
        __weak typeof(self)weakSelf = self;
        [_specialFilterView registerDidSelectEffectFilterBlock:^(AliyunEffectFilterInfo * _Nonnull filterInfo) {
            NSLog(@"%@",filterInfo);
            if(filterInfo.eid == -1){
                [weakSelf.specialFilterView showRegulatorView:nil paramList:nil];
                [weakSelf.cameraController deleteAnimationFilter];
                return ;
            }
            AliyunEffectFilter *animationFilter =[[AliyunEffectFilter alloc] initWithFile:[filterInfo localFilterResourcePath]];
            NSArray *paramList = [AlivcRegulatorView getSliderParams:animationFilter.effectConfig];
            if (paramList.count>0) {
                //显示参数调节器
                [weakSelf.specialFilterView showRegulatorView:animationFilter paramList:paramList];
            }else{
                [weakSelf.specialFilterView showRegulatorView:nil paramList:nil];
            }
            [weakSelf.cameraController applyAnimationFilter:animationFilter];
        }];
        
        _specialFilterView.didChangeEffectFinish = ^(AliyunEffectFilter * _Nonnull effect) {
            [weakSelf.cameraController updateAnimationFilter:effect];
        };
        
        //下载回调
        [_specialFilterView registerDidShowMoreEffectFilterBlock:^{
            AliyunEffectMoreViewController *effectMoreVC = [[AliyunEffectMoreViewController alloc]initWithEffectType:AliyunEffectTypeSpecialFilter];
            effectMoreVC.effectMoreCallback = ^(AliyunEffectInfo *info) {
                    [weakSelf.specialFilterView fetchEffectGroupDataWithCurrentShowGroup:info];
                   };
                   UINavigationController *effecNC = [[UINavigationController alloc]initWithRootViewController:effectMoreVC];
               [weakSelf presentViewController:effecNC animated:YES completion:nil];
        }];
        
    }
    return _specialFilterView;
}

// 聚焦点
- (AlivcRecordFocusView *)focusView{
    if (!_focusView) {
        CGFloat size = 150;
        _focusView =[[AlivcRecordFocusView alloc]initWithFrame:CGRectMake(0, 0, size, size)];
        _focusView.animation =YES;
        [_cameraPreview addSubview:_focusView];
    }
    return _focusView;
}

// MARK: - 事件
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = UIColor.blackColor;
    [self startRetainCameraRotate];
    UIApplication.sharedApplication.idleTimerDisabled = YES;
    [UIApplication.sharedApplication setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    if (self.shouldStartPreviewWhenActive) {
        [self.recorder startPreview];
        self.shouldStartPreviewWhenActive = NO;
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.shouldStartPreviewForSetup) {
        [self.recorder startPreview];
        self.shouldStartPreviewForSetup = NO;
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.motionManager stopDeviceMotionUpdates];
    UIApplication.sharedApplication.idleTimerDisabled = NO;
    [UIApplication.sharedApplication setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

// MARK: - AlivcRecordNavigationBarDelegate
- (void)alivcRecordNavigationBarButtonActionType:(AlivcRecordNavigationBarType)type
{
    switch (type) {
        case AlivcRecordNavigationBarTypeGoback://返回
        {
            [_recorder stopPreview];
#if SDK_VERSION == SDK_VERSION_CUSTOM
            [FUDemoManager destory];
#endif
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case AlivcRecordNavigationBarTypeCameraSwitch://切换摄像头
        {
            if (self.cameraPosition == AVCaptureDevicePositionFront) {
                self.cameraPosition = AVCaptureDevicePositionBack;
            } else {
                self.cameraPosition = AVCaptureDevicePositionFront;
            }
        }
            break;
        case AlivcRecordNavigationBarTypeTiming://定时拍摄
        {
            __weak typeof(self)weakSelf =self;
            [self.timerCountLab startTimerWithComplete:^{
                [weakSelf.recorder startRecord];
                [weakSelf updateForLoading];
            }];
            [self updateForLoading];
        }
            break;
        case AlivcRecordNavigationBarTypeFlashMode://闪光灯
        {
            if (self.torchMode == AlivcRecordTorchModeDisabled) {
                return;
            }
            
            if (self.torchMode == AlivcRecordTorchModeOn) {
                self.torchMode = AlivcRecordTorchModeOff;
            } else {
                self.torchMode = AlivcRecordTorchModeOn;
            }
        }
            break;
        case AlivcRecordNavigationBarTypeFinish://完成
        {
            if (self.finishBlock || isRace || self.quVideo.deleteVideoClipOnExit) {
                [self finishRecord];
            } else {
                [self finishRecordForEdit];
            }
        }
            break;
        default:
            break;
    }
}

// MARK: - AlivcRecordSliderButtonsViewDelegate
- (void)alivcRecordSlidButtonAction:(AlivcRecordSlidButtonType)type
{
    if (type == AlivcRecordSlidButtonTypeFilter) {
        [self.filterView show];
    }else if (type == AlivcRecordSlidButtonTypeMusic){
        [self pickBgMusic];
    }else if (type == AlivcRecordSlidButtonTypeSwitchRatio){
        [self switchRatio];
    }else if (type == AlivcRecordSlidButtonTypeTakePhoto){
        [self takePhoto];
    }else if (type == AlivcRecordSlidButtonTypeSpecialEffects){
        [self.specialFilterView show];
    }else{
        NSLog(@"#Warning:对应的type没做实现");
    }
}

// MARK: - AliyunMusicPickViewControllerDelegate
/**
 选择了音乐，并点击了应用按钮响应

 @param music 选择的音乐
 @param tab 表明是本地音乐还是在线音乐
 */
- (void)didSelectMusic:(AliyunMusicPickModel *)music tab:(NSInteger)tab
{
    _lastSelectedMusicType = tab;
    _lastSelectedMusic = music;
    if ([music.name isEqualToString:NSLocalizedString(@"无音乐" , nil)] || !music.path || ![[NSFileManager defaultManager] fileExistsAtPath:music.path]) {
        //清除音乐效果
        _lastSelectedMusic = nil;
        [self.recorder.config removeBgMusic];
    }else{
        AVURLAsset*audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:music.path] options:nil];
        float audioDuration = CMTimeGetSeconds(audioAsset.duration);
        [self.recorder.config setBgMusicWithFile:music.path
                                       startTime:music.startTime / 1000.0
                                        duration:MIN(self.maxDuration, audioDuration)];
    }
    
    [self.sliderButtonsView updateMusicCoverWithUrl:_lastSelectedMusic.image];
}

// MARK: - AlivcRecordBottomViewDelegate
/**
 录制速度改变

 @param rate 速度
 */
- (void)alivcRecordBottomViewDidSelectRate:(CGFloat)rate
{
    self.recorder.rate = rate;
}

/**
 删除录制片段
 
 */
- (void)alivcRecordBottomViewDeleteVideoPart
{
    [self.recorder.clipManager deletePart];
}

/**
 停止录制
 */
- (void)alivcRecordBottomViewStopRecord
{
    [self.recorder stopRecord];
}

/**
 开始录制

 @return 是否成功
 */
- (BOOL)alivcRecordBottomViewStartRecord
{
    return ([self.recorder startRecord] == 0);
}

/**
 是否在录制中

 @return YES:录制中   NO:未录制
 */
- (BOOL)alivcRecordBottomViewIsRecording
{
    return self.recorder.isRecording;
}

/**
 美颜按钮点击事件
 */
- (void)alivcRecordBottomViewBeautyButtonOnclick
{
    [self.beautyView show];
}

/**
 特效按钮点击事件
 */
- (void)alivcRecordBottomViewEffectButtonOnclick
{
    [self.pasterView show];
}

// MARK: - AlivcRecordBeautyViewDelegate
/**
 基础美颜等级改变

 @param level 基础美颜等级
 */
- (void)alivcRecordBeautyDidChangeBaseBeautyLevel:(NSInteger)level
{
    _cameraController.beautifyValue = (int)level*20;
}

/**
 美颜类型改变

 @param type 美颜类型：高级、基础
 */
- (void)alivcRecordBeautyDidChangeBeautyType:(AlivcBeautySettingViewStyle)type
{
    if (type == AlivcBeautySettingViewStyle_ShortVideo_BeautyFace_Base) {
        _cameraController.beautifyStatus = YES;
        _cameraController.beautifyValue = (int)self.beautyView.currentBaseBeautyLevel*20;
    }else{
        _cameraController.beautifyStatus = NO;
        _cameraController.beautifyValue = 0;
    }
}

/**
 如何获取faceunity介绍
 */
- (void)alivcRecordBeautyDidSelectedGetFaceUnityLink
{
    AlivcWebViewController *introduceC = [[AlivcWebViewController alloc] initWithUrl:kIntroduceUrl title:NSLocalizedString(@"Third-party capability acquisition instructions", nil)];
    [self.navigationController pushViewController:introduceC animated:YES];
}

// MARK: - AlivcRecordPasterViewDelegate
/**
 选中动图的代理方法

 @param pasterInfo 被选中的动图信息
 @param cell 被选中的cell
 */
- (void)alivcRecordPasterViewDidSelectedPasterInfo:(AliyunPasterInfo *)pasterInfo cell:(UICollectionViewCell *)cell
{
    if (pasterInfo.eid <= 0 || [pasterInfo.bundlePath isEqualToString:@"icon"]) {//remove
        [self deleteCurrentEffectPaster];
        [self.pasterView refreshUIWhenThePasterInfoApplyedWithPasterInfo:pasterInfo];
        return;
    }
    //new
    [self deleteCurrentEffectPaster]; //delete pre
    if (pasterInfo.bundlePath != nil) {
        [self addEffectWithPasterInfo:pasterInfo path:pasterInfo.bundlePath];
        return;
    }
    if (![pasterInfo fileExist]) {
        cell.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //防止下载异常导致cell不能响应事件
            cell.userInteractionEnabled = YES;
        });
        AliyunDownloadTask *task = [[AliyunDownloadTask alloc] initWithInfo:pasterInfo];
        [self.downloadManager addTask:task];
        AliyunMagicCameraEffectCell *effectCell = (AliyunMagicCameraEffectCell *)cell;
        [effectCell shouldDownload:NO];
        task.progressBlock = ^(NSProgress *progress) {
            CGFloat pgs = progress.completedUnitCount * 1.0 / progress.totalUnitCount;
            [effectCell downloadProgress:pgs];
        };
        __weak typeof(self) weakSelf = self;
        task.completionHandler = ^(NSString *path, NSError *err) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.userInteractionEnabled = YES;
                effectCell.isLoading = NO;
                if (err) {
                    AliyunMagicCameraEffectCell *magicCell = (AliyunMagicCameraEffectCell *)cell;
                    [effectCell shouldDownload:YES];
                    magicCell.downloadImageView.image = [AlivcImage imageNamed:@"shortVideo_downloadFailed"];
                    [MBProgressHUD showMessage:NSLocalizedString(@"网络不给力" , nil) inView:self.view];
                }else{
                    [weakSelf addEffectWithPasterInfo:pasterInfo path:path];
                }
            });
        };
    } else {
        [self addEffectWithPasterInfo:pasterInfo path:[pasterInfo filePath]];
    }
}

// MARK: - Mic view
- (UIView *) micBottomView
{
    if (_micBottomView) {
        return _micBottomView;
    }
    
    CGRect frame = CGRectMake(0, 0, ScreenWidth, 52);
    frame.origin.y = self.bottomView.frame.origin.y - frame.size.height - 30;

    _micBottomView = [[UIView alloc] initWithFrame:frame];
    _micBottomView.backgroundColor = UIColor.clearColor;
    
    struct {
        NSString *img;
        NSString *title;
        SEL action;
    } BtnInfos[] = {
        { @"alivc_svEdit_audio", @"删除Mic", @selector(micAddDidPressed:) },
        { @"alivc_svEdit_audio", @"Mic静音", @selector(micMuteDidPressed:) },
        { @"alivc_svEdit_audio", @"Mic降噪", @selector(micDenoiseDidPressed:) },
        { @"alivc_svEdit_audio", @"Bgm不混", @selector(bgMixDidPressed:) },
    };
    
    CGRect btnFrame = CGRectMake(ScreenWidth, 0, 52, 52);
    for (int i = 0, l = sizeof(BtnInfos)/sizeof(BtnInfos[0]); i < l; ++i) {
        btnFrame.origin.x -=  btnFrame.size.width + 10;
        
        AlivcButton *effectBtn = [[AlivcButton alloc] initWithButtonType:AlivcButtonTypeTitleBottom];
        effectBtn.frame = btnFrame;
        [effectBtn addTarget:self action:BtnInfos[i].action forControlEvents:UIControlEventTouchUpInside];
        [effectBtn setTitle:BtnInfos[i].title forState:UIControlStateNormal];
        [effectBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [effectBtn setImage:[AlivcImage imageNamed:BtnInfos[i].img] forState:UIControlStateNormal];
        effectBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_micBottomView addSubview:effectBtn];
    }
    
    return _micBottomView;
}

- (void) micAddDidPressed:(UIButton *)btn {
    BOOL hasMic = self.recorder.config.microphoneController != nil;
    [btn setTitle:hasMic ? @"添加Mic" : @"删除Mic" forState:UIControlStateNormal];
    if (hasMic) {
        [self.recorder.config removeMicrophone];
    } else {
        [self.recorder.config addMicrophone];
    }
}

- (void) soundEffectDidPressed:(UIButton *)btn {
    self.audioEffectView.isShow = YES;
}

- (void) micMuteDidPressed:(UIButton *)btn {
    BOOL isMute = !self.recorder.config.microphoneController.isMute;
    self.recorder.config.microphoneController.isMute = isMute;
    [btn setTitle:isMute ? @"开麦" : @"Mic静音" forState:UIControlStateNormal];
}

- (void) bgMixDidPressed:(UIButton *)btn {
    BOOL isMix = !self.recorder.config.bgmController.isMix;
    self.recorder.config.bgmController.isMix = isMix;
    [btn setTitle:isMix ? @"Bgm不混" : @"Bg混音" forState:UIControlStateNormal];
}

- (void) micDenoiseDidPressed:(UIButton *)btn {
    BOOL isDenoise = self.recorder.config.microphoneController.denoiseWeight == 0;
    self.recorder.config.microphoneController.denoiseWeight = isDenoise ? 50 : 0;
    [btn setTitle:isDenoise ? @"Mic正常" : @"Mic降噪" forState:UIControlStateNormal];
}

- (AliyunRecordAudioEffectView *) audioEffectView {
    if (!_audioEffectView) {
        _audioEffectView = [AliyunRecordAudioEffectView new];
        _audioEffectView.delegate = self;
        [self.view addSubview:_audioEffectView];
    }
    return _audioEffectView;
}

// MARK: - AliyunRecordAudioEffectViewDelegate
- (void) onAliyunRecordAudioEffectView:(AliyunRecordAudioEffectView *)view didSelect:(AlivcEffectSoundType)soundType {
    // 暂不支持
//    if (soundType == AlivcEffectSoundTypeClear) {
//        self.recorder.config.microphoneController.effect = nil;
//        return;
//    }
//
//    AliyunAudioEffect *micEffect = [AliyunAudioEffect new];
//    micEffect.weight = 50;
//    micEffect.type = [self getSDKType:soundType];
//    self.recorder.config.microphoneController.effect = micEffect;
}

-(AliyunAudioEffectType)getSDKType:(AlivcEffectSoundType)type {
    NSDictionary *dic =@{@(AlivcEffectSoundTypeLolita):@(AliyunAudioEffectLolita),
                         @(AlivcEffectSoundTypeUncle):@(AliyunAudioEffectUncle),
                         @(AlivcEffectSoundTypeEcho):@(AliyunAudioEffectEcho),
                         @(AlivcEffectSoundTypeRevert):@(AliyunAudioEffectReverb),
                         @(AlivcEffectSoundTypeDenoise):@(AliyunAudioEffectDenoise),
                         @(AlivcEffectSoundTypeMinion):@(AliyunAudioEffectMinions),
                         @(AlivcEffectSoundTypeRobot):@(AliyunAudioEffectRobot),
                         @(AlivcEffectSoundTypeDevil):@(AliyunAudioEffectBigDevil),
                         @(AlivcEffectSoundTypeDialect):@(AliyunAudioEffectDialect),
    };
    return (AliyunAudioEffectType)[dic[@(type)] integerValue];
}

// MARK: - Helper
- (NSOperationQueue *) queue
{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}

- (void)startRetainCameraRotate {
    //初始化全局管理对象
    if (!self.motionManager) {
        self.motionManager = [[CMMotionManager alloc] init];
    }
    if ([self.motionManager isDeviceMotionAvailable]) {
        __weak typeof(self) weakSelf = self;
        self.motionManager.deviceMotionUpdateInterval = 1;
        [self.motionManager startDeviceMotionUpdatesToQueue:self.queue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            // Gravity 获取手机的重力值在各个方向上的分量，根据这个就可以获得手机的空间位置，倾斜角度等
            double gravityX = motion.gravity.x;
            double gravityY = motion.gravity.y;
            double xyTheta = atan2(gravityX,gravityY)/M_PI*180.0;//手机旋转角度。
            CGFloat rotate = 0;
            if (xyTheta >= -45 && xyTheta <= 45) {//down
                rotate = 180;
            } else if (xyTheta > 45 && xyTheta < 135) {//left
                rotate = 90;
            } else if ((xyTheta >= 135 && xyTheta < 180) || (xyTheta >= -180 && xyTheta < -135)) {//up
                rotate = 0;
            } else if (xyTheta >= -135 && xyTheta < -45) {//right
                rotate = 270;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.outputRotation = rotate;
            });
        }];
    }
}

- (void)saveImage:(NSString *)urlString path:(NSString *)path
{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
    UIImage *image = [UIImage imageWithData:data];
    NSString *filePath = [path stringByAppendingPathComponent:@"icon.png"];
    BOOL result =[UIImagePNGRepresentation(image)writeToFile:filePath atomically:YES];
    if (result == YES) {
        NSLog(@"保存成功===%@",filePath);
    }
}

- (NSString *) randomOutputPath
{
    NSString *recordDir = [AliyunPathManager createRecrodDir];
    [AliyunPathManager makeDirExist:recordDir];
    //视频存储路径
    return [[recordDir stringByAppendingPathComponent:[AliyunPathManager randomString]] stringByAppendingPathExtension:@"mp4"];
}

// MARK: - 屏幕旋转
- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
@end
