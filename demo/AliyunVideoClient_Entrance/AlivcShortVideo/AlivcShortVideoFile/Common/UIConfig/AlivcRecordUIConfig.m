//
//  AlivcShootVCUIConfig.m
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/10/9.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcRecordUIConfig.h"

@implementation AlivcRecordUIConfig

- (instancetype)init{
    self = [super init];
    if(self){
        [self setDefaultValue];
    }
    return self;
}

- (void)setDefaultValue{
    
    self.backgroundColor = [UIColor clearColor];
    self.backImage = [UIImage imageNamed:@"back"];
    
    _musicImage = [AlivcImage imageNamed:@"shortVideo_music"];
    _ligheImageOpen = [AlivcImage imageNamed:@"shortVideo_onLight"];
    _ligheImageAuto = [AlivcImage imageNamed:@"shortVideo_autoLight"];
    _ligheImageUnable = [AlivcImage imageNamed:@"shortVideo_noLight"];
    _ligheImageClose = [AlivcImage imageNamed:@"shortVideo_noLight"];
    _countdownImage = [AlivcImage imageNamed:@"shortVideo_countDown"];
    _switchCameraImage = [AlivcImage imageNamed:@"shortVideo_cameraid"];
    _finishImageUnable = [AlivcImage imageNamed:@"shortVideo_finishButtonDisabled"];
    _finishImageEnable = [AlivcImage imageNamed:@"shortVideo_finishButtonNormal"];
    
    _faceImage = [AlivcImage imageNamed:@"shortVideo_beauty"];
    _magicImage = [AlivcImage imageNamed:@"shortVideo_gif"];
    _videoShootImageNormal = [AlivcImage imageNamed:@"shortVideo_recordBtn_singleClick"];
    _videoShootImageShooting = [AlivcImage imageNamed:@"shortVideo_recordBtn_pause"];
    _videoShootImageLongPressing = [AlivcImage imageNamed:@"shortVideo_recordBtn_longPress"];
    _deleteImage = [AlivcImage imageNamed:@"shortVideo_deleteButton"];
    _dotImage = [AlivcImage imageNamed:@"shortVideo_dot"];
    _triangleImage = [AlivcImage imageNamed:@"shortVideo_triangle"];
}

@end
