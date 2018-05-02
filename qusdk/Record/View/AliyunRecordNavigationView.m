//
//  AliyunRecordNavigationView.m
//  AliyunVideo
//
//  Created by dangshuai on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunRecordNavigationView.h"
#import "AliyunIConfig.h"

@interface AliyunRecordNavigationView ()
@property (nonatomic, assign) CGFloat currentRatio;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *ratioButton;
@property (nonatomic, strong) UIButton *beautyButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *flashButton;

@end

@implementation AliyunRecordNavigationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _currentRatio = 3/4.0;
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
  
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    backgroundView.backgroundColor = [AliyunIConfig config].backgroundColor;
    backgroundView.alpha = 0.5;
    [self addSubview:backgroundView];
    
    _backButton   = [self createButtonWithImage:[AliyunImage imageNamed:@"back"] withCenterX:22];
    CGFloat x_left = 44;
    CGFloat anchor = ScreenWidth - 22;
    NSInteger distance = 0;
    if (![AliyunIConfig config].hiddenFlashButton) {
        _flashButton  = [self createButtonWithImage:[AliyunImage imageNamed:@"camera_flash_close"] withCenterX:anchor - x_left * distance];
        distance ++;
    }
    if (![AliyunIConfig config].hiddenCameraButton) {
        _cameraButton = [self createButtonWithImage:[AliyunImage imageNamed:@"camera_id"] withCenterX:anchor - x_left * distance];
        distance ++;
    }
    
    if (![AliyunIConfig config].hiddenBeautyButton) {
        _beautyButton = [self createButtonWithImage:[AliyunImage imageNamed:@"record_beauty"] withCenterX:anchor - x_left * distance];
        distance ++;
    }

    [AliyunIConfig config].hiddenRatioButton = NO;
    if (![AliyunIConfig config].hiddenRatioButton) {
        _ratioButton  = [self createButtonWithImage:[AliyunImage imageNamed:@"record_ratio"] withCenterX:anchor - x_left * distance];
        distance ++;
    }

    [_backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_ratioButton addTarget:self action:@selector(ratioButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_beautyButton addTarget:self action:@selector(beautyButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_cameraButton addTarget:self action:@selector(cameraButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_flashButton addTarget:self action:@selector(flashButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [_ratioButton setImage:[AliyunImage imageNamed:@"record_ratio_dis"] forState:UIControlStateDisabled];
    [_beautyButton setImage:[AliyunImage imageNamed:@"record_beauty_dis"] forState:UIControlStateDisabled];
    [_cameraButton setImage:[AliyunImage imageNamed:@"camera_id_dis"] forState:UIControlStateDisabled];
    [_flashButton setImage:[AliyunImage imageNamed:@"camera_flash_dis"] forState:UIControlStateDisabled];
    [_beautyButton setImage:[AliyunImage imageNamed:@"record_beauty_on"] forState:UIControlStateSelected];
    _beautyButton.selected = YES;
    _ratioButton.hidden = YES;
}

- (void)setupBeautyStatus:(BOOL)isBeauty flashStatus:(NSInteger)flashStatus {
    
    self.beautyButton.selected = isBeauty;
    [self updateNavigationFlashStatus:flashStatus];
}

- (void)updateNavigationStatusWithDuration:(CGFloat)duration {
    if (duration > 0 && _ratioButton.enabled) {
        _ratioButton.enabled = NO;
    }
    if (duration <= 0 && !_ratioButton.enabled) {
        _ratioButton.enabled = YES;
    }
}

- (void)updateNavigationStatusWithRecord:(BOOL)isRecording {
    _flashButton.enabled  = !isRecording;
    _beautyButton.enabled = !isRecording;
    _cameraButton.enabled = !isRecording;
    _backButton.enabled = !isRecording;
}

- (void)backButtonClick {
    [_delegate navigationBackButtonClick];
}

- (void)ratioButtonClick {
    if (_currentRatio == 3/4.0) {
        _currentRatio = 9/16.0;
    } else if (_currentRatio == 9/16.0) {
        _currentRatio = 1;
    } else if (_currentRatio == 1) {
        _currentRatio = 3/4.0;
    }
    [self updateNavigationRatioStatus];
    [_delegate navigationRatioDidChangedWithValue:_currentRatio];
}

- (void)beautyButtonClick {
    _beautyButton.selected = !_beautyButton.selected;
    [_delegate navigationBeautyDidChangedStatus:_beautyButton.selected];
}

- (void)flashButtonClick {
    NSInteger status = [_delegate navigationFlashModeDidChanged];
    [self updateNavigationFlashStatus:status];
}


- (void)updateNavigationFlashStatus:(NSInteger)status {
    
    if (status == 0) {
        [_flashButton setImage:[AliyunImage imageNamed:@"camera_flash_close"] forState:0];
    } else if (status == 1) {
        [_flashButton setImage:[AliyunImage imageNamed:@"camera_flash_on"] forState:0];
    } else {
        [_flashButton setImage:[AliyunImage imageNamed:@"camera_flash_auto"] forState:0];
    }
}

- (void)updateNavigationRatioStatus {
    if (_currentRatio == 1) {
        [_ratioButton setImage:[AliyunImage imageNamed:@"record_videoSize_1_1"] forState:0];
    } else if (_currentRatio == 9/16.0) {
        [_ratioButton setImage:[AliyunImage imageNamed:@"record_videoSize_9_16"] forState:0];
    } else {
        [_ratioButton setImage:[AliyunImage imageNamed:@"record_videoSize_4_3"] forState:0];
    }
}

- (void)cameraButtonClick {
    _cameraButton.selected = !_cameraButton.selected;
    [_delegate navigationCamerationPositionDidChanged:_cameraButton.selected];
}

- (UIButton *)createButtonWithImage:(UIImage *)imageName withCenterX:(CGFloat)x {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:imageName forState:0];
    button.bounds = CGRectMake(0, 0, 40, 40);
    button.center = CGPointMake(x, 22);
    [self addSubview:button];
    return button;
}

@end
