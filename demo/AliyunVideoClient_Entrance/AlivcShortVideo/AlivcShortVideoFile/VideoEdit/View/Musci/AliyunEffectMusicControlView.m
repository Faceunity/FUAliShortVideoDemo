//
//  AliyunEffectMusicControlView.m
//  AliyunVideo
//
//  Created by Worthy on 2017/3/15.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectMusicControlView.h"
#import "AVC_ShortVideo_Config.h"

@interface AliyunEffectMusicControlView ()<TTRangeSliderDelegate>

@property (nonatomic, strong) UILabel *labelCut;
@property (nonatomic, strong) UILabel *labelSteamCut;
@property (nonatomic, strong) UILabel *labelOrigin;
@property (nonatomic, strong) UILabel *labelMusic;

@end

@implementation AliyunEffectMusicControlView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.buttonMute = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.buttonMute addTarget:self action:@selector(muteClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonMute setImage:[AliyunImage imageNamed:@"voice"] forState:UIControlStateNormal];
    [self.buttonMute setImage:[AliyunImage imageNamed:@"voice_none"] forState:UIControlStateSelected];
    [self addSubview:self.buttonMute];
    
    self.labelOrigin = [[UILabel alloc] initWithFrame:CGRectZero];
    self.labelOrigin.text = NSLocalizedString(@"original_music_edit", nil);
    self.labelOrigin.font = [UIFont systemFontOfSize:12];
    self.labelOrigin.contentMode = UIViewContentModeCenter;
    self.labelOrigin.textColor = [UIColor whiteColor];
    [self addSubview:self.labelOrigin];
    
    self.sliderVolume = [[UISlider alloc] initWithFrame:CGRectZero];
    [self.sliderVolume setThumbImage:[AliyunImage imageNamed:@"voice_slide"] forState:UIControlStateNormal];
    [self.sliderVolume setMaximumTrackTintColor:rgba(239,75,129,1)];
    [self.sliderVolume setMinimumTrackTintColor:[UIColor whiteColor]];
    [self.sliderVolume addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.sliderVolume];
    self.sliderVolume.value = 1;
    
    self.labelMusic = [[UILabel alloc] initWithFrame:CGRectZero];
    self.labelMusic.text = NSLocalizedString(@"music_edit", nil);
    self.labelMusic.font = [UIFont systemFontOfSize:12];
    self.labelMusic.contentMode = UIViewContentModeCenter;
    self.labelMusic.textColor = rgba(239,75,129,1);
    [self addSubview:self.labelMusic];
    
    self.labelCut = [[UILabel alloc] initWithFrame:CGRectZero];
    self.labelCut.text = @"配乐裁剪";
    self.labelCut.font = [UIFont systemFontOfSize:12];
    self.labelCut.contentMode = UIViewContentModeCenter;
    self.labelCut.textColor = [UIColor whiteColor];
    [self addSubview:self.labelCut];
    
    self.labelSteamCut = [[UILabel alloc] initWithFrame:CGRectZero];
    self.labelSteamCut.text = @"添加区间";
    self.labelSteamCut.font = [UIFont systemFontOfSize:12];
    self.labelSteamCut.contentMode = UIViewContentModeCenter;
    self.labelSteamCut.textColor = [UIColor whiteColor];
    [self addSubview:self.labelSteamCut];
    
    self.sliderTime = [[TTRangeSlider alloc] initWithFrame:CGRectZero];
    [self.sliderTime setHandleImage:[AliyunImage imageNamed:@"voice_slide"]];
    [self.sliderTime setTintColorBetweenHandles:rgba(239,75,129,1)];
    [self.sliderTime setLineBorderColor:[UIColor whiteColor]];
    [self.sliderTime setMinValue:0];
    [self.sliderTime setMaxValue:100];
    [self.sliderTime setSelectedMinimum:0];
    [self.sliderTime setSelectedMaximum:100];
    [self.sliderTime setLineHeight:2];
    [self.sliderTime setTintColor:[UIColor whiteColor]];
    self.sliderTime.delegate = self;
    NSNumberFormatter *customFormatter = [[NSNumberFormatter alloc] init];
    customFormatter.positiveSuffix = @"%";
    self.sliderTime.numberFormatterOverride = customFormatter;
    [self addSubview:self.sliderTime];
    
    
    self.sliderStreamTime = [[TTRangeSlider alloc] initWithFrame:CGRectZero];
    [self.sliderStreamTime setHandleImage:[AliyunImage imageNamed:@"voice_slide"]];
    [self.sliderStreamTime setTintColorBetweenHandles:rgba(239,75,129,1)];
    [self.sliderStreamTime setLineBorderColor:[UIColor whiteColor]];
    [self.sliderStreamTime setMinValue:0];
    [self.sliderStreamTime setMaxValue:100];
    [self.sliderStreamTime setSelectedMinimum:0];
    [self.sliderStreamTime setSelectedMaximum:100];
    [self.sliderStreamTime setLineHeight:2];
    [self.sliderStreamTime setTintColor:[UIColor whiteColor]];
    self.sliderStreamTime.delegate = self;
    self.sliderStreamTime.numberFormatterOverride = customFormatter;
    [self addSubview:self.sliderStreamTime];
    
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self layout];
}

- (void)layout {
    CGFloat width = CGRectGetWidth(self.frame);
    self.buttonMute.frame = CGRectMake(0, 0, 40, 40);
    self.labelOrigin.frame = CGRectMake(40, 0, 32, 40);
    self.sliderVolume.frame = CGRectMake(40+40, 0, width-40-40-40, 40);
    self.labelMusic.frame = CGRectMake(width-32, 0, 32, 40);
    
    self.labelCut.frame = CGRectMake(8, 40, 64, 40);
    self.sliderTime.frame = CGRectMake(64, 40, width-64, 40);
    self.labelSteamCut.frame = CGRectMake(8, 80, 64, 40);
    self.sliderStreamTime.frame = CGRectMake(64, 80, width-64, 40);
}


- (void)updateControlSliderWithWeight:(float)weight {
    
    self.sliderVolume.value = weight;
}

#pragma mark - action

- (void)sliderChanged:(UISlider *)sender {
    [_delegate controlViewDidUpadteVolume:sender.value];
}

- (void)muteClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [_delegate controlViewDidUpdateMute:YES];
    }else {
        [_delegate controlViewDidUpdateMute:NO];
    }
}

-(void)rangeSlider:(TTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum {

}

@end
