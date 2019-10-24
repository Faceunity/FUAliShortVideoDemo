 //
//  ViewController.m
//  AliyunVideo
//
//  Created by Vienta on 2016/12/29.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunMagicCameraViewController.h"
#import <AliyunVideoSDKPro/AliyunIRecorder.h>
#import "AliyunMagicCameraView.h"
#import <AVFoundation/AVFoundation.h>
#import <AliyunVideoSDKPro/AliyunFacePoint.h>
#import <AliyunVideoSDKPro/AliyunEffectFilter.h>
#import <AliyunVideoSDKPro/AliyunEffectPaster.h>
#import <AliyunVideoSDKPro/AliyunClipManager.h>
#import <AliyunVideoSDKPro/AliyunHttpClient.h>
#import "AliyunPasterInfoGroup.h"
#import "AliyunPasterInfo.h"
#import "AliyunDownloadManager.h"
#import "AliyunMagicCameraEffectCell.h"
#import <CoreMotion/CoreMotion.h>
#import "AliyunResourceManager.h"
#import "AliyunMusicPickViewController.h"
#import "AliyunPathManager.h"
#import "MBProgressHUD.h"
#import "AliyunEffectResourceModel.h"
#import "AVC_ShortVideo_Config.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AlivcUIConfig.h"
#import "AliyunResourceRequestManager.h"
#import "AliyunReachability.h"
#import "AliyunDBHelper.h"
#import "AlivcBeautySettingUIDefine.h"
#import "AlivcDefine.h"

#if SDK_VERSION == SDK_VERSION_CUSTOM
#import "AlivcShortVideoFaceUnityManager.h"
#endif

#import "AliyunEffectMvGroup.h"
#import "AliyunMediator.h"
#import "AliyunMediaConfig.h"
#import "MBProgressHUD+AlivcHelper.h"
#import "AlivcPushBeautyDataManager.h"
#import "AliyunEffectFilterInfo.h"



#import <FUAPIDemoBar/FUAPIDemoBar.h>
#import "FUManager.h"


@interface AliyunMagicCameraViewController () <AliyunMusicPickViewControllerDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate, AliyunIRecorderDelegate, FUAPIDemoBarDelegate>

/**
 SDK录制类
 */
@property (nonatomic, strong) AliyunIRecorder *recorder;

/**
 控制器view
 */
@property (nonatomic, strong) AliyunMagicCameraView *magicCameraView;
@property (nonatomic, strong) NSMutableArray *effectFilterItems; //滤镜数组
@property (nonatomic, strong) NSMutableArray<AliyunPasterInfo*> *effectGifItems; //动图数组
@property (nonatomic, strong) NSMutableArray *mvItems; // MV
@property (nonatomic, strong) NSMutableArray *allPasterInfoArray; //网络请求到的动图资源

/**
 下载管理（动图）
 */
@property (nonatomic, strong) AliyunDownloadManager *downloadManager;

/**
 资源管理（动图）
 */
@property (nonatomic, strong) AliyunResourceManager *resourceManager;


/**
 最新的摄像头位置（前置还是后置）
 */
@property (nonatomic, assign) AliyunIRecorderCameraPosition lastCameraPosition;

/**
 iPhone4s机型以下
 */
@property (nonatomic, assign) BOOL belowiPhone4s;

/**
 倒计时控件
 */
@property (nonatomic, weak) UILabel *countLabel;

/**
 定时器
 */
@property (nonatomic,weak) NSTimer *timer;

/**
 高级美颜美白参数值（0-1）
 */
@property (nonatomic,assign) CGFloat beautyWhiteValue;

/**
 高级美颜磨皮参数值（0-1）
 */
@property (nonatomic,assign) CGFloat blurValue;

/**
 美肌大眼参数值（0-1）
 */
@property (nonatomic,assign) CGFloat bigEyeValue;

/**
 美肌瘦脸参数值（0-1）
 */
@property (nonatomic,assign) CGFloat slimFaceValue;

/**
 高级美颜红润参数值（0-1）
 */
@property (nonatomic,assign) CGFloat buddyValue;

@property (nonatomic, strong) AlivcPushBeautyDataManager *beautyFaceDataManager_normal;     //普通美颜的数据管理器
@property (nonatomic, strong) AlivcPushBeautyDataManager *beautyFaceDataManager_advanced;   //高级美颜的数据管理器
@property (nonatomic, strong) AlivcPushBeautyDataManager *beautySkinDataManager;            //美肌的数据管理器
@property (nonatomic, strong) AliyunEffectMvGroup *mvGroup; //之前应用的mv
@property (nonatomic, strong) AliyunMusicPickModel *music;  //之前应用的音乐
@property (nonatomic, assign) NSInteger tab;  //之前应用的音乐的所属0远程 1本地
@property (nonatomic, strong) AliyunReachability *reachability;       //网络监听
@property (nonatomic, strong) AliyunDBHelper *dbHelper; //数据库

/**
 美颜状态默认是否开启
 */
@property (nonatomic, assign) BOOL beauty;

/**
 是否是从后台进入前台这种场景录制
 */
@property (nonatomic, assign) BOOL backToFrontRecord;


/**
 开始录制时间
 */
@property (nonatomic, assign) double downTime;

/**
 结束录制时间
 */
@property (nonatomic, assign) double upTime;

/**
 开始录制视频段数
 */
@property (nonatomic, assign) NSInteger downVideoCount;

/**
 结束录制视频段数
 */
@property (nonatomic, assign) NSInteger upVideoCount;

/**
 当前的人脸动图
 */
@property (nonatomic, strong) AliyunEffectPaster *currentEffectPaster;

/**
 视频片段管理器
 */
@property (nonatomic, strong) AliyunClipManager *clipManager;

/**
 录制时间
 */
@property (nonatomic, assign) CFTimeInterval recordingDuration;

/**
 APP是否处于悬挂状态
 */
@property (nonatomic, assign) BOOL suspend;

@property (nonatomic, strong) FUAPIDemoBar *demoBar ;
@end

@implementation AliyunMagicCameraViewController

/**             ---------- FaceUnity ----------             **/

- (CVPixelBufferRef)customRenderedPixelBufferWithRawSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVPixelBufferRef buffer = CMSampleBufferGetImageBuffer(sampleBuffer) ;
    [[FUManager shareManager] renderItemsToPixelBuffer:buffer];
    return buffer ;
}

-(FUAPIDemoBar *)demoBar {
    if (!_demoBar) {
        _demoBar = [[FUAPIDemoBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 164 - 126, self.view.frame.size.width, 164)];
        
        _demoBar.itemsDataSource = [FUManager shareManager].itemsDataSource;
        _demoBar.selectedItem = [FUManager shareManager].selectedItem;
        _demoBar.skinDetectEnable = [FUManager shareManager].skinDetectEnable;
        _demoBar.blurShape = [FUManager shareManager].blurShape ;
        _demoBar.blurLevel = [FUManager shareManager].blurLevel ;
        _demoBar.whiteLevel = [FUManager shareManager].whiteLevel ;
        _demoBar.redLevel = [FUManager shareManager].redLevel;
        _demoBar.eyelightingLevel = [FUManager shareManager].eyelightingLevel ;
        _demoBar.beautyToothLevel = [FUManager shareManager].beautyToothLevel ;
        _demoBar.faceShape = [FUManager shareManager].faceShape ;
        
        _demoBar.enlargingLevel = [FUManager shareManager].enlargingLevel ;
        _demoBar.thinningLevel = [FUManager shareManager].thinningLevel ;
        _demoBar.enlargingLevel_new = [FUManager shareManager].enlargingLevel_new ;
        _demoBar.thinningLevel_new = [FUManager shareManager].thinningLevel_new ;
        _demoBar.jewLevel = [FUManager shareManager].jewLevel ;
        _demoBar.foreheadLevel = [FUManager shareManager].foreheadLevel ;
        _demoBar.noseLevel = [FUManager shareManager].noseLevel ;
        _demoBar.mouthLevel = [FUManager shareManager].mouthLevel ;
        
        _demoBar.filtersDataSource = [FUManager shareManager].filtersDataSource ;
        _demoBar.beautyFiltersDataSource = [FUManager shareManager].beautyFiltersDataSource ;
        _demoBar.filtersCHName = [FUManager shareManager].filtersCHName ;
        _demoBar.selectedFilter = [FUManager shareManager].selectedFilter ;
        [_demoBar setFilterLevel:[FUManager shareManager].selectedFilterLevel forFilter:[FUManager shareManager].selectedFilter] ;
        
        _demoBar.delegate = self;
    }
    return _demoBar ;
}


- (void)demoBarDidSelectedItem:(NSString *)itemName {
    
    [[FUManager shareManager] loadItem:itemName];
}

- (void)demoBarBeautyParamChanged {
    
    [FUManager shareManager].skinDetectEnable = _demoBar.skinDetectEnable;
    [FUManager shareManager].blurShape = _demoBar.blurShape;
    [FUManager shareManager].blurLevel = _demoBar.blurLevel ;
    [FUManager shareManager].whiteLevel = _demoBar.whiteLevel;
    [FUManager shareManager].redLevel = _demoBar.redLevel;
    [FUManager shareManager].eyelightingLevel = _demoBar.eyelightingLevel;
    [FUManager shareManager].beautyToothLevel = _demoBar.beautyToothLevel;
    [FUManager shareManager].faceShape = _demoBar.faceShape;
    [FUManager shareManager].enlargingLevel = _demoBar.enlargingLevel;
    [FUManager shareManager].thinningLevel = _demoBar.thinningLevel;
    [FUManager shareManager].enlargingLevel_new = _demoBar.enlargingLevel_new;
    [FUManager shareManager].thinningLevel_new = _demoBar.thinningLevel_new;
    [FUManager shareManager].jewLevel = _demoBar.jewLevel;
    [FUManager shareManager].foreheadLevel = _demoBar.foreheadLevel;
    [FUManager shareManager].noseLevel = _demoBar.noseLevel;
    [FUManager shareManager].mouthLevel = _demoBar.mouthLevel;
    
    [FUManager shareManager].selectedFilter = _demoBar.selectedFilter ;
    [FUManager shareManager].selectedFilterLevel = _demoBar.selectedFilterLevel;
}

-(void)dealloc {
    
    NSLog(@"~~~~~~%s delloc", __PRETTY_FUNCTION__);
    [_recorder destroyRecorder];
    _recorder = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.timer invalidate];
    self.timer = nil;
    [_recorder stopPreview];
    
#if SDK_VERSION == SDK_VERSION_CUSTOM
    [[AlivcShortVideoFaceUnityManager shareManager] destoryItems];
#endif
    
    [[FUManager shareManager] destoryItems];
}
/**             ---------- FaceUnity ----------             **/

- (instancetype)init
{
    self = [super init];
    if (self) {
        _beautyFaceDataManager_normal = [[AlivcPushBeautyDataManager alloc]initWithType:AlivcPushBeautyParamsTypeShortVideo customSaveString:@"beautyFaceDataManager_normal"];
        _beautyFaceDataManager_advanced = [[AlivcPushBeautyDataManager alloc]initWithType:AlivcPushBeautyParamsTypeShortVideo customSaveString:@"beautyFaceDataManager_advanced"];
        _beautySkinDataManager = [[AlivcPushBeautyDataManager alloc]initWithType:AlivcPushBeautyParamsTypeShortVideo customSaveString:@"beautySkinDataManager"];
    
        AlivcPushBeautyParams *params = [_beautyFaceDataManager_advanced getBeautyParamsOfLevel:[_beautyFaceDataManager_advanced getBeautyLevel]];
        self.beautyWhiteValue = params.beautyWhite/100.0;
        self.blurValue = params.beautyBuffing/100.0;
        self.buddyValue = params.beautyRuddy/100.0;
       
        AlivcPushBeautyParams *params2 = [_beautySkinDataManager getBeautyParamsOfLevel:[_beautySkinDataManager getBeautyLevel]];
        self.bigEyeValue = params2.beautyBigEye/100.0;
        self.slimFaceValue = params2.beautySlimFace/100.0;
        _beauty = NO;
        [self setupSDKUI];

       
    }
    return self;
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(!_uiConfig){
        _uiConfig = [[AlivcRecordUIConfig alloc]init];
    }
    [self configBaseUI];
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    if (CGSizeEqualToSize(size, CGSizeMake(320, 480)) || CGSizeEqualToSize(size, CGSizeMake(480, 320))) {
        _belowiPhone4s = YES;
    }
    [self updateUIWithVideoSize:_quVideo.outputSize];
    self.view.backgroundColor = [UIColor blackColor];
    
    //清除之前生成的录制路径
    NSString *recordDir = [AliyunPathManager createRecrodDir];
    [AliyunPathManager clearDir:recordDir];
    //生成这次的存储路径
    NSString *taskPath = [recordDir stringByAppendingPathComponent:[AliyunPathManager randomString]];
    //视频存储路径
    NSString *videoSavePath = [[taskPath stringByAppendingPathComponent:[AliyunPathManager randomString]] stringByAppendingPathExtension:@"mp4"];
    
    _recorder = [[AliyunIRecorder alloc] initWithDelegate:self videoSize:_quVideo.outputSize];
    _recorder.preview = self.magicCameraView.previewView;
    
    _recorder.outputType = AliyunIRecorderVideoOutputPixelFormatType420f;//SDK自带人脸识别只支持YUV格式
    _recorder.useFaceDetect = YES;
    _recorder.faceDetectCount = 2;
    _recorder.faceDectectSync = NO;
    _recorder.frontCaptureSessionPreset = @"AVCaptureSessionPreset960x540";
    _recorder.encodeMode = _quVideo.encodeMode;
    _recorder.GOP = _quVideo.gop;
    _recorder.videoQuality = (AliyunVideoQuality)_quVideo.videoQuality;
    _recorder.outputPath = _quVideo.outputPath?_quVideo.outputPath:videoSavePath;
    _recorder.taskPath = taskPath;
    _recorder.beautifyStatus = self.beauty;
    _recorder.beautifyValue = 50;
    _recorder.bitrate = _quVideo.bitrate;
    _recorder.delegate = self ;
    
    
    //录制片段设置
    _clipManager = _recorder.clipManager;
    _clipManager.maxDuration = _quVideo.maxDuration;
    _clipManager.minDuration = _quVideo.minDuration;
    self.magicCameraView.maxDuration = _clipManager.maxDuration;
    _lastCameraPosition = AliyunIRecorderCameraPositionFront;
    _quVideo.outputPath = _recorder.outputPath;

   
    [self addGesture];
    [self addNotification];
    [self setupFilterEffectData];
    [self fetchData];
    [self fetchMVListData];
    
    //网络状态判定
    _reachability = [AliyunReachability reachabilityForInternetConnection];
    [_reachability startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged)
                                                 name:AliyunPVReachabilityChangedNotification
                                               object:nil];
    
    [self.dbHelper openResourceDBSuccess:nil failure:nil];
    
    
    NSLog(@"---- aliyun SDK version: %@", [AliyunIRecorder version]);
    
    /**             FaceUnity             **/
    
    [[FUManager shareManager] loadItems];
    [self.view addSubview:self.demoBar ];
    /**             FaceUnity             **/
}


/**
 设置UI
 */
- (void)configBaseUI{
    self.magicCameraView = [[AliyunMagicCameraView alloc] initWithUIConfig:self.uiConfig];
    self.magicCameraView.delegate = (id)self;
    [self.view addSubview:self.magicCameraView];
    self.view.backgroundColor = _uiConfig.backgroundColor;
}


/**
 根据要求设置录制view的大小

 @param videoSize 输出的视频size
 */
- (void)updateUIWithVideoSize:(CGSize)videoSize {
    CGFloat r = videoSize.width / videoSize.height;
    BOOL top = (r - 9/16.0)<0.01; //是否是9：16的比例
    CGFloat y = ((r == 1) ? NoStatusBarSafeTop+44 : NoStatusBarSafeTop);
    CGRect preFrame = CGRectMake(0, y, ScreenWidth, ScreenWidth / r);
    
    if (_belowiPhone4s && top) {
        preFrame = CGRectMake((ScreenWidth - ScreenHeight * r)/2.f , 0, ScreenHeight * r, ScreenHeight);
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        _magicCameraView.previewView.frame = preFrame;
    }];
    
    y = CGRectGetMaxY(_magicCameraView.previewView.frame);
    if (_belowiPhone4s) {
        if (r == 1) {
            _magicCameraView.bottomView.frame = CGRectMake(0, y, ScreenWidth, ScreenHeight - y);
            self.magicCameraView.topView.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;

        } else {
            _magicCameraView.bottomView.frame = CGRectMake(0, ScreenHeight - 98, ScreenWidth, 98);
            self.magicCameraView.topView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.01];

        }
    } else {
        if (!top) {
            if (r == 1) {
                self.magicCameraView.topView.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
            }else{
                self.magicCameraView.topView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.01];
            }
            _magicCameraView.bottomView.frame = CGRectMake(0, y, ScreenWidth, ScreenHeight - y);

        } else {

            _magicCameraView.bottomView.frame = CGRectMake(0, ScreenHeight, 0, 0);
        
            self.magicCameraView.topView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.01];

        }
    }
    
}

/**
 录制界面的UI配置
 */
- (void)setupSDKUI {
    
    AliyunIConfig *config = [[AliyunIConfig alloc] init];
    
    config.backgroundColor = RGBToColor(35, 42, 66);
    config.timelineBackgroundCollor = RGBToColor(35, 42, 66);
    config.timelineDeleteColor = [UIColor redColor];
    config.timelineTintColor = RGBToColor(239, 75, 129);
    config.durationLabelTextColor = [UIColor redColor];
    config.hiddenDurationLabel = NO;
    config.hiddenFlashButton = NO;
    config.hiddenBeautyButton = NO;
    config.hiddenCameraButton = NO;
    config.hiddenImportButton = NO;
    config.hiddenDeleteButton = NO;
    config.hiddenFinishButton = NO;
    config.recordOnePart = NO;
    config.filterArray = @[@"filter/炽黄",@"filter/粉桃",@"filter/海蓝",@"filter/红润",@"filter/灰白",@"filter/经典",@"filter/麦茶",@"filter/浓烈",@"filter/柔柔",@"filter/闪耀",@"filter/鲜果",@"filter/雪梨",@"filter/阳光",@"filter/优雅",@"filter/朝阳",@"filter/波普",@"filter/光圈",@"filter/海盐",@"filter/黑白",@"filter/胶片",@"filter/焦黄",@"filter/蓝调",@"filter/迷糊",@"filter/思念",@"filter/素描",@"filter/鱼眼",@"filter/马赛克",@"filter/模糊"];
    config.imageBundleName = @"QPSDK";
    config.recordType = AliyunIRecordActionTypeClick;
    config.filterBundleName = nil;
    config.showCameraButton = NO;
    
    [AliyunIConfig setConfig:config];
}



#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    
    if ( [[UIApplication sharedApplication] canOpenURL: url] ) {
        
        NSURL*url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        [[UIApplication sharedApplication] openURL:url];
        
    }
    
}


/**
 添加手势
 */
- (void)addGesture
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToFocusPoint:)];
    [_recorder.preview addGestureRecognizer:tapGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    pinchGesture.delegate = self;
    [_recorder.preview addGestureRecognizer:pinchGesture];
    

}

//需要旋转 缩放同时起效 设置delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}


/**
 监听通知
 */
- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resourceDelete:) name:AliyunEffectResourceDeleteNotification object:nil];
    //监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mvButtonNotificationCenter:) name:@"AliyunNotificationMVButton" object:nil];
}

/**
 资源被删除的通知

 @param noti 通知对象
 */
- (void)resourceDelete:(NSNotification *)noti{
    AliyunEffectResourceModel *model = noti.userInfo[@"deleteModel"];
    if (model.effectType == AliyunEffectTypeMV) {
        if (self.mvGroup.eid == model.eid) {
            while (_magicCameraView.progressView.videoCount) {
                [self deleteButtonClicked];
            }
        }
        [self fetchMVListData];
    }
}

// 利用通知获取到录制中的
-(void)mvButtonNotificationCenter:(NSNotification *)noti
{
    //使用object处理消息
    UIButton *mvButton = [noti object];
    mvButton.enabled = ![_clipManager partCount];
    if([_clipManager partCount]){
        UIButton *alphaButton = [[UIButton alloc] initWithFrame:mvButton.frame];
        [alphaButton addTarget:self action:@selector(tip:) forControlEvents:UIControlEventTouchUpInside];
        [mvButton.superview addSubview:alphaButton];
    }
}


/**
 提示弹框

 @param button 提示按钮
 */
- (void)tip:(UIButton *)button{
    [MBProgressHUD showMessage:@"录制过程中, 不能更改MV效果" inView:self.view];
}

- (void)appWillResignActive:(id)sender
{
    if ([_recorder isRecording]) {
        [_recorder stopRecording];
        [_recorder stopPreview];
        _suspend = YES;
        if ([AliyunIConfig config].recordType == AliyunIRecordActionTypeClick) {
            [self.magicCameraView recordButtonTouchDown];
            [self.magicCameraView recordButtonTouchUp];
        }else{
            [self.magicCameraView recordButtonTouchUp];
        }
    }
    if (self.countLabel) {
        [self.timer invalidate];
        self.timer = nil;
        [self.countLabel removeFromSuperview];
        _suspend = YES;
        self.magicCameraView.circleBtn.hidden = NO;
        self.magicCameraView.countdownButton.enabled = YES;
    }
   
    AliyunIRecorderTorchMode mode = _recorder.torchMode;
    if (mode == AliyunIRecorderTorchModeOn) {
        [_recorder switchTorchWithMode:AliyunIRecorderTorchModeOff];
        [_magicCameraView.flashButton setImage:_uiConfig.ligheImageUnable forState:0];
        
    }
    self.backToFrontRecord = YES;
}

- (void)appDidBecomeActive:(id)sender
{
    
    if([_recorder isRecording]){
        [_recorder stopRecording];
        [_recorder stopPreview];
        _suspend = YES;
        if ([AliyunIConfig config].recordType == AliyunIRecordActionTypeClick) {
            [self.magicCameraView recordButtonTouchDown];
            [self.magicCameraView recordButtonTouchUp];
        }else{
            [self.magicCameraView recordButtonTouchUp];
        }
    }
    
    if (_suspend) {
        _suspend = NO;
        [_recorder startPreview];
    }
    
    _magicCameraView.hide = NO;
    [_magicCameraView resetRecordButtonUI];
    _magicCameraView.recording = NO;
    _magicCameraView.realVideoCount = [_clipManager partCount];
    // hide的隐藏状态会覆盖bottomHide的隐藏状态，重新调用bottomHide的set方法
    if (_magicCameraView.bottomHide == YES) {
        _magicCameraView.bottomHide = YES;
    }
}


#pragma mark - 请求数据

//滤镜
- (void)setupFilterEffectData
{
    NSArray *filters = @[@"炽黄",@"粉桃",@"海蓝",@"红润",@"灰白",
                         @"经典",@"麦茶",@"浓烈",@"柔柔",@"闪耀",
                         @"鲜果",@"雪梨",@"阳光",@"优雅",@"朝阳",
                         @"波普",@"光圈",@"海盐",@"黑白",@"胶片",
                         @"焦黄",@"蓝调",@"迷糊",@"思念",@"素描",
                         @"鱼眼",@"马赛克",@"模糊"];
    
    [self.effectFilterItems removeAllObjects];
    
    AliyunEffectFilter *effectFilter1 = [[AliyunEffectFilter alloc] init];
    [self.effectFilterItems addObject:effectFilter1];//作为空效果
    for (int idx = 0; idx < [filters count]; idx++ ){
        NSString *filterName = [NSString stringWithFormat:@"filter/%@",filters[idx]];
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:filterName ofType:nil];
        AliyunEffectFilter *effectFilter = [[AliyunEffectFilter alloc] initWithFile:path];
        
        [self.effectFilterItems addObject:effectFilter];
    }
}

// 设置人脸动图数据
- (void)setupPasterEffectData
{
    AliyunPasterInfo *empty1 = [[AliyunPasterInfo alloc] init];
    empty1.icon = [[NSBundle mainBundle] pathForResource:@"QPSDK.bundle/MV_none@2x" ofType:@"png"];
    empty1.bundlePath = @"123";
    
    NSString *filterName = [NSString stringWithFormat:@"hanfumei-800"];
    NSString *path = [[NSBundle mainBundle] pathForResource:filterName ofType:nil];
    
    AliyunPasterInfo *paster = [[AliyunPasterInfo alloc] initWithBundleFile:path];

    [self.effectGifItems removeAllObjects];
    [self.effectGifItems addObject:empty1];
    [self.effectGifItems addObject:paster];
    [self.effectGifItems addObjectsFromArray:self.allPasterInfoArray];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_magicCameraView refreshUIWithGifItems:self.effectGifItems];
    });
}


// 动图数据请求 + ui更新
- (void)fetchData
{
    [self.allPasterInfoArray removeAllObjects];
    AliyunHttpClient *httpClient = [[AliyunHttpClient alloc] initWithBaseUrl:kQPResourceHostUrl];
    NSDictionary *param = @{@"bundleId":@"com.duanqu.qusdkdemo"};
    [httpClient GET:@"api/res/prepose" parameters:param completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        if (error||![responseObject isKindOfClass:[NSArray class]]) {
            NSArray *groups = [self loadLocalData];
            
            if (groups.count > 0) {
                AliyunPasterInfoGroup *pasterInfoGroup = [groups objectAtIndex:0];
                
                self.allPasterInfoArray = [NSMutableArray arrayWithArray:pasterInfoGroup.pasterList];
            }
            [self setupPasterEffectData];
            
            return ;
        }
        
        for (NSDictionary *dict in responseObject) {
            AliyunPasterInfoGroup *group = [[AliyunPasterInfoGroup alloc] initWithDictionary:dict error:nil];
            
            for (AliyunPasterInfo *info in group.pasterList) {
                info.groupName = group.name;
                [self.allPasterInfoArray addObject:info];
            }
        }
        
        [self setupPasterEffectData];
    }];
}


- (AliyunDBHelper *)dbHelper {
    
    if (!_dbHelper) {
        _dbHelper = [[AliyunDBHelper alloc] init];
    }
    return _dbHelper;
}
//请求mv资源
- (void)fetchMVListData {
    self.mvItems = [[NSMutableArray alloc]init];
    __weak __typeof (self)weakSelf = self;
    NSLog(@"mv数据：重新加载");
    [AliyunResourceRequestManager requestWithEffectTypeTag:3 success:^(NSArray *resourceListArray) {
        
        //本地数据
        [self.dbHelper queryResourceWithEffecInfoType:3 success:^(NSArray *infoModelArray) {
            for (int i = 0;i < infoModelArray.count ; i++){
                AliyunEffectMvGroup *mvGroup = infoModelArray[i];
                [mvGroup setValue:@(3) forKey:@"effectType"];
                [mvGroup setValue:@(1) forKey:@"isDBContain"];
                [_mvItems addObject:mvGroup];
                NSLog(@"mv数据：本地添加%@ - %ld",mvGroup.name,(long)_mvItems.count);
            }
            
            
        } failure:^(NSError *error) {
            
        }];
        
        //远程数据
        for (NSDictionary *resourceDic in resourceListArray) {
            
            AliyunEffectResourceModel *model = [[AliyunEffectResourceModel alloc] initWithDictionary:resourceDic error:nil];
            [model setValue:@(3) forKey:@"effectType"];
            
            BOOL isContain = [self.dbHelper queryOneResourseWithEffectResourceModel:model];
            [model setValue:@(isContain) forKey:@"isDBContain"];
            
            
            if (isContain) {
                
            } else {
                [weakSelf.mvItems addObject:model];
                NSLog(@"mv数据：远程添加%@,--%ld",model.name,(long)_mvItems.count);
            }
        };
        
        
        AliyunEffectInfo *effctMore = [[AliyunEffectInfo alloc] init];
        effctMore.name = @"原片";
        effctMore.eid = -1;
        effctMore.effectType = 3;
        effctMore.icon = @"shortVideo_clear";
        effctMore.resourcePath = nil;
        effctMore.isDBContain = YES;
        [_mvItems insertObject:effctMore atIndex:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.magicCameraView refreshUIWithMVItems:weakSelf.mvItems];
        });
        
    } failure:^(NSError *error) {
        AliyunEffectInfo *effctMore = [[AliyunEffectInfo alloc] init];
        effctMore.name = @"原片";
        effctMore.eid = -1;
        effctMore.effectType = 3;
        effctMore.icon = @"shortVideo_clear";
        effctMore.resourcePath = nil;
        effctMore.isDBContain = YES;
        [_mvItems insertObject:effctMore atIndex:0];
        // 请求失败时加载本地数据
        NSLog(@"资源列表请求失败:%@", error);
        [self.dbHelper queryResourceWithEffecInfoType:3 success:^(NSArray *infoModelArray) {
            for (int i = 0;i < infoModelArray.count ; i++){
                AliyunEffectMvGroup *mvGroup = infoModelArray[i];
                [mvGroup setValue:@(3) forKey:@"effectType"];
                [mvGroup setValue:@(1) forKey:@"isDBContain"];
                [_mvItems addObject:mvGroup];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.magicCameraView refreshUIWithMVItems:_mvItems];
            });
            
        } failure:^(NSError *error) {
            
        }];
    }];
}

//本地的动图资源
- (NSArray *)loadLocalData
{
    return [self.resourceManager loadLocalFacePasters];
}

#pragma mark - 设备旋转

// 支持设备自动旋转
- (BOOL)shouldAutorotate
{
    return YES;
}

// 支持竖屏显示
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)appDidEnterBackground:(NSNotification *)noti
{
    [_recorder stopPreview];
}

- (void)appWillEnterForeground:(NSNotification *)noti
{
    if ([self.navigationController.childViewControllers lastObject] != self) {
        return;
    }
    
    
    [_recorder startPreview];
    _magicCameraView.flashButton.userInteractionEnabled = (_recorder.cameraPosition != 0);
    
    AliyunIRecorderTorchMode mode = _recorder.torchMode;
    if (mode == AliyunIRecorderTorchModeOn) {
        [_magicCameraView.flashButton setImage:_uiConfig.ligheImageOpen forState:0];
    } else if (mode == AliyunIRecorderTorchModeOff) {
        [_magicCameraView.flashButton setImage:_uiConfig.ligheImageClose forState:0];
    } else {
        [_magicCameraView.flashButton setImage:_uiConfig.ligheImageAuto forState:0];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_recorder startPreviewWithPositon:_lastCameraPosition];
    if (_recordingDuration >= _quVideo.minDuration) {
        self.magicCameraView.finishButton.enabled = YES;
    } else {
        self.magicCameraView.finishButton.enabled = NO;
    }
    NSLog(@"%zd",[_clipManager partCount]);
    [_magicCameraView.flashButton setImage:_uiConfig.ligheImageClose forState:0];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    //禁用侧滑手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_recorder stopPreview];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    //启用侧滑手势
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

/**
 点按手势的触发方法

 @param tapGesture 点按手势
 */
- (void)tapToFocusPoint:(UITapGestureRecognizer *)tapGesture {
    UIView *tapView = tapGesture.view;
    CGPoint point = [tapGesture locationInView:tapView];
    self.recorder.focusPoint = point;
    [self.magicCameraView cancelRecordBeautyView];
    
}


/**
 捏合手势的触发方法

 @param pinchGesture 捏合方法
 */
- (void)pinchGesture:(UIPinchGestureRecognizer *)pinchGesture {
    if (isnan(pinchGesture.velocity) || pinchGesture.numberOfTouches != 2) {
        return;
    }
    _recorder.videoZoomFactor = pinchGesture.velocity;
    pinchGesture.scale = 1;
    
    return;
}

#pragma mark - Getter -
- (NSMutableArray *)effectFilterItems
{
    if (!_effectFilterItems) {
        _effectFilterItems = [[NSMutableArray alloc] init];
    }
    return _effectFilterItems;
}

- (NSMutableArray *)effectGifItems
{
    if (!_effectGifItems) {
        _effectGifItems = [[NSMutableArray alloc] init];
    }
    return _effectGifItems;
}

- (AliyunDownloadManager *)downloadManager
{
    if (!_downloadManager) {
        _downloadManager = [[AliyunDownloadManager alloc] init];
    }
    return _downloadManager;
}

- (AliyunResourceManager *)resourceManager
{
    if (!_resourceManager) {
        _resourceManager = [[AliyunResourceManager alloc] init];
    }
    return _resourceManager;
}

- (NSMutableArray *)allPasterInfoArray
{
    
    if (!_allPasterInfoArray) {
        _allPasterInfoArray = [[NSMutableArray alloc] init];
    }
    return _allPasterInfoArray;
}

#pragma mark - MagicCameraViewDelegate -
    
- (void)magicCameraView:(AliyunMagicCameraView *)view dismissButtonTouched:(UIButton *)button{
    [self.magicCameraView cancelRecordBeautyView];
}

- (void)didChangeAdvancedMode{
    _recorder.beautifyStatus = NO;
    _recorder.beautifyValue = 0;
    AlivcPushBeautyParams *params = [_beautyFaceDataManager_advanced getBeautyParamsOfLevel:[_beautyFaceDataManager_advanced getBeautyLevel]];
    self.beautyWhiteValue = params.beautyWhite/100.0;
    self.blurValue = params.beautyBuffing/100.0;
    self.buddyValue = params.beautyRuddy/100.0;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:AlivcBeautySettingViewStyle_ShortVideo_BeautyFace_Advanced forKey:@"shortVideo_beautyType"];
    [defaults synchronize];
}
    
- (void)didChangeCommonMode{
    self.beautyWhiteValue = 0;
    self.blurValue = 0;
    self.buddyValue = 0;
    _recorder.beautifyStatus = YES;
    _recorder.beautifyValue = [_beautyFaceDataManager_normal getBeautyLevel]*20;
   
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:AlivcBeautySettingViewStyle_ShortVideo_BeautyFace_Base forKey:@"shortVideo_beautyType"];
    [defaults synchronize];
}
    
- (void)tapButtonClicked{
    [AliyunIConfig config].recordType = AliyunIRecordActionTypeClick;
}

- (void)longPressButtonClicked{
    [AliyunIConfig config].recordType = AliyunIRecordActionTypeHold;
}
- (void)didChangeAdvancedBeautyWhiteValue:(CGFloat)beautyWhiteValue{
    self.beautyWhiteValue = beautyWhiteValue/100;
    NSLog(@"beautyWhiteValue：%f",beautyWhiteValue);
}
- (void)didChangeAdvancedBlurValue:(CGFloat)blurValue{
    self.blurValue = blurValue/100;
    NSLog(@"blurValue：%f",blurValue);
}
- (void)didChangeAdvancedBigEye:(CGFloat)bigEyeValue{
    self.bigEyeValue = bigEyeValue/100;
    NSLog(@"bigEyeValue：%f",bigEyeValue);
}
- (void)didChangeAdvancedSlimFace:(CGFloat)slimFaceValue{
    self.slimFaceValue = slimFaceValue/100;
    NSLog(@"slimFaceValue：%f",slimFaceValue);
}
- (void)didChangeAdvancedBuddy:(CGFloat)buddyValue{
    self.buddyValue = buddyValue/100;
}
- (void)didChangeBeautyValue:(CGFloat)beautyValue{
    _recorder.beautifyValue = beautyValue*20;
    
}
//滤镜
- (void)didSelectEffectFilter:(AliyunEffectFilterInfo *)filter{
    AliyunEffectFilter *effectFilter =[[AliyunEffectFilter alloc] initWithFile:[filter localFilterResourcePath]];
    NSLog(@"vvvv effectfilter2:%@", effectFilter.path);
    [_recorder applyFilter:effectFilter];
}

- (void)recordButtonRecordVideo{

    self.downTime = CFAbsoluteTimeGetCurrent();
    self.downVideoCount = [_clipManager partCount];
     NSLog(@"开始拍摄：动图测试");
    _recorder.cameraRotate = [self cameraRotate];
    // 从后台进入前台，需要延迟才能点击录制
    if (self.backToFrontRecord) {
        _magicCameraView.hide = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          int code =  [_recorder startRecording];
            if (code == 0) {
                _magicCameraView.hide = YES;
            }else{
                _magicCameraView.hide = NO;
                [self.magicCameraView resetRecordButtonUI];
                self.magicCameraView.recording = NO;
                _magicCameraView.realVideoCount = [_clipManager partCount];
            }
            
            self.backToFrontRecord = NO;
        });
    }else{
        int code =  [_recorder startRecording];
        if (code == 0) {
            _magicCameraView.hide = YES;
        }else{
            _magicCameraView.hide = NO;
            [self.magicCameraView resetRecordButtonUI];
            self.magicCameraView.recording = NO;
            _magicCameraView.realVideoCount = [_clipManager partCount];
        }

    }
}

- (void)recordButtonPauseVideo{
    [_recorder stopRecording];
    self.upTime = CFAbsoluteTimeGetCurrent();
    _magicCameraView.hide = NO;
}

- (void)recordButtonFinishVideo{
    [_recorder stopPreview];
    _quVideo.videoRotate = [_clipManager firstClipVideoRotation];
    [_recorder finishRecording];
    _magicCameraView.hide = NO;
}

- (void)timerButtonClicked{
    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    countLabel.center = self.view.center;
    countLabel.backgroundColor = [UIColor clearColor];
    countLabel.textColor = [UIColor whiteColor];
    countLabel.font = [UIFont systemFontOfSize:144];
    countLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.text = @"3";
    [self.view addSubview:countLabel];
    self.countLabel = countLabel;
    
    self.magicCameraView.hide = YES;
    self.magicCameraView.circleBtn.hidden = YES;

    NSTimer* timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    self.timer = timer;
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

/**
 定时器触发方法（每隔一段时间调用一次）
 */
- (void)countDown{
    int count = [self.countLabel.text intValue] ;
    count--;
    if (count == 0) {
        [self.countLabel removeFromSuperview];
        if ([AliyunIConfig config].recordType == AliyunIRecordActionTypeClick) {
            [self.magicCameraView recordButtonTouchDown];
            [self.magicCameraView recordButtonTouchUp];
            
        }else{
            [self.magicCameraView recordButtonTouchDown];
        }
        
        self.magicCameraView.circleBtn.hidden = NO;
        [self.timer invalidate];
    }else{
        self.countLabel.text = [NSString stringWithFormat:@"%d",count];
    }
}

- (void)backButtonClicked
{
    [_recorder stopPreview];
    #if SDK_VERSION == SDK_VERSION_CUSTOM
        [[AlivcShortVideoFaceUnityManager shareManager] destoryItems];
    #endif
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)flashButtonClicked
{
    AliyunIRecorderTorchMode mode = [_recorder switchTorchMode];
    if (mode == AliyunIRecorderTorchModeOn) {
        return @"shortVideo_onLight";
    } else if (mode == AliyunIRecorderTorchModeOff) {
        return @"shortVideo_noLight";
    } else {
        return @"shortVideo_autoLight";
    }
}

- (void)cameraIdButtonClicked
{
    [_recorder switchCameraPosition];
    _lastCameraPosition = _recorder.cameraPosition;
    _magicCameraView.flashButton.enabled = (_recorder.cameraPosition != 0);
    
    AliyunIRecorderTorchMode mode = _recorder.torchMode;
    if (mode == AliyunIRecorderTorchModeOn) {
        [_magicCameraView.flashButton setImage:_uiConfig.ligheImageOpen forState:0];
    } else if (mode == AliyunIRecorderTorchModeOff) {
        [_magicCameraView.flashButton setImage:_uiConfig.ligheImageClose forState:0];
    } else {
        [_magicCameraView.flashButton setImage:_uiConfig.ligheImageAuto forState:0];
    }
    
}

- (void)musicButtonClicked
{
    [self pausePreview];
    AliyunMusicPickViewController *vc = [[AliyunMusicPickViewController alloc] init];
    vc.duration = _clipManager.maxDuration;
    vc.selectedMusic = self.music;
    vc.selectedTab = self.tab;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pausePreview {
    [_recorder stopPreview];
}

- (void)resumePreview {
    [_recorder startPreviewWithPositon:_lastCameraPosition];
    [_magicCameraView.flashButton setImage:_uiConfig.ligheImageClose forState:0];
}


//mv
- (void)didSelectEffectMV:(AliyunEffectMvGroup *)mvGroup {
    self.mvGroup = mvGroup;
    if (![NSStringFromClass([mvGroup class]) isEqualToString:@"AliyunEffectMvGroup"]&&mvGroup) {
        return;
    }
    if (mvGroup == NULL) {//点击原片 清掉所有mv效果
        [self.recorder applyMV:nil];
        //如果之前存在音乐的，播放此音乐
        if (![self.music.name isEqualToString:@"无音乐"] && self.music.path) {
            [self didSelectMusic:self.music tab:self.tab];
        }
        
        return;
    }
    
    float aspects[5] = {9/16.0, 3/4.0, 1.0, 4/3.0,16/9.0};
    CGSize fixedSize = self.magicCameraView.previewView.frame.size;
    float videoAspect = fixedSize.width/fixedSize.height;
    int index = 0;
    for (int i = 0; i < 5; i++) {
        index = i;
        if (videoAspect <= aspects[i]) break;
    }
    if (index > 0) {
        if (fabsf(videoAspect - aspects[index]) > fabsf(videoAspect-aspects[index-1])) {
            index = index-1;
        }
    }
    
    NSLog(@"mv奔溃原因查找index:%d",index);
    if (index < 0) {
        index = 0;
    }
    
    NSString *str = [mvGroup localResoucePathWithVideoRatio:index];
    
    NSLog(@"mv奔溃原因查找str:%@",str);
    if (str) {
        [self.recorder applyMV:[[AliyunEffectMV alloc] initWithFile:str]];
    }

}

-(void)deleteButtonClicked {
    [_clipManager deletePart];
    _magicCameraView.progressView.videoCount--;
    CGFloat percent = _clipManager.duration / _clipManager.maxDuration;
    [self.magicCameraView recordingPercent:percent];
    _recordingDuration = _clipManager.duration;
    _magicCameraView.finishButton.enabled = [_clipManager partCount];
    _magicCameraView.musicButton.enabled = ![_clipManager partCount];
    
    if (_recordingDuration >= _quVideo.minDuration) {
        self.magicCameraView.finishButton.enabled = YES;
    } else {
        self.magicCameraView.finishButton.enabled = NO;
    }
    if ((self.magicCameraView.progressView.videoCount == 0)&&([AliyunIConfig config].recordType == AliyunIRecordActionTypeHold)) {
        [self.magicCameraView.circleBtn setTitle:@"按住拍" forState:UIControlStateNormal];
    }
}

- (void)finishButtonClicked {
    if ([_clipManager partCount]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [_recorder finishRecording];
    }
}

- (CGFloat)cameraRotate {
    return 0;
}

//点击动图回调
- (void)effectItemFocusToIndex:(NSInteger)index cell:(UICollectionViewCell *)cell
{
    AliyunPasterInfo *pasterInfo = [self.effectGifItems objectAtIndex:index];
    if (pasterInfo.eid <= 0 || index == 0) {
        [self deleteCurrentEffectPaster];
        [_magicCameraView refreshUIWhenThePasterInfoApplyedWithIndex:0];
        return;
    }
    
    //new
    
    [self deleteCurrentEffectPaster]; //delete pre
    
    if (pasterInfo.bundlePath != nil) {
        [self addEffectWithPasterInfo:pasterInfo path:pasterInfo.bundlePath];
        return;
    }
    
    BOOL isExist = [pasterInfo fileExist];
    
    if (!isExist) {
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
                if (err) {
                    AliyunMagicCameraEffectCell *magicCell = (AliyunMagicCameraEffectCell *)cell;
                    [effectCell shouldDownload:YES];
                    magicCell.downloadImageView.image = [AlivcImage imageNamed:@"shortVideo_downloadFailed"];
                    [MBProgressHUD showMessage:@"网络不给力" inView:self.view];
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
 应用新的动图特效

 @param info 动图对应的模型类
 @param path 此动图对应的路径
 */
- (void)addEffectWithPasterInfo:(AliyunPasterInfo *)info path:(NSString *)path
{

    if(self.magicCameraView.recording){
        NSLog(@"动图测试:添加动图：录制中，不添加");
        return;
    }
    [self deleteCurrentEffectPaster];
    
   AliyunEffectPaster *paster = [[AliyunEffectPaster alloc] initWithFile:path];
    [_recorder applyPaster:paster];
    _currentEffectPaster = paster;
    //更新选中效果
    NSInteger newIndex = [self.effectGifItems indexOfObject:info];
    NSLog(@"动图测试:添加动图：%ld,%@\n",(long)newIndex,paster.path);
    NSLog(@"动图测试:添加动图 更新选中数据:%ld",(long)newIndex);
    [_magicCameraView refreshUIWhenThePasterInfoApplyedWithIndex:newIndex];
    
}

/**
 删除当前的动图
 */
- (void)deleteCurrentEffectPaster
{
    if (_currentEffectPaster) {
        [_recorder deletePaster:_currentEffectPaster];
       
         NSLog(@"动图测试：删除动图：%@\n",_currentEffectPaster.path);
         _currentEffectPaster = nil;
    }
}

- (void)recorderVideoDuration:(CGFloat)duration {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGFloat percent = duration / _clipManager.maxDuration;
        [self.magicCameraView recordingPercent:percent];
        _recordingDuration = duration;
    });
}

//需要reset
- (void)recordReset {
    if (_recordingDuration < [_clipManager minDuration]) {
        [_clipManager deletePart];
        _recordingDuration = 0;
        return;
    }
    
    _recordingDuration = 0;
    [_clipManager deleteAllPart];
}

- (void)didSelectRate:(CGFloat)rate {
    [self.recorder setRate:rate];
}

#pragma mark - AliyunMusicPickViewControllerDelegate

-(void)didSelectMusic:(AliyunMusicPickModel *)music tab:(NSInteger)tab{
    self.music = music;
    self.tab = tab;
    [self resumePreview];
    
    if ([music.name isEqualToString:@"无音乐"] || !music.path) {
        //清除音乐效果
        [_recorder applyMusic:nil];
        //尝试播放之前的mv
        if (self.mvGroup) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self didSelectEffectMV:self.mvGroup];
            });
            
        }
    }else{
        AliyunEffectMusic *effectMusic = [[AliyunEffectMusic alloc] initWithFile:music.path];
        effectMusic.startTime = music.startTime;
        effectMusic.duration = music.duration;
        [_recorder applyMusic:effectMusic];
        NSLog(@"%@",effectMusic.path);
    }
}

-(void)didCancelPick {
    [self resumePreview];
}

#pragma mark - AliyunIRecorderDelegate -

- (void)recorderDeviceAuthorization:(AliyunIRecorderDeviceAuthor)status {
    if (status == 1) {
        [self showAlertViewWithWithTitle:@"麦克风无权限"];
    } else if (status == 2) {
        [self showAlertViewWithWithTitle:@"摄像头无权限"];
    }
}

/**
 弹框提示
 
 @param title 弹框文字
 */
- (void)showAlertViewWithWithTitle:(NSString *)title {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"打开相机失败" message:title delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    
    NSDictionary *options = @{
                              (NSString*)kCVPixelBufferCGImageCompatibilityKey : @YES,
                              (NSString*)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES,
                              };
    
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image),
                                          CGImageGetHeight(image), kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    if (status!=kCVReturnSuccess) {
        NSLog(@"Operation failed");
    }
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, CGImageGetWidth(image),
                                                 CGImageGetHeight(image), 8, 4*CGImageGetWidth(image), rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGAffineTransform flipVertical = CGAffineTransformMake( 1, 0, 0, -1, 0, CGImageGetHeight(image) );
    CGContextConcatCTM(context, flipVertical);
    CGAffineTransform flipHorizontal = CGAffineTransformMake( -1.0, 0.0, 0.0, 1.0, CGImageGetWidth(image), 0.0 );
    CGContextConcatCTM(context, flipHorizontal);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    
    return pxbuffer;
}
// 集成faceunity
#if SDK_VERSION == SDK_VERSION_CUSTOM
    
//- (CVPixelBufferRef)customRenderedPixelBufferWithRawSampleBuffer:(CMSampleBufferRef)sampleBuffer {
//
//    if((self.beautyWhiteValue == 0)&&(self.blurValue == 0)&&(self.bigEyeValue == 0)&&(self.slimFaceValue == 0)&&(self.buddyValue == 0) ){
//        return CMSampleBufferGetImageBuffer(sampleBuffer);
//    }
//    CVPixelBufferRef buf = [[AlivcShortVideoFaceUnityManager shareManager] RenderedPixelBufferWithRawSampleBuffer:sampleBuffer beautyWhiteValue:self.beautyWhiteValue blurValue:self.blurValue bigEyeValue:self.bigEyeValue slimFaceValue:self.slimFaceValue buddyValue:self.buddyValue];
//
//    return buf;
//
//}

#endif
- (void)recorderDidStopRecording {
    // 注释允许多段录制
    //[_recorder finishRecording];
    self.upVideoCount = [_clipManager partCount];
    if ([AliyunIConfig config].recordType == AliyunIRecordActionTypeHold){
        // 录制时间小于0.2秒，并且录制结束后的视频段大于录制开始时的视频段，回删最后一段视频。
        if (((self.upTime - self.downTime)<0.2)&&(self.upVideoCount>self.downVideoCount)) {
            
            NSInteger code = [_clipManager partCount];
            [self deleteButtonClicked];
            [_clipManager partCount];
            NSInteger code2 = [_clipManager partCount];
            NSLog(@"录制参数：%zd--%zd",code,code2);
        }else if((self.upVideoCount == self.downVideoCount)){
            self.magicCameraView.progressView.videoCount--;
            CGFloat percent = _clipManager.duration / _clipManager.maxDuration;
            [self.magicCameraView recordingPercent:percent];
            _recordingDuration = _clipManager.duration;
            // 当录制结束后的视频段=录制开始时的视频=0时，恢复默认UI
            if ((self.downVideoCount==0)&&(self.upVideoCount == 0)) {
                self.magicCameraView.bottomHide = NO;
            }
        }
    }
    if (_recordingDuration >= _quVideo.minDuration) {
        self.magicCameraView.finishButton.enabled = YES;
    } else {
        self.magicCameraView.finishButton.enabled = NO;
    }
    _magicCameraView.musicButton.enabled = ![_clipManager partCount];

    
    [_magicCameraView destroy];
}

- (void)recorderDidFinishRecording {
    [[MBProgressHUD HUDForView:self.view] hideAnimated:YES];
    if (_suspend == NO) {
        if ([AliyunIConfig config].recordType == AliyunIRecordActionTypeClick) {
            if (self.magicCameraView.recording) {
                [self.magicCameraView recordButtonTouchDown];
                [self.magicCameraView recordButtonTouchUp];
            }
            
        }else if([AliyunIConfig config].recordType == AliyunIRecordActionTypeHold){
            [self.magicCameraView recordButtonTouchUp];
        }
        self.magicCameraView.hide = NO;
        //跳转处理
        NSString *outputPath = _recorder.outputPath;
        if (self.finishBlock) {
            self.finishBlock(outputPath);
        }else{
            [[AlivcShortVideoRoute shared]registerEditVideoPath:outputPath];
            [[AlivcShortVideoRoute shared]registerEditMediasPath:nil];
            UIViewController *editVC = [[AlivcShortVideoRoute shared]alivcViewControllerWithType:AlivcViewControlEdit];
            [self.navigationController pushViewController:editVC animated:YES];
        }
     
    }
   
}

- (void)recorderDidStopWithMaxDuration {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.magicCameraView.flashButton.userInteractionEnabled = (_recorder.cameraPosition != 0);
    self.magicCameraView.progressView.videoCount++;
    self.magicCameraView.progressView.showBlink = NO;
    [self.recorder finishRecording];
    [self.magicCameraView destroy];
}

- (void)recoderError:(NSError *)error
{
    _magicCameraView.hide = NO;
    [_magicCameraView resetRecordButtonUI];
    _magicCameraView.recording = NO;
    _magicCameraView.realVideoCount = [_clipManager partCount];
}

#pragma mark - 网络变化
//网络状态判定
- (void)reachabilityChanged{
    AliyunPVNetworkStatus status = [self.reachability currentReachabilityStatus];
    if (status != AliyunPVNetworkStatusNotReachable) {
        [self fetchData];
        [self fetchMVListData];
    }
}

@end
