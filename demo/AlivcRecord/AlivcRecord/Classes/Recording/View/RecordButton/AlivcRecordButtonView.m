//
//  AlivcRecordButtonView.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/4/9.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcRecordButtonView.h"
#import "UIColor+AlivcHelper.h"
#import "NSString+AlivcHelper.h"


static CGFloat AlivcRecordFlagSize = 10;//录制中圆点直径
static CGFloat AlivcRecordFlagSpace = 8;//录制圆点与录制时间空隙
static CGFloat AlivcRecordTimeLabelWidth = 48;//录制时间lab宽度

@interface AlivcRecordButtonView()

@end

@implementation AlivcRecordButtonView
{
    BOOL _isRecording;
    UILabel *_timeLab;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self =[super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews{
    CGFloat recordBtnSize =70;
    self.backgroundColor =[UIColor clearColor];
    _recordBtn =[[AlivcRecordButton alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.frame)-recordBtnSize)/2, CGRectGetHeight(self.frame)-recordBtnSize, recordBtnSize, recordBtnSize)];
    _recordBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_recordBtn addTarget:self action:@selector(recordButtonTouchUp) forControlEvents:UIControlEventTouchUpInside];
    [_recordBtn addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [_recordBtn addTarget:self action:@selector(recordButtonTouchUpDragOutside) forControlEvents:UIControlEventTouchDragOutside];
    _recordBtn.exclusiveTouch = YES;
    [self addSubview:_recordBtn];
    
    CGFloat timeLab_x = (CGRectGetWidth(self.bounds) - (AlivcRecordFlagSize + AlivcRecordFlagSpace + AlivcRecordTimeLabelWidth))/2+AlivcRecordFlagSize + AlivcRecordFlagSpace;
    _timeLab = [[UILabel alloc]initWithFrame:CGRectMake(timeLab_x, 0, AlivcRecordTimeLabelWidth, 25)];
    _timeLab.hidden =NO;
    _timeLab.font =[UIFont boldSystemFontOfSize:15];
    _timeLab.textColor =[UIColor whiteColor];
    _timeLab.textAlignment =NSTextAlignmentLeft;
    [self addSubview:_timeLab];
//    _timeLab.center = CGPointMake(_recordBtn.center.x, _timeLab.center.y);
    
}

- (void)setRecordStatud:(BOOL)isRecording{
    _isRecording =isRecording;
    if (isRecording) {
        _recordBtn.transform = CGAffineTransformScale(self.transform, 1.2, 1.2);
        _timeLab.hidden = NO;
    }else{
        _recordBtn.transform = CGAffineTransformIdentity;
        _timeLab.hidden = YES;
    }
    
//    [_recordBtn changeRecordButtonStyleTouchDown:isRecording];
    [self setNeedsDisplay];
}
- (void)setRecordStatus:(BOOL)isRecording withRecordType:(NSInteger)type{
    _isRecording =isRecording;
    if (isRecording && type == 0) {
        [_recordBtn changeRecordButtonStatus:AlivcRecordButtonStatusSelected];
    }else if(isRecording && type == 1){
        [_recordBtn changeRecordButtonStatus:AlivcRecordButtonStatusHighlight];
    }else{
        [_recordBtn changeRecordButtonStatus:AlivcRecordButtonStatusNormal];
    }
    if (isRecording) {
        _recordBtn.transform = CGAffineTransformScale(self.transform, 1.2, 1.2);
        _timeLab.hidden = NO;
    }else{
        _recordBtn.transform = CGAffineTransformIdentity;
        _timeLab.hidden = YES;
    }
    [self setNeedsDisplay];
}

- (void)refreshRecordingTime:(CGFloat)percent{
    int d = percent;
    int m = d / 60;
    int s = d % 60;
    dispatch_async(dispatch_get_main_queue(), ^{
        _timeLab.text = [NSString stringWithFormat:@"%02d:%02d",m,s];
    });
    
}


- (void)switchShowRecordButtonTip:(BOOL)isShow{
    if (isShow) {
        [_recordBtn setTitle:[@"长按拍" localString] forState:UIControlStateNormal];
        if (_recordBtn.titleLabel.text.length > 5) {
            _recordBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        }else {
            _recordBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        }
    }else{
        [_recordBtn setTitle:@"" forState:UIControlStateNormal];
    }
}

- (void)drawRect:(CGRect)rect{
    if (_isRecording) {
        //画一个圆点
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [UIColor colorWithHexString:@"#FC4347"].CGColor);
        CGContextSetLineWidth(context, 1.0);
        CGContextAddArc(context, CGRectGetMinX(_timeLab.frame) - AlivcRecordFlagSize/2 -AlivcRecordFlagSpace, CGRectGetMidY(_timeLab.frame), AlivcRecordFlagSize/2, 0, M_PI*2, 0);
        CGContextDrawPath(context, kCGPathFill);
    }
}

#pragma mark - Delgate Action
- (void)recordButtonTouchUp{
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcRecordButtonTouchUp)]) {
        [self.delegate alivcRecordButtonTouchUp];
    }
}
- (void)recordButtonTouchDown{
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcRecordButtonTouchDown)]) {
        [self.delegate alivcRecordButtonTouchDown];
    }
}
- (void)recordButtonTouchUpDragOutside{
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcRecordButtonTouchUpDragOutside)]) {
        [self.delegate alivcRecordButtonTouchUpDragOutside];
    }
}

@end
