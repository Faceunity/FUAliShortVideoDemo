//
//  AlivcAudioEffectView.h
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/3/4.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AlivcEffectSoundType) {
    AlivcEffectSoundTypeClear = 0,
    AlivcEffectSoundTypeLolita,  // 萝莉
    AlivcEffectSoundTypeUncle,   // 大叔
    AlivcEffectSoundTypeEcho,    // 回声
    AlivcEffectSoundTypeRevert,  // 混响
    AlivcEffectSoundTypeDenoise, // 去噪
    AlivcEffectSoundTypeMinion, // 小黄人
    AlivcEffectSoundTypeRobot, // 机器人
    AlivcEffectSoundTypeDevil, // 大魔王
};


@protocol AlivcAudioEffectViewDelegate <NSObject>

- (void)AlivcAudioEffectViewDidSelectCell:(AlivcEffectSoundType)type;

@end

@interface AlivcAudioEffectView : UIView

@property(nonatomic, weak)id<AlivcAudioEffectViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
