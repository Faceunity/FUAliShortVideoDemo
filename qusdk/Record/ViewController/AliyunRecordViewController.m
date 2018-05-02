//
//  AliyunRecordViewController.m
//  AliyunVideo
//
//  Created by dangshuai on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunRecordViewController.h"
#import "AliyunRecordNavigationView.h"
#import "AliyunRecordBottomView.h"
#import "AliyunRecordFocusView.h"
#import <AliyunVideoSDKPro/AliyunIRecorder.h>
#import <CoreMotion/CoreMotion.h>
#import "AliyunPathManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AliyunMediator.h"
#import "AliyunRecoderFilterPlugin.h"

#import <FUAPIDemoBar/FUAPIDemoBar.h>
#import "FUManager.h"


@interface AliyunRecordViewController ()<AliyunIRecorderDelegate,UIGestureRecognizerDelegate, FUAPIDemoBarDelegate>


@property (nonatomic, strong) AliyunRecordNavigationView *navigationView;
@property (nonatomic, strong) AliyunRecordBottomView *bottomView;
@property (nonatomic, strong) AliyunRecordFocusView *focusView;
@property (nonatomic, strong) AliyunIRecorder *recorder;
@property (nonatomic, strong) AliyunClipManager *clipManager;
@property (nonatomic, strong) AliyunRecoderFilterPlugin *filterPlugin;
@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, assign) CGFloat lastPanY;
@property (nonatomic, assign) BOOL belowiPhone4s;
@property (nonatomic, assign) BOOL isFirstLoad;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, assign) int cameraRotate;


@property (nonatomic, strong) FUAPIDemoBar *demoBar ;
@end

@implementation AliyunRecordViewController
{
    int *tmpItem;
    CMSampleBufferRef tmpSampleBufferRef;
    int tmpFrameId;
    dispatch_semaphore_t sem;
    NSLock *lock;
    EAGLContext *mcontext;
    BOOL _suspend;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isCameraBack = NO;
        self.beautifyStatus = YES;
        self.beautifyValue = 100;
        self.torchMode = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isFirstLoad = YES;
    
    [self setupSubViews];
    
    [self addNotifications];
    
    NSString *videoSavePath = [[[AliyunPathManager createRecrodDir] stringByAppendingPathComponent:[AliyunPathManager uuidString]] stringByAppendingPathExtension:@"mp4"];
    NSString *taskPath = [AliyunPathManager createRecrodDir];
    if ([[NSFileManager defaultManager] fileExistsAtPath:taskPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:taskPath error:nil];
    }

    _recorder = [[AliyunIRecorder alloc] initWithDelegate:self videoSize:_quVideo.outputSize];
    _recorder.preview = self.previewView;
    _recorder.outputType = AliyunIRecorderVideoOutputPixelFormatTypeBGRA;
    _recorder.encodeMode = _quVideo.encodeMode;
    _recorder.GOP = _quVideo.gop;
    _recorder.videoQuality = (AliyunVideoQuality)_quVideo.videoQuality;
    _recorder.outputPath = _quVideo.outputPath?_quVideo.outputPath:videoSavePath;
    _recorder.taskPath = taskPath;
    _recorder.beautifyStatus = self.beautifyStatus;
    _recorder.beautifyValue = self.beautifyValue;
    _recorder.bitrate = _quVideo.bitrate;

    _previewView.backgroundColor = [UIColor clearColor];
    
    //录制片段设置
    _clipManager = _recorder.clipManager;
    _clipManager.maxDuration = _quVideo.maxDuration;
    _clipManager.minDuration = _quVideo.minDuration;
    
    _quVideo.outputPath = _recorder.outputPath;
    
    //滤镜插件
    if ([AliyunIConfig config].filterArray.count > 0) {
        _filterPlugin = [[AliyunRecoderFilterPlugin alloc] initWithFilterArry:[AliyunIConfig config].filterArray];
        _filterPlugin.disPlayView = _previewView;
        _filterPlugin.delegate = (id<AliyunRecoderFilterPluginDelegate>)self;
    }
    
    
    /**             FaceUnity             **/
    
    [[FUManager shareManager] loadItems];
    [self.view addSubview:self.demoBar ];
    /**             FaceUnity             **/
}

/**             ---------- FaceUnity ----------             **/

- (void)recorderOutputVideoRawSampleBuffer:(CMSampleBufferRef)sampleBuffer{

    CVPixelBufferRef buffer = CMSampleBufferGetImageBuffer(sampleBuffer) ;
    [[FUManager shareManager] renderItemsToPixelBuffer:buffer ItemFlipx:_isCameraBack];
    
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
    
    [[FUManager shareManager] destoryItems];
    [_recorder destroyRecorder];
}

/**             ---------- FaceUnity ----------             **/


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    if (_isFirstLoad) {
        _isFirstLoad = NO;
        [_recorder startPreviewWithPositon:AliyunIRecorderCameraPositionFront];
    } else {
        [_recorder startPreviewWithPositon:_recorder.cameraPosition];
    }
    [_recorder switchTorchWithMode:_torchMode];
    [self startMotionManager];
    
    
//   tmpItem = [[AuthFaceUnity share] loadItem];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self addWaterMark];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_recorder stopPreview];
    [_motionManager stopDeviceMotionUpdates];
}


- (void)addWaterMark {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"watermark" ofType:@"png"];
    AliyunEffectImage *testImage = [[AliyunEffectImage alloc] initWithFile:path];
    // frame的宽高要和图片宽高等比例
    testImage.frame = CGRectMake(20, 20, 70, 50);
    [_recorder applyImage:testImage];
}

- (void)setupSubViews {
    self.view.backgroundColor = [AliyunIConfig config].backgroundColor;
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    if (CGSizeEqualToSize(size, CGSizeMake(320, 480)) || CGSizeEqualToSize(size, CGSizeMake(480, 320))) {
        _belowiPhone4s = YES;
    }

    [self.view addSubview:self.previewView];
    [self.view addSubview:self.navigationView];
    [self.view addSubview:self.bottomView];
    [self.previewView addSubview:self.focusView];
    [self.previewView addSubview:self.durationLabel];
    [self addGesture];
    [self.navigationView setupBeautyStatus:self.beautifyStatus flashStatus:self.torchMode];
    [self updateUIWithVideoSize:_quVideo.outputSize];
    
    
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];

}

- (void)startMotionManager {
    if (_motionManager == nil) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    //实时获取设备旋转
    _motionManager.deviceMotionUpdateInterval = 1.0;
//    __weak typeof(self) weakSelf = self;
    [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue new] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        CMDeviceMotion *deviceMotion = _motionManager.deviceMotion;
        if (deviceMotion) {
            int rotate = 0;
            double gravityX = -deviceMotion.gravity.x;
            double gravityY = deviceMotion.gravity.y;
            double gravityZ = deviceMotion.gravity.z;
            
            if (gravityZ <= -0.9 || gravityZ >= 0.9) {
                rotate = 0;
            } else {
                BOOL isMirror = _recorder.cameraPosition == AliyunIRecorderCameraPositionBack;

                float radians = atan2(gravityY, gravityX);
                if(radians >= -2 && radians <= -1) {                  // up
                    rotate = 0;
                }else if(radians >= -0.5 && radians <= 0.5) {         // right
                    rotate = isMirror ? 270 : 270;
                }else if(radians >= 1.0 && radians <= 2.0)  {         // down
                    rotate = 180;
                }else if(radians <= -2.5 || radians >= 2.5) {         // left
                    rotate = isMirror ? 90 : 90;
                }
            }
            _cameraRotate = rotate;
//            _recorder.cameraRotate = _cameraRotate;//需设置 否则拍摄旋转角度有问题
        }
    }];
    
}


- (void)addGesture {
    UITapGestureRecognizer *previewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewTapGesture:)];
    previewTap.delegate = self;
    [_previewView addGestureRecognizer:previewTap];
    
    UIPanGestureRecognizer *previewPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(previewPanGesture:)];
    previewPan.delegate = self;
    [_previewView addGestureRecognizer:previewPan];
    
    UIPinchGestureRecognizer *previewPinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(previewPinchGesture:)];
    previewPinch.delegate = self;
    [_previewView addGestureRecognizer:previewPinch];
}

//需要旋转 缩放同时起效 设置delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}


- (void)previewTapGesture:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:_previewView];
    _recorder.focusPoint = point;
    _focusView.center = point;
    [_focusView refreshPosition];
}

- (void)previewPanGesture:(UIPanGestureRecognizer *)gesture {
    if (_focusView.alpha == 0 || gesture.numberOfTouches == 2) {
        return;
    }
    CGPoint point = [gesture translationInView:_previewView];
    CGFloat y = point.y;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _lastPanY = y;
    }
    if (fabs(y) > fabs(point.x)) {
        CGFloat v = (_lastPanY - y)/CGRectGetHeight(_previewView.bounds);
        _recorder.exposureValue += v;
        [_focusView changeExposureValue:_recorder.exposureValue];
    }
    _lastPanY = y;
}

- (void)previewPinchGesture:(UIPinchGestureRecognizer *)gesture {
    if (isnan(gesture.velocity) || gesture.numberOfTouches != 2) {
        return;
    }
    _recorder.videoZoomFactor = gesture.velocity;
    gesture.scale = 1;
    
    return;
}

#pragma mark --- AliyunIRecorderDelegate

- (void)recorderDeviceAuthorization:(AliyunIRecorderDeviceAuthor)status {
    if (status == 1) {
        [self showAlertViewWithWithTitle:@"麦克风无权限"];
    } else if (status == 2) {
        [self showAlertViewWithWithTitle:@"摄像头无权限"];
    }
}

- (void)showAlertViewWithWithTitle:(NSString *)title {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"打开相机失败" message:title delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void)recorderDidFinishRecording {
    if (_delegate) {
        [_delegate recoderFinish:self videopath:_recorder.outputPath];
    }
}

- (void)recorderDidStopWithMaxDuration {
    [_bottomView updateRecordStatus];
    [_bottomView updateRecordTypeToEndRecord];
    [_navigationView updateNavigationStatusWithRecord:NO];
    _durationLabel.hidden = YES;
    [self bottomViewFinishVideo];
}
- (void)recorderVideoDuration:(CGFloat)duration {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"已录制:%f",duration);
        [_bottomView updateVideoDuration:duration];
        [_navigationView updateNavigationStatusWithDuration:duration];
        [self showDuration:duration];
    });
}

- (void)recoderError:(NSError *)error {
    NSLog(@"录制错误");
    // update UI
    [self.bottomView deleteLastProgress];
    [_clipManager deletePart];
    [_bottomView updateVideoDuration:_clipManager.duration];
    [_navigationView updateNavigationStatusWithDuration:_clipManager.duration];
}

- (void)showDuration:(CGFloat)duration {
    int d = duration;
    int m = d / 60;
    int s = d % 60;
    _durationLabel.text = [NSString stringWithFormat:@"%02d:%02d",m,s];
}
////接入faceunity
//- (NSInteger)recorderOutputVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer textureName:(NSInteger)textureName {
//    if (tmpItem == NULL) {
//        NSLog(@"~~~~~~~~~~~环境未好");
//        return textureName;
//    }
//    
//    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
//    
//    int h = (int)CVPixelBufferGetHeight(pixelBuffer);
//    int w = (int)CVPixelBufferGetWidth(pixelBuffer);
//    int stride = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
//    
//    TIOSDualInput input;
//    input.p_BGRA = CVPixelBufferGetBaseAddress(pixelBuffer);
//    input.tex_handle = (GLuint)textureName;
//    input.format = FU_IDM_FORMAT_BGRA;
//    input.stride_BGRA = stride;
//    
//    GLuint outHandle;
//    fuRenderItemsEx(FU_FORMAT_RGBA_TEXTURE, &outHandle, FU_FORMAT_INTERNAL_IOS_DUAL_INPUT, &input, w, h, tmpFrameId, tmpItem, 1);
//    tmpFrameId++;
//    
//    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
//    
//    
//    return outHandle;
//}

//- (CVPixelBufferRef)customRenderedPixelBufferWithRawSampleBuffer:(CMSampleBufferRef)sampleBuffer {
//    
//    CVPixelBufferRef pixbuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    
//    if (tmpItem == NULL) {
//        NSLog(@"~~~~~~~~~~~环境未好");
//        return pixbuffer;
//    }
//    
//   	if(!mcontext){
//        mcontext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
//    }
//    if(!mcontext || ![EAGLContext setCurrentContext:mcontext]){
//        NSLog(@"faceunity: failed to create / set a GLES2 context");
//    }
//
//    CVPixelBufferRef pix = [[FURenderer shareRenderer] renderPixelBuffer:pixbuffer withFrameId:tmpFrameId items:tmpItem itemCount:1];
//    tmpFrameId++;
//    return pix;
//}


#pragma mark --- AliyunRecordNavigationViewDelegate
- (void)navigationBackButtonClick {
    if (_delegate) {
        [_delegate exitRecord];
    }

}

- (void)navigationRatioDidChangedWithValue:(CGFloat)r {
    
    CGSize videoSize = [_quVideo updateVideoSizeWithRatio:r];
    [_recorder stopPreview];
    [_recorder reStartPreviewWithVideoSize:videoSize];
    [self updateUIWithVideoSize:videoSize];
}

- (void)updateUIWithVideoSize:(CGSize)videoSize {
    CGFloat r = videoSize.width / videoSize.height;
    BOOL top = (r - 9/16.0)<0.01;
    CGFloat y = top ? SafeTop : SafeTop+44;

    CGRect preFrame = CGRectMake(0, y, ScreenWidth, ScreenWidth / r);
    
    if (_belowiPhone4s && top) {
        preFrame = CGRectMake((ScreenWidth - ScreenHeight * r)/2.f , 0, ScreenHeight * r, ScreenHeight);
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        _previewView.frame = preFrame;
    }];
    
    y = CGRectGetMaxY(_previewView.frame);
    if (_belowiPhone4s) {
        if (r == 1) {
            _bottomView.frame = CGRectMake(0, y, ScreenWidth, ScreenHeight - y);
            _durationLabel.center = CGPointMake(ScreenWidth /2.f, CGRectGetHeight(_previewView.bounds) - 10);
        } else {
            _bottomView.frame = CGRectMake(0, ScreenHeight - 98, ScreenWidth, 98);
            _durationLabel.center = CGPointMake(CGRectGetMidX(_previewView.bounds), CGRectGetHeight(_previewView.bounds) - 108);
        }
    } else {
        if (!top) {
            _bottomView.frame = CGRectMake(0, y, ScreenWidth, ScreenHeight - y);
            _durationLabel.center = CGPointMake(ScreenWidth /2.f, CGRectGetHeight(_previewView.bounds) - 10);
        } else {
            CGFloat bottomTop = ScreenWidth * 4/3.f + 44 + SafeTop;
            if (ScreenHeight-y > 0 && y-bottomTop > 60) {
                [_bottomView updateHeight:y-bottomTop];
            }
            _durationLabel.center = CGPointMake(ScreenWidth / 2.f, 34 + ScreenWidth *4/3.f);
        }
    }

}

- (void)navigationBeautyDidChangedStatus:(BOOL)on {
    _recorder.beautifyStatus = !_recorder.beautifyStatus;
}

- (void)navigationCamerationPositionDidChanged:(BOOL)front {
    
    [_recorder switchCameraPosition];
    
/**             ---------- FaceUnity ----------             **/
    [[FUManager shareManager] onCameraChange];
/**             ---------- FaceUnity ----------             **/
    
    _isCameraBack = front ;
    
}

- (NSInteger)navigationFlashModeDidChanged {
    _torchMode = [_recorder switchTorchMode];
    return (NSInteger)_torchMode;
}

#pragma mark --- AliyunRecordBottomViewDelegate

- (void)bottomViewRecordVideo {
//    if ([_clipManager partCount] == 0) {
        _recorder.cameraRotate = _cameraRotate; // 旋转角度以第一段视频为准  产品需求更改:不以第一段视频角度计算
//    }

    [_recorder startRecording];

    _durationLabel.hidden = [AliyunIConfig config].hiddenDurationLabel;
    [_navigationView updateNavigationStatusWithRecord:YES];
}

- (void)bottomViewPauseVideo {
    [_recorder stopRecording];
    _durationLabel.hidden = YES;
    [_navigationView updateNavigationStatusWithRecord:NO];
}

- (void)bottomViewDeleteFinished {
    [_clipManager deletePart];
    [_bottomView updateVideoDuration:_clipManager.duration];
    [_navigationView updateNavigationStatusWithDuration:_clipManager.duration];
}

- (void)bottomViewFinishVideo {
    
    [_recorder stopPreview];
//    // TODO:有没有更好的判断方法
//    if ([[self.delegate class] isEqual:NSClassFromString(@"AliyunVideoBase")]) {
//        [_recorder finishRecording];
//    }
//
    _quVideo.videoRotate = [_clipManager firstClipVideoRotation];
    if (!self.isSkipEditVC) {
        [_recorder finishRecording];
    }else {
#if SDK_VERSION == SDK_VERSION_BASE
        [_recorder destroyRecorder];
#endif
        if (_delegate) {
            [_delegate recoderFinish:self videopath:_recorder.outputPath];
        }
    }
}

- (void)bottomViewShowLibrary {
        
    if (_delegate) {
        [_delegate recordViewShowLibrary:self];
        return;
    }
}

- (void)selectFilter:(AliyunEffectFilter*)filter index:(NSInteger)index{

    [_recorder applyFilter:filter];
}

#pragma mark --- Get

- (AliyunRecordNavigationView *)navigationView {
    if (!_navigationView) {
        _navigationView = [[AliyunRecordNavigationView alloc] initWithFrame:CGRectMake(0, SafeTop, ScreenWidth, 44)];
        _navigationView.delegate = (id<AliyunRecordNavigationViewDelegate>)self;
    }
    return _navigationView;
}

- (AliyunRecordBottomView *)bottomView {
    if (!_bottomView) {
        CGRect rect = CGRectMake(0,ScreenWidth * 4/3.f + 44 + SafeTop, ScreenWidth, ScreenHeight - ScreenWidth * 4/3.f - 44 - SafeTop - SafeBottom);
        if (_belowiPhone4s) {
            rect.size.height = 98;
            rect.origin.y = ScreenHeight - 98;
        }
        _bottomView = [[AliyunRecordBottomView alloc] initWithFrame:rect];
        _bottomView.delegate = (id<AliyunRecordBottomViewDelegate>)self;
        _bottomView.minDuration = _quVideo.minDuration;
        _bottomView.maxDuration = _quVideo.maxDuration;
    }
    return _bottomView;
}

- (UIView *)previewView {
    if (!_previewView) {
        _previewView = [[UIView alloc] initWithFrame:CGRectMake(0, 44+SafeTop, ScreenWidth, ScreenWidth * 4/3.f)];
        _previewView.clipsToBounds = YES;
        
    }
    return _previewView;
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.bounds = CGRectMake(0, 0, 100, 10);
        int a = _belowiPhone4s ? 98 : 10;
        CGPoint p = CGPointMake(ScreenWidth / 2.f, ScreenWidth * 4/3.f - a);
        _durationLabel.center = p;
        _durationLabel.textAlignment = 1;
        _durationLabel.textColor = [AliyunIConfig config].durationLabelTextColor;
        _durationLabel.font = [UIFont systemFontOfSize:10];
        _durationLabel.hidden = YES;
        _durationLabel.text = @"00:00";
    }
    return _durationLabel;
}

- (AliyunRecordFocusView *)focusView {
    if (!_focusView) {
        _focusView = [[AliyunRecordFocusView alloc] init];
        _focusView.bounds = CGRectMake(0, 0, 72, 72);
        _focusView.center = CGPointMake(ScreenWidth /2.f, CGRectGetMidY(_previewView.bounds));
        _focusView.alpha = 0;
        _focusView.userInteractionEnabled = NO;
    }
    return _focusView;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)appWillResignActive:(id)sender
{
    if ([self.navigationController.childViewControllers lastObject] != self) {
        return;
    }
    if ([_recorder isRecording]) {
        [_recorder stopRecording];
        [_recorder stopPreview];
        _suspend = YES;
    }
}

- (void)appDidBecomeActive:(id)sender
{
    if ([self.navigationController.childViewControllers lastObject] != self) {
        return;
    }
    if (_suspend) {
        _suspend = NO;
        
        [_recorder startPreview];
        [_recorder switchTorchWithMode:_torchMode];
        [self.navigationView updateNavigationFlashStatus:_torchMode];
        [self.navigationView updateNavigationStatusWithRecord:NO];
        [self.bottomView updateRecordTypeToEndRecord];
    }
}

@end
