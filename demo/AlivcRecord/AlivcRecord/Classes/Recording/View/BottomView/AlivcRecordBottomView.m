//
//  AlivcRecordBottomView.m
//  AlivcVideoClient_Entrance
//
//  Created by wanghao on 2019/2/25.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcRecordBottomView.h"
#import "AlivcRecordRateSelectView.h"
#import "AlivcRecordUIConfig.h"
#import "AlivcRecordToolView.h"
#import "AlivcRecordButtonView.h"
#import "AlivcButton.h"
#import "NSString+AlivcHelper.h"

@interface AlivcRecordBottomView()<AlivcRecordToolViewDelegate,AlivcRecordButtonViewDelegate>

@property(nonatomic, strong)AlivcButton *beautyBtn;

@property(nonatomic, strong)AlivcButton *pasterBtn;

@property(nonatomic, strong)AlivcRecordButtonView *recordButttonView;

@property(nonatomic, strong)AlivcRecordToolView *toolView;

@property(nonatomic, strong)AlivcRecordRateSelectView *rateSelectView;

@end


@implementation AlivcRecordBottomView

- (instancetype)initWithFrame:(CGRect)frame withUIConfig:(nonnull AlivcRecordUIConfig *)uiConfig{
    self =[super initWithFrame:frame];
    if (self) {
        [self setupSubviewsWithUIConfig:uiConfig];
    }
    return self;
}

- (void)setupSubviewsWithUIConfig:(AlivcRecordUIConfig *)uiConfig{
    //速度选择条
    _rateSelectView =[[AlivcRecordRateSelectView alloc]initWithFrame:CGRectMake(30, 0, ScreenWidth-60, 40)];
    __weak typeof(self)weakSelf = self;
    [_rateSelectView setupViewsWithItems:@[[@"极慢" localString],[@"慢" localString],[@"标准" localString],[@"快" localString],[@"极快" localString]] selectedRateBlock:^(CGFloat rate) {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(alivcRecordBottomViewDidSelectRate:)]) {
            [weakSelf.delegate alivcRecordBottomViewDidSelectRate:rate];
        }
    }];
    [self addSubview:_rateSelectView];
    
    //拍摄模式选择
    _toolView =[[AlivcRecordToolView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) -50, ScreenWidth, 50)];
    _toolView.delegate =self;
    [self addSubview:_toolView];
    
    //美颜按钮
    CGFloat btn_size =60;
    CGFloat center_y =CGRectGetMinY(_toolView.frame)- btn_size/2 -30;
    _beautyBtn =[[AlivcButton alloc]initWithButtonType:AlivcButtonTypeTitleBottom];
    [_beautyBtn setTitle:[@"美颜" localString] forState:UIControlStateNormal];
    _beautyBtn.titleLabel.font =[UIFont systemFontOfSize:13];
    _beautyBtn.frame =CGRectMake(CGRectGetMinX(_rateSelectView.frame), center_y - btn_size/2, btn_size, btn_size+20);
    [_beautyBtn setImage:uiConfig.faceImage forState:UIControlStateNormal];
    [_beautyBtn addTarget:self action:@selector(beautyBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_beautyBtn];
    
    //特效按钮
    _pasterBtn =[[AlivcButton alloc]initWithButtonType:AlivcButtonTypeTitleBottom];
    _pasterBtn.frame =CGRectMake(CGRectGetWidth(self.frame)- CGRectGetMaxX(_beautyBtn.frame), CGRectGetMinY(_beautyBtn.frame), btn_size, CGRectGetHeight(_beautyBtn.frame));
    [_pasterBtn setTitle:[@"道具" localString] forState:UIControlStateNormal];
    _pasterBtn.titleLabel.font =[UIFont systemFontOfSize:13];
    [_pasterBtn setImage:uiConfig.magicImage forState:UIControlStateNormal];
    [_pasterBtn addTarget:self action:@selector(effectBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_pasterBtn];
    
    //录制按钮View
    _recordButttonView = [[AlivcRecordButtonView alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.frame)-120)/2, CGRectGetMidY(_beautyBtn.frame)+40-130, 120, 130)];
    _recordButttonView.delegate = self;
    [self addSubview:_recordButttonView];
    [self sendSubviewToBack:_recordButttonView];


}

#pragma mark - Actions
- (void)updateUI{
    BOOL isRecording =[self isRecording];
    [_beautyBtn setHidden:isRecording];
    [_pasterBtn setHidden:isRecording];
//    [_recordButttonView setRecordStatud:isRecording];
    [_recordButttonView setRecordStatus:isRecording withRecordType:_toolView.touchMode];
    [_toolView setHidden:isRecording];
    [_rateSelectView setHidden:isRecording];
}
- (void)startRecordDelegate{
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcRecordBottomViewStartRecord)]) {
        [self.delegate alivcRecordBottomViewStartRecord];
    }
}
- (void)stopRecordDelegate{
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcRecordBottomViewStopRecord)]) {
        [self.delegate alivcRecordBottomViewStopRecord];
    }
}
- (BOOL)isRecording{
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcRecordBottomViewIsRecording)]) {
        return [self.delegate alivcRecordBottomViewIsRecording];
    }
    return NO;
}
- (void)updateViewsWithVideoPartCount:(NSInteger)partCount{
    [_toolView showDeleteButton:(partCount>0)];
}
- (void)beautyBtnAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcRecordBottomViewBeautyButtonOnclick)]) {
        [self.delegate alivcRecordBottomViewBeautyButtonOnclick];
    }
}
- (void)effectBtnAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcRecordBottomViewEffectButtonOnclick)]) {
        [self.delegate alivcRecordBottomViewEffectButtonOnclick];
    }
}

#pragma mark - Public
- (void)refreshRecorderVideoDuration:(CGFloat)duration{
    [self.recordButttonView refreshRecordingTime:duration];
}
- (void)updateRecorderUI{
    if (_toolView.touchMode == AlivcRecordButtonTouchModeLongPress) {
        [_recordButttonView switchShowRecordButtonTip:![self isRecording]];
    }
    [self updateUI];
}
- (void)startRecord{
    [self startRecordDelegate];
    [self updateUI];
}

#pragma mark - AlivcRecordToolViewDelegate
- (void)alivcRecordToolViewSwitchTouchMode:(AlivcRecordButtonTouchMode)touchMode{
    [_recordButttonView switchShowRecordButtonTip:(touchMode==AlivcRecordButtonTouchModeLongPress && ![self isRecording])];
}
- (void)alivcRecordToolViewDeleteVideoPart{
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcRecordBottomViewDeleteVideoPart)]) {
        [self.delegate alivcRecordBottomViewDeleteVideoPart];
    }
}

#pragma mark - AlivcRecordButtonViewDelegate
- (void)alivcRecordButtonTouchUp{
    NSLog(@"recordButtonTouchUp");
    if (_toolView.touchMode == AlivcRecordButtonTouchModeLongPress) {
        [self stopRecordDelegate];
        [_recordButttonView switchShowRecordButtonTip:YES];
    }else{
        [self isRecording]?[self stopRecordDelegate]:[self startRecordDelegate];
    }
    [self updateUI];
}
- (void)alivcRecordButtonTouchDown{
    NSLog(@"recordButtonTouchDown");
    if (_toolView.touchMode == AlivcRecordButtonTouchModeLongPress) {
        [_recordButttonView switchShowRecordButtonTip:NO];
        [self startRecordDelegate];
    }
}
- (void)alivcRecordButtonTouchUpDragOutside{
    NSLog(@"recordButtonTouchUpDragOutside");
    if (_toolView.touchMode == AlivcRecordButtonTouchModeLongPress) {
        [self stopRecordDelegate];
        [self updateUI];
    }
}

@end
