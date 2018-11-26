//
//  MagicCameraView.m
//  AliyunVideo
//
//  Created by Vienta on 2017/1/3.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunMagicCameraView.h"
#import "AVC_ShortVideo_Config.h"
#import "AlivcUIConfig.h"
#import "AliyunRecordBeautyView.h"
@interface AliyunMagicCameraView ()<AliyunRecordBeautyViewDelegate>

/**
 返回按钮
 */
@property (nonatomic, strong) UIButton *backButton;

/**
 前后摄像头切换按钮
 */
@property (nonatomic, strong) UIButton *cameraIdButton;

/**
 回删按钮
 */
@property (nonatomic, strong) UIButton *deleteButton;

/**
 美颜按钮（录制按钮左边）
 */
@property (nonatomic, strong) UIButton *beautyButton;


/**
 动图按钮（录制按钮右边）
 */
@property (nonatomic, strong) UIButton *gifPictureButton;

/**
 时间显示控件
 */
@property (nonatomic, strong) UILabel *timeLabel;

/**
 手指按下录制按钮的时间
 */
@property (nonatomic, assign) double startTime;

/**
 点击录制按钮旁边左右两个按钮弹出的view
 */
@property (nonatomic, weak) AliyunRecordBeautyView *beautyView;

/**
 录制按钮右边的按钮
 */
@property (nonatomic, strong) AliyunRecordBeautyView *rightView;
/**
 录制按钮左边的按钮
 */
@property (nonatomic, strong) AliyunRecordBeautyView *leftView;
/**
 底部显示三角形的view
 */
@property (nonatomic, strong) UIImageView *triangleImageView;

/**
 显示单击拍文字的按钮
 */
@property (nonatomic, strong) UIButton *tapButton;

/**
 显示长按拍文字的按钮
 */
@property (nonatomic, strong) UIButton *longPressButton;

/**
 时间显示控件旁边的小圆点，正在录制的时候显示
 */
@property (nonatomic, strong) UIImageView *dotImageView;

@property (nonatomic, copy) NSArray *effectItems; //动图
@property (nonatomic, strong) NSMutableArray *mvItems; //mv

/**
 短视频拍摄界面UI配置
 */
@property (nonatomic, strong) AlivcRecordUIConfig *uiConfig;

/**
  是否是第一次加载动图和MV数据
 */
@property (nonatomic, assign) BOOL isFirst;
@end

@implementation AliyunMagicCameraView

- (instancetype)initWithUIConfig:(AlivcRecordUIConfig *)uiConfig{
    self = [super initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    if(self){
        _uiConfig = uiConfig;
        [self setupSubview];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
    
        [self setupSubview];
    }
    return self;
}

/**
 添加子控件
 */
- (void)setupSubview
{
    
    if(!_uiConfig){
        _uiConfig = [[AlivcRecordUIConfig alloc]init];
    }
    self.mvItems = [[NSMutableArray alloc] init];
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0,(IPHONEX ? 44 : 0), CGRectGetWidth(self.bounds), 44+8)];
    [self addSubview:self.topView];
    
    [self.topView addSubview:self.backButton];
    [self.topView addSubview:self.cameraIdButton];
    [self.topView addSubview:self.flashButton];
    self.flashButton.enabled = NO;
    [self.topView addSubview:self.countdownButton];
    [self.topView addSubview:self.finishButton];
    [self.topView addSubview:self.musicButton];

    self.previewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    [self insertSubview:self.previewView atIndex:0];
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 60 , CGRectGetWidth(self.bounds), 60)];
    self.bottomView.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
    [self addSubview:self.bottomView];
    
    self.topView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.01];
    
    
    self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2-40, ScreenHeight-42 - SafeBottom, 70, 40)];
    self.deleteButton.hidden = YES;
    self.deleteButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.deleteButton setTitle:@" 回删" forState:UIControlStateNormal];
    [self.deleteButton setImage:_uiConfig.deleteImage forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(deletePartClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.deleteButton];
    
    self.rateView = [[AliyunRateSelectView alloc] initWithItems:@[@"极慢",@"慢",@"标准",@"快",@"极快"]];
    self.rateView.frame = CGRectMake(40, ScreenHeight-169-40 - SafeBottom, ScreenWidth-80, 40);
    self.rateView.selectedSegmentIndex = 2;
    [self.rateView addTarget:self action:@selector(rateChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.rateView];
    
    self.circleBtn = [[MagicCameraPressCircleView alloc] initWithFrame:CGRectMake(ScreenWidth/2-40, ScreenHeight - 120 - SafeBottom, 80, 80)];
    [self addSubview:self.circleBtn];
    [self.circleBtn addTarget:self action:@selector(recordButtonTouchUp) forControlEvents:UIControlEventTouchUpInside];
    [self.circleBtn addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [self.circleBtn addTarget:self action:@selector(recordButtonTouchUp) forControlEvents:UIControlEventTouchDragOutside];
    
    
    self.beautyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.beautyButton setImage:_uiConfig.faceImage forState:UIControlStateNormal];
    [self.beautyButton setBackgroundColor:[UIColor clearColor]];
    [self.beautyButton addTarget:self action:@selector(beauty) forControlEvents:UIControlEventTouchUpInside];
    self.beautyButton.frame = CGRectMake(0, 0, 40, 40);
    CGFloat y = self.circleBtn.center.y;
    CGFloat x = ScreenWidth/2-120;
    self.beautyButton.center = CGPointMake(x, y);
    [self addSubview:self.beautyButton];
    
    self.gifPictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.gifPictureButton setImage:_uiConfig.magicImage forState:UIControlStateNormal];
    [self.gifPictureButton setBackgroundColor:[UIColor clearColor]];
    [self.gifPictureButton addTarget:self action:@selector(getGifPictureView) forControlEvents:UIControlEventTouchUpInside];
    self.gifPictureButton.frame = CGRectMake(0, 0, 40, 40);
    self.gifPictureButton.center = CGPointMake(ScreenWidth/2+120, y);
    [self addSubview:self.gifPictureButton];

    
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.frame = CGRectMake(0, 0, 60, 16);
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.center = CGPointMake(ScreenWidth / 2+10, ScreenHeight - 152-SafeBottom);
    [self addSubview:self.timeLabel];
    
    self.dotImageView = [[UIImageView alloc] initWithImage:_uiConfig.dotImage];
    self.dotImageView.center = CGPointMake(ScreenWidth/2-30, self.timeLabel.center.y);
    self.dotImageView.hidden = YES;
    [self addSubview:self.dotImageView];
    
    self.progressView = [[QUProgressView alloc] initWithFrame: CGRectMake(0, IPHONEX ? 44 : 0, ScreenWidth, 4)];
    self.progressView.showBlink = NO;
    self.progressView.showNoticePoint = YES;
    self.progressView.maxDuration = 1;
    self.progressView.minDuration = 0;
    self.progressView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.01];
    [self addSubview:self.progressView];
    
    self.triangleImageView = [[UIImageView alloc] initWithImage:_uiConfig.triangleImage];
    self.triangleImageView.center = CGPointMake(ScreenWidth/2, ScreenHeight-8-SafeBottom);
    [self addSubview:self.triangleImageView];
    
    UIButton *tapButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2-21, ScreenHeight-36-SafeBottom, 45, 20)];
    [tapButton setTitle:@"单击拍" forState:UIControlStateNormal];
    [tapButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [tapButton addTarget:self action:@selector(tapButtonClick) forControlEvents:UIControlEventTouchUpInside];
    tapButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.tapButton = tapButton;
    [self addSubview:tapButton];
    
    UIButton *longPressButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2-21+72, ScreenHeight-36-SafeBottom, 45, 20)];
    [longPressButton setTitle:@"长按拍" forState:UIControlStateNormal];
    [longPressButton setTitleColor:AlivcOxRGB(0xc3c5c6) forState:UIControlStateNormal];
    [longPressButton addTarget:self action:@selector(longPressButtonClick) forControlEvents:UIControlEventTouchUpInside];
    longPressButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.longPressButton = longPressButton;
    [self addSubview:longPressButton];
    
    [self setExclusiveTouchInButtons];
}

/**
 按钮间设置不能同时点击
 */
- (void)setExclusiveTouchInButtons{
    [self.tapButton setExclusiveTouch:YES];
    [self.beautyButton setExclusiveTouch:YES];
    [self.gifPictureButton setExclusiveTouch:YES];
    [self.musicButton setExclusiveTouch:YES];
    [self.countdownButton setExclusiveTouch:YES];
    [self.deleteButton setExclusiveTouch:YES];
    [self.finishButton setExclusiveTouch:YES];
}


/**
 显示单击拍按钮的点击事件
 */
- (void)tapButtonClick{
    CGFloat y = self.tapButton.center.y;
    self.tapButton.center = CGPointMake(ScreenWidth/2, y);
    self.longPressButton.center = CGPointMake(ScreenWidth/2+72, y);
    [self.tapButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.longPressButton setTitleColor:AlivcOxRGB(0xc3c5c6) forState:UIControlStateNormal];
    [self.circleBtn setTitle:@"" forState:UIControlStateNormal];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapButtonClicked)]) {
        [self.delegate tapButtonClicked];
    }
    
}

/**
 显示长按拍按钮的点击时间
 */
- (void)longPressButtonClick{
    CGFloat y = self.tapButton.center.y;
    self.tapButton.center = CGPointMake(ScreenWidth/2-72, y);
    self.longPressButton.center = CGPointMake(ScreenWidth/2, y);
    [self.tapButton setTitleColor:AlivcOxRGB(0xc3c5c6) forState:UIControlStateNormal];
    [self.longPressButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.circleBtn setTitle:@"按住拍" forState:UIControlStateNormal];
    if (self.delegate && [self.delegate respondsToSelector:@selector(longPressButtonClicked)]) {
        [self.delegate longPressButtonClicked];
    }
}


/**
 美颜按钮的点击事件
 */
- (void)beauty{

    self.beautyView = self.leftView;
    [self addSubview:self.beautyView];
    self.bottomHide = YES;
    
}

- (AliyunRecordBeautyView *)leftView{
    if (!_leftView) {
        _leftView = [[AliyunRecordBeautyView alloc] initWithFrame:CGRectMake(0, ScreenHeight-180-78, ScreenWidth, 180+78)  titleArray:@[@"滤镜",@"美颜",@"美肌"] imageArray:@[@"shortVideo_fliter",@"shortVideo_emotion",@"shortVideo_beautySkin"]];
        _leftView.delegate = self;
    }
    return _leftView;
}

/**
 动图按钮的点击事件
 */
- (void)getGifPictureView{
    self.beautyView = self.rightView;
    [self addSubview:self.beautyView];
    self.bottomHide = YES;
    
    if (!self.isFirst) {
        [self refreshUIWithMVItems:self.mvItems];
        [self refreshUIWithGifItems:self.effectItems];
        self.isFirst = YES;
    }
}
//2d/3d贴纸 animoji 哈哈镜 背景分割，动漫滤镜和手势识别
- (AliyunRecordBeautyView *)rightView{
    if (!_rightView) {
       _rightView = [[AliyunRecordBeautyView alloc] initWithFrame:CGRectMake(0, ScreenHeight-200, ScreenWidth, 200)  titleArray:@[@"动图",@"MV",@"贴纸",@"animoji",@"哈哈镜",@"背景分割",@"动漫滤镜",@"手势识别"] imageArray:@[@"shortVideo_gifPicture",@"shortVideo_MV",@"",@"",@"",@"",@"",@""]];
        _rightView.delegate = self;
        
    }
    return _rightView;
}
- (void)cancelRecordBeautyView{
    if (self.beautyView) {
        self.bottomHide = NO;
        [self.beautyView removeFromSuperview];
    }
    
}

- (void)recordButtonTouchUp {
    NSLog(@" DD----  %f    %f  - %f", CFAbsoluteTimeGetCurrent(), _startTime, (CFAbsoluteTimeGetCurrent() - _startTime));
    BOOL longPass = (CFAbsoluteTimeGetCurrent() - _startTime) >= 0.2;
    switch ([AliyunIConfig config].recordType) {
        case AliyunIRecordActionTypeCombination:
            if (longPass) {
                if (_recording) {
                    [self endRecord];
                }
            }else{
                if (_recording) {
                    
                }else{
                    
                }
            }
            break;
            
        case AliyunIRecordActionTypeHold:
            if (_recording) {
                
                [self endRecord];
                self.circleBtn.transform = CGAffineTransformIdentity;
                [self.circleBtn setBackgroundImage:_uiConfig.videoShootImageNormal forState:UIControlStateNormal];
            }
            break;
            
        case AliyunIRecordActionTypeClick:
            if (_recording) {
                [self endRecord];
                self.circleBtn.transform = CGAffineTransformIdentity;
                [self.circleBtn setBackgroundImage:_uiConfig.videoShootImageNormal forState:UIControlStateNormal];
                return;
                
            }else{
                
                _recording = YES;
                _progressView.videoCount++;
                [_delegate recordButtonRecordVideo];
                self.circleBtn.transform = CGAffineTransformScale(self.transform, 1.32, 1.32);
                [self.circleBtn setBackgroundImage:_uiConfig.videoShootImageShooting forState:UIControlStateNormal];
            }
            break;
        default:
            break;
    }
    
}


- (void)recordButtonTouchDown {
    _startTime = CFAbsoluteTimeGetCurrent();
    
    NSLog(@"  YY----%f---%zd", _startTime,[AliyunIConfig config].recordType);
    
    switch ([AliyunIConfig config].recordType) {
        case AliyunIRecordActionTypeCombination:
            if (_recording) {
                [self endRecord];
                return;
            }else{
                _recording = YES;
            }
            break;
        case AliyunIRecordActionTypeHold:
            
            if (_recording == NO) {
                _recording = YES;
                self.circleBtn.transform = CGAffineTransformScale(self.transform, 1.32, 1.32);
                [self.circleBtn setBackgroundImage:_uiConfig.videoShootImageLongPressing forState:UIControlStateNormal];
                [self.circleBtn setTitle:@"" forState:UIControlStateNormal];
                [_delegate recordButtonRecordVideo];
                _progressView.videoCount++;
            }
            
            break;
            
        case AliyunIRecordActionTypeClick:
            
            break;
        default:
            break;
    }
    
    
    self.tapButton.hidden = YES;
    self.longPressButton.hidden = YES;
    self.triangleImageView.hidden = YES;
    self.dotImageView.hidden = NO;
    _progressView.showBlink = NO;
}

/**
 结束录制
 */
- (void)endRecord{
    if (!_recording) {
        return;
    }
    _startTime = 0;
    _recording = NO;
    [_delegate recordButtonPauseVideo];
    _progressView.showBlink = NO;
     [self destroy];
    _deleteButton.enabled = YES;
   
    if ([AliyunIConfig config].recordOnePart) {
        if (_delegate) {
            [_delegate recordButtonFinishVideo];
        }
    }
    self.countdownButton.enabled = YES;
    if (self.progressView.videoCount) {
        self.deleteButton.hidden = NO;
    }
    
    self.dotImageView.hidden = YES;
}


- (void)recordingPercent:(CGFloat)percent
{
    [self.progressView updateProgress:percent];
    if(_recording){
        self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)(_maxDuration * percent)/60,(int)(_maxDuration * percent)%60];
    }
    
    if(percent == 0){
        [self.progressView reset];
        self.deleteButton.hidden = YES;
        self.triangleImageView.hidden = NO;
        self.tapButton.hidden = NO;
        self.longPressButton.hidden = NO;
        self.timeLabel.text = @"";
    }
}

- (void)destroy
{
    self.timeLabel.text = @"";
    self.dotImageView.hidden = YES;
}

#pragma mark - AliyunRecordBeautyViewDelegate
- (void)didChangeAdvancedMode{
    if ([self.delegate respondsToSelector:@selector(didChangeAdvancedMode)]) {
        [self.delegate didChangeAdvancedMode];
    }
}

- (void)didChangeCommonMode{
    if ([self.delegate respondsToSelector:@selector(didChangeCommonMode)]) {
        [self.delegate didChangeCommonMode];
    }
}
- (void)didFetchGIFListData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFetchGIFListData)]) {
        [self.delegate didFetchGIFListData];
    }
}
- (void)didSelectEffectFilter:(AliyunEffectFilterInfo *)filter{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectEffectFilter:)]) {
        [self.delegate didSelectEffectFilter:filter];
    }
}

- (void)didChangeBeautyValue:(CGFloat)beautyValue{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeBeautyValue:)]) {
        [self.delegate didChangeBeautyValue:beautyValue];
    }
}

- (void)didChangeAdvancedBeautyWhiteValue:(CGFloat)beautyWhiteValue{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeAdvancedBeautyWhiteValue:)]) {
        [self.delegate didChangeAdvancedBeautyWhiteValue:beautyWhiteValue];
    }
}
- (void)didChangeAdvancedBlurValue:(CGFloat)blurValue{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeAdvancedBlurValue:)]) {
        [self.delegate didChangeAdvancedBlurValue:blurValue];
    }
}
- (void)didChangeAdvancedBigEye:(CGFloat)bigEyeValue{
        if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeAdvancedBigEye:)]) {
        [self.delegate didChangeAdvancedBigEye:bigEyeValue];
    }
}
- (void)didChangeAdvancedSlimFace:(CGFloat)slimFaceValue{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeAdvancedSlimFace:)]) {
        [self.delegate didChangeAdvancedSlimFace:slimFaceValue];
    }
}

- (void)didChangeAdvancedBuddy:(CGFloat)buddyValue{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeAdvancedBuddy:)]) {
        [self.delegate didChangeAdvancedBuddy:buddyValue];
    }
}

- (void)recordBeautyView:(AliyunRecordBeautyView *)view dismissButtonTouched:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(magicCameraView:dismissButtonTouched:)]) {
        [self.delegate magicCameraView:self dismissButtonTouched:button];
    }
}
#pragma mark - MagicCameraScrollViewDelegate

- (void)focusItemIndex:(NSInteger)index cell:(UICollectionViewCell *)cell
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(effectItemFocusToIndex:cell:)]&&(!_recording) && self.beautyView) {
        [self.delegate effectItemFocusToIndex:index cell: cell];
    }
}

- (void)didSelectEffectMV:(AliyunEffectMvGroup *)mvGroup{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectEffectMV:)]&&(!_recording)) {
        [self.delegate didSelectEffectMV:mvGroup];
    }
}
- (void)didSelectEffectMV:(AliyunEffectMvGroup *)mvGroup itemIndex:(NSInteger)index{

    self.mvItems[index] = mvGroup;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectEffectMV:)]&&(!_recording)) {
        [self.delegate didSelectEffectMV:mvGroup];
    }
}
- (void)setHide:(BOOL)hide {
    self.deleteButton.hidden = hide;
    self.topView.hidden = hide;
    self.rateView.hidden = hide;
    self.beautyButton.hidden = hide;
    self.gifPictureButton.hidden = hide;
    
}

- (void)setBottomHide:(BOOL)hide{
    _bottomHide = hide;
    self.rateView.hidden = hide;
    self.beautyButton.hidden = hide;
    self.gifPictureButton.hidden = hide;
    self.circleBtn.hidden = hide;
    if(self.progressView.videoCount){
        self.triangleImageView.hidden = YES;
        self.longPressButton.hidden = YES;
        self.tapButton.hidden = YES;
        self.deleteButton.hidden = NO;
    }else{
        self.triangleImageView.hidden = hide;
        self.longPressButton.hidden = hide;
        self.tapButton.hidden = hide;
        self.deleteButton.hidden = YES;
        if ([AliyunIConfig config].recordType == AliyunIRecordActionTypeHold) {
            [self.circleBtn setTitle:@"按住拍" forState:UIControlStateNormal];
        }
    }
    
}

- (void)setRealVideoCount:(NSInteger)realVideoCount{
    if (realVideoCount) {
        self.triangleImageView.hidden = YES;
        self.longPressButton.hidden = YES;
        self.tapButton.hidden = YES;
        self.deleteButton.hidden = NO;
    }else{
        self.triangleImageView.hidden = NO;
        self.longPressButton.hidden = NO;
        self.tapButton.hidden = NO;
        self.deleteButton.hidden = YES;
    }
}
#pragma mark - Getter -
- (UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.backgroundColor = [UIColor clearColor];
        _backButton.frame = CGRectMake(0, 8, 44, 44);
        [_backButton setImage:_uiConfig.backImage forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIButton *)finishButton
{
    if (!_finishButton) {
        _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _finishButton.backgroundColor = [UIColor clearColor];
        _finishButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 34 - 10, 8, 44, 44);
        _finishButton.hidden = NO;
        [_finishButton setImage:_uiConfig.finishImageUnable forState:UIControlStateDisabled];
        _finishButton.enabled = NO;
        [_finishButton setImage:_uiConfig.finishImageEnable forState:UIControlStateNormal];
        [_finishButton addTarget:self action:@selector(finishButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _finishButton;
}



- (UIButton *)cameraIdButton
{
    if (!_cameraIdButton) {
        _cameraIdButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cameraIdButton.backgroundColor = [UIColor clearColor];
        _cameraIdButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 78 - 10 - 5, 8, 44, 44);
        [_cameraIdButton setImage:_uiConfig.switchCameraImage forState:UIControlStateNormal];
        [_cameraIdButton addTarget:self action:@selector(cameraIdButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraIdButton;
}


- (UIButton *)flashButton
{
    if (!_flashButton) {
        _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _flashButton.backgroundColor = [UIColor clearColor];
        _flashButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 166 - 10 - 15, 8, 44, 44);
        _flashButton.hidden = NO;
        [_flashButton setImage:_uiConfig.ligheImageUnable forState:UIControlStateNormal];
        [_flashButton addTarget:self action:@selector(flashButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashButton;
}



-(UIButton *)countdownButton {
    if (!_countdownButton) {
        _countdownButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _countdownButton.backgroundColor = [UIColor clearColor];
        _countdownButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 122 - 10 - 10, 8, 44, 44);
        [_countdownButton setImage:_uiConfig.countdownImage forState:UIControlStateNormal];
        [_countdownButton addTarget:self action:@selector(timerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _countdownButton;
}



- (UIButton *)musicButton{
    if (!_musicButton) {
        _musicButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _musicButton.backgroundColor = [UIColor clearColor];
        _musicButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 210 - 10 - 20, 8, 44, 44);
        [_musicButton setImage:_uiConfig.musicImage forState:UIControlStateNormal];
        [_musicButton addTarget:self action:@selector(musicButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _musicButton;
}


#pragma mark - Actions -

/**
 速度选择控件的点击时间

 @param rateView 速度选择控件
 */
- (void)rateChanged:(AliyunRateSelectView *)rateView {
    CGFloat rate = 1.0f;
    switch (rateView.selectedSegmentIndex) {
        case 0:
            rate = 0.5f;
            break;
        case 1:
            rate = 0.75f;
            break;
        case 2:
            rate = 1.0f;
            break;
        case 3:
            rate = 1.5f;
            break;
        case 4:
            rate = 2.0f;
            break;
        default:
            break;
    }
    [self.delegate didSelectRate:rate];
}

- (void)resetRecordButtonUI{
    self.circleBtn.transform = CGAffineTransformIdentity;
    [self.circleBtn setBackgroundImage:_uiConfig.videoShootImageNormal forState:UIControlStateNormal];
    if([AliyunIConfig config].recordType == AliyunIRecordActionTypeClick){
        [self.circleBtn setTitle:@"" forState:UIControlStateNormal];
    }else if([AliyunIConfig config].recordType == AliyunIRecordActionTypeHold){
        if (!self.progressView.videoCount) {
            [self.circleBtn setTitle:@"按住拍" forState:UIControlStateNormal];
        }
        
    }
}

/**
 返回按钮的点击事件

 @param sender 返回按钮
 */
- (void)backButtonClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(backButtonClicked)]) {
        [self.delegate backButtonClicked];
    }
}


/**
 闪光灯按钮的点击事件

 @param sender 闪光灯按钮
 */
- (void)flashButtonClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(flashButtonClicked)]) {
        NSString *imageName = [self.delegate flashButtonClicked];
        [button setImage:[AlivcImage imageNamed:imageName] forState:0];
    }
}


/**
 前置、后置摄像头切换按钮的点击事件

 @param sender 前置、后置摄像头切换按钮
 */
- (void)cameraIdButtonClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraIdButtonClicked)]) {
        [self.delegate cameraIdButtonClicked];
    }
}


/**
 定时器按钮的点击事件

 @param sender 定时器按钮
 */
- (void)timerButtonClicked:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(timerButtonClicked)]) {
        [self.delegate timerButtonClicked];
        self.triangleImageView.hidden = YES;
        self.tapButton.hidden = YES;
        self.longPressButton.hidden = YES;
        self.timeLabel.text = @"";
        if (self.beautyView) {
            [self.beautyView removeFromSuperview];
        }
    }
    self.countdownButton.enabled = NO;
}


/**
 音乐按钮的点击事件

 @param sender 音乐按钮
 */
- (void)musicButtonClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(musicButtonClicked)]) {
        [self.delegate musicButtonClicked];
    }
}


/**
 回删按钮的点击事件
 */
- (void)deletePartClicked {
    if ([self.delegate respondsToSelector:@selector(deleteButtonClicked)]) {
        [self.delegate deleteButtonClicked];
    }
}


/**
 完成按钮的点击事件
 */
- (void)finishButtonClicked {
    if ([self.delegate respondsToSelector:@selector(finishButtonClicked)]) {
        [self.delegate finishButtonClicked];
    }
}



/**
 根据新的动图数组刷新ui
 
 @param effectItems 新的动图数组
 */
- (void)refreshUIWithGifItems:(NSArray *)effectItems{
    if (effectItems) {
        self.effectItems = effectItems;
        if (self.beautyView) {
             [self.beautyView refreshUIWithGifItems:effectItems];
        }
       
    }
}


/**
 根据新的mv数组刷新ui
 
 @param mvItems 新的mv数组
 */
- (void)refreshUIWithMVItems:(NSMutableArray *)mvItems{
    if (mvItems) {
        self.mvItems = mvItems;
        if (self.beautyView) {
            [self.beautyView refreshUIWithMVItems:mvItems];
        }
        
    }
}

/**
 动图实际应用时候调用此方法刷新UI选中状态
 */
- (void)refreshUIWhenThePasterInfoApplyedWithIndex:(NSInteger)applyedIndex{
    if (self.beautyView) {
        [self.beautyView refreshUIWhenThePasterInfoApplyedWithIndex:applyedIndex];
    }
}
@end
