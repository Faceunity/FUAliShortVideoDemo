//
//  AliyunMagicCameraViewController.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/2/20.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AliyunMagicCameraViewController.h"
#import <AliyunVideoSDKPro/AliyunIRecorder.h>
#import <AliyunVideoSDKPro/AliyunErrorCode.h>
#import <CoreMotion/CoreMotion.h>

#import "AVC_ShortVideo_Config.h"
#import "AlivcDefine.h"
#import "AliyunPathManager.h"
#import "AlivcUIConfig.h"
#import "MBProgressHUD+AlivcHelper.h"
#import "AlivcShortVideoRoute.h"
#import "AliyunReachability.h"
//view
#import "AlivcRecordNavigationBar.h"
#import "QUProgressView.h"
#import "AlivcRecordBottomView.h"
#import "AlivcRecordTimerLable.h"
#import "AlivcRecordFocusView.h"
#import "AliyunMusicPickViewController.h"
#import "AlivcRecordSliderButtonsView.h"
//美颜
#if SDK_VERSION == SDK_VERSION_CUSTOM
#import "AlivcShortVideoFaceUnityManager.h"
#import "AlivcShortVideoRaceManager.h"
#endif
#import "AlivcWebViewController.h"
//动图
#import <AliyunVideoSDKPro/AliyunHttpClient.h>
#import "AliyunResourceManager.h"
#import "AliyunDownloadManager.h"
#import "AlivcRecordPasterView.h"
#import "AliyunMagicCameraEffectCell.h"
//滤镜
#import "AlivcBottomMenuFilterView.h"
#import "NSString+AlivcHelper.h"

#import "AlivcBottomMenuSpecialFilterView.h"
#import "AliyunEffectMoreViewController.h"
#import "AlivcRegulatorView.h"

@interface AliyunMagicCameraViewController ()<AliyunIRecorderDelegate,AlivcRecordBottomViewDelegate,
AlivcRecordNavigationBarDelegate,AliyunMusicPickViewControllerDelegate,
AlivcRecordSliderButtonsViewDelegate,AlivcRecordBeautyViewDelegate,
AlivcRecordPasterViewDelegate>
//SDK
@property (nonatomic, strong) AliyunIRecorder *recorder;        //录制
//system
@property (nonatomic, strong) CMMotionManager *motionManager;   //陀螺仪
//view
@property (nonatomic, strong) QUProgressView *progressView;                 //进度条
@property (nonatomic, strong) AlivcRecordNavigationBar *navigationBar;      //顶部导航栏
@property (nonatomic, strong) AlivcRecordSliderButtonsView *sliderButtonsView;  //侧边菜单栏
@property (nonatomic, strong) AlivcRecordBottomView *bottomView;        //底部view
@property (nonatomic, strong) AlivcRecordTimerLable *timerCountLab;     //倒计时lab
@property (nonatomic, strong) AlivcRecordPasterView *pasterView;        //动图view
@property (nonatomic, strong) AlivcBottomMenuFilterView *filterView;    //滤镜view
@property (nonatomic, strong) AlivcBottomMenuSpecialFilterView *specialFilterView;
@property (nonatomic, strong) AlivcRecordFocusView *focusView;          //聚焦框
//data
@property (nonatomic, strong) AliyunDownloadManager *downloadManager;   //下载管理（动图）
@property (nonatomic, strong) AliyunResourceManager *resourceManager;   //资源管理（动图）
@property (nonatomic, strong) NSMutableArray *allPasterInfoArray;       //所有动图资源
@property (nonatomic, strong) AliyunEffectPaster *currentEffectPaster;  //当前的人脸动图
@property (nonatomic, strong) AliyunReachability *reachability;         //网络监听

@property (nonatomic, assign) BOOL shouldStartPreviewWhenActive;    //跳转其他页面停止预览，返回开始预览，退后台进入前台则一直在预览。这2种情况通过此变量区别。

@property (nonatomic, assign) CGFloat recorderDuration; //本地记录的视频录制时长

@property (nonatomic, strong) NSOperationQueue *queue;
@end

@implementation AliyunMagicCameraViewController
{
    NSInteger _cameraRotate; //相机旋转角度
    CGSize _outputSize;     //初始输出分辨率，此值切换画幅的时候用到
    NSInteger _musicTab;   //之前选中的音乐tab：本地、远程
    AliyunMusicPickModel *_currentMusic;//当前应用的音乐
    //    BOOL _stopRecordActionUnfinished; //录制结束动作未完成，（有个场景需求是调用stopRecording和回调recorderDidStopRecording返回之间不响应录制按钮事件）
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor blackColor];
    //开启陀螺仪获取手机旋转角度
    [self startRetainCameraRotate];
    [self updateNavigationBarTorchModeStatus];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];//录制模块禁止自动熄屏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    if (self.shouldStartPreviewWhenActive) {
        [self.recorder startPreview];
        self.shouldStartPreviewWhenActive = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.motionManager stopDeviceMotionUpdates];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    //关闭闪光灯
    [self.recorder switchTorchWithMode:AliyunIRecorderTorchModeOff];
    [self updateNavigationBarTorchModeStatus];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (isRace) {
        NSString *watermarkPath = [AlivcImage pathOfImageName:@"watermark"];
        AliyunEffectImage *watermark =
        [[AliyunEffectImage alloc] initWithFile:watermarkPath];
        CGFloat outsizex = 44;
        CGFloat outsizey = 132;
        watermark.frame = CGRectMake(outsizex, outsizey, 42, 30);
        [self.recorder applyImage:watermark];
    }
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置默认视频角度为
    //    _cameraRotate =90;
    //VC布局
    [self setupSubviews];
    //添加通知
    [self addNotification];
    //开始预览
    [self.recorder startPreviewWithPositon:AliyunIRecorderCameraPositionFront];
    //设置默认美颜状态
    [self alivcRecordBeautyDidChangeBeautyType:self.beautyView.currentBeautyType];
    //添加手势
    [self addGesture];
    //开启网络监听
    [self startNetworkReachability];
    //默认值设置
    self.shouldStartPreviewWhenActive = NO;
    self.recorderDuration = 0;
    
    self.queue = [[NSOperationQueue alloc] init];
    
}
- (void)setupSubviews{
    if (!_uiConfig) {
        _uiConfig =[[AlivcRecordUIConfig alloc]init];
    }
    self.view.backgroundColor = _uiConfig.backgroundColor;
    //添加倒计时lab
    [self.view addSubview:self.timerCountLab];
    //添加预览view
    [self.view addSubview:self.recorder.preview];
    //添加顶部录制进度条
    [self.view addSubview:self.progressView];
    //添加顶部导航条
    _navigationBar =[[AlivcRecordNavigationBar alloc]initWithUIConfig:_uiConfig];
    _navigationBar.delegate =self;
    [self.view addSubview:_navigationBar];
    //添加右侧菜单栏
    [self.view addSubview:self.sliderButtonsView];
    //添加底部view
    [self.view addSubview:self.bottomView];
    //提前加载好美颜view，防止在异步线程里惰性加载view
    [self beautyView];

}
// 监听通知
- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resourceDelete:) name:AliyunEffectResourceDeleteNotification object:nil];
}
- (void)startNetworkReachability{
    //网络状态判定
    _reachability = [AliyunReachability reachabilityForInternetConnection];
    [_reachability startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged)
                                                 name:AliyunSVReachabilityChangedNotification
                                               object:nil];
}
// 资源被删除的通知
- (void)resourceDelete:(NSNotification *)noti{
    
}

- (void)appWillResignActive:(id)sender
{
    [self.recorder switchTorchWithMode:AliyunIRecorderTorchModeOff];
    [self.timerCountLab stopTimer];
    if (self.recorder.isRecording) {
        [self.recorder stopRecording];
    }
    [self updateViewsStatus];
}


- (void)appDidBecomeActive:(id)sender
{
    //刷新闪光灯按钮状态
    [self updateNavigationBarTorchModeStatus];
}

#pragma mark - 网络变化
//网络状态判定
- (void)reachabilityChanged{
    AliyunSVNetworkStatus status = [self.reachability currentReachabilityStatus];
    if (status != AliyunSVNetworkStatusNotReachable && self.allPasterInfoArray.count == 0) {
        [self fetchData];
    }
}
//预览view的坐标大小计算
- (CGRect)previewFrame{
    CGFloat ratio =_quVideo.outputSize.width / _quVideo.outputSize.height;
    CGRect finalFrame = CGRectMake(0, NoStatusBarSafeTop+44+10, ScreenWidth, ScreenWidth /ratio);
    if ([_quVideo mediaRatio] == AliyunMediaRatio9To16){
        finalFrame =CGRectMake((ScreenWidth - ScreenHeight * ratio)/2.f , 0, ScreenHeight * ratio, ScreenHeight);
    }
    return finalFrame;
}
//更新UI状态
- (void)updateViewsStatus{
    //更新录制按钮下方的删除按钮状态
    [self.bottomView updateViewsWithVideoPartCount:[self partCount]];
    //更新录制时间
    [self.bottomView refreshRecorderVideoDuration:self.recorderDuration];
    //更新录制UI
    [self.bottomView updateRecorderUI];
    //更新导航栏完成按钮状态
    [self.navigationBar setFinishButtonEnabled:(self.recorderDuration >= [self finishButtonEnabledMinDuration])];
    //更新右侧按钮显示/隐藏状态
    [_navigationBar setHidden:(self.recorder.isRecording||self.timerCountLab.isTiming)];
    //更新定时录制按钮的可点击状态
    [_navigationBar setTimerButtonEnabled:(self.recorderDuration < [self maxDuration])];
    [self.sliderButtonsView setHidden:(self.recorder.isRecording||self.timerCountLab.isTiming)];
    //更新音乐按钮的可点击状态
    [self.sliderButtonsView setMusicButtonEnabled:(self.recorderDuration == 0)];
    //更新底部录制view
    [self.bottomView setHidden:self.timerCountLab.isTiming];
}
//更新闪光灯按钮状态
- (void)updateNavigationBarTorchModeStatus{
    if (self.recorder.cameraPosition == AliyunIRecorderCameraPositionFront) {//前置摄像头禁用闪光灯
        [self.navigationBar setTorchButtonImageWithMode:AlivcRecordTorchModeDisabled];
    }else{//后置摄像头
        [self.navigationBar setTorchButtonImageWithMode:(AlivcRecordTorchMode)self.recorder.torchMode];
    }
}

- (void)hiddenSideBarButtons {
    UIButton *musicButton = [self.sliderButtonsView viewWithTag:AlivcRecordSlidButtonTypeMusic];
    UIButton *filterButton = [self.sliderButtonsView viewWithTag:AlivcRecordSlidButtonTypeFilter];
    UIButton *switchRatioButton = [self.sliderButtonsView viewWithTag:AlivcRecordSlidButtonTypeSwitchRatio];
    UIButton *effectButton = [self.sliderButtonsView viewWithTag:AlivcRecordSlidButtonTypeSpecialEffects];
    [self.sliderButtonsView setPhotoButtonEnabled:NO];
    musicButton.hidden = YES;
    switchRatioButton.hidden = YES;
    effectButton.frame = filterButton.frame;
    filterButton.frame = musicButton.frame;
   
}
- (CGFloat)finishButtonEnabledMinDuration {
    return _quVideo.minDuration;
}
#pragma mark - GET
- (AliyunIRecorder *)recorder{
    if (!_recorder) {
        //清除之前生成的录制路径
        NSString *recordDir = [AliyunPathManager createRecrodDir];
        [AliyunPathManager clearDir:recordDir];
        //生成这次的存储路径
        NSString *taskPath = [recordDir stringByAppendingPathComponent:[AliyunPathManager randomString]];
        //视频存储路径
        NSString *videoSavePath = [[taskPath stringByAppendingPathComponent:[AliyunPathManager randomString]] stringByAppendingPathExtension:@"mp4"];
        _recorder =[[AliyunIRecorder alloc] initWithDelegate:self videoSize:_quVideo.outputSize];
        _recorder.preview = [[UIView alloc]initWithFrame:[self previewFrame]];
        _recorder.outputType = AliyunIRecorderVideoOutputPixelFormatType420f;//SDK自带人脸识别只支持YUV格式
        _recorder.useFaceDetect = YES;
        _recorder.faceDetectCount = 2;
        _recorder.faceDectectSync = NO;
        _recorder.frontCaptureSessionPreset = AVCaptureSessionPreset1280x720;
        _recorder.encodeMode = (_quVideo.encodeMode == AliyunEncodeModeSoftFFmpeg)?0:1;
        NSLog(@"录制编码方式：%d",_recorder.encodeMode);
        _recorder.GOP = _quVideo.gop;
        _recorder.videoQuality = (AliyunVideoQuality)_quVideo.videoQuality;
        _recorder.recordFps = _quVideo.fps;
        _recorder.outputPath = _quVideo.outputPath?_quVideo.outputPath:videoSavePath;
        _quVideo.outputPath = _recorder.outputPath;
        _recorder.taskPath = taskPath;
        _recorder.beautifyStatus = YES;
        _recorder.videoFlipH = _quVideo.videoFlipH;
        //录制片段设置
        //        _recorder.clipManager.maxDuration = _quVideo.maxDuration;
        [self recorder:_recorder setMaxDuration:_quVideo.maxDuration];
        //        _recorder.clipManager.minDuration = _quVideo.minDuration;
        [self recorder:_recorder setMinDuration:_quVideo.minDuration];
    }
    return _recorder;
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
        _progressView.maxDuration = _quVideo.maxDuration;
        _progressView.minDuration = _quVideo.minDuration;
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
        [_filterView registerDidSelectEffectFilterBlock:^(AliyunEffectFilterInfo * _Nonnull filterInfo) {
            AliyunEffectFilter *effectFilter =[[AliyunEffectFilter alloc] initWithFile:[filterInfo localFilterResourcePath]];
            NSLog(@"vvvv effectfilter2:%@", effectFilter.path);
            [weakSelf.recorder applyFilter:effectFilter];
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
                [weakSelf.recorder deleteAnimationFilter];
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
            [weakSelf.recorder applyAnimationFilter:animationFilter];
        }];
        
        _specialFilterView.didChangeEffectFinish = ^(AliyunEffectFilter * _Nonnull effect) {
            [weakSelf.recorder updateAnimationFilter:effect];
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


- (AlivcRecordFocusView *)focusView{
    if (!_focusView) {
        CGFloat size = 150;
        _focusView =[[AlivcRecordFocusView alloc]initWithFrame:CGRectMake(0, 0, size, size)];
        _focusView.animation =YES;
        [self.recorder.preview addSubview:_focusView];
    }
    return _focusView;
}

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
#pragma mark - SET
- (void)setQuVideo:(AliyunMediaConfig *)quVideo{
    //需要copy一份，不然录制模块的参数改动会保存到配置页面
    _quVideo = [quVideo copy];
    _outputSize = _quVideo.outputSize;
}
#pragma mark - AlivcRecordNavigationBarDelegate -
- (void)alivcRecordNavigationBarButtonActionType:(AlivcRecordNavigationBarType)type{
    switch (type) {
        case AlivcRecordNavigationBarTypeGoback://返回
        {
            [self.recorder stopPreview];
#if SDK_VERSION == SDK_VERSION_CUSTOM
            [[AlivcShortVideoFaceUnityManager shareManager] destoryItems];
#endif
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case AlivcRecordNavigationBarTypeCameraSwitch://切换摄像头
        {
            if (![self checkAVAuthorizationStatus]) {
                return;
            }
            [self.recorder switchCameraPosition];
            [self updateNavigationBarTorchModeStatus];
        }
            break;
        case AlivcRecordNavigationBarTypeTiming://定时拍摄
        {
            if (![self checkAVAuthorizationStatus]) {
                return;
            }
            __weak typeof(self)weakSelf =self;
            [self.timerCountLab startTimerWithComplete:^{
                [weakSelf.recorder startRecording];
                [weakSelf updateViewsStatus];
                NSLog(@"倒计时结束");
            }];
            [self updateViewsStatus];
        }
            break;
        case AlivcRecordNavigationBarTypeFlashMode://闪光灯
        {
            [self.recorder switchTorchWithMode:!self.recorder.torchMode];
            [self updateNavigationBarTorchModeStatus];
        }
            break;
        case AlivcRecordNavigationBarTypeFinish://完成
        {
            if(self.isMixedViedo) {
                [self recorderDidFinishRecording];
            }else{
                [self.recorder finishRecording];
            }
            
        }
            break;
        default:
            break;
    }
}
#pragma mark - AlivcRecordSlidButtonsViewDelegate -
- (void)alivcRecordSlidButtonAction:(AlivcRecordSlidButtonType)type{
    if (type == AlivcRecordSlidButtonTypeFilter) {
        [self.filterView show];
    }else if (type == AlivcRecordSlidButtonTypeMusic){
        AliyunMusicPickViewController *vc =[[AliyunMusicPickViewController alloc] init];
        vc.delegate = self;
        vc.duration = _quVideo.maxDuration;
        [vc setSelectedMusic:_currentMusic type:_musicTab];
        [self.recorder stopPreview];
        self.shouldStartPreviewWhenActive = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (type == AlivcRecordSlidButtonTypeSwitchRatio){
        [self switchRatio];
    }else if (type == AlivcRecordSlidButtonTypeTakePhoto){
        NSLog(@"点击拍照按钮");
        [self takePhotos];
    }else if (type == AlivcRecordSlidButtonTypeSpecialEffects){
        NSLog(@"点击特效按钮");
        [self.specialFilterView show];
    }else{
        NSLog(@"#Warning:对应的type没做实现");
    }
}

- (void)takePhotos {
    __weak typeof(self) weakSelf = self;
    
    if([self.recorder respondsToSelector:@selector(takePhoto:)]) {
        [self.recorder takePhoto:^(UIImage *image, UIImage *rawImage) {
            //保存到相册中
            UIImageWriteToSavedPhotosAlbum(image, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)weakSelf);
//            UIImageWriteToSavedPhotosAlbum(rawImage, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)weakSelf);
        }];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
    [MBProgressHUD showMessage:@"图片已保存到相册中" inView:self.view];
}
//切换画幅
- (void)switchRatio{
    [self.sliderButtonsView setSwitchRationButtonEnabled:NO];
    //关闭闪光灯
    [self.recorder switchTorchWithMode:AliyunIRecorderTorchModeOff];
    [self updateNavigationBarTorchModeStatus];
    _quVideo.videoRotate = 0;//初始化为0度
    switch ([_quVideo mediaRatio]) {
        case AliyunMediaRatio9To16:
            _quVideo.outputSize = CGSizeMake(_outputSize.width, _outputSize.width*4.0/3);
            break;
        case AliyunMediaRatio3To4:
            _quVideo.outputSize = CGSizeMake(_outputSize.width, _outputSize.width);
            break;
        case AliyunMediaRatio1To1:
            _quVideo.outputSize =  CGSizeMake(_outputSize.width, _outputSize.width*16.0/9);
            break;
        default:break;
    }
    
    [self.recorder reStartPreviewWithVideoSize:[_quVideo fixedSize]];
    [UIView animateWithDuration:0.3 animations:^{
        self.recorder.preview.frame = [self previewFrame];
        
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - AlivcRecordBottomViewDelegate -
- (void)didSelectMusic:(AliyunMusicPickModel *)music tab:(NSInteger)tab{
    _musicTab = tab;
    _currentMusic = music;
    if ([music.name isEqualToString:NSLocalizedString(@"无音乐" , nil)] || !music.path || ![[NSFileManager defaultManager] fileExistsAtPath:music.path]) {
        //清除音乐效果
        [self.recorder applyMusic:nil];
    }else{
        AliyunEffectMusic *effectMusic = [[AliyunEffectMusic alloc] initWithFile:music.path];
        effectMusic.startTime = music.startTime / 1000.0f;
        effectMusic.duration = music.duration;
        //添加音乐
        int result = [self.recorder applyMusic:effectMusic];
        if (result != ALIVC_COMMON_RETURN_SUCCESS) {
            
            [MBProgressHUD showMessage:[@"添加失败" localString] inView:self.view];
        }
        
        NSLog(@"%@",effectMusic.path);
        NSLog(@"----------->:有path，有文件");
    }
    
    [self.sliderButtonsView updateMusicCoverWithUrl:music.image];
}
- (void)alivcRecordBottomViewDidSelectRate:(CGFloat)rate{
    NSLog(@"速度:%f",rate);
    [self.recorder setRate:rate];
}
- (void)alivcRecordBottomViewDeleteVideoPart{
    [self deletePart];
    self.progressView.videoCount = [self partCount];
    self.recorderDuration =[self duration];
    [self.progressView updateProgress:[self duration]];
    [self updateViewsStatus];
}
- (BOOL)alivcRecordBottomViewStartRecord{
    //    if (_stopRecordActionUnfinished) {
    //        NSLog(@"有停止录制动作未完成");
    //        return NO;
    //    }
    if (![self checkAVAuthorizationStatus]) {
        return NO;
    }
    if ([self partCount]<=0) {
        
        self.recorder.cameraRotate = (int)_cameraRotate;
        _quVideo.videoRotate = self.recorder.cameraRotate;
        
    }
    if ([self.recorder startRecording] == 0) {
        [self updateViewsStatus];
        return YES;
    }else{
        return NO;
    }
}

- (void)alivcRecordBottomViewStopRecord{
    //    _stopRecordActionUnfinished =YES;
    [self.recorder stopRecording];
    //刷新界面
    [self updateViewsStatus];
}
- (BOOL)alivcRecordBottomViewIsRecording{
    return self.recorder.isRecording;
}
- (void)alivcRecordBottomViewBeautyButtonOnclick{
    [self.beautyView show];
}
- (void)alivcRecordBottomViewEffectButtonOnclick{
    [self.pasterView show];
}
//检测权限
-(BOOL)checkAVAuthorizationStatus{
    for (AVMediaType mediaType in @[AVMediaTypeVideo,AVMediaTypeAudio]) {
        if ([AVCaptureDevice authorizationStatusForMediaType:mediaType] != AVAuthorizationStatusAuthorized) {
            [self showAVAuthorizationAlertWithMediaType:mediaType];
            return NO;
        }
    }
    return YES;
}
//显示一个权限弹窗
-(void)showAVAuthorizationAlertWithMediaType:(AVMediaType)mediaType{
     __weak typeof(self) weakSelf = self;
    NSString *title =[@"打开相机失败" localString];
    NSString *message =[@"摄像头无权限" localString];
    if (mediaType == AVMediaTypeAudio) {
        title = [@"获取麦克风权限失败" localString];
        message =[@"麦克风无权限" localString];
    }
    UIAlertController *alertController =[UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 =[UIAlertAction actionWithTitle:[@"取消" localString] style:UIAlertActionStyleDestructive handler:nil];
    UIAlertAction *action2 =[UIAlertAction actionWithTitle:[@"设置" localString] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf goSetting];
    }];
    [alertController addAction:action1];
    [alertController addAction:action2];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)goSetting {
     [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

#pragma mark - 美颜 -
#pragma mark - AlivcRecordBeautyViewDelegate
- (void)alivcRecordBeautyDidChangeBeautyType:(AlivcBeautySettingViewStyle)type{
    if (type == AlivcBeautySettingViewStyle_ShortVideo_BeautyFace_Base) {
        self.recorder.beautifyStatus = YES;
        self.recorder.beautifyValue = (int)self.beautyView.currentBaseBeautyLevel*20;
    }else{
        self.recorder.beautifyStatus = NO;
        self.recorder.beautifyValue = 0;
    }
}
- (void)alivcRecordBeautyDidChangeBaseBeautyLevel:(NSInteger)level{
    self.recorder.beautifyValue = (int)level*20;
}
- (void)alivcRecordBeautyDidSelectedGetFaceUnityLink{
    AlivcWebViewController *introduceC = [[AlivcWebViewController alloc] initWithUrl:kIntroduceUrl title:NSLocalizedString(@"Third-party capability acquisition instructions", nil)];
    [self.navigationController pushViewController:introduceC animated:YES];
}

#pragma mark - AliyunIRecorderDelegate -
// 设备权限
- (void)recorderDeviceAuthorization:(AliyunIRecorderDeviceAuthor)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status == AliyunIRecorderDeviceAuthorAudioDenied) {
            [self showAVAuthorizationAlertWithMediaType:AVMediaTypeAudio];
        } else if (status == AliyunIRecorderDeviceAuthorVideoDenied) {
            [self showAVAuthorizationAlertWithMediaType:AVMediaTypeVideo];
        }
        //当权限有问题的时候，不会走startPreview，所以这里需要更新下UI
        [self.sliderButtonsView setSwitchRationButtonEnabled:(self.recorderDuration == 0)];
    });
}
// 录制进度
- (void)recorderVideoDuration:(CGFloat)duration{
    NSLog(@"录制中：%f",duration);
    [self.progressView updateProgress:duration];
    [self.bottomView refreshRecorderVideoDuration:duration];
    self.recorderDuration = duration;
}
// 录制停止
- (void)recorderDidStopRecording{
    NSLog(@"----停止录制");
    //    _stopRecordActionUnfinished =NO;
    _progressView.videoCount = [self partCount];
    //更新录制按钮下方的删除按钮状态
    [self.bottomView updateViewsWithVideoPartCount:[self partCount]];
}

- (void)recorderDidFinishRecording{
    NSLog(@"----完成录制");
    //    UISaveVideoAtPathToSavedPhotosAlbum(_recorder.outputPath, self, nil, nil);
    [self updateViewsStatus];
    //停止预览
    [self.recorder stopPreview];
    self.shouldStartPreviewWhenActive = YES;
    //跳转处理
    NSString *outputPath = self.recorder.outputPath;
    if (self.finishBlock) {
        self.finishBlock(outputPath);
    }else{
        //如果没有编辑类证明是race的demo
        if (isRace) {
             UISaveVideoAtPathToSavedPhotosAlbum(self.recorder.outputPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            return;
        }
       
        [[AlivcShortVideoRoute shared]registerEditVideoPath:outputPath];
        [[AlivcShortVideoRoute shared]registerEditMediasPath:nil];
        [[AlivcShortVideoRoute shared]registerMediaConfig:_quVideo];
        if(_currentMusic && ![_currentMusic.name isEqualToString:NSLocalizedString(@"无音乐" , nil)]){
            [[AlivcShortVideoRoute shared] registerHasRecordMusic:YES];
        }else{
            [[AlivcShortVideoRoute shared] registerHasRecordMusic:NO];
        }
        [[AlivcShortVideoRoute shared] registerIsMixedVideo:self.isMixedViedo];
       
        UIViewController *editVC = [[AlivcShortVideoRoute shared]alivcViewControllerWithType:AlivcViewControlEdit];
        if (editVC) {
             [self.navigationController pushViewController:editVC animated:YES];
        }else{
             UISaveVideoAtPathToSavedPhotosAlbum(self.recorder.outputPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        } 
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

//当录至最大时长时回调
- (void)recorderDidStopWithMaxDuration{
    NSLog(@"录制到最大时长");
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.recorder finishRecording];
}
- (void)recorderDidStartPreview{
    [self.sliderButtonsView setSwitchRationButtonEnabled:(self.recorderDuration == 0)];
    NSLog(@"-------->开始预览");
}
// 录制异常
- (void)recoderError:(NSError *)error {
    NSLog(@"recoderError%@",error);
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [MBProgressHUD showWarningMessage:[NSString stringWithFormat:@"录制异常：%@",error.localizedDescription] inView:self.view];
    [self updateViewsStatus];
}

#if SDK_VERSION == SDK_VERSION_CUSTOM
- (void)destroyRender{
    if ([[AlivcShortVideoRoute shared] currentBeautyType] == AlivcBeautyTypeRace) {
           [[AlivcShortVideoRaceManager shareManager] clear];
    }else {
           [[AlivcShortVideoFaceUnityManager shareManager] destoryItems];
    }
}

// 集成faceunity
#warning 以下为faceunity高级美颜接入代码，如果未集成faceunity，可以把此回调方法注释掉，以避免产生额外的license校验请求。

- (CVPixelBufferRef)customRenderedPixelBufferWithRawSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if ([[AlivcShortVideoRoute shared] currentBeautyType] == AlivcBeautyTypeRace) {
        return CMSampleBufferGetImageBuffer(sampleBuffer);
    }
    if (self.beautyView.currentBeautyType == AlivcBeautySettingViewStyle_ShortVideo_BeautyFace_Base) {
        return CMSampleBufferGetImageBuffer(sampleBuffer);
    }
    
    //注意这里美颜美型的参数是分开的beautyParams和beautySkinParams
    //美颜参数设置(这里用的是beautyParams)
    CGFloat beautyWhite = self.beautyView.beautyParams.beautyWhite;
    CGFloat beautyBuffing = self.beautyView.beautyParams.beautyBuffing;
    CGFloat beautyRuddy = self.beautyView.beautyParams.beautyRuddy;
    //美型参数设置(这里用的是beautySkinParams)
    CGFloat beautyBigEye = self.beautyView.beautySkinParams.beautyBigEye;
    CGFloat beautySlimFace = self.beautyView.beautySkinParams.beautySlimFace;
    
    CVPixelBufferRef buf = [[AlivcShortVideoFaceUnityManager shareManager] RenderedPixelBufferWithRawSampleBuffer:sampleBuffer beautyWhiteValue:beautyWhite/100.0 blurValue:beautyBuffing/100.0 bigEyeValue:beautyBigEye/100.0 slimFaceValue:beautySlimFace/100.0 buddyValue:beautyRuddy/100.0];
    return buf;
}

#endif

#pragma mark - 动图数据相关 -
// 动图数据请求 + ui更新
- (void)fetchData
{
    [self.allPasterInfoArray removeAllObjects];
    AliyunHttpClient *httpClient = [[AliyunHttpClient alloc] initWithBaseUrl:kAlivcQuUrlString];
    NSDictionary *param = @{@"type":@(1)};
    __weak typeof(self)weakSelf = self;
    [httpClient GET:@"resource/getFrontPasterList" parameters:param completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        __strong typeof(self)strongSelf = weakSelf;
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

//点击动图回调
- (void)alivcRecordPasterViewDidSelectedPasterInfo:(AliyunPasterInfo *)pasterInfo cell:(UICollectionViewCell *)cell{
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
                    NSLog(@"");
                }
            });
        };
    } else {
        [self addEffectWithPasterInfo:pasterInfo path:[pasterInfo filePath]];
    }
}
/**
 删除当前的动图
 */
- (void)deleteCurrentEffectPaster
{
    if (_currentEffectPaster) {
        [self.recorder deletePaster:_currentEffectPaster];
        NSLog(@"动图测试：删除动图：%@\n",_currentEffectPaster.path);
        _currentEffectPaster = nil;
    }
}
/**
 应用新的动图特效
 @param info 动图对应的模型类
 @param path 此动图对应的路径
 */
- (void)addEffectWithPasterInfo:(AliyunPasterInfo *)info path:(NSString *)path
{
    if(self.recorder.isRecording){
        NSLog(@"动图测试:添加动图：录制中，不添加");
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:path];
    if(result) {
        [self deleteCurrentEffectPaster];
        AliyunEffectPaster *paster = [[AliyunEffectPaster alloc] initWithFile:path];
        [self.recorder applyPaster:paster];
        _currentEffectPaster = paster;
        [_pasterView refreshUIWhenThePasterInfoApplyedWithPasterInfo:info];
        
        //如果不存在icon 自行拉取icon图片
        if (![fileManager fileExistsAtPath:[path stringByAppendingPathComponent:@"icon.png"]]) {
            [self saveImage:info.icon path:path];
        }
    }
}

- (void)saveImage:(NSString *)urlString path:(NSString *)path{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
    UIImage *image = [UIImage imageWithData:data];
    NSString *filePath = [path stringByAppendingPathComponent:@"icon.png"];
    BOOL result =[UIImagePNGRepresentation(image)writeToFile:filePath atomically:YES];
    if (result == YES) {
        NSLog(@"保存成功===%@",filePath);
    }
    
}

//添加手势
- (void)addGesture
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToFocusPoint:)];
    [self.recorder.preview addGestureRecognizer:tapGesture];
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [self.recorder.preview addGestureRecognizer:pinchGesture];
}
//点按手势的触发方法
- (void)tapToFocusPoint:(UITapGestureRecognizer *)tapGesture {
    UIView *tapView = tapGesture.view;
    CGPoint point = [tapGesture locationInView:tapView];
    self.recorder.focusPoint = point;
    self.focusView.center = point;
    [self.recorder.preview bringSubviewToFront:self.focusView];
    //    if (!self.recorder.isRecording) {
    //        [self.magicCameraView cancelRecordBeautyView];
    //    }
    
}
//捏合手势的触发方法
- (void)pinchGesture:(UIPinchGestureRecognizer *)pinchGesture {
    if (isnan(pinchGesture.velocity) || pinchGesture.numberOfTouches != 2) {
        return;
    }
    self.recorder.videoZoomFactor = pinchGesture.velocity;
    pinchGesture.scale = 1;
    return;
}
- (void)startRetainCameraRotate {
    //初始化全局管理对象
    if (!self.motionManager) {
        self.motionManager = [[CMMotionManager alloc] init];
    }
    if ([self.motionManager isDeviceMotionAvailable]) {
        self.motionManager.deviceMotionUpdateInterval =1;
        [self.motionManager startDeviceMotionUpdatesToQueue:self.queue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            // Gravity 获取手机的重力值在各个方向上的分量，根据这个就可以获得手机的空间位置，倾斜角度等
            double gravityX = motion.gravity.x;
            double gravityY = motion.gravity.y;
            double xyTheta = atan2(gravityX,gravityY)/M_PI*180.0;//手机旋转角度。
            if (xyTheta >= -45 && xyTheta <= 45) {//down
                self->_cameraRotate =180;
            } else if (xyTheta > 45 && xyTheta < 135) {//left
                self->_cameraRotate = 90;
            } else if ((xyTheta >= 135 && xyTheta < 180) || (xyTheta >= -180 && xyTheta < -135)) {//up
                self->_cameraRotate = 0;
            } else if (xyTheta >= -135 && xyTheta < -45) {//right
                self->_cameraRotate = 270;
            }
            //            NSLog(@"手机旋转的角度为 --- %d", _cameraRotate);
        }];
    }
}
 
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    [MBProgressHUD showMessage:NSLocalizedString(@"已保存到手机相册", nil) inView:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [self.navigationController popViewControllerAnimated:YES];
    });
}
  

#pragma mark - 设备旋转
- (BOOL)shouldAutorotate
{
    return YES;
}
// 竖屏显示
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (void)dealloc
{
    NSLog(@"~~~~~~%s delloc", __PRETTY_FUNCTION__);
    [_recorder stopPreview];
    [_recorder destroyRecorder];
    _recorder = nil;
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger)partCount {
    return self.recorder.clipManager.partCount;
}

- (CGFloat)duration {
    return self.recorder.clipManager.duration;
    //    return self.recorderDuration;
}

- (void)deletePart {
    [self.recorder.clipManager deletePart];
}

- (void)recorder:(AliyunIRecorder *)recorder setMaxDuration:(CGFloat)maxDuration {
    recorder.clipManager.maxDuration = maxDuration;
}
- (CGFloat)maxDuration {
    return self.recorder.clipManager.maxDuration;
}

- (void)recorder:(AliyunIRecorder *)recorder setMinDuration:(CGFloat)minDuration {
    recorder.clipManager.minDuration = minDuration;
}


@end
