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
    self.backImage = [AlivcImage imageNamed:@"avcBackIcon"];
}

- (UIImage *)musicImage {
    if (!_musicImage) {
         _musicImage = [AlivcImage imageNamed:@"shortVideo_music"];
    }
    return _musicImage;
}

- (UIImage *)filterImage {
    if (!_filterImage) {
        _filterImage = [AlivcImage imageNamed:@"alivc_svEdit_filter"];
    }
    return _filterImage;
}


- (UIImage *)ligheImageOpen {
    if (!_ligheImageOpen) {
         _ligheImageOpen = [AlivcImage imageNamed:@"shortVideo_onLight"];
    }
    return _ligheImageOpen;
}

- (UIImage *)ligheImageAuto {
    if (!_ligheImageAuto) {
        _ligheImageAuto = [AlivcImage imageNamed:@"shortVideo_autoLight"];
    }
    return _ligheImageAuto;
}

- (UIImage *)ligheImageUnable {
    if (!_ligheImageUnable) {
         _ligheImageUnable = [AlivcImage imageNamed:@"shortVideo_noLight"];
    }
    return _ligheImageUnable;
}

- (UIImage *)ligheImageClose {
    if (!_ligheImageClose) {
        _ligheImageClose = [AlivcImage imageNamed:@"shortVideo_noLight"];
    }
    return _ligheImageClose;
}


- (UIImage *)countdownImage {
    if (!_countdownImage) {
        _countdownImage = [AlivcImage imageNamed:@"shortVideo_countDown"];
    }
    return _countdownImage;
}

- (UIImage *)switchCameraImage {
    if (!_switchCameraImage) {
       _switchCameraImage = [AlivcImage imageNamed:@"shortVideo_cameraid"];
    }
    return _switchCameraImage;
}

- (UIImage *)finishImageUnable {
    if (!_finishImageUnable) {
        _finishImageUnable = [AlivcImage imageNamed:@"shortVideo_finishButtonDisabled"];
    }
    return _finishImageUnable;
}


- (UIImage *)finishImageEnable {
    if (!_finishImageEnable) {
        _finishImageEnable = [AlivcImage imageNamed:@"shortVideo_finishButtonNormal"];
    }
    return _finishImageEnable;
}

- (UIImage *)faceImage {
    if (!_faceImage) {
        _faceImage = [AlivcImage imageNamed:@"shortVideo_beauty"];
    }
    return _faceImage;
}

- (UIImage *)magicImage {
    if (!_magicImage) {
        _magicImage = [AlivcImage imageNamed:@"shortVideo_gif"];
    }
    return _magicImage;
}


- (UIImage *)videoShootImageNormal {
    if (!_videoShootImageNormal) {
         _videoShootImageNormal = [AlivcImage imageNamed:@"shortVideo_recordBtn_singleClick"];
    }
    return _videoShootImageNormal;
}


- (UIImage *)videoShootImageShooting {
    if (!_videoShootImageShooting) {
        _videoShootImageShooting = [AlivcImage imageNamed:@"shortVideo_recordBtn_pause"];
    }
    return _videoShootImageShooting;
}

- (UIImage *)videoShootImageLongPressing {
    if (!_videoShootImageLongPressing) {
        _videoShootImageLongPressing = [AlivcImage imageNamed:@"shortVideo_recordBtn_longPress"];
    }
    return _videoShootImageLongPressing;
}


- (UIImage *)deleteImage {
    if (!_deleteImage) {
       _deleteImage = [AlivcImage imageNamed:@"shortVideo_deleteButton"];
    }
    return _deleteImage;
}

- (UIImage *)_dotImage {
    if (!_dotImage) {
        _dotImage = [AlivcImage imageNamed:@"shortVideo_dot"];
    }
    return _dotImage;
}

- (UIImage *)triangleImage {
    if (!_triangleImage) {
        _triangleImage = [AlivcImage imageNamed:@"shortVideo_triangle"];
    }
    return _triangleImage;
}


@end
