//
//  AlivcPlayTimeView.m
//  AlivcEdit
//
//  Created by Bingo on 2021/11/24.
//

#import "AlivcPlayTimeView.h"

@interface AlivcPlayTimeView () <AlivcPlayManagerObserver>

@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UISlider *progressView;
@property (nonatomic, strong) UILabel *durationLabel;

@property (nonatomic, assign) BOOL isMoving;


@end

@implementation AlivcPlayTimeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
        [btn setImage:[AlivcImage imageNamed:@"alivc_shortVideo_play"] forState:UIControlStateNormal];
        [btn setImage:[AlivcImage imageNamed:@"alivc_svEdit_pause"] forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        [btn addTarget:self action:@selector(onPlayClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        self.playBtn = btn;
        
        UILabel *timeLabel = [UILabel new];
        timeLabel.text = @"00:00";
        timeLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
        timeLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:timeLabel];
        self.timeLabel = timeLabel;
        
        UISlider *progressView = [UISlider new];
        progressView.minimumTrackTintColor = [[UIColor systemPinkColor] colorWithAlphaComponent:0.75];
        progressView.maximumTrackTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.25];
        progressView.thumbTintColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
//        progressView.userInteractionEnabled = NO;
        progressView.value = 0;
        [progressView addTarget:self action:@selector(onValueChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:progressView];
        self.progressView = progressView;
        
        UILabel *durationLabel = [UILabel new];
        durationLabel.text = @"00:00";
        durationLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
        durationLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:durationLabel];
        self.durationLabel = durationLabel;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.playBtn.frame = CGRectMake(16, 0, 32, CGRectGetHeight(self.bounds));
    [self.timeLabel sizeToFit];
    self.timeLabel.frame = CGRectMake(CGRectGetMaxX(self.playBtn.frame) + 6, 0, CGRectGetWidth(self.timeLabel.frame), CGRectGetHeight(self.bounds));
    [self.durationLabel sizeToFit];
    self.durationLabel.frame = CGRectMake(CGRectGetMaxX(self.bounds) - 16 - CGRectGetWidth(self.durationLabel.frame), 0, CGRectGetWidth(self.durationLabel.frame), CGRectGetHeight(self.bounds));
    
    self.progressView.frame = CGRectMake(CGRectGetMaxX(self.timeLabel.frame) + 6, 0, CGRectGetMinX(self.durationLabel.frame) - 12 - CGRectGetMaxX(self.timeLabel.frame), CGRectGetHeight(self.bounds));
}

- (void)setPlayManager:(AlivcPlayManager *)playManager {
    if (playManager != _playManager) {
        [_playManager removeObserver:self];
        _playManager = nil;
    }
    _playManager = playManager;
    [_playManager addObserver:self];
    self.durationLabel.text = [NSString stringWithFormat:@"%02d:%02d", ((int)_playManager.getDuration)/60, ((int)_playManager.getDuration)%60];
}

- (void)onPlayClicked:(UIButton *)sender {
    if (self.playManager.isPlaying) {
        [self.playManager pause];
    }
    else {
        [self.playManager play];
    }
}

- (void)onValueChanged:(UISlider *)sender forEvent:(UIEvent*)event {
    UITouch* touchEvent = [[event allTouches] anyObject];
    switch(touchEvent.phase) {
        case UITouchPhaseBegan:
            self.isMoving = YES;
            NSLog(@"开始拖动");
            break;
        case UITouchPhaseMoved:
            break;
        case UITouchPhaseEnded:
            NSLog(@"结束拖动");
            self.isMoving = NO;
            double time = self.playManager.getDuration * self.progressView.value;
            [self.playManager seek:time];
            break;
        default:
            break;
    }
}

#pragma AlivcPlayManagerObserver

- (void)playStatus:(BOOL)isPlaying {
    self.playBtn.selected = self.playManager.isPlaying;
}

- (void)playError:(int)errorCode {
    NSLog(@"playError:%d", errorCode);
}

- (void)playerDidEnd {
    [self.playManager replay];
}

- (void)playProgress:(double)progress {
    if (self.isMoving) {
        return;
    }
    self.progressView.value = progress;
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", ((int)_playManager.getCurrentTime)/60, ((int)_playManager.getCurrentTime)%60];

}

@end
