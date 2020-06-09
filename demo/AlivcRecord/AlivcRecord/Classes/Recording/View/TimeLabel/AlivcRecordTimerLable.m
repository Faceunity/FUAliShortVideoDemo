//
//  AlivcRecordTimerLable.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/4/8.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcRecordTimerLable.h"
@interface AlivcRecordTimerLable()
@property (nonatomic, strong) NSTimer *cameraTimer;//倒计时拍摄计时器
@property (nonatomic, copy)AlivcRecordTimerCompleteBlock completeBlock;

@end

@implementation AlivcRecordTimerLable

- (instancetype)initWithFrame:(CGRect)frame{
    self =[super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.backgroundColor =[UIColor clearColor];
        self.text =@"-1";
        self.font = [UIFont systemFontOfSize:144];
        self.textAlignment =NSTextAlignmentCenter;
        self.textColor =[UIColor whiteColor];
        self.hidden = YES;
    }
    return self;
}

- (void)startTimerWithComplete:(AlivcRecordTimerCompleteBlock)complete{
    _completeBlock = complete;
    if (!_cameraTimer) {
        _cameraTimer =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(showCameraLab) userInfo:nil repeats:YES];
    }
    [_cameraTimer fire];
}
- (void)showCameraLab{
    self.hidden = NO;
    _isTiming = YES;
    int timerCount = [self.text intValue];
    if (timerCount <0) {
        self.text = @"3";
        [self.superview bringSubviewToFront:self];
    }else{
        timerCount --;
        if (timerCount == 0) {
            [self stopTimer];
            if (_completeBlock) {
                _completeBlock();
            }
        }else{
            self.text = [NSString stringWithFormat:@"%d",timerCount];
            [self.superview bringSubviewToFront:self];
        }
        
    }
}
- (void)stopTimer{
    self.hidden = YES;
    [self.superview sendSubviewToBack:self];
    self.text = @"-1";
    [self destroyTiemr];
}
- (void)destroyTiemr{
    if (_cameraTimer) {
        [_cameraTimer invalidate];
        _cameraTimer = nil;
    }
    _isTiming = NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
