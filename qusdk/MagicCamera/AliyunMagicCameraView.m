//
//  MagicCameraView.m
//  AliyunVideo
//
//  Created by Vienta on 2017/1/3.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunMagicCameraView.h"


@interface AliyunMagicCameraView ()

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) UIButton *cameraIdButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIView *centerView;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UICollectionView *pasterCollectionView;
@property (nonatomic, strong) UIButton *captureButton;

@property (nonatomic, strong) UILabel *timeLabel;


@end

@implementation AliyunMagicCameraView
{
    CGSize _videoSize;
    CFTimeInterval _beginTime;
}

- (instancetype)initWithFrame:(CGRect)frame videoSize:(CGSize)size
{
    if (self = [super initWithFrame:frame]) {
        _videoSize = size;
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview
{
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0,SafeTop, CGRectGetWidth(self.bounds), 44)];
    [self addSubview:self.topView];
    
    [self.topView addSubview:self.backButton];
    [self.topView addSubview:self.cameraIdButton];
    [self.topView addSubview:self.flashButton];
    [self.topView addSubview:self.musicButton];
    [self.topView addSubview:self.finishButton];
    [self.topView addSubview:self.mvButton];
    
    CGFloat whRatio = _videoSize.width / _videoSize.height;
    CGFloat w, h;
    if (whRatio <= 1) {
        h = CGRectGetHeight(self.bounds);
        w = h * whRatio;
    } else {
        w = CGRectGetWidth(self.bounds);
        h = w / whRatio;
    }

    self.centerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ceilf(w), ceilf(h))];
    self.centerView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self insertSubview:self.centerView atIndex:0];
    
    self.previewView = [[UIView alloc] initWithFrame:self.centerView.bounds];
    [self.centerView addSubview:self.previewView];
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 60 , CGRectGetWidth(self.bounds), 60)];
    self.bottomView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.bottomView];
    
    self.topView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.01];
    
    
    self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2-30, ScreenHeight-200 - SafeBottom, 60, 40)];
    [self.deleteButton setTitle:@"回删" forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(deletePartClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.deleteButton];
    
    self.rateView = [[AliyunRateSelectView alloc] initWithItems:@[@"极慢",@"慢",@"标准",@"快",@"极快"]];
    self.rateView.frame = CGRectMake(40, ScreenHeight-150 - SafeBottom, ScreenWidth-80, 40);
    self.rateView.selectedSegmentIndex = 2;
    [self.rateView addTarget:self action:@selector(rateChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.rateView];
    
    self.srollView = [[AliyunMagicCameraScrollView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 75 - SafeBottom, ScreenWidth, 60) delegate:self];
    [self addSubview:self.srollView];
    self.srollView.delegate = (id)self;
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.frame = CGRectMake(0, 0, 60, 16);
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.center = CGPointMake(ScreenWidth / 2, ScreenHeight - 98);
    [self addSubview:self.timeLabel];
    
    self.filterLabel = [[UILabel alloc] init];
    self.filterLabel.textAlignment = 1;
    self.filterLabel.center = self.center;
    self.filterLabel.bounds = CGRectMake(0, 0, 100, 22);
    self.filterLabel.backgroundColor = [UIColor clearColor];
    self.filterLabel.textColor = [UIColor whiteColor];
    self.filterLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:self.filterLabel];
    
    self.progressView = [[QUProgressView alloc] initWithFrame: CGRectMake(0, SafeTop, ScreenWidth, 4)];
    self.progressView.showBlink = NO;
    self.progressView.showNoticePoint = YES;
    self.progressView.maxDuration = 1;
    self.progressView.minDuration = 0;
    self.progressView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.01];
    [self addSubview:self.progressView];
    

}

- (void)loadEffectData:(NSArray *)effectData
{
    self.srollView.effectItems = effectData;
}

- (void)recordingPercent:(CGFloat)percent
{
    [self.progressView updateProgress:percent];
    self.timeLabel.text = [NSString stringWithFormat:@"%.2lf s",_maxDuration * percent];
}

- (void)recording:(CADisplayLink *)displayLink
{
    if (_beginTime == 0) {
        _beginTime = displayLink.timestamp;
    }
    CFTimeInterval duration = displayLink.timestamp - _beginTime;
    
    self.timeLabel.text = [NSString stringWithFormat:@"%.2lf s",duration];

    if (self.delegate && [self.delegate respondsToSelector:@selector(recordingProgressDuration:)]) {
        [self.delegate recordingProgressDuration:duration];
    }
}

- (void)destroy
{
    _beginTime = 0;
    self.timeLabel.text = @"";
//    [self recordingPercent:0.0];
    [self.srollView resetCircleView];
    [self.srollView hiddenScroll:NO];
}

- (void)displayFilterName:(NSString *)filterName {
    if (!filterName) filterName = @"原色(美颜)";
    CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animation];
    keyframeAnimation.duration = 1.f;
    keyframeAnimation.keyTimes = @[@0.0, @0.3, @0.7, @1.0];
    keyframeAnimation.values   = @[@0.0, @1.0, @1.0, @0.0];
    keyframeAnimation.fillMode = kCAFillModeForwards;
    keyframeAnimation.repeatCount = 1;
    keyframeAnimation.removedOnCompletion = NO;
    [self.filterLabel.layer addAnimation:keyframeAnimation forKey:@"opacity"];
    
    self.filterLabel.text = filterName;
}

#pragma mark - MagicCameraScrollViewDelegate -
- (void)touchesBegin
{
    _progressView.showBlink = NO;
    _progressView.videoCount++;
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordButtonTouchesBegin)]) {
        [self.delegate recordButtonTouchesBegin];
    }
}

- (void)touchesEnd
{
    [self destroy];
    _progressView.showBlink = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordButtonTouchesEnd)]) {
        [self.delegate recordButtonTouchesEnd];
    }
}

- (void)focusItemIndex:(NSInteger)index cell:(UICollectionViewCell *)cell
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(effectItemFocusToIndex:cell:)]) {
        [self.delegate effectItemFocusToIndex:index cell: cell];
    }
}

-(void)setHide:(BOOL)hide {
    self.topView.hidden = hide;
    self.rateView.hidden = hide;
    self.deleteButton.hidden = hide;
}

#pragma mark - Getter -
- (UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.backgroundColor = [UIColor clearColor];
        _backButton.frame = CGRectMake(0, 0, 44, 44);
        [_backButton setImage:[AliyunImage imageNamed:@"back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIButton *)finishButton
{
    if (!_finishButton) {
        _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _finishButton.backgroundColor = [UIColor clearColor];
        _finishButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 34 - 10, 0, 44, 44);
        _finishButton.hidden = NO;
        [_finishButton setImage:[AliyunImage imageNamed:@"NextDisable"] forState:UIControlStateDisabled];
        [_finishButton setImage:[AliyunImage imageNamed:@"NextNormal"] forState:UIControlStateNormal];
        _finishButton.enabled = NO;
        [_finishButton addTarget:self action:@selector(finishButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishButton;
}



- (UIButton *)cameraIdButton
{
    if (!_cameraIdButton) {
        _cameraIdButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cameraIdButton.backgroundColor = [UIColor clearColor];
        _cameraIdButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 78 - 10, 0, 44, 44);
        [_cameraIdButton setImage:[AliyunImage imageNamed:@"camera_id"] forState:UIControlStateNormal];
        [_cameraIdButton addTarget:self action:@selector(cameraIdButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraIdButton;
}


- (UIButton *)flashButton
{
    if (!_flashButton) {
        _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _flashButton.backgroundColor = [UIColor clearColor];
        _flashButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 122 - 10, 0, 44, 44);
        _flashButton.hidden = NO;
        [_flashButton setImage:[AliyunImage imageNamed:@"camera_flash_close"] forState:UIControlStateNormal];
        [_flashButton addTarget:self action:@selector(flashButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashButton;
}



-(UIButton *)musicButton {
    if (!_musicButton) {
        _musicButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _musicButton.backgroundColor = [UIColor clearColor];
        _musicButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 166 - 10, 0, 44, 44);
        [_musicButton setImage:[AliyunImage imageNamed:@"Music"] forState:UIControlStateNormal];
        [_musicButton addTarget:self action:@selector(musicButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _musicButton;
}

- (UIButton *)mvButton {
    if (!_mvButton) {
        _mvButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _mvButton.backgroundColor = [UIColor clearColor];
        _mvButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 210 - 10, 0, 44, 44);
        [_mvButton setImage:[AliyunImage imageNamed:@"camera_mv"] forState:UIControlStateNormal];
        [_mvButton addTarget:self action:@selector(mvButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mvButton;
}


#pragma mark - Actions -

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
- (void)backButtonClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(backButtonClicked)]) {
        [self.delegate backButtonClicked];
    }
}

- (void)flashButtonClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(flashButtonClicked)]) {
        NSString *imageName = [self.delegate flashButtonClicked];
        [button setImage:[UIImage imageNamed:imageName] forState:0];
    }
}

- (void)cameraIdButtonClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraIdButtonClicked)]) {
        [self.delegate cameraIdButtonClicked];
    }
}

- (void)musicButtonClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(musicButtonClicked)]) {
        [self.delegate musicButtonClicked];
    }
}

- (void)mvButtonClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(mvButtonClicked)]) {
        [self.delegate mvButtonClicked];
    }
}

- (void)deletePartClicked {
    if ([self.delegate respondsToSelector:@selector(deleteButtonClicked)]) {
        [self.delegate deleteButtonClicked];
    }
}

- (void)finishButtonClicked {
    if ([self.delegate respondsToSelector:@selector(finishButtonClicked)]) {
        [self.delegate finishButtonClicked];
    }
}

@end
