//
//  AliyunRecordBottomView.m
//  AliyunVideo
//
//  Created by dangshuai on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunRecordBottomView.h"
#import "QUProgressView.h"
#import "AliyunIConfig.h"

@interface AliyunRecordBottomView ()
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *finishButton;
@property (nonatomic, strong) UIButton *photoLibraryButton;
@property (nonatomic, strong) QUProgressView *progressView;
@property (nonatomic, assign) BOOL recording;
@property (nonatomic, assign) double startTime;
@property (nonatomic, assign) CGFloat height;
@end

@implementation AliyunRecordBottomView {
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    backgroundView.backgroundColor = [AliyunIConfig config].backgroundColor;
    backgroundView.alpha = 0.5;
    [self addSubview:backgroundView];
    [self addSubview:self.recordButton];
    [self addSubview:self.deleteButton];
    [self addSubview:self.progressView];
    [self addSubview:self.photoLibraryButton];
    
    self.photoLibraryButton.hidden = [AliyunIConfig config].hiddenImportButton;
    self.finishButton.hidden = [AliyunIConfig config].hiddenFinishButton;
    
    self.finishButton.enabled = NO;
}

- (void)setMaxDuration:(CGFloat)maxDuration {
    _maxDuration = maxDuration;
    _progressView.maxDuration = maxDuration;
}

- (void)setMinDuration:(CGFloat)minDuration {
    _minDuration = minDuration;
    _progressView.minDuration = minDuration;
}

- (void)updateRecordStatus {
    _deleteButton.enabled = YES;
    _progressView.showBlink = YES;
}

-(void)updateHeight:(CGFloat)height {
    _height = height;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat centerY = CGRectGetHeight(self.bounds) / 2;
    if (_height) {
        centerY = _height / 2;
    }
    CGFloat w = CGRectGetWidth(self.bounds);
    _recordButton.center = CGPointMake(CGRectGetMidX(self.bounds), centerY);
    _deleteButton.center = CGPointMake(SizeWidth(55), centerY);
    _finishButton.center = CGPointMake(w - SizeWidth(55), centerY);
    _photoLibraryButton.center = CGPointMake(SizeWidth(55), centerY);
}

- (void)updateVideoDuration:(CGFloat)duration {
    [_progressView updateProgress:duration];
    if (duration >= _minDuration) {
        _finishButton.enabled = YES;
    } else {
        _finishButton.enabled = NO;
    }
    
    if (duration > 0 && _deleteButton.hidden && ![AliyunIConfig config].hiddenDeleteButton) {
        if (![AliyunIConfig config].hiddenDeleteButton) {
            _deleteButton.hidden = NO;
        }
        _photoLibraryButton.hidden = YES;
    }
    
    if (duration <=0) {
        [self.finishButton removeFromSuperview];
    } else {
        [self addSubview:self.finishButton];
    }
}

- (void)endRecord{
    if (!_recording) {
        return;
    }
    _startTime = 0;
    [self updateRecordTypeToEndRecord];
    [_delegate bottomViewPauseVideo];
    _progressView.showBlink = YES;
    
    _deleteButton.enabled = YES;
    
    if ([AliyunIConfig config].recordOnePart) {
        if (_delegate) {
            [_delegate bottomViewFinishVideo];
        }
    }
}

- (void)updateRecordTypeToEndRecord {
    [self.recordButton setBackgroundImage:[AliyunImage imageNamed:@"record_btn_normal"]forState:UIControlStateNormal];
    _recording = NO;
    _progressView.showBlink = YES;
    [self changeOtherButtonType];
}

- (void)recordButtonTouchUp {
    NSLog(@" DD----  %f    %f  - %f", CFAbsoluteTimeGetCurrent(), _startTime, (CFAbsoluteTimeGetCurrent() - _startTime));
    BOOL longPass = (CFAbsoluteTimeGetCurrent() - _startTime) > 1;
    switch ([AliyunIConfig config].recordType) {
        case AliyunIRecordActionTypeCombination:
           
            if (longPass) {
                if (_recording) {
                    [self endRecord];
                }
            }else{
                if (_recording) {
                    [_recordButton setBackgroundImage:[AliyunImage imageNamed:@"record_btn_suspend"]forState:UIControlStateNormal];
                    
                }else{
                    [_recordButton setBackgroundImage:[AliyunImage imageNamed:@"record_btn_normal"]forState:UIControlStateNormal];
                }
            }
            break;
        case AliyunIRecordActionTypeHold:
            [self endRecord];
            break;
            
        case AliyunIRecordActionTypeClick:
            if (_recording) {
                [_recordButton setBackgroundImage:[AliyunImage imageNamed:@"record_btn_suspend"]forState:UIControlStateNormal];
            }else{
                [_recordButton setBackgroundImage:[AliyunImage imageNamed:@"record_btn_normal"]forState:UIControlStateNormal];
            }
            break;
        default:
            break;
    }
    
}

- (void)recordButtonTouchDown {    
    _startTime = CFAbsoluteTimeGetCurrent();
    
    NSLog(@"  YY----%f", _startTime);

    switch ([AliyunIConfig config].recordType) {
        case AliyunIRecordActionTypeCombination:
            if (_recording) {
                [self endRecord];
                return;
            }else{
                [_recordButton setBackgroundImage:[AliyunImage imageNamed:@"record_btn_hold"]forState:UIControlStateNormal];
                _recording = YES;
            }
            break;
        case AliyunIRecordActionTypeHold:
            _recording = YES;
            [_recordButton setBackgroundImage:[AliyunImage imageNamed:@"record_btn_hold"]forState:UIControlStateNormal];
            break;
            
        case AliyunIRecordActionTypeClick:
            if (_recording) {
                [self endRecord];
                return;
            }else{
                _recording = YES;
            }
            break;
        default:
            break;
    }
    
    [self changeOtherButtonType];
    
    [_delegate bottomViewRecordVideo];
    
    _progressView.showBlink = NO;
    _progressView.videoCount++;
    
    _deleteButton.selected = NO;
}

- (void)deleteButtonClick:(UIButton *)buttonClick {
    NSLog(@"delete   %d", self.deleteButton.selected);
    buttonClick.selected = !buttonClick.selected;
    if (buttonClick.selected) {
        _progressView.selectedIndex = _progressView.videoCount - 1;
    } else {
        _progressView.videoCount--;
        [_delegate bottomViewDeleteFinished];
        if (_progressView.videoCount <= 0) {
            if (![AliyunIConfig config].hiddenImportButton) {
                _photoLibraryButton.hidden = NO;
            }
            
            _deleteButton.hidden = YES;
        }
    }
}

- (void)deleteLastProgress {
    
    _progressView.videoCount--;
}

- (void)changeOtherButtonType {

    _deleteButton.userInteractionEnabled = !_recording;
    _finishButton.userInteractionEnabled = !_recording;
}

- (void)finishButtonClick {
    [_delegate bottomViewFinishVideo];
}

- (void)photoLibraryButtonClick {
    [_delegate bottomViewShowLibrary];
}

- (UIButton *)recordButton {
    if (!_recordButton) {
        _recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _recordButton.bounds = CGRectMake(0, 0, 60, 60);
        _recordButton.backgroundColor = [UIColor clearColor];
        _recordButton.adjustsImageWhenHighlighted = NO;
        [_recordButton setBackgroundImage:[AliyunImage imageNamed:@"record_btn_normal"]forState:UIControlStateNormal];
        _recordButton.layer.masksToBounds = YES;
        _recordButton.layer.cornerRadius = 30;
        [_recordButton addTarget:self action:@selector(recordButtonTouchUp) forControlEvents:UIControlEventTouchUpInside];
        [_recordButton addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
        [_recordButton addTarget:self action:@selector(recordButtonTouchUp) forControlEvents:UIControlEventTouchDragOutside];
    }
    return _recordButton;
}

- (QUProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[QUProgressView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 5)];
        _progressView.showBlink = YES;
        _progressView.showNoticePoint = YES;
    }
    return _progressView;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.bounds = CGRectMake(0, 0, SizeWidth(40), SizeWidth(40));
        _deleteButton.hidden = YES;
        [_deleteButton setImage:[AliyunImage imageNamed:@"record_delete"] forState:0];
        [_deleteButton setImage:[AliyunImage imageNamed:@"record_delete_sure"] forState:(UIControlStateSelected)];
        [_deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

- (UIButton *)finishButton {
    if (!_finishButton) {
        _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _finishButton.bounds = CGRectMake(0, 0, SizeWidth(40), SizeWidth(40));
        [_finishButton setImage:[AliyunImage imageNamed:@"record_finish"] forState:0];
        [_finishButton addTarget:self action:@selector(finishButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishButton;
}

- (UIButton *)photoLibraryButton {
    if (!_photoLibraryButton) {
        _photoLibraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _photoLibraryButton.bounds = CGRectMake(0, 0, SizeWidth(40), SizeWidth(40));
        [_photoLibraryButton setImage:[AliyunImage imageNamed:@"record_lib"] forState:0];
        [_photoLibraryButton addTarget:self action:@selector(photoLibraryButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoLibraryButton;
}



@end
