//
//  AlivcEditVCUIConfig.m
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/10/9.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcEditUIConfig.h"


@implementation AlivcEditUIConfig
- (instancetype)init{
    self = [super init];
    if(self){
        [self setDefaultValue];
    }
    return self;
}

- (void)setDefaultValue{
    
    self.backgroundColor = [UIColor blackColor];
    self.backImage = [UIImage imageNamed:@"avcBackIcon"];

    _filterImage = [AlivcImage imageNamed:@"alivc_svEdit_filter"];
    
    _musicImage = [AlivcImage imageNamed:@"alivc_svEdit_music"];
    _pasterImage = [AlivcImage imageNamed:@"alivc_svEdit_paster"];
    _captionImage = [AlivcImage imageNamed:@"alivc_svEdit_subtitle"];
    _mvImage = [AlivcImage imageNamed:@"alivc_svEdit_mv"];
    _soundImage =[AlivcImage imageNamed:@"alivc_svEdit_audio"];
    _effectImage = [AlivcImage imageNamed:@"alivc_svEdit_effect"];
    _timeImage = [AlivcImage imageNamed:@"alivc_svEdit_time"];
    _translationImage = [AlivcImage imageNamed:@"alivc_svEdit_translation"];
    _paintImage = [AlivcImage imageNamed:@"alivc_svEdit_paint"];
    _coverImage = [AlivcImage imageNamed:@"alivc_svEdit_cover"];
    
    _playImage = [AlivcImage imageNamed:@"alivc_shortVideo_play"];
    _pauseImage = [AlivcImage imageNamed:@"alivc_svEdit_pause"];
    _finishImage = [AlivcImage imageNamed:@"shortVideo_finishButtonNormal"];
    
}
@end
