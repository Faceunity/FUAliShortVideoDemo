//
//  AlivcRecordNavigationBar.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/2/22.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcRecordNavigationBar.h"
#import "AlivcRecordUIConfig.h"
#import "UIColor+AlivcHelper.h"
#import "NSString+AlivcHelper.h"

static CGFloat AlivcRecordNavigationBarItemSpace = 30;//按钮间间隔

@interface AlivcRecordNavigationBar()
@property (nonatomic, strong)AlivcRecordUIConfig *uiConfig;
@property (nonatomic, assign)CFTimeInterval cameraIdButtonClickTime;


@end

@implementation AlivcRecordNavigationBar

- (instancetype)initWithUIConfig:(AlivcRecordUIConfig *)uiConfig{
    self = [super initWithFrame:CGRectMake(0, NoStatusBarSafeTop+21, ScreenWidth, 30)];
    if (self) {
        _cameraIdButtonClickTime =CFAbsoluteTimeGetCurrent();
        _uiConfig = uiConfig;
        self.backgroundColor =[UIColor clearColor];
        [self setupSubviews];
    }
    return self;
}
- (void)setupSubviews{
//    NSArray *buttons =@[@"完成",@"切换摄像头",@"倒计时",@"闪光灯",@"音乐",@"返回"];
    NSArray *buttonTypes =@[@(AlivcRecordNavigationBarTypeFinish),
                            @(AlivcRecordNavigationBarTypeCameraSwitch),
                            @(AlivcRecordNavigationBarTypeFlashMode),
                            @(AlivcRecordNavigationBarTypeTiming),
                            /*@(AlivcRecordNavigationBarTypeMusic),*/
                            @(AlivcRecordNavigationBarTypeGoback)];
    NSArray *buttonImgs =@[_uiConfig.finishImageUnable,_uiConfig.switchCameraImage,
                           _uiConfig.ligheImageClose,_uiConfig.countdownImage,
                           /*_uiConfig.musicImage,*/_uiConfig.backImage];
    for (int i =0; i<buttonImgs.count; i++) {
        CGFloat size = 25 + ScreenWidth*0.013;
        CGFloat fw = (i==0?30:0);
        CGFloat fx = (i==4)?15:(ScreenWidth- (size+AlivcRecordNavigationBarItemSpace)*(i+1));
        CGFloat fs = (i==4)?(-4):0;
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(fx+(i!=4?-14:0), 0-fs/2, size+fs+fw, size+fs)];
        btn.tag =[buttonTypes[i] integerValue];
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        if ([buttonTypes[i] integerValue] == AlivcRecordNavigationBarTypeFinish) {
            btn.layer.masksToBounds = YES;
            if (isRace) {
               [btn setTitle:[@"保存" localString] forState:UIControlStateNormal];
            }else{
               [btn setTitle:[@"下一步" localString] forState:UIControlStateNormal];
            }
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            btn.layer.cornerRadius = 3;
            [self setFinishButtonEnabled:NO];
        }else if([buttonTypes[i] integerValue] == AlivcRecordNavigationBarTypeFlashMode) {
            [btn setBackgroundImage:(UIImage *)buttonImgs[i] forState:UIControlStateNormal];
            [btn setBackgroundImage:_uiConfig.ligheImageUnable forState:UIControlStateDisabled];
        }else{
            [btn setBackgroundImage:(UIImage *)buttonImgs[i] forState:UIControlStateNormal];
        }
        
    }
}

- (void)btnAction:(UIButton *)btn{
    AlivcRecordNavigationBarType btnType = (AlivcRecordNavigationBarType)btn.tag;
    if (btnType == AlivcRecordNavigationBarTypeCameraSwitch) {
        if (CFAbsoluteTimeGetCurrent()-_cameraIdButtonClickTime <1.2) {//限制连续点击时间间隔不能小于1.2s
            return;
        }
        _cameraIdButtonClickTime =CFAbsoluteTimeGetCurrent();
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcRecordNavigationBarButtonActionType:)]) {
        [self.delegate alivcRecordNavigationBarButtonActionType:(AlivcRecordNavigationBarType)btn.tag];
    }
}

- (void)setFinishButtonEnabled:(BOOL)enabled{
    UIButton *finishBtn = (UIButton *)[self viewWithTag:(NSInteger)AlivcRecordNavigationBarTypeFinish];
    finishBtn.enabled = enabled;
    if (enabled) {
        finishBtn.backgroundColor = [UIColor colorWithHexString:@"0xFC4448"];
    }else{
        finishBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.45];
    }
}

- (void)setTimerButtonEnabled:(BOOL)enabled{
    UIButton *timerBtn = (UIButton *)[self viewWithTag:(NSInteger)AlivcRecordNavigationBarTypeTiming];
    timerBtn.enabled =enabled;
}

- (void)setTorchButtonImageWithMode:(AlivcRecordTorchMode)mode{
    UIButton *flashBtn = (UIButton *)[self viewWithTag:(NSInteger)AlivcRecordNavigationBarTypeFlashMode];
    switch (mode) {
        case AlivcRecordTorchModeOff:
            [flashBtn setBackgroundImage:_uiConfig.ligheImageClose forState:UIControlStateNormal];
            flashBtn.enabled =YES;
            break;
        case AlivcRecordTorchModeOn:
            [flashBtn setBackgroundImage:_uiConfig.ligheImageOpen forState:UIControlStateNormal];
            flashBtn.enabled =YES;
            break;
        case AlivcRecordTorchModeAuto:
            [flashBtn setBackgroundImage:_uiConfig.ligheImageAuto forState:UIControlStateNormal];
            flashBtn.enabled =YES;
            break;
        case AlivcRecordTorchModeDisabled:
            [flashBtn setBackgroundImage:_uiConfig.ligheImageUnable forState:UIControlStateNormal];
            flashBtn.enabled =NO;
            flashBtn.selected = YES;
            break;
            
        default:
            break;
    }
}

@end
